namespace ChargeNet.Model.SearchObjects
{
    public class TariffSearchObject
    {
        public string? Name { get; set; }
        public string? Currency { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? ValidAt { get; set; }
    }
}
