namespace ChargeNet.Model.SearchObjects
{
    public class TariffSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Currency { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? ValidAt { get; set; }
    }
}
