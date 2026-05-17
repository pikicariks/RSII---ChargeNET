namespace ChargeNet.Model.SearchObjects
{
    public class ChargingStationSearchObject
    {
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public int? StatusId { get; set; }
        public int? ConnectorTypeId { get; set; }
        public bool? IsFastCharger { get; set; }
        public bool? Has24hAccess { get; set; }
        public decimal? MinPowerKW { get; set; }
        public bool? HasAvailableConnector { get; set; }
    }
}
