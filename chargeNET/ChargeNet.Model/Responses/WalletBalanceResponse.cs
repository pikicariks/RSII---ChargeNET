namespace ChargeNet.Model.Responses
{
    public class WalletBalanceResponse
    {
        public int UserId { get; set; }
        public decimal Balance { get; set; }
        public string Currency { get; set; } = "EUR";
    }
}
