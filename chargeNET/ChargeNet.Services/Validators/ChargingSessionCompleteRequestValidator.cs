using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ChargingSessionCompleteRequestValidator : AbstractValidator<ChargingSessionCompleteRequest>
    {
        public ChargingSessionCompleteRequestValidator()
        {
            RuleFor(x => x.EnergyConsumedKWh)
                .GreaterThan(0).WithMessage("EnergyConsumedKWh must be greater than 0.");
        }
    }
}
