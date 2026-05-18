using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class FaultReportService :
        BaseCRUDService<FaultReport, FaultReportResponse, FaultReportSearchObject, FaultReportInsertRequest, FaultReportUpdateRequest>,
        IFaultReportService
    {
        public FaultReportService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<FaultReportResponse> Insert(FaultReportInsertRequest request)
        {
            if (!request.UserId.HasValue)
            {
                throw new ValidationException("UserId is required.");
            }

            await EnsureReferencesExist(request.ChargingStationId, request.ConnectorId, request.UserId.Value);
            return await base.Insert(request);
        }

        public override async Task<FaultReportResponse> Update(int id, FaultReportUpdateRequest request)
        {
            if (request.ChargingStationId.HasValue)
            {
                var stationExists = await _context.ChargingStations.AnyAsync(x => x.Id == request.ChargingStationId.Value);
                if (!stationExists)
                {
                    throw new ValidationException($"ChargingStation with id {request.ChargingStationId.Value} does not exist.");
                }
            }

            if (request.ConnectorId.HasValue)
            {
                var connectorExists = await _context.Connectors.AnyAsync(x => x.Id == request.ConnectorId.Value);
                if (!connectorExists)
                {
                    throw new ValidationException($"Connector with id {request.ConnectorId.Value} does not exist.");
                }
            }

            return await base.Update(id, request);
        }

        protected override IQueryable<FaultReport> AddFilter(IQueryable<FaultReport> query, FaultReportSearchObject? search)
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

            if (search.IsResolved.HasValue)
            {
                query = query.Where(x => x.IsResolved == search.IsResolved.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Description))
            {
                query = query.Where(x => x.Description.Contains(search.Description));
            }

            return query;
        }

        protected override IQueryable<FaultReport> AddInclude(IQueryable<FaultReport> query, FaultReportSearchObject? search)
        {
            return query
                .Include(x => x.User)
                .Include(x => x.ChargingStation)
                .Include(x => x.Connector);
        }

        protected override FaultReport MapInsert(FaultReportInsertRequest request)
        {
            return new FaultReport
            {
                UserId = request.UserId!.Value,
                ChargingStationId = request.ChargingStationId,
                ConnectorId = request.ConnectorId,
                Description = request.Description.Trim(),
                IsResolved = false,
                ReportedAt = DateTime.UtcNow
            };
        }

        protected override void MapUpdate(FaultReportUpdateRequest request, FaultReport entity)
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

            if (!string.IsNullOrWhiteSpace(request.Description))
            {
                entity.Description = request.Description.Trim();
            }

            if (request.IsResolved.HasValue)
            {
                entity.IsResolved = request.IsResolved.Value;
                entity.ResolvedAt = request.IsResolved.Value ? DateTime.UtcNow : null;
            }

            if (request.ResolvedAt.HasValue)
            {
                entity.ResolvedAt = request.ResolvedAt.Value;
            }
            else if (request.ClearResolvedAt)
            {
                entity.ResolvedAt = null;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        private async Task EnsureReferencesExist(int chargingStationId, int? connectorId, int userId)
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
                var connectorExists = await _context.Connectors.AnyAsync(x => x.Id == connectorId.Value);
                if (!connectorExists)
                {
                    throw new ValidationException($"Connector with id {connectorId.Value} does not exist.");
                }
            }
        }
    }
}
