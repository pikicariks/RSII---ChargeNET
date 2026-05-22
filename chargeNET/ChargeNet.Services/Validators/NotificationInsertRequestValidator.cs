using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class NotificationInsertRequestValidator : AbstractValidator<NotificationInsertRequest>
    {
        public NotificationInsertRequestValidator()
        {
            RuleFor(x => x.UserId)
                .GreaterThan(0).WithMessage("UserId must be greater than 0.");

            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Title is required.")
                .MaximumLength(200);

            RuleFor(x => x.Message)
                .NotEmpty().WithMessage("Message is required.")
                .MaximumLength(1000);

            RuleFor(x => x.NotificationType)
                .NotEmpty().WithMessage("NotificationType is required.")
                .MaximumLength(50);

            RuleFor(x => x.RelatedEntityType)
                .MaximumLength(50)
                .When(x => !string.IsNullOrWhiteSpace(x.RelatedEntityType));
        }
    }
}
