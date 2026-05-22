using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ReservationUpdateRequestValidator : AbstractValidator<ReservationUpdateRequest>
    {
        private static readonly TimeSpan MaxDuration = TimeSpan.FromHours(24);

        public ReservationUpdateRequestValidator()
        {
            RuleFor(x => x.ChargingStationId)
                .GreaterThan(0)
                .When(x => x.ChargingStationId.HasValue);

            RuleFor(x => x.ConnectorId)
                .GreaterThan(0)
                .When(x => x.ConnectorId.HasValue);

            RuleFor(x => x)
                .Must(x =>
                {
                    if (!x.ReservationStart.HasValue || !x.ReservationEnd.HasValue)
                    {
                        return true;
                    }

                    return x.ReservationEnd > x.ReservationStart;
                })
                .WithMessage("ReservationEnd must be after ReservationStart.");

            RuleFor(x => x)
                .Must(x =>
                {
                    if (!x.ReservationStart.HasValue || !x.ReservationEnd.HasValue)
                    {
                        return true;
                    }

                    return x.ReservationEnd.Value - x.ReservationStart.Value <= MaxDuration;
                })
                .WithMessage("Reservation duration must not exceed 24 hours.");
        }
    }
}
