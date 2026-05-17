namespace ChargeNet.Model.Requests
{
    public class ChargingStationInsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public int CityId { get; set; }
        public decimal? Latitude { get; set; }
        public decimal? Longitude { get; set; }
        public int StatusId { get; set; }
        public bool HasCCS { get; set; }
        public bool HasCHAdeMO { get; set; }
        public bool HasType2 { get; set; }
        public decimal? MaxPowerKW { get; set; }
        public bool IsFastCharger { get; set; }
        public bool HasIndoor { get; set; }
        public bool Has24hAccess { get; set; }
        public decimal? Rating { get; set; }
    }
}
