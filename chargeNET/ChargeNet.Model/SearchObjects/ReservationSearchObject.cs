namespace ChargeNet.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public int? StatusId { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
    }
}
