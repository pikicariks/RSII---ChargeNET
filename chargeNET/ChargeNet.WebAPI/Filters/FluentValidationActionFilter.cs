using FluentValidation;
using ValidationException = ChargeNet.Model.Exceptions.ValidationException;
using Microsoft.AspNetCore.Mvc.Filters;

namespace ChargeNet.WebAPI.Filters
{
    public class FluentValidationActionFilter : IAsyncActionFilter
    {
        private readonly IServiceProvider _serviceProvider;

        public FluentValidationActionFilter(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            foreach (var argument in context.ActionArguments.Values)
            {
                if (argument is null)
                {
                    continue;
                }

                var argumentType = argument.GetType();
                var validatorType = typeof(IValidator<>).MakeGenericType(argumentType);
                var validator = _serviceProvider.GetService(validatorType);

                if (validator is not IValidator validatorInstance)
                {
                    continue;
                }

                var validationContext = new ValidationContext<object>(argument);
                var result = await validatorInstance.ValidateAsync(validationContext, context.HttpContext.RequestAborted);

                if (!result.IsValid)
                {
                    throw new ValidationException(
                        "Validation failed.",
                        result.Errors.Select(e => e.ErrorMessage).ToList());
                }
            }

            await next();
        }
    }
}
