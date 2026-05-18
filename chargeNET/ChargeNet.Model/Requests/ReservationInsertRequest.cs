namespace ChargeNet.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int? UserId { get; set; }
        public int ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public DateTime ReservationStart { get; set; }
        public DateTime ReservationEnd { get; set; }
    }
}
