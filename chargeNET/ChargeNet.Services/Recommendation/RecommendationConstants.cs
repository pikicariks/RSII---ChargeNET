namespace ChargeNet.Services.Recommendation
{
    internal static class RecommendationConstants
    {
        public const double MaxPowerKw = 350d;
        public const double MaxPricePerKWh = 1.50d;
        public const double MaxDistanceKm = 50d;

        public static double NormalizePower(decimal? powerKw)
        {
            return Normalize(powerKw.HasValue ? (double)powerKw.Value : 0d, 0d, MaxPowerKw);
        }

        public static double NormalizePrice(decimal pricePerKWh)
        {
            return Normalize((double)pricePerKWh, 0d, MaxPricePerKWh);
        }

        public static double NormalizeDistance(double distanceKm)
        {
            return Normalize(distanceKm, 0d, MaxDistanceKm);
        }

        private static double Normalize(double value, double min, double max)
        {
            if (max <= min)
            {
                return 0d;
            }

            return Math.Clamp((value - min) / (max - min), 0d, 1d);
        }
    }
}
