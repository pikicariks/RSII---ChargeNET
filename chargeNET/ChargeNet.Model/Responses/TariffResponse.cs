namespace ChargeNet.Model.Responses
{
    public class TariffResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal PricePerKWh { get; set; }
        public decimal? PricePerMinute { get; set; }
        public string Currency { get; set; } = string.Empty;
        public TimeSpan? StartHour { get; set; }
        public TimeSpan? EndHour { get; set; }
        public bool IsActive { get; set; }
        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
