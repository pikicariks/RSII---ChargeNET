namespace ChargeNet.Model.Requests
{
    public class TariffUpdateRequest
    {
        public string? Name { get; set; }
        public decimal? PricePerKWh { get; set; }
        public decimal? PricePerMinute { get; set; }
        public bool ClearPricePerMinute { get; set; }
        public string? Currency { get; set; }
        public TimeSpan? StartHour { get; set; }
        public bool ClearStartHour { get; set; }
        public TimeSpan? EndHour { get; set; }
        public bool ClearEndHour { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? ValidFrom { get; set; }
        public bool ClearValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
        public bool ClearValidTo { get; set; }
    }
}
