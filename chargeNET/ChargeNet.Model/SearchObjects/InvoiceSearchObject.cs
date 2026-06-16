namespace ChargeNet.Model.SearchObjects
{
    public class InvoiceSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? TransactionId { get; set; }
        public string? Status { get; set; }
        public string? InvoiceNumber { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
    }
}
