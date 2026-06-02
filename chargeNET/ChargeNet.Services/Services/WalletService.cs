using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Payment;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class WalletService : IWalletService
    {
        private readonly ChargeNetDbContext _context;

        public WalletService(ChargeNetDbContext context)
        {
            _context = context;
        }

        public async Task<WalletBalanceResponse> GetBalanceAsync(int userId)
        {
            var wallet = await GetOrCreateWalletAsync(userId);

            return new WalletBalanceResponse
            {
                UserId = userId,
                Balance = wallet.Balance,
                Currency = PaymentConstants.DefaultCurrency
            };
        }

        public async Task<UserWallet> GetOrCreateWalletAsync(int userId)
        {
            var userExists = await _context.Users.AnyAsync(user => user.Id == userId && !user.IsDeleted);
            if (!userExists)
            {
                throw new NotFoundException(nameof(User), userId);
            }

            var wallet = await _context.UserWallets.FirstOrDefaultAsync(w => w.UserId == userId);
            if (wallet != null)
            {
                return wallet;
            }

            wallet = new UserWallet
            {
                UserId = userId,
                Balance = 0m,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserWallets.Add(wallet);
            await _context.SaveChangesAsync();

            return wallet;
        }
    }
}
