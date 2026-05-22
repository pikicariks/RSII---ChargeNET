using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ChargingStationInsertRequestValidator : AbstractValidator<ChargingStationInsertRequest>
    {
        public ChargingStationInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Name is required.")
                .MaximumLength(100);

            RuleFor(x => x.Address)
                .NotEmpty().WithMessage("Address is required.")
                .MaximumLength(200);

            RuleFor(x => x.CityId)
                .GreaterThan(0).WithMessage("CityId must be greater than 0.");

            RuleFor(x => x.StatusId)
                .GreaterThan(0).WithMessage("StatusId must be greater than 0.");

            RuleFor(x => x.Latitude)
                .InclusiveBetween(-90m, 90m)
                .When(x => x.Latitude.HasValue);

            RuleFor(x => x.Longitude)
                .InclusiveBetween(-180m, 180m)
                .When(x => x.Longitude.HasValue);

            RuleFor(x => x.Rating)
                .InclusiveBetween(0m, 5m)
                .When(x => x.Rating.HasValue);
        }
    }
}
