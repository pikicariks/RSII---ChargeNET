using ChargeNet.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Recommendation
{
    public class UserProfileService : IUserProfileService
    {
        private readonly ChargeNetDbContext _context;
        private readonly IStationVectorService _stationVectorService;

        public UserProfileService(ChargeNetDbContext context, IStationVectorService stationVectorService)
        {
            _context = context;
            _stationVectorService = stationVectorService;
        }

        public async Task<UserRecommendationProfile> GetProfileAsync(
            int userId,
            double latitude,
            double longitude,
            CancellationToken cancellationToken = default)
        {
            await _stationVectorService.EnsureVectorsAsync(cancellationToken);
            await UpdateProfileAsync(userId, cancellationToken);

            var completedSessions = await _context.ChargingSessions
                .AsNoTracking()
                .Include(session => session.Connector)
                    .ThenInclude(connector => connector.ChargingStation)
                        .ThenInclude(station => station.StationVector)
                .Include(session => session.Connector)
                    .ThenInclude(connector => connector.ChargingStation)
                        .ThenInclude(station => station.Connectors)
                .Include(session => session.Tariff)
                .Where(session => session.UserId == userId && session.EndTime.HasValue)
                .ToListAsync(cancellationToken);

            if (completedSessions.Count == 0)
            {
                return await BuildColdStartProfileAsync(userId, latitude, longitude, cancellationToken);
            }

            var preferredConnectorTypeId = completedSessions
                .GroupBy(session => session.Connector.ConnectorTypeId)
                .OrderByDescending(group => group.Count())
                .ThenBy(group => group.Key)
                .Select(group => (int?)group.Key)
                .FirstOrDefault();

            var preferredSlot = completedSessions
                .GroupBy(session => new { session.StartTime.DayOfWeek, session.StartTime.Hour })
                .OrderByDescending(group => group.Count())
                .ThenBy(group => group.Key.DayOfWeek)
                .ThenBy(group => group.Key.Hour)
                .Select(group => new
                {
                    group.Key.DayOfWeek,
                    group.Key.Hour
                })
                .First();

            var normalizedPower = 0d;
            var normalizedPrice = 0d;
            var normalizedDistance = 0d;

            foreach (var session in completedSessions)
            {
                var station = session.Connector.ChargingStation;
                var powerKw = RecommendationEngineHelper.GetStationPowerKw(station) ?? session.Connector.PowerKW;
                var distanceKm = RecommendationEngineHelper.CalculateDistanceKm(station, latitude, longitude);

                normalizedPower += RecommendationConstants.NormalizePower(powerKw);
                normalizedPrice += RecommendationConstants.NormalizePrice(session.Tariff.PricePerKWh);
                normalizedDistance += RecommendationConstants.NormalizeDistance(distanceKm);
            }

            var count = completedSessions.Count;

            return new UserRecommendationProfile
            {
                PreferredConnectorTypeId = preferredConnectorTypeId,
                AverageNormalizedPower = normalizedPower / count,
                AverageNormalizedPrice = normalizedPrice / count,
                AverageNormalizedDistance = normalizedDistance / count,
                PreferredDayOfWeek = preferredSlot.DayOfWeek,
                PreferredHourOfDay = preferredSlot.Hour,
                IsColdStart = false
            };
        }

        public async Task UpdateProfileAsync(int userId, CancellationToken cancellationToken = default)
        {
            var aggregates = await _context.ChargingSessions
                .Where(session => session.UserId == userId && session.EndTime.HasValue)
                .GroupBy(session => session.Connector.ChargingStationId)
                .Select(group => new
                {
                    ChargingStationId = group.Key,
                    VisitedCount = group.Count(),
                    LastVisitedAt = group.Max(session => session.EndTime)
                })
                .ToListAsync(cancellationToken);

            if (aggregates.Count == 0)
            {
                return;
            }

            var existingProfiles = await _context.UserStationProfiles
                .Where(profile => profile.UserId == userId)
                .ToDictionaryAsync(profile => profile.ChargingStationId, cancellationToken);

            foreach (var aggregate in aggregates)
            {
                if (!existingProfiles.TryGetValue(aggregate.ChargingStationId, out var profile))
                {
                    profile = new UserStationProfile
                    {
                        UserId = userId,
                        ChargingStationId = aggregate.ChargingStationId,
                        CreatedAt = DateTime.UtcNow
                    };

                    _context.UserStationProfiles.Add(profile);
                }

                profile.VisitedCount = aggregate.VisitedCount;
                profile.LastVisitedAt = aggregate.LastVisitedAt;
                profile.ModifiedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync(cancellationToken);
        }

        private async Task<UserRecommendationProfile> BuildColdStartProfileAsync(
            int userId,
            double latitude,
            double longitude,
            CancellationToken cancellationToken)
        {
            var preferredConnectorTypeId = await _context.Vehicles
                .AsNoTracking()
                .Where(vehicle => vehicle.UserId == userId && vehicle.ConnectorTypeId.HasValue)
                .GroupBy(vehicle => vehicle.ConnectorTypeId)
                .OrderByDescending(group => group.Count())
                .ThenBy(group => group.Key)
                .Select(group => group.Key)
                .FirstOrDefaultAsync(cancellationToken);

            var nowUtc = DateTime.UtcNow;
            var activeTariffs = await _context.Tariffs
                .AsNoTracking()
                .Where(tariff => tariff.IsActive)
                .ToListAsync(cancellationToken);

            var stations = await _context.ChargingStations
                .AsNoTracking()
                .Include(station => station.Connectors)
                .Include(station => station.StationVector)
                .Where(station => station.StatusId == 1 && station.Connectors.Any())
                .ToListAsync(cancellationToken);

            if (stations.Count == 0)
            {
                return new UserRecommendationProfile
                {
                    PreferredConnectorTypeId = preferredConnectorTypeId,
                    AverageNormalizedPower = 0d,
                    AverageNormalizedPrice = 0d,
                    AverageNormalizedDistance = 0d,
                    PreferredDayOfWeek = nowUtc.DayOfWeek,
                    PreferredHourOfDay = nowUtc.Hour,
                    IsColdStart = true
                };
            }

            var normalizedPower = 0d;
            var normalizedPrice = 0d;
            var normalizedDistance = 0d;

            foreach (var station in stations)
            {
                var powerKw = RecommendationEngineHelper.GetStationPowerKw(station);
                var pricePerKWh = RecommendationEngineHelper.ResolveCurrentPricePerKWh(station, activeTariffs, nowUtc);
                var distanceKm = RecommendationEngineHelper.CalculateDistanceKm(station, latitude, longitude);

                normalizedPower += RecommendationConstants.NormalizePower(powerKw);
                normalizedPrice += RecommendationConstants.NormalizePrice(pricePerKWh);
                normalizedDistance += RecommendationConstants.NormalizeDistance(distanceKm);
            }

            var count = stations.Count;

            return new UserRecommendationProfile
            {
                PreferredConnectorTypeId = preferredConnectorTypeId,
                AverageNormalizedPower = normalizedPower / count,
                AverageNormalizedPrice = normalizedPrice / count,
                AverageNormalizedDistance = normalizedDistance / count,
                PreferredDayOfWeek = nowUtc.DayOfWeek,
                PreferredHourOfDay = nowUtc.Hour,
                IsColdStart = true
            };
        }
    }
}
