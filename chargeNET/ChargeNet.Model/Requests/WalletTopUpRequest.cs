namespace ChargeNet.Model.Requests
{
    public class WalletTopUpRequest
    {
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EUR";
    }
}
