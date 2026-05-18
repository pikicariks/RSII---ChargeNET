namespace ChargeNet.Model.Requests
{
    public class FaultReportUpdateRequest
    {
        public int? ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public bool ClearConnectorId { get; set; }
        public string? Description { get; set; }
        public bool? IsResolved { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public bool ClearResolvedAt { get; set; }
    }
}
