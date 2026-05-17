namespace ChargeNet.Model.SearchObjects
{
    public class ConnectorSearchObject
    {
        public int? ChargingStationId { get; set; }
        public int? ConnectorTypeId { get; set; }
        public bool? IsAvailable { get; set; }
        public decimal? MinPowerKW { get; set; }
        public string? Label { get; set; }
    }
}
