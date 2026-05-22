using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ReservationInsertRequestValidator : AbstractValidator<ReservationInsertRequest>
    {
        private static readonly TimeSpan MaxDuration = TimeSpan.FromHours(24);

        public ReservationInsertRequestValidator()
        {
            RuleFor(x => x.ChargingStationId)
                .GreaterThan(0).WithMessage("ChargingStationId must be greater than 0.");

            RuleFor(x => x.ConnectorId)
                .GreaterThan(0)
                .When(x => x.ConnectorId.HasValue);

            RuleFor(x => x.ReservationStart)
                .Must(start => start > DateTime.UtcNow)
                .WithMessage("ReservationStart must be in the future.");

            RuleFor(x => x.ReservationEnd)
                .GreaterThan(x => x.ReservationStart)
                .WithMessage("ReservationEnd must be after ReservationStart.");

            RuleFor(x => x)
                .Must(x => x.ReservationEnd - x.ReservationStart <= MaxDuration)
                .WithMessage("Reservation duration must not exceed 24 hours.");
        }
    }
}
