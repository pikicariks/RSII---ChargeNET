using AutoMapper;
using ChargeNet.Model.Enums;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.StateMachines;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class ReservationService :
        BaseCRUDService<Reservation, ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>,
        IReservationService
    {
        private readonly INotificationService _notificationService;

        public ReservationService(
            ChargeNetDbContext context,
            IMapper mapper,
            INotificationService notificationService) : base(context, mapper)
        {
            _notificationService = notificationService;
        }

        public override async Task<ReservationResponse> Insert(ReservationInsertRequest request)
        {
            if (!request.UserId.HasValue)
            {
                throw new ValidationException("UserId is required.");
            }

            ValidateTimeRange(request.ReservationStart, request.ReservationEnd);
            await EnsureReferencesExist(request.UserId.Value, request.ChargingStationId, request.ConnectorId);
            await EnsureNoOverlap(request.ChargingStationId, request.ConnectorId, request.ReservationStart, request.ReservationEnd);

            return await base.Insert(request);
        }

        public override async Task<ReservationResponse> Update(int id, ReservationUpdateRequest request)
        {
            var entity = await _dbSet.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                throw new NotFoundException(nameof(Reservation), id);
            }

            if (entity.StatusId != ReservationStatusIds.Pending)
            {
                throw new BusinessException("Only pending reservations can be updated.", 400);
            }

            var stationId = request.ChargingStationId ?? entity.ChargingStationId;
            var connectorId = request.ConnectorId.HasValue
                ? request.ConnectorId.Value
                : request.ClearConnectorId ? null : entity.ConnectorId;
            var start = request.ReservationStart ?? entity.ReservationStart;
            var end = request.ReservationEnd ?? entity.ReservationEnd;

            ValidateTimeRange(start, end);
            await EnsureReferencesExist(entity.UserId, stationId, connectorId);
            await EnsureNoOverlap(stationId, connectorId, start, end, id);

            return await base.Update(id, request);
        }

        public async Task<ReservationResponse> Confirm(int id)
        {
            var result = await ApplyTransitionAsync(id, (reservation, state) => state.Confirm(reservation));
            await NotifyReservationAsync(
                result,
                NotificationType.ReservationConfirmed,
                "Reservation confirmed",
                $"Your reservation #{result.Id} has been confirmed.");
            return result;
        }

        public Task<ReservationResponse> Cancel(int id) =>
            ApplyTransitionAsync(id, (reservation, state) => state.Cancel(reservation));

        public Task<ReservationResponse> Complete(int id) =>
            ApplyTransitionAsync(id, (reservation, state) => state.Complete(reservation));

        public async Task<ReservationResponse> Reject(int id, ReservationRejectRequest request)
        {
            var reason = request.Reason.Trim();
            var result = await ApplyTransitionAsync(id, (reservation, state) => state.Reject(reservation, reason));
            await NotifyReservationAsync(
                result,
                NotificationType.ReservationRejected,
                "Reservation rejected",
                $"Your reservation #{result.Id} was rejected. Reason: {reason}");
            return result;
        }

        public Task<ReservationResponse> Expire(int id) =>
            ApplyTransitionAsync(id, (reservation, state) => state.Expire(reservation));

        protected override IQueryable<Reservation> AddFilter(IQueryable<Reservation> query, ReservationSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.ChargingStationId.HasValue)
            {
                query = query.Where(x => x.ChargingStationId == search.ChargingStationId.Value);
            }

            if (search.ConnectorId.HasValue)
            {
                query = query.Where(x => x.ConnectorId == search.ConnectorId.Value);
            }

            if (search.StatusId.HasValue)
            {
                query = query.Where(x => x.StatusId == search.StatusId.Value);
            }

            if (search.From.HasValue)
            {
                query = query.Where(x => x.ReservationStart >= search.From.Value);
            }

            if (search.To.HasValue)
            {
                query = query.Where(x => x.ReservationEnd <= search.To.Value);
            }

            return query;
        }

        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject? search)
        {
            return query
                .Include(x => x.User)
                .Include(x => x.ChargingStation)
                .Include(x => x.Connector)
                .Include(x => x.Status);
        }

        protected override Reservation MapInsert(ReservationInsertRequest request)
        {
            return new Reservation
            {
                UserId = request.UserId!.Value,
                ChargingStationId = request.ChargingStationId,
                ConnectorId = request.ConnectorId,
                ReservationStart = request.ReservationStart,
                ReservationEnd = request.ReservationEnd,
                StatusId = ReservationStatusIds.Pending
            };
        }

        protected override void MapUpdate(ReservationUpdateRequest request, Reservation entity)
        {
            if (request.ChargingStationId.HasValue)
            {
                entity.ChargingStationId = request.ChargingStationId.Value;
            }

            if (request.ConnectorId.HasValue)
            {
                entity.ConnectorId = request.ConnectorId.Value;
            }
            else if (request.ClearConnectorId)
            {
                entity.ConnectorId = null;
            }

            if (request.ReservationStart.HasValue)
            {
                entity.ReservationStart = request.ReservationStart.Value;
            }

            if (request.ReservationEnd.HasValue)
            {
                entity.ReservationEnd = request.ReservationEnd.Value;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        private async Task NotifyReservationAsync(
            ReservationResponse reservation,
            NotificationType notificationType,
            string title,
            string message)
        {
            await _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = reservation.UserId,
                Title = title,
                Message = message,
                NotificationType = notificationType.ToString(),
                RelatedEntityType = nameof(Reservation),
                RelatedEntityId = reservation.Id
            });
        }

        private async Task<ReservationResponse> ApplyTransitionAsync(
            int id,
            Action<Reservation, IReservationState> transition)
        {
            var entity = await _dbSet
                .Include(x => x.Connector)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
            {
                throw new NotFoundException(nameof(Reservation), id);
            }

            var state = ReservationStateFactory.Create(entity.StatusId);
            transition(entity, state);
            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return await GetById(id);
        }

        private static void ValidateTimeRange(DateTime start, DateTime end)
        {
            if (start >= end)
            {
                throw new ValidationException("ReservationStart must be before ReservationEnd.");
            }
        }

        private async Task EnsureReferencesExist(int userId, int chargingStationId, int? connectorId)
        {
            var userExists = await _context.Users.AnyAsync(x => x.Id == userId && !x.IsDeleted);
            if (!userExists)
            {
                throw new ValidationException($"User with id {userId} does not exist.");
            }

            var stationExists = await _context.ChargingStations.AnyAsync(x => x.Id == chargingStationId);
            if (!stationExists)
            {
                throw new ValidationException($"ChargingStation with id {chargingStationId} does not exist.");
            }

            if (connectorId.HasValue)
            {
                var connectorExistsForStation = await _context.Connectors.AnyAsync(x =>
                    x.Id == connectorId.Value && x.ChargingStationId == chargingStationId);
                if (!connectorExistsForStation)
                {
                    throw new ValidationException(
                        $"Connector with id {connectorId.Value} does not belong to ChargingStation {chargingStationId}.");
                }
            }
        }

        private async Task EnsureNoOverlap(int chargingStationId, int? connectorId, DateTime start, DateTime end, int? excludeReservationId = null)
        {
            var query = _context.Reservations.AsQueryable();

            if (excludeReservationId.HasValue)
            {
                query = query.Where(x => x.Id != excludeReservationId.Value);
            }

            query = query.Where(x =>
                (x.StatusId == ReservationStatusIds.Pending || x.StatusId == ReservationStatusIds.Confirmed) &&
                x.ReservationStart < end &&
                x.ReservationEnd > start);

            query = connectorId.HasValue
                ? query.Where(x => x.ConnectorId == connectorId.Value)
                : query.Where(x => x.ChargingStationId == chargingStationId);

            var overlapExists = await query.AnyAsync();
            if (overlapExists)
            {
                throw new BusinessException("Reservation time overlaps with an existing reservation.", 409);
            }
        }
    }
}
