namespace ChargeNet.Model.SearchObjects
{
    public class TransactionSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ChargingSessionId { get; set; }
        public string? Type { get; set; }
        public string? Status { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
    }
}
