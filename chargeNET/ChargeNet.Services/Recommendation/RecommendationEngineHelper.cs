using ChargeNet.Services.Database;

namespace ChargeNet.Services.Recommendation
{
    internal static class RecommendationEngineHelper
    {
        public static decimal? GetStationPowerKw(ChargingStation station)
        {
            if (station.StationVector?.MaxPowerKW.HasValue == true)
            {
                return station.StationVector.MaxPowerKW.Value;
            }

            if (station.MaxPowerKW.HasValue)
            {
                return station.MaxPowerKW.Value;
            }

            return station.Connectors.Count == 0
                ? null
                : station.Connectors.Max(connector => (decimal?)connector.PowerKW);
        }

        public static double CalculateDistanceKm(ChargingStation station, double latitude, double longitude)
        {
            if (!station.Latitude.HasValue || !station.Longitude.HasValue)
            {
                return RecommendationConstants.MaxDistanceKm;
            }

            return CalculateDistanceKm(
                (double)station.Latitude.Value,
                (double)station.Longitude.Value,
                latitude,
                longitude);
        }

        public static decimal ResolveCurrentPricePerKWh(
            ChargingStation station,
            IReadOnlyCollection<Tariff> activeTariffs,
            DateTime nowUtc)
        {
            if (activeTariffs.Count == 0)
            {
                return 0m;
            }

            var currentlyApplicable = activeTariffs
                .Where(tariff => IsTariffApplicable(tariff, nowUtc))
                .ToList();

            var candidates = currentlyApplicable.Count > 0
                ? currentlyApplicable
                : activeTariffs.ToList();

            if (IsFastChargingStation(station))
            {
                var fastTariff = candidates.FirstOrDefault(tariff =>
                    tariff.Name.Contains("fast", StringComparison.OrdinalIgnoreCase));

                if (fastTariff != null)
                {
                    return fastTariff.PricePerKWh;
                }
            }

            var timeSpecificTariff = candidates
                .Where(tariff => tariff.StartHour.HasValue || tariff.EndHour.HasValue)
                .OrderBy(tariff => tariff.PricePerKWh)
                .FirstOrDefault();

            if (timeSpecificTariff != null)
            {
                return timeSpecificTariff.PricePerKWh;
            }

            return candidates
                .OrderBy(tariff => tariff.PricePerKWh)
                .First()
                .PricePerKWh;
        }

        private static bool IsFastChargingStation(ChargingStation station)
        {
            return station.IsFastCharger || (GetStationPowerKw(station) ?? 0m) >= 50m;
        }

        private static bool IsTariffApplicable(Tariff tariff, DateTime nowUtc)
        {
            if (!tariff.IsActive)
            {
                return false;
            }

            if (tariff.ValidFrom.HasValue && tariff.ValidFrom.Value > nowUtc)
            {
                return false;
            }

            if (tariff.ValidTo.HasValue && tariff.ValidTo.Value < nowUtc)
            {
                return false;
            }

            if (!tariff.StartHour.HasValue && !tariff.EndHour.HasValue)
            {
                return true;
            }

            var nowTime = nowUtc.TimeOfDay;
            var start = tariff.StartHour;
            var end = tariff.EndHour;

            if (start.HasValue && end.HasValue)
            {
                return start.Value <= end.Value
                    ? nowTime >= start.Value && nowTime <= end.Value
                    : nowTime >= start.Value || nowTime <= end.Value;
            }

            if (start.HasValue)
            {
                return nowTime >= start.Value;
            }

            return nowTime <= end!.Value;
        }

        private static double CalculateDistanceKm(
            double latitude1,
            double longitude1,
            double latitude2,
            double longitude2)
        {
            const double earthRadiusKm = 6371d;

            var deltaLatitude = DegreesToRadians(latitude2 - latitude1);
            var deltaLongitude = DegreesToRadians(longitude2 - longitude1);

            var a =
                Math.Sin(deltaLatitude / 2) * Math.Sin(deltaLatitude / 2) +
                Math.Cos(DegreesToRadians(latitude1)) *
                Math.Cos(DegreesToRadians(latitude2)) *
                Math.Sin(deltaLongitude / 2) *
                Math.Sin(deltaLongitude / 2);

            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return earthRadiusKm * c;
        }

        private static double DegreesToRadians(double degrees)
        {
            return degrees * (Math.PI / 180d);
        }
    }
}
