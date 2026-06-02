using ChargeNet.Model.Responses;

namespace ChargeNet.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<WalletTopUpResponse> CreatePaymentIntent(decimal amount, string currency, int userId);
        Task ConfirmPayment(string paymentIntentId);
        Task MarkPaymentFailed(string paymentIntentId);
    }
}
