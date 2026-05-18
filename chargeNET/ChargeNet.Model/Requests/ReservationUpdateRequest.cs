namespace ChargeNet.Model.Requests
{
    public class ReservationUpdateRequest
    {
        public int? ChargingStationId { get; set; }
        public int? ConnectorId { get; set; }
        public bool ClearConnectorId { get; set; }
        public DateTime? ReservationStart { get; set; }
        public DateTime? ReservationEnd { get; set; }
    }
}
