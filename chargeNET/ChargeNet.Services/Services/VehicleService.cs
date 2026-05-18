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
    public class VehicleService : BaseCRUDService<Vehicle, VehicleResponse, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>, IVehicleService
    {
        public VehicleService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<VehicleResponse> Insert(VehicleInsertRequest request)
        {
            if (!request.UserId.HasValue)
            {
                throw new ValidationException("UserId is required.");
            }

            await EnsureReferencesExist(request.UserId.Value, request.ConnectorTypeId);
            return await base.Insert(request);
        }

        protected override IQueryable<Vehicle> AddFilter(IQueryable<Vehicle> query, VehicleSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Make))
            {
                query = query.Where(x => x.Make.Contains(search.Make));
            }

            if (!string.IsNullOrWhiteSpace(search.Model))
            {
                query = query.Where(x => x.Model.Contains(search.Model));
            }

            if (!string.IsNullOrWhiteSpace(search.LicensePlate))
            {
                query = query.Where(x => x.LicensePlate != null && x.LicensePlate.Contains(search.LicensePlate));
            }

            if (search.ConnectorTypeId.HasValue)
            {
                query = query.Where(x => x.ConnectorTypeId == search.ConnectorTypeId.Value);
            }

            return query;
        }

        protected override IQueryable<Vehicle> AddInclude(IQueryable<Vehicle> query, VehicleSearchObject? search)
        {
            return query.Include(x => x.User).Include(x => x.ConnectorType);
        }

        protected override Vehicle MapInsert(VehicleInsertRequest request)
        {
            return new Vehicle
            {
                UserId = request.UserId!.Value,
                Make = request.Make.Trim(),
                Model = request.Model.Trim(),
                Year = request.Year,
                LicensePlate = request.LicensePlate,
                BatteryCapacity = request.BatteryCapacity,
                ConnectorTypeId = request.ConnectorTypeId
            };
        }

        protected override void MapUpdate(VehicleUpdateRequest request, Vehicle entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Make))
            {
                entity.Make = request.Make.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.Model))
            {
                entity.Model = request.Model.Trim();
            }

            if (request.Year.HasValue)
            {
                entity.Year = request.Year.Value;
            }
            else if (request.ClearYear)
            {
                entity.Year = null;
            }

            if (request.LicensePlate != null)
            {
                entity.LicensePlate = request.LicensePlate;
            }
            else if (request.ClearLicensePlate)
            {
                entity.LicensePlate = null;
            }

            if (request.BatteryCapacity.HasValue)
            {
                entity.BatteryCapacity = request.BatteryCapacity.Value;
            }
            else if (request.ClearBatteryCapacity)
            {
                entity.BatteryCapacity = null;
            }

            if (request.ConnectorTypeId.HasValue)
            {
                entity.ConnectorTypeId = request.ConnectorTypeId.Value;
            }
            else if (request.ClearConnectorTypeId)
            {
                entity.ConnectorTypeId = null;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        public override async Task<VehicleResponse> Update(int id, VehicleUpdateRequest request)
        {
            if (request.ConnectorTypeId.HasValue)
            {
                var connectorTypeExists = await _context.ConnectorTypes.AnyAsync(x => x.Id == request.ConnectorTypeId.Value);
                if (!connectorTypeExists)
                {
                    throw new ValidationException($"ConnectorType with id {request.ConnectorTypeId.Value} does not exist.");
                }
            }

            return await base.Update(id, request);
        }

        private async Task EnsureReferencesExist(int userId, int? connectorTypeId)
        {
            var userExists = await _context.Users.AnyAsync(x => x.Id == userId && !x.IsDeleted);
            if (!userExists)
            {
                throw new ValidationException($"User with id {userId} does not exist.");
            }

            if (connectorTypeId.HasValue)
            {
                var connectorTypeExists = await _context.ConnectorTypes.AnyAsync(x => x.Id == connectorTypeId.Value);
                if (!connectorTypeExists)
                {
                    throw new ValidationException($"ConnectorType with id {connectorTypeId.Value} does not exist.");
                }
            }
        }
    }
}
