namespace ChargeNet.Model.Requests
{
    public class ConnectorInsertRequest
    {
        public int ChargingStationId { get; set; }
        public int ConnectorTypeId { get; set; }
        public string? Label { get; set; }
        public bool IsAvailable { get; set; } = true;
        public decimal PowerKW { get; set; }
    }
}
