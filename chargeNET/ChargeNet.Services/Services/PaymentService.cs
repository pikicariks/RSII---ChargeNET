using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Payment;
using Microsoft.EntityFrameworkCore;
using Stripe;

namespace ChargeNet.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly ChargeNetDbContext _context;
        private readonly IWalletService _walletService;

        public PaymentService(ChargeNetDbContext context, IWalletService walletService)
        {
            _context = context;
            _walletService = walletService;
        }

        public async Task<WalletTopUpResponse> CreatePaymentIntent(decimal amount, string currency, int userId)
        {
            EnsureStripeConfigured();

            var normalizedCurrency = NormalizeCurrency(currency);
            var roundedAmount = Math.Round(amount, 2, MidpointRounding.AwayFromZero);

            if (roundedAmount < PaymentConstants.MinTopUpAmount || roundedAmount > PaymentConstants.MaxTopUpAmount)
            {
                throw new ValidationException(
                    $"Amount must be between {PaymentConstants.MinTopUpAmount} and {PaymentConstants.MaxTopUpAmount}.");
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);

            if (user == null)
            {
                throw new NotFoundException(nameof(User), userId);
            }

            var wallet = await _walletService.GetOrCreateWalletAsync(userId);
            var stripeCustomerId = await EnsureStripeCustomerAsync(user, wallet);

            var paymentIntentService = new PaymentIntentService();
            var paymentIntent = await paymentIntentService.CreateAsync(new PaymentIntentCreateOptions
            {
                Amount = ToStripeAmount(roundedAmount),
                Currency = normalizedCurrency,
                Customer = stripeCustomerId,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                },
                Metadata = new Dictionary<string, string>
                {
                    { "UserId", userId.ToString() },
                    { "Purpose", PaymentConstants.TransactionTypes.TopUp }
                }
            });

            var transaction = new Transaction
            {
                UserId = userId,
                Amount = roundedAmount,
                Currency = normalizedCurrency.ToUpperInvariant(),
                Type = PaymentConstants.TransactionTypes.TopUp,
                Status = PaymentConstants.TransactionStatuses.Pending,
                StripePaymentIntentId = paymentIntent.Id,
                CreatedAt = DateTime.UtcNow
            };

            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            return new WalletTopUpResponse
            {
                TransactionId = transaction.Id,
                StripePaymentIntentId = paymentIntent.Id,
                ClientSecret = paymentIntent.ClientSecret,
                Amount = roundedAmount,
                Currency = transaction.Currency,
                Status = transaction.Status
            };
        }

        public async Task ConfirmPayment(string paymentIntentId)
        {
            var transaction = await _context.Transactions
                .FirstOrDefaultAsync(t => t.StripePaymentIntentId == paymentIntentId);

            if (transaction == null)
            {
                throw new NotFoundException(nameof(Transaction), paymentIntentId);
            }

            if (transaction.Status == PaymentConstants.TransactionStatuses.Completed)
            {
                return;
            }

            if (transaction.Status == PaymentConstants.TransactionStatuses.Failed)
            {
                throw new BusinessException("Cannot confirm a failed payment.", 400);
            }

            if (transaction.Type != PaymentConstants.TransactionTypes.TopUp)
            {
                throw new BusinessException($"Unsupported transaction type '{transaction.Type}'.", 400);
            }

            var wallet = await _walletService.GetOrCreateWalletAsync(transaction.UserId);
            var now = DateTime.UtcNow;

            wallet.Balance += transaction.Amount;
            wallet.ModifiedAt = now;
            transaction.Status = PaymentConstants.TransactionStatuses.Completed;
            transaction.ModifiedAt = now;

            await _context.SaveChangesAsync();
        }

        public async Task MarkPaymentFailed(string paymentIntentId)
        {
            var transaction = await _context.Transactions
                .FirstOrDefaultAsync(t => t.StripePaymentIntentId == paymentIntentId);

            if (transaction == null)
            {
                throw new NotFoundException(nameof(Transaction), paymentIntentId);
            }

            if (transaction.Status == PaymentConstants.TransactionStatuses.Completed)
            {
                return;
            }

            if (transaction.Status == PaymentConstants.TransactionStatuses.Failed)
            {
                return;
            }

            transaction.Status = PaymentConstants.TransactionStatuses.Failed;
            transaction.ModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
        }

        public async Task ApplyChargingSessionPaymentAsync(
            int userId,
            int chargingSessionId,
            decimal amount,
            string currency)
        {
            var roundedAmount = Math.Round(amount, 2, MidpointRounding.AwayFromZero);
            if (roundedAmount <= 0)
            {
                throw new ValidationException("Session cost must be greater than zero.");
            }

            var alreadyPaid = await _context.Transactions.AnyAsync(transaction =>
                transaction.ChargingSessionId == chargingSessionId &&
                transaction.Type == PaymentConstants.TransactionTypes.Payment &&
                transaction.Status == PaymentConstants.TransactionStatuses.Completed);

            if (alreadyPaid)
            {
                return;
            }

            var wallet = await _walletService.GetOrCreateWalletAsync(userId);
            if (wallet.Balance < roundedAmount)
            {
                throw new BusinessException(
                    $"Insufficient wallet balance. Required: {roundedAmount:F2} {PaymentConstants.DefaultCurrency}, available: {wallet.Balance:F2} {PaymentConstants.DefaultCurrency}.",
                    402);
            }

            var normalizedCurrency = string.IsNullOrWhiteSpace(currency)
                ? PaymentConstants.DefaultCurrency
                : currency.Trim().ToUpperInvariant();

            var now = DateTime.UtcNow;
            wallet.Balance -= roundedAmount;
            wallet.ModifiedAt = now;

            _context.Transactions.Add(new Transaction
            {
                UserId = userId,
                ChargingSessionId = chargingSessionId,
                Amount = roundedAmount,
                Currency = normalizedCurrency,
                Type = PaymentConstants.TransactionTypes.Payment,
                Status = PaymentConstants.TransactionStatuses.Completed,
                CreatedAt = now
            });
        }

        public async Task<RefundResponse> RefundPayment(int transactionId, decimal? amount = null)
        {
            EnsureStripeConfigured();

            var original = await _context.Transactions
                .FirstOrDefaultAsync(transaction => transaction.Id == transactionId);

            if (original == null)
            {
                throw new NotFoundException(nameof(Transaction), transactionId);
            }

            if (original.Status != PaymentConstants.TransactionStatuses.Completed)
            {
                throw new BusinessException("Only completed transactions can be refunded.", 400);
            }

            if (original.Type != PaymentConstants.TransactionTypes.TopUp &&
                original.Type != PaymentConstants.TransactionTypes.Payment)
            {
                throw new BusinessException($"Transaction type '{original.Type}' cannot be refunded.", 400);
            }

            var alreadyRefunded = await _context.Transactions
                .Where(transaction =>
                    transaction.SourceTransactionId == transactionId &&
                    transaction.Type == PaymentConstants.TransactionTypes.Refund &&
                    transaction.Status == PaymentConstants.TransactionStatuses.Completed)
                .SumAsync(transaction => transaction.Amount);

            var remainingAmount = original.Amount - alreadyRefunded;
            if (remainingAmount <= 0)
            {
                throw new BusinessException("This transaction has already been fully refunded.", 409);
            }

            var refundAmount = amount.HasValue
                ? Math.Round(amount.Value, 2, MidpointRounding.AwayFromZero)
                : remainingAmount;

            if (refundAmount <= 0 || refundAmount > remainingAmount)
            {
                throw new ValidationException(
                    $"Refund amount must be between 0.01 and {remainingAmount:F2} {original.Currency}.");
            }

            var wallet = await _walletService.GetOrCreateWalletAsync(original.UserId);
            var now = DateTime.UtcNow;

            if (original.Type == PaymentConstants.TransactionTypes.TopUp)
            {
                if (string.IsNullOrWhiteSpace(original.StripePaymentIntentId))
                {
                    throw new BusinessException("Top-up transaction is missing Stripe payment intent.", 400);
                }

                if (wallet.Balance < refundAmount)
                {
                    throw new BusinessException(
                        $"Insufficient wallet balance to process refund. Required: {refundAmount:F2} {original.Currency}, available: {wallet.Balance:F2} {original.Currency}.",
                        402);
                }

                var refundService = new RefundService();
                await refundService.CreateAsync(new RefundCreateOptions
                {
                    PaymentIntent = original.StripePaymentIntentId,
                    Amount = refundAmount < remainingAmount ? ToStripeAmount(refundAmount) : null
                });

                wallet.Balance -= refundAmount;
            }
            else
            {
                wallet.Balance += refundAmount;
            }

            wallet.ModifiedAt = now;

            var refundTransaction = new Transaction
            {
                UserId = original.UserId,
                ChargingSessionId = original.ChargingSessionId,
                Amount = refundAmount,
                Currency = original.Currency,
                Type = PaymentConstants.TransactionTypes.Refund,
                Status = PaymentConstants.TransactionStatuses.Completed,
                SourceTransactionId = transactionId,
                CreatedAt = now
            };

            _context.Transactions.Add(refundTransaction);
            await _context.SaveChangesAsync();

            return new RefundResponse
            {
                RefundTransactionId = refundTransaction.Id,
                SourceTransactionId = transactionId,
                RefundedAmount = refundAmount,
                NewWalletBalance = wallet.Balance,
                Currency = original.Currency,
                Status = refundTransaction.Status
            };
        }

        private async Task<string> EnsureStripeCustomerAsync(User user, UserWallet wallet)
        {
            if (!string.IsNullOrWhiteSpace(wallet.StripeCustomerId))
            {
                return wallet.StripeCustomerId;
            }

            var customerService = new CustomerService();
            var customer = await customerService.CreateAsync(new CustomerCreateOptions
            {
                Email = user.Email,
                Name = $"{user.FirstName} {user.LastName}".Trim(),
                Metadata = new Dictionary<string, string>
                {
                    { "UserId", user.Id.ToString() }
                }
            });

            wallet.StripeCustomerId = customer.Id;
            wallet.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return customer.Id;
        }

        private static void EnsureStripeConfigured()
        {
            if (string.IsNullOrWhiteSpace(StripeConfiguration.ApiKey))
            {
                throw new BusinessException("Stripe is not configured.", 503);
            }
        }

        private static string NormalizeCurrency(string currency)
        {
            if (string.IsNullOrWhiteSpace(currency))
            {
                return PaymentConstants.DefaultCurrency.ToLowerInvariant();
            }

            return currency.Trim().ToLowerInvariant();
        }

        private static long ToStripeAmount(decimal amount)
        {
            return (long)Math.Round(amount * 100m, MidpointRounding.AwayFromZero);
        }
    }
}
