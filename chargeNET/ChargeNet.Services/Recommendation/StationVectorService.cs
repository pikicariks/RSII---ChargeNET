using ChargeNet.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Recommendation
{
    public class StationVectorService : IStationVectorService
    {
        private readonly ChargeNetDbContext _context;

        public StationVectorService(ChargeNetDbContext context)
        {
            _context = context;
        }

        public async Task EnsureVectorsAsync(CancellationToken cancellationToken = default)
        {
            var stationIds = await _context.ChargingStations
                .AsNoTracking()
                .Select(station => station.Id)
                .ToListAsync(cancellationToken);

            var existingVectorIds = await _context.StationVectors
                .AsNoTracking()
                .Select(vector => vector.ChargingStationId)
                .ToListAsync(cancellationToken);

            foreach (var missingStationId in stationIds.Except(existingVectorIds))
            {
                await RecomputeAsync(missingStationId, cancellationToken);
            }
        }

        public async Task RecomputeAsync(int chargingStationId, CancellationToken cancellationToken = default)
        {
            var station = await _context.ChargingStations
                .Include(s => s.Connectors)
                    .ThenInclude(connector => connector.ConnectorType)
                .FirstOrDefaultAsync(s => s.Id == chargingStationId, cancellationToken);

            if (station == null)
            {
                return;
            }

            var vector = await _context.StationVectors
                .FirstOrDefaultAsync(v => v.ChargingStationId == chargingStationId, cancellationToken);

            if (vector == null)
            {
                vector = new StationVector
                {
                    ChargingStationId = chargingStationId
                };

                _context.StationVectors.Add(vector);
            }

            vector.HasCCS = station.HasCCS || station.Connectors.Any(connector =>
                connector.ConnectorType.Name.Equals("CCS", StringComparison.OrdinalIgnoreCase));

            vector.HasCHAdeMO = station.HasCHAdeMO || station.Connectors.Any(connector =>
                connector.ConnectorType.Name.Equals("CHAdeMO", StringComparison.OrdinalIgnoreCase));

            vector.HasType2 = station.HasType2 || station.Connectors.Any(connector =>
                connector.ConnectorType.Name.Equals("Type 2", StringComparison.OrdinalIgnoreCase));

            vector.MaxPowerKW = RecommendationEngineHelper.GetStationPowerKw(station);
            vector.IsFastCharger = station.IsFastCharger || (vector.MaxPowerKW ?? 0m) >= 50m;
            vector.HasIndoor = station.HasIndoor;
            vector.Has24hAccess = station.Has24hAccess;
            vector.Rating = station.Rating;
            vector.LastComputedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);
        }

        public async Task RecomputeAllAsync(CancellationToken cancellationToken = default)
        {
            var stationIds = await _context.ChargingStations
                .AsNoTracking()
                .Select(station => station.Id)
                .ToListAsync(cancellationToken);

            foreach (var stationId in stationIds)
            {
                await RecomputeAsync(stationId, cancellationToken);
            }
        }
    }
}
