using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class WalletController : ControllerBase
    {
        private readonly IWalletService _walletService;
        private readonly IPaymentService _paymentService;

        public WalletController(IWalletService walletService, IPaymentService paymentService)
        {
            _walletService = walletService;
            _paymentService = paymentService;
        }

        [HttpGet("balance")]
        public async Task<IActionResult> GetBalance()
        {
            var result = await _walletService.GetBalanceAsync(GetCurrentUserId());
            return Ok(result);
        }

        [HttpPost("topup")]
        public async Task<IActionResult> TopUp([FromBody] WalletTopUpRequest request)
        {
            var result = await _paymentService.CreatePaymentIntent(
                request.Amount,
                request.Currency,
                GetCurrentUserId());

            return Ok(result);
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
            {
                throw new BusinessException("User identity is invalid.", 401);
            }

            return userId;
        }
    }
}
