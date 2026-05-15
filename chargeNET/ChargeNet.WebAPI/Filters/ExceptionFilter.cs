using System.Net;
using System.Text.Json;
using ChargeNet.Model.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace ChargeNet.WebAPI.Filters
{
    public class ExceptionFilter : IExceptionFilter
    {
        private readonly ILogger<ExceptionFilter> _logger;

        public ExceptionFilter(ILogger<ExceptionFilter> logger)
        {
            _logger = logger;
        }

        public void OnException(ExceptionContext context)
        {
            HttpStatusCode statusCode;
            string message;
            List<string>? errors = null;

            switch (context.Exception)
            {
                case NotFoundException notFound:
                    statusCode = HttpStatusCode.NotFound;
                    message = notFound.Message;
                    break;

                case BusinessException business:
                    statusCode = (HttpStatusCode)business.StatusCode;
                    message = business.Message;
                    break;

                case ValidationException validation:
                    statusCode = HttpStatusCode.BadRequest;
                    message = validation.Message;
                    errors = validation.Errors;
                    break;

                case UnauthorizedAccessException:
                    statusCode = HttpStatusCode.Unauthorized;
                    message = "Unauthorized.";
                    break;

                default:
                    statusCode = HttpStatusCode.InternalServerError;
                    message = "An unexpected error occurred.";
                    _logger.LogError(context.Exception, "Unhandled exception: {Message}", context.Exception.Message);
                    break;
            }

            var response = new
            {
                message,
                errors
            };

            context.HttpContext.Response.ContentType = "application/json";
            context.HttpContext.Response.StatusCode = (int)statusCode;
            context.Result = new JsonResult(response);
            context.ExceptionHandled = true;
        }
    }
}
