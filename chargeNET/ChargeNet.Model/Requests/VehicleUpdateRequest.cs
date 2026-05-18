namespace ChargeNet.Model.Requests
{
    public class VehicleUpdateRequest
    {
        public string? Make { get; set; }
        public string? Model { get; set; }
        public int? Year { get; set; }
        public bool ClearYear { get; set; }
        public string? LicensePlate { get; set; }
        public bool ClearLicensePlate { get; set; }
        public decimal? BatteryCapacity { get; set; }
        public bool ClearBatteryCapacity { get; set; }
        public int? ConnectorTypeId { get; set; }
        public bool ClearConnectorTypeId { get; set; }
    }
}
