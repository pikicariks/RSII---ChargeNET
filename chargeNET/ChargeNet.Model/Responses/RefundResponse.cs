namespace ChargeNet.Model.Responses
{
    public class RefundResponse
    {
        public int RefundTransactionId { get; set; }
        public int SourceTransactionId { get; set; }
        public decimal RefundedAmount { get; set; }
        public decimal NewWalletBalance { get; set; }
        public string Currency { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }
}
