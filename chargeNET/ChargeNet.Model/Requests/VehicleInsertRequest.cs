namespace ChargeNet.Model.Requests
{
    public class VehicleInsertRequest
    {
        public int? UserId { get; set; }
        public string Make { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public int? Year { get; set; }
        public string? LicensePlate { get; set; }
        public decimal? BatteryCapacity { get; set; }
        public int? ConnectorTypeId { get; set; }
    }
}
