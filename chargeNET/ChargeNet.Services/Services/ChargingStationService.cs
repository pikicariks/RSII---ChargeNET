using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Recommendation;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class ChargingStationService :
        BaseCRUDService<ChargingStation, ChargingStationResponse, ChargingStationSearchObject, ChargingStationInsertRequest, ChargingStationUpdateRequest>,
        IChargingStationService
    {
        private readonly IStationVectorService _stationVectorService;
        private readonly IRecommendationCacheService _recommendationCacheService;

        public ChargingStationService(
            ChargeNetDbContext context,
            IMapper mapper,
            IStationVectorService stationVectorService,
            IRecommendationCacheService recommendationCacheService) : base(context, mapper)
        {
            _stationVectorService = stationVectorService;
            _recommendationCacheService = recommendationCacheService;
        }

        public override async Task<ChargingStationResponse> Insert(ChargingStationInsertRequest request)
        {
            await EnsureForeignKeysExist(request.CityId, request.StatusId);

            var result = await base.Insert(request);
            await _stationVectorService.RecomputeAsync(result.Id);
            _recommendationCacheService.InvalidateAll();

            return result;
        }

        public override async Task<ChargingStationResponse> Update(int id, ChargingStationUpdateRequest request)
        {
            if (request.CityId.HasValue)
            {
                var cityExists = await _context.Cities.AnyAsync(x => x.Id == request.CityId.Value);
                if (!cityExists)
                {
                    throw new ValidationException($"City with id {request.CityId.Value} does not exist.");
                }
            }

            if (request.StatusId.HasValue)
            {
                var statusExists = await _context.StationStatuses.AnyAsync(x => x.Id == request.StatusId.Value);
                if (!statusExists)
                {
                    throw new ValidationException($"StationStatus with id {request.StatusId.Value} does not exist.");
                }
            }

            var result = await base.Update(id, request);
            await _stationVectorService.RecomputeAsync(id);
            _recommendationCacheService.InvalidateAll();

            return result;
        }

        public override async Task Delete(int id)
        {
            await base.Delete(id);
            _recommendationCacheService.InvalidateAll();
        }

        protected override IQueryable<ChargingStation> AddFilter(IQueryable<ChargingStation> query, ChargingStationSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(x => x.CityId == search.CityId.Value);
            }

            if (search.StatusId.HasValue)
            {
                query = query.Where(x => x.StatusId == search.StatusId.Value);
            }

            if (search.IsFastCharger.HasValue)
            {
                query = query.Where(x => x.IsFastCharger == search.IsFastCharger.Value);
            }

            if (search.Has24hAccess.HasValue)
            {
                query = query.Where(x => x.Has24hAccess == search.Has24hAccess.Value);
            }

            if (search.MinPowerKW.HasValue)
            {
                query = query.Where(x => x.MaxPowerKW.HasValue && x.MaxPowerKW.Value >= search.MinPowerKW.Value);
            }

            if (search.ConnectorTypeId.HasValue)
            {
                query = query.Where(x => x.Connectors.Any(c => c.ConnectorTypeId == search.ConnectorTypeId.Value));
            }

            if (search.HasAvailableConnector.HasValue)
            {
                query = search.HasAvailableConnector.Value
                    ? query.Where(x => x.Connectors.Any(c => c.IsAvailable))
                    : query.Where(x => x.Connectors.Any() && x.Connectors.All(c => !c.IsAvailable));
            }

            return query;
        }

        protected override IQueryable<ChargingStation> AddInclude(IQueryable<ChargingStation> query, ChargingStationSearchObject? search)
        {
            return query
                .Include(x => x.City)
                .Include(x => x.Status)
                .Include(x => x.Connectors);
        }

        protected override ChargingStation MapInsert(ChargingStationInsertRequest request)
        {
            return new ChargingStation
            {
                Name = request.Name.Trim(),
                Address = request.Address.Trim(),
                CityId = request.CityId,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                StatusId = request.StatusId,
                HasCCS = request.HasCCS,
                HasCHAdeMO = request.HasCHAdeMO,
                HasType2 = request.HasType2,
                MaxPowerKW = request.MaxPowerKW,
                IsFastCharger = request.IsFastCharger,
                HasIndoor = request.HasIndoor,
                Has24hAccess = request.Has24hAccess,
                Rating = request.Rating
            };
        }

        protected override void MapUpdate(ChargingStationUpdateRequest request, ChargingStation entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                entity.Name = request.Name.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.Address))
            {
                entity.Address = request.Address.Trim();
            }

            if (request.CityId.HasValue)
            {
                entity.CityId = request.CityId.Value;
            }

            if (request.Latitude.HasValue)
            {
                entity.Latitude = request.Latitude.Value;
            }
            else if (request.ClearLatitude)
            {
                entity.Latitude = null;
            }

            if (request.Longitude.HasValue)
            {
                entity.Longitude = request.Longitude.Value;
            }
            else if (request.ClearLongitude)
            {
                entity.Longitude = null;
            }

            if (request.StatusId.HasValue)
            {
                entity.StatusId = request.StatusId.Value;
            }

            if (request.HasCCS.HasValue)
            {
                entity.HasCCS = request.HasCCS.Value;
            }

            if (request.HasCHAdeMO.HasValue)
            {
                entity.HasCHAdeMO = request.HasCHAdeMO.Value;
            }

            if (request.HasType2.HasValue)
            {
                entity.HasType2 = request.HasType2.Value;
            }

            if (request.MaxPowerKW.HasValue)
            {
                entity.MaxPowerKW = request.MaxPowerKW.Value;
            }
            else if (request.ClearMaxPowerKW)
            {
                entity.MaxPowerKW = null;
            }

            if (request.IsFastCharger.HasValue)
            {
                entity.IsFastCharger = request.IsFastCharger.Value;
            }

            if (request.HasIndoor.HasValue)
            {
                entity.HasIndoor = request.HasIndoor.Value;
            }

            if (request.Has24hAccess.HasValue)
            {
                entity.Has24hAccess = request.Has24hAccess.Value;
            }

            if (request.Rating.HasValue)
            {
                entity.Rating = request.Rating.Value;
            }
            else if (request.ClearRating)
            {
                entity.Rating = null;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        private async Task EnsureForeignKeysExist(int cityId, int statusId)
        {
            var cityExists = await _context.Cities.AnyAsync(x => x.Id == cityId);
            if (!cityExists)
            {
                throw new ValidationException($"City with id {cityId} does not exist.");
            }

            var statusExists = await _context.StationStatuses.AnyAsync(x => x.Id == statusId);
            if (!statusExists)
            {
                throw new ValidationException($"StationStatus with id {statusId} does not exist.");
            }
        }
    }
}
