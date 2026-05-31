namespace ChargeNet.Model.Responses
{
    public class ChargingSessionResponse
    {
        public int Id { get; set; }
        public int? ReservationId { get; set; }
        public int UserId { get; set; }
        public string UserEmail { get; set; } = string.Empty;
        public int ConnectorId { get; set; }
        public string ConnectorLabel { get; set; } = string.Empty;
        public int ChargingStationId { get; set; }
        public string ChargingStationName { get; set; } = string.Empty;
        public int TariffId { get; set; }
        public string TariffName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public decimal? EnergyConsumedKWh { get; set; }
        public decimal? Cost { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
