using ChargeNet.Model.Requests;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    public class UserUpdateRequestValidator : AbstractValidator<UserUpdateRequest>
    {
        public UserUpdateRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .MaximumLength(50)
                .When(x => !string.IsNullOrWhiteSpace(x.FirstName));

            RuleFor(x => x.LastName)
                .MaximumLength(50)
                .When(x => !string.IsNullOrWhiteSpace(x.LastName));

            RuleFor(x => x.Email)
                .ValidChargeNetEmailWhenPresent();

            RuleFor(x => x.Password)
                .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
                .When(x => !string.IsNullOrWhiteSpace(x.Password));

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(20)
                .When(x => x.PhoneNumber != null);

            RuleFor(x => x.Address)
                .MaximumLength(200)
                .When(x => x.Address != null);
        }
    }
}
