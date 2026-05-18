namespace ChargeNet.Model.Responses
{
    public class FaultReportResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserEmail { get; set; } = string.Empty;
        public int ChargingStationId { get; set; }
        public string ChargingStationName { get; set; } = string.Empty;
        public int? ConnectorId { get; set; }
        public string? ConnectorLabel { get; set; }
        public string Description { get; set; } = string.Empty;
        public bool IsResolved { get; set; }
        public DateTime ReportedAt { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
