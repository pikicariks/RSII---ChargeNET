using ChargeNet.Model.Responses;

namespace ChargeNet.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<WalletTopUpResponse> CreatePaymentIntent(decimal amount, string currency, int userId);
        Task<WalletTopUpResponse> SyncTopUpPayment(int transactionId, int userId);
        Task ConfirmPayment(string paymentIntentId);
        Task MarkPaymentFailed(string paymentIntentId);
        Task ApplyChargingSessionPaymentAsync(int userId, int chargingSessionId, decimal amount, string currency);
        Task<RefundResponse> RefundPayment(int transactionId, decimal? amount = null);
    }
}
