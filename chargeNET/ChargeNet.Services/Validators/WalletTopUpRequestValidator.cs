using ChargeNet.Model.Requests;
using ChargeNet.Services.Payment;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class WalletTopUpRequestValidator : AbstractValidator<WalletTopUpRequest>
    {
        public WalletTopUpRequestValidator()
        {
            RuleFor(x => x.Amount)
                .InclusiveBetween(PaymentConstants.MinTopUpAmount, PaymentConstants.MaxTopUpAmount)
                .WithMessage($"Amount must be between {PaymentConstants.MinTopUpAmount} and {PaymentConstants.MaxTopUpAmount}.");

            RuleFor(x => x.Currency)
                .NotEmpty()
                .Length(3)
                .WithMessage("Currency must be a 3-letter ISO code.");
        }
    }
}
