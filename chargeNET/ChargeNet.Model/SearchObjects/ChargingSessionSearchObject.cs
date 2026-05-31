namespace ChargeNet.Model.SearchObjects
{
    public class ChargingSessionSearchObject
    {
        public int? UserId { get; set; }
        public int? ConnectorId { get; set; }
        public int? ChargingStationId { get; set; }
        public int? TariffId { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
    }
}
