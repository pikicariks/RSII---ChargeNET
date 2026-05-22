using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class VehicleInsertRequestValidator : AbstractValidator<VehicleInsertRequest>
    {
        public VehicleInsertRequestValidator()
        {
            RuleFor(x => x.Make)
                .NotEmpty().WithMessage("Make is required.")
                .MaximumLength(50);

            RuleFor(x => x.Model)
                .NotEmpty().WithMessage("Model is required.")
                .MaximumLength(50);

            RuleFor(x => x.Year)
                .GreaterThanOrEqualTo(2000)
                .When(x => x.Year.HasValue);

            RuleFor(x => x.LicensePlate)
                .MaximumLength(20)
                .Matches(@"^[A-Za-z0-9\-\s]+$")
                .WithMessage("LicensePlate contains invalid characters.")
                .When(x => !string.IsNullOrWhiteSpace(x.LicensePlate));

            RuleFor(x => x.BatteryCapacity)
                .GreaterThan(0)
                .When(x => x.BatteryCapacity.HasValue);

            RuleFor(x => x.ConnectorTypeId)
                .GreaterThan(0)
                .When(x => x.ConnectorTypeId.HasValue);
        }
    }
}
