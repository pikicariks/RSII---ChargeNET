namespace ChargeNet.Model.Responses
{
    public class WalletTopUpResponse
    {
        public int TransactionId { get; set; }
        public string StripePaymentIntentId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
    }
}
