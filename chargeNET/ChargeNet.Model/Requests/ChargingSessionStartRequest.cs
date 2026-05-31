namespace ChargeNet.Model.Requests
{
    public class ChargingSessionStartRequest
    {
        public int? UserId { get; set; }
        public int ConnectorId { get; set; }
        public int TariffId { get; set; }
        public int? ReservationId { get; set; }
    }
}
