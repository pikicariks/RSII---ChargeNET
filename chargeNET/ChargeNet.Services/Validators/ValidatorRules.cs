using ChargeNet.Model.Validation;
using FluentValidation;

namespace ChargeNet.Services.Validators
{
    internal static class ValidatorRules
    {
        public static IRuleBuilderOptions<T, string> ValidChargeNetEmail<T>(this IRuleBuilder<T, string> ruleBuilder)
        {
            return ruleBuilder
                .Must(email => EmailValidation.TryNormalizeAndValidate(email, out _, out _))
                .WithMessage("Email format is invalid.");
        }

        public static IRuleBuilderOptions<T, string?> ValidChargeNetEmailWhenPresent<T>(this IRuleBuilder<T, string?> ruleBuilder)
        {
            return ruleBuilder
                .Must(email => string.IsNullOrWhiteSpace(email) ||
                               EmailValidation.TryNormalizeAndValidate(email, out _, out _))
                .WithMessage("Email format is invalid.");
        }
    }
}
