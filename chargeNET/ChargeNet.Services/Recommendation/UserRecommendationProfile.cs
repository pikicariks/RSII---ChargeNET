namespace ChargeNet.Services.Recommendation
{
    public class UserRecommendationProfile
    {
        public int? PreferredConnectorTypeId { get; set; }
        public double AverageNormalizedPower { get; set; }
        public double AverageNormalizedPrice { get; set; }
        public double AverageNormalizedDistance { get; set; }
        public DayOfWeek PreferredDayOfWeek { get; set; }
        public int PreferredHourOfDay { get; set; }
        public bool IsColdStart { get; set; }
    }
}
