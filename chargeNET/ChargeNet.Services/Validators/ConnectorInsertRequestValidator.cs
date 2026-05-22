using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ConnectorInsertRequestValidator : AbstractValidator<ConnectorInsertRequest>
    {
        public ConnectorInsertRequestValidator()
        {
            RuleFor(x => x.ChargingStationId)
                .GreaterThan(0).WithMessage("ChargingStationId must be greater than 0.");

            RuleFor(x => x.ConnectorTypeId)
                .GreaterThan(0).WithMessage("ConnectorTypeId must be greater than 0.");

            RuleFor(x => x.PowerKW)
                .GreaterThan(0).WithMessage("PowerKW must be greater than 0.");

            RuleFor(x => x.Label)
                .MaximumLength(50)
                .When(x => !string.IsNullOrWhiteSpace(x.Label));
        }
    }
}
