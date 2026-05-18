namespace ChargeNet.Model.Responses
{
    public class VehicleResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserEmail { get; set; } = string.Empty;
        public string Make { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public int? Year { get; set; }
        public string? LicensePlate { get; set; }
        public decimal? BatteryCapacity { get; set; }
        public int? ConnectorTypeId { get; set; }
        public string? ConnectorTypeName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
