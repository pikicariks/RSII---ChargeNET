using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Recommendation;
using ChargeNet.Services.StateMachines;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class ChargingSessionService :
        BaseReadService<ChargingSession, ChargingSessionResponse, ChargingSessionSearchObject>,
        IChargingSessionService
    {
        private readonly IUserProfileService _userProfileService;
        private readonly IRecommendationCacheService _recommendationCacheService;

        public ChargingSessionService(
            ChargeNetDbContext context,
            IMapper mapper,
            IUserProfileService userProfileService,
            IRecommendationCacheService recommendationCacheService) : base(context, mapper)
        {
            _userProfileService = userProfileService;
            _recommendationCacheService = recommendationCacheService;
        }

        public async Task<ChargingSessionResponse> Start(ChargingSessionStartRequest request)
        {
            if (!request.UserId.HasValue)
            {
                throw new ValidationException("UserId is required.");
            }

            var connector = await _context.Connectors
                .Include(connector => connector.ChargingStation)
                .FirstOrDefaultAsync(connector => connector.Id == request.ConnectorId);

            if (connector == null)
            {
                throw new ValidationException($"Connector with id {request.ConnectorId} does not exist.");
            }

            var userExists = await _context.Users.AnyAsync(user => user.Id == request.UserId.Value && !user.IsDeleted);
            if (!userExists)
            {
                throw new ValidationException($"User with id {request.UserId.Value} does not exist.");
            }

            var tariff = await _context.Tariffs.FirstOrDefaultAsync(t => t.Id == request.TariffId && t.IsActive);
            if (tariff == null)
            {
                throw new ValidationException($"Active tariff with id {request.TariffId} does not exist.");
            }

            if (request.ReservationId.HasValue)
            {
                var reservation = await _context.Reservations
                    .FirstOrDefaultAsync(r => r.Id == request.ReservationId.Value);

                if (reservation == null)
                {
                    throw new ValidationException($"Reservation with id {request.ReservationId.Value} does not exist.");
                }

                if (reservation.UserId != request.UserId.Value)
                {
                    throw new BusinessException("Reservation does not belong to this user.", 403);
                }

                if (reservation.StatusId != ReservationStatusIds.Confirmed)
                {
                    throw new BusinessException("Only confirmed reservations can be used to start a session.", 400);
                }

                if (reservation.ConnectorId.HasValue && reservation.ConnectorId.Value != request.ConnectorId)
                {
                    throw new BusinessException("Connector does not match the reservation.", 400);
                }
            }
            else if (!connector.IsAvailable)
            {
                throw new BusinessException("Connector is not available.", 409);
            }

            var activeSessionExists = await _context.ChargingSessions.AnyAsync(session =>
                session.ConnectorId == request.ConnectorId && !session.EndTime.HasValue);

            if (activeSessionExists)
            {
                throw new BusinessException("Connector already has an active charging session.", 409);
            }

            var entity = new ChargingSession
            {
                UserId = request.UserId.Value,
                ConnectorId = request.ConnectorId,
                TariffId = request.TariffId,
                ReservationId = request.ReservationId,
                StartTime = DateTime.UtcNow
            };

            connector.IsAvailable = false;

            _dbSet.Add(entity);
            await _context.SaveChangesAsync();

            return await GetById(entity.Id);
        }

        public async Task<ChargingSessionResponse> Complete(int id, ChargingSessionCompleteRequest request)
        {
            var entity = await _dbSet
                .Include(session => session.Connector)
                .Include(session => session.Tariff)
                .FirstOrDefaultAsync(session => session.Id == id);

            if (entity == null)
            {
                throw new NotFoundException(nameof(ChargingSession), id);
            }

            if (entity.EndTime.HasValue)
            {
                throw new BusinessException("Charging session is already completed.", 400);
            }

            var endTime = DateTime.UtcNow;
            var durationMinutes = (decimal)(endTime - entity.StartTime).TotalMinutes;

            entity.EndTime = endTime;
            entity.EnergyConsumedKWh = request.EnergyConsumedKWh;
            entity.Cost = CalculateCost(entity.Tariff, request.EnergyConsumedKWh, durationMinutes);
            entity.ModifiedAt = endTime;

            entity.Connector.IsAvailable = true;

            await _context.SaveChangesAsync();

            await _userProfileService.UpdateProfileAsync(entity.UserId);
            _recommendationCacheService.InvalidateUser(entity.UserId);

            return await GetById(id);
        }

        protected override IQueryable<ChargingSession> AddFilter(IQueryable<ChargingSession> query, ChargingSessionSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(session => session.UserId == search.UserId.Value);
            }

            if (search.ConnectorId.HasValue)
            {
                query = query.Where(session => session.ConnectorId == search.ConnectorId.Value);
            }

            if (search.ChargingStationId.HasValue)
            {
                query = query.Where(session => session.Connector.ChargingStationId == search.ChargingStationId.Value);
            }

            if (search.TariffId.HasValue)
            {
                query = query.Where(session => session.TariffId == search.TariffId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = search.IsActive.Value
                    ? query.Where(session => !session.EndTime.HasValue)
                    : query.Where(session => session.EndTime.HasValue);
            }

            if (search.From.HasValue)
            {
                query = query.Where(session => session.StartTime >= search.From.Value);
            }

            if (search.To.HasValue)
            {
                query = query.Where(session => session.StartTime <= search.To.Value);
            }

            return query;
        }

        protected override IQueryable<ChargingSession> AddInclude(IQueryable<ChargingSession> query, ChargingSessionSearchObject? search)
        {
            return query
                .Include(session => session.User)
                .Include(session => session.Connector)
                    .ThenInclude(connector => connector.ChargingStation)
                .Include(session => session.Tariff);
        }

        private static decimal CalculateCost(Tariff tariff, decimal energyConsumedKWh, decimal durationMinutes)
        {
            var energyCost = energyConsumedKWh * tariff.PricePerKWh;
            var minuteCost = tariff.PricePerMinute.HasValue
                ? durationMinutes * tariff.PricePerMinute.Value
                : 0m;

            return Math.Round(energyCost + minuteCost, 2);
        }
    }
}
