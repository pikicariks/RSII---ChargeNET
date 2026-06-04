namespace ChargeNet.Model.Requests
{
    public class RefundPaymentRequest
    {
        public int TransactionId { get; set; }
        public decimal? Amount { get; set; }
    }
}
