using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;

namespace ChargeNet.Services.Interfaces
{
    public interface IWalletService
    {
        Task<WalletBalanceResponse> GetBalanceAsync(int userId);
        Task<UserWallet> GetOrCreateWalletAsync(int userId);
    }
}
