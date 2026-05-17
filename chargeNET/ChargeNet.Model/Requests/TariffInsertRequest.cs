namespace ChargeNet.Model.Requests
{
    public class TariffInsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public decimal PricePerKWh { get; set; }
        public decimal? PricePerMinute { get; set; }
        public string Currency { get; set; } = "EUR";
        public TimeSpan? StartHour { get; set; }
        public TimeSpan? EndHour { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
    }
}
