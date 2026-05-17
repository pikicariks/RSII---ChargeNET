namespace ChargeNet.Model.Responses
{
    public class ConnectorResponse
    {
        public int Id { get; set; }
        public int ChargingStationId { get; set; }
        public string ChargingStationName { get; set; } = string.Empty;
        public int ConnectorTypeId { get; set; }
        public string ConnectorTypeName { get; set; } = string.Empty;
        public string? Label { get; set; }
        public bool IsAvailable { get; set; }
        public decimal PowerKW { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
