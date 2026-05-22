using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class TariffInsertRequestValidator : AbstractValidator<TariffInsertRequest>
    {
        public TariffInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Name is required.")
                .MaximumLength(100);

            RuleFor(x => x.PricePerKWh)
                .GreaterThan(0).WithMessage("PricePerKWh must be greater than 0.");

            RuleFor(x => x.PricePerMinute)
                .GreaterThan(0)
                .When(x => x.PricePerMinute.HasValue);

            RuleFor(x => x.Currency)
                .NotEmpty()
                .Length(3).WithMessage("Currency must be a 3-letter code.");
        }
    }
}
