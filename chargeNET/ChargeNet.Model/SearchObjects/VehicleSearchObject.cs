namespace ChargeNet.Model.SearchObjects
{
    public class VehicleSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public string? Make { get; set; }
        public string? Model { get; set; }
        public string? LicensePlate { get; set; }
        public int? ConnectorTypeId { get; set; }
    }
}
