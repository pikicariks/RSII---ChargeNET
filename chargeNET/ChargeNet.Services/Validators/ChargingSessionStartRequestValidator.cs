using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ChargingSessionStartRequestValidator : AbstractValidator<ChargingSessionStartRequest>
    {
        public ChargingSessionStartRequestValidator()
        {
            RuleFor(x => x.ConnectorId)
                .GreaterThan(0).WithMessage("ConnectorId must be greater than 0.");

            RuleFor(x => x.TariffId)
                .GreaterThan(0).WithMessage("TariffId must be greater than 0.");

            RuleFor(x => x.ReservationId)
                .GreaterThan(0)
                .When(x => x.ReservationId.HasValue);
        }
    }
}
