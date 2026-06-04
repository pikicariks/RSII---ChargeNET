namespace ChargeNet.Model.Messages
{
    public class InvoiceGenerationMessage
    {
        public int InvoiceId { get; set; }
        public int TransactionId { get; set; }
        public int UserId { get; set; }
        public string InvoiceNumber { get; set; } = string.Empty;
        public DateTime IssuedAt { get; set; }
    }
}
