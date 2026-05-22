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
    public class ConnectorService :
        BaseCRUDService<Connector, ConnectorResponse, ConnectorSearchObject, ConnectorInsertRequest, ConnectorUpdateRequest>,
        IConnectorService
    {
        public ConnectorService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<ConnectorResponse> Insert(ConnectorInsertRequest request)
        {
            await EnsureForeignKeysExist(request.ChargingStationId, request.ConnectorTypeId);
            return await base.Insert(request);
        }

        public override async Task<ConnectorResponse> Update(int id, ConnectorUpdateRequest request)
        {
            if (request.ChargingStationId.HasValue)
            {
                var stationExists = await _context.ChargingStations.AnyAsync(x => x.Id == request.ChargingStationId.Value);
                if (!stationExists)
                {
                    throw new ValidationException($"ChargingStation with id {request.ChargingStationId.Value} does not exist.");
                }
            }

            if (request.ConnectorTypeId.HasValue)
            {
                var typeExists = await _context.ConnectorTypes.AnyAsync(x => x.Id == request.ConnectorTypeId.Value);
                if (!typeExists)
                {
                    throw new ValidationException($"ConnectorType with id {request.ConnectorTypeId.Value} does not exist.");
                }
            }

            return await base.Update(id, request);
        }

        protected override IQueryable<Connector> AddFilter(IQueryable<Connector> query, ConnectorSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.ChargingStationId.HasValue)
            {
                query = query.Where(x => x.ChargingStationId == search.ChargingStationId.Value);
            }

            if (search.ConnectorTypeId.HasValue)
            {
                query = query.Where(x => x.ConnectorTypeId == search.ConnectorTypeId.Value);
            }

            if (search.IsAvailable.HasValue)
            {
                query = query.Where(x => x.IsAvailable == search.IsAvailable.Value);
            }

            if (search.MinPowerKW.HasValue)
            {
                query = query.Where(x => x.PowerKW >= search.MinPowerKW.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Label))
            {
                query = query.Where(x => x.Label != null && x.Label.Contains(search.Label));
            }

            return query;
        }

        protected override IQueryable<Connector> AddInclude(IQueryable<Connector> query, ConnectorSearchObject? search)
        {
            return query
                .Include(x => x.ChargingStation)
                .Include(x => x.ConnectorType);
        }

        protected override Connector MapInsert(ConnectorInsertRequest request)
        {
            return new Connector
            {
                ChargingStationId = request.ChargingStationId,
                ConnectorTypeId = request.ConnectorTypeId,
                Label = request.Label,
                IsAvailable = request.IsAvailable,
                PowerKW = request.PowerKW
            };
        }

        protected override void MapUpdate(ConnectorUpdateRequest request, Connector entity)
        {
            if (request.ChargingStationId.HasValue)
            {
                entity.ChargingStationId = request.ChargingStationId.Value;
            }

            if (request.ConnectorTypeId.HasValue)
            {
                entity.ConnectorTypeId = request.ConnectorTypeId.Value;
            }

            if (request.Label != null)
            {
                entity.Label = request.Label;
            }
            else if (request.ClearLabel)
            {
                entity.Label = null;
            }

            if (request.IsAvailable.HasValue)
            {
                entity.IsAvailable = request.IsAvailable.Value;
            }

            if (request.PowerKW.HasValue)
            {
                if (request.PowerKW.Value <= 0)
                {
                    throw new ValidationException("PowerKW must be greater than 0.");
                }

                entity.PowerKW = request.PowerKW.Value;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        private async Task EnsureForeignKeysExist(int chargingStationId, int connectorTypeId)
        {
            var stationExists = await _context.ChargingStations.AnyAsync(x => x.Id == chargingStationId);
            if (!stationExists)
            {
                throw new ValidationException($"ChargingStation with id {chargingStationId} does not exist.");
            }

            var typeExists = await _context.ConnectorTypes.AnyAsync(x => x.Id == connectorTypeId);
            if (!typeExists)
            {
                throw new ValidationException($"ConnectorType with id {connectorTypeId} does not exist.");
            }
        }
    }
}
