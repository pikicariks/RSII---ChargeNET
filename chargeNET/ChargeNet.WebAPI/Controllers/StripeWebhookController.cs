using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/stripe")]
    public class StripeWebhookController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<StripeWebhookController> _logger;

        public StripeWebhookController(
            IPaymentService paymentService,
            IConfiguration configuration,
            ILogger<StripeWebhookController> logger)
        {
            _paymentService = paymentService;
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost("webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> Webhook(CancellationToken cancellationToken)
        {
            var webhookSecret = _configuration["Stripe:WebhookSecret"];
            if (string.IsNullOrWhiteSpace(webhookSecret))
            {
                _logger.LogError("Stripe webhook secret is not configured.");
                return StatusCode(StatusCodes.Status503ServiceUnavailable);
            }

            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync(cancellationToken);
            var signatureHeader = Request.Headers["Stripe-Signature"].ToString();

            Event stripeEvent;
            try
            {
                stripeEvent = EventUtility.ConstructEvent(json, signatureHeader, webhookSecret);
            }
            catch (StripeException ex)
            {
                _logger.LogWarning(ex, "Stripe webhook signature verification failed.");
                return BadRequest(new { message = "Invalid Stripe webhook signature." });
            }

            try
            {
                switch (stripeEvent.Type)
                {
                    case EventTypes.PaymentIntentSucceeded:
                        if (stripeEvent.Data.Object is PaymentIntent paymentIntent)
                        {
                            await _paymentService.ConfirmPayment(paymentIntent.Id);
                            _logger.LogInformation(
                                "Confirmed payment for PaymentIntent {PaymentIntentId}.",
                                paymentIntent.Id);
                        }
                        break;

                    case EventTypes.PaymentIntentPaymentFailed:
                        if (stripeEvent.Data.Object is PaymentIntent failedIntent)
                        {
                            await _paymentService.MarkPaymentFailed(failedIntent.Id);
                            _logger.LogInformation(
                                "Marked payment failed for PaymentIntent {PaymentIntentId}.",
                                failedIntent.Id);
                        }
                        break;

                    default:
                        _logger.LogDebug("Unhandled Stripe event type: {EventType}", stripeEvent.Type);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing Stripe webhook event {EventType}.", stripeEvent.Type);
                return StatusCode(StatusCodes.Status500InternalServerError);
            }

            return Ok();
        }
    }
}
