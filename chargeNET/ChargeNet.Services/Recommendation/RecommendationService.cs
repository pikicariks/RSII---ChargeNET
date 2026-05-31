using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Recommendation
{
    public class RecommendationService : IRecommendationService
    {
        private readonly ChargeNetDbContext _context;
        private readonly IUserProfileService _userProfileService;
        private readonly IStationVectorService _stationVectorService;
        private readonly IRecommendationCacheService _recommendationCacheService;

        public RecommendationService(
            ChargeNetDbContext context,
            IUserProfileService userProfileService,
            IStationVectorService stationVectorService,
            IRecommendationCacheService recommendationCacheService)
        {
            _context = context;
            _userProfileService = userProfileService;
            _stationVectorService = stationVectorService;
            _recommendationCacheService = recommendationCacheService;
        }

        public async Task<List<RecommendedStationResponse>> GetRecommendationsAsync(
            int userId,
            double latitude,
            double longitude,
            int topN = 10,
            CancellationToken cancellationToken = default)
        {
            ValidateInput(latitude, longitude, topN);

            if (_recommendationCacheService.TryGet(userId, latitude, longitude, topN, out var cachedRecommendations)
                && cachedRecommendations != null)
            {
                return cachedRecommendations;
            }

            await _stationVectorService.EnsureVectorsAsync(cancellationToken);

            var profile = await _userProfileService.GetProfileAsync(userId, latitude, longitude, cancellationToken);
            var nowUtc = DateTime.UtcNow;

            var activeTariffs = await _context.Tariffs
                .AsNoTracking()
                .Where(tariff => tariff.IsActive)
                .ToListAsync(cancellationToken);

            var stations = await _context.ChargingStations
                .AsNoTracking()
                .Include(station => station.City)
                .Include(station => station.Status)
                .Include(station => station.Connectors)
                .Include(station => station.StationVector)
                .Where(station => station.StatusId == 1 && station.Connectors.Any())
                .ToListAsync(cancellationToken);

            var candidates = BuildCandidates(
                stations,
                activeTariffs,
                profile.PreferredConnectorTypeId,
                latitude,
                longitude,
                nowUtc,
                withinRadiusOnly: true);

            if (candidates.Count == 0)
            {
                candidates = BuildCandidates(
                    stations,
                    activeTariffs,
                    profile.PreferredConnectorTypeId,
                    latitude,
                    longitude,
                    nowUtc,
                    withinRadiusOnly: false);
            }

            if (candidates.Count == 0 && profile.PreferredConnectorTypeId.HasValue)
            {
                candidates = BuildCandidates(
                    stations,
                    activeTariffs,
                    preferredConnectorTypeId: null,
                    latitude,
                    longitude,
                    nowUtc,
                    withinRadiusOnly: true);
            }

            if (candidates.Count == 0)
            {
                candidates = BuildCandidates(
                    stations,
                    activeTariffs,
                    preferredConnectorTypeId: null,
                    latitude,
                    longitude,
                    nowUtc,
                    withinRadiusOnly: false);
            }

            if (candidates.Count == 0)
            {
                return new List<RecommendedStationResponse>();
            }

            var occupancyPenaltyByStation = await GetHistoricalOccupancyPenaltiesAsync(
                candidates,
                profile.PreferredDayOfWeek,
                profile.PreferredHourOfDay,
                cancellationToken);

            var recommendations = candidates
                .Select(candidate =>
                {
                    var euclideanDistance = Math.Sqrt(
                        Math.Pow(profile.AverageNormalizedPower - candidate.NormalizedPower, 2) +
                        Math.Pow(profile.AverageNormalizedPrice - candidate.NormalizedPrice, 2) +
                        Math.Pow(profile.AverageNormalizedDistance - candidate.NormalizedDistance, 2));

                    var baseScore = 1d / (1d + euclideanDistance);
                    var occupancyPenalty = occupancyPenaltyByStation.TryGetValue(candidate.Station.Id, out var penalty)
                        ? penalty
                        : 0d;

                    var adjustedScore = baseScore * (1d - occupancyPenalty);

                    return new RecommendedStationResponse
                    {
                        Id = candidate.Station.Id,
                        Name = candidate.Station.Name,
                        Address = candidate.Station.Address,
                        CityId = candidate.Station.CityId,
                        CityName = candidate.Station.City.Name,
                        StatusId = candidate.Station.StatusId,
                        StatusName = candidate.Station.Status.Name,
                        Latitude = candidate.Station.Latitude,
                        Longitude = candidate.Station.Longitude,
                        HasCCS = candidate.Station.HasCCS,
                        HasCHAdeMO = candidate.Station.HasCHAdeMO,
                        HasType2 = candidate.Station.HasType2,
                        MaxPowerKW = candidate.PowerKw,
                        IsFastCharger = candidate.Station.IsFastCharger,
                        HasIndoor = candidate.Station.HasIndoor,
                        Has24hAccess = candidate.Station.Has24hAccess,
                        Rating = candidate.Station.Rating,
                        ConnectorCount = candidate.ConnectorCount,
                        EstimatedPricePerKWh = candidate.PricePerKWh,
                        DistanceKm = Math.Round(candidate.DistanceKm, 2),
                        BaseScore = Math.Round(baseScore, 4),
                        OccupancyPenalty = Math.Round(occupancyPenalty, 4),
                        Score = Math.Round(adjustedScore, 4)
                    };
                })
                .OrderByDescending(recommendation => recommendation.Score)
                .ThenByDescending(recommendation => recommendation.Rating ?? 0m)
                .ThenBy(recommendation => recommendation.DistanceKm)
                .Take(topN)
                .ToList();

            _recommendationCacheService.Set(userId, latitude, longitude, topN, recommendations);

            return recommendations;
        }

        private static void ValidateInput(double latitude, double longitude, int topN)
        {
            if (latitude < -90d || latitude > 90d)
            {
                throw new ValidationException("Latitude must be between -90 and 90.");
            }

            if (longitude < -180d || longitude > 180d)
            {
                throw new ValidationException("Longitude must be between -180 and 180.");
            }

            if (topN < 1 || topN > 50)
            {
                throw new ValidationException("TopN must be between 1 and 50.");
            }
        }

        private static List<CandidateStation> BuildCandidates(
            IEnumerable<ChargingStation> stations,
            IReadOnlyCollection<Tariff> activeTariffs,
            int? preferredConnectorTypeId,
            double latitude,
            double longitude,
            DateTime nowUtc,
            bool withinRadiusOnly)
        {
            return stations
                .Where(station => !preferredConnectorTypeId.HasValue ||
                    station.Connectors.Any(connector => connector.ConnectorTypeId == preferredConnectorTypeId.Value))
                .Select(station =>
                {
                    var distanceKm = RecommendationEngineHelper.CalculateDistanceKm(station, latitude, longitude);
                    var powerKw = RecommendationEngineHelper.GetStationPowerKw(station);
                    var pricePerKWh = RecommendationEngineHelper.ResolveCurrentPricePerKWh(station, activeTariffs, nowUtc);

                    return new CandidateStation
                    {
                        Station = station,
                        PowerKw = powerKw,
                        PricePerKWh = pricePerKWh,
                        DistanceKm = distanceKm,
                        NormalizedPower = RecommendationConstants.NormalizePower(powerKw),
                        NormalizedPrice = RecommendationConstants.NormalizePrice(pricePerKWh),
                        NormalizedDistance = RecommendationConstants.NormalizeDistance(distanceKm),
                        ConnectorCount = station.Connectors.Count
                    };
                })
                .Where(candidate => !withinRadiusOnly || candidate.DistanceKm <= RecommendationConstants.MaxDistanceKm)
                .OrderBy(candidate => candidate.DistanceKm)
                .ToList();
        }

        private async Task<Dictionary<int, double>> GetHistoricalOccupancyPenaltiesAsync(
            IReadOnlyCollection<CandidateStation> candidates,
            DayOfWeek preferredDayOfWeek,
            int preferredHourOfDay,
            CancellationToken cancellationToken)
        {
            var stationIds = candidates
                .Select(candidate => candidate.Station.Id)
                .Distinct()
                .ToList();

            var connectorCountByStation = candidates.ToDictionary(
                candidate => candidate.Station.Id,
                candidate => Math.Max(candidate.ConnectorCount, 1));

            var sessionHistory = await _context.ChargingSessions
                .AsNoTracking()
                .Where(session => stationIds.Contains(session.Connector.ChargingStationId))
                .Select(session => new
                {
                    StationId = session.Connector.ChargingStationId,
                    session.StartTime
                })
                .ToListAsync(cancellationToken);

            return sessionHistory
                .GroupBy(entry => entry.StationId)
                .ToDictionary(
                    group => group.Key,
                    group =>
                    {
                        var oldestSession = group.Min(entry => entry.StartTime);
                        var weeksObserved = Math.Max(1d, (DateTime.UtcNow - oldestSession).TotalDays / 7d);
                        var matchingSlotCount = group.Count(entry =>
                            entry.StartTime.DayOfWeek == preferredDayOfWeek &&
                            entry.StartTime.Hour == preferredHourOfDay);

                        var occupancyFraction = matchingSlotCount / (weeksObserved * connectorCountByStation[group.Key]);
                        return Math.Min(0.5d, occupancyFraction);
                    });
        }

        private sealed class CandidateStation
        {
            public ChargingStation Station { get; set; } = null!;
            public decimal? PowerKw { get; set; }
            public decimal PricePerKWh { get; set; }
            public double DistanceKm { get; set; }
            public double NormalizedPower { get; set; }
            public double NormalizedPrice { get; set; }
            public double NormalizedDistance { get; set; }
            public int ConnectorCount { get; set; }
        }
    }
}
