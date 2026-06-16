using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Payment;
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
        private readonly ITransactionService _transactionService;

        public WalletController(
            IWalletService walletService,
            IPaymentService paymentService,
            ITransactionService transactionService)
        {
            _walletService = walletService;
            _paymentService = paymentService;
            _transactionService = transactionService;
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

        [HttpGet("transactions")]
        public async Task<IActionResult> GetTransactions()
        {
            var search = new TransactionSearchObject
            {
                UserId = GetCurrentUserId()
            };

            var transactions = await _transactionService.Get(search);
            var walletTypes = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                PaymentConstants.TransactionTypes.TopUp,
                PaymentConstants.TransactionTypes.Payment,
                PaymentConstants.TransactionTypes.Refund
            };

            var result = transactions.Items
                .Where(transaction => walletTypes.Contains(transaction.Type))
                .OrderByDescending(transaction => transaction.CreatedAt)
                .ToList();

            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("refund")]
        public async Task<IActionResult> Refund([FromBody] RefundPaymentRequest request)
        {
            var result = await _paymentService.RefundPayment(request.TransactionId, request.Amount);
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
