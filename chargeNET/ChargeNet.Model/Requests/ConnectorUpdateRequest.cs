namespace ChargeNet.Model.Requests
{
    public class ConnectorUpdateRequest
    {
        public int? ChargingStationId { get; set; }
        public int? ConnectorTypeId { get; set; }
        public string? Label { get; set; }
        public bool ClearLabel { get; set; }
        public bool? IsAvailable { get; set; }
        public decimal? PowerKW { get; set; }
    }
}
