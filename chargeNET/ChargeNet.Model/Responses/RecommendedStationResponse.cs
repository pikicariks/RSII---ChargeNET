namespace ChargeNet.Model.Responses
{
    public class RecommendedStationResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public int CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public int StatusId { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public bool HasCCS { get; set; }
        public bool HasCHAdeMO { get; set; }
        public bool HasType2 { get; set; }
        public decimal? MaxPowerKW { get; set; }
        public bool IsFastCharger { get; set; }
        public bool HasIndoor { get; set; }
        public bool Has24hAccess { get; set; }
        public decimal? Rating { get; set; }
        public int ConnectorCount { get; set; }
        public decimal EstimatedPricePerKWh { get; set; }
        public double DistanceKm { get; set; }
        public double BaseScore { get; set; }
        public double OccupancyPenalty { get; set; }
        public double Score { get; set; }
    }
}
