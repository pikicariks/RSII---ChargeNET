using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class ReservationRejectRequestValidator : AbstractValidator<ReservationRejectRequest>
    {
        public ReservationRejectRequestValidator()
        {
            RuleFor(x => x.Reason)
                .NotEmpty().WithMessage("Rejection reason is required.")
                .MaximumLength(500);
        }
    }
}
