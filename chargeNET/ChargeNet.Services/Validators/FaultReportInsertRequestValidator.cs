using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class FaultReportInsertRequestValidator : AbstractValidator<FaultReportInsertRequest>
    {
        public FaultReportInsertRequestValidator()
        {
            RuleFor(x => x.ChargingStationId)
                .GreaterThan(0).WithMessage("ChargingStationId must be greater than 0.");

            RuleFor(x => x.ConnectorId)
                .GreaterThan(0)
                .When(x => x.ConnectorId.HasValue);

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .MaximumLength(1000);
        }
    }
}
