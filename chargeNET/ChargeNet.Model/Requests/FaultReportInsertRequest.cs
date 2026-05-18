namespace ChargeNet.Model.Requests
{
    public class FaultReportInsertRequest
    {
        public int? UserId { get; set; }
        public int ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public string Description { get; set; } = string.Empty;
    }
}
