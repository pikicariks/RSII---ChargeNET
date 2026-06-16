namespace ChargeNet.Model.SearchObjects
{
    public class FaultReportSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public bool? IsResolved { get; set; }
        public string? Description { get; set; }
    }
}
