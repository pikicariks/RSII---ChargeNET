using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [Authorize]
    public class TransactionsController : BaseController<TransactionResponse, TransactionSearchObject>
    {
        public TransactionsController(ITransactionService service) : base(service)
        {
        }

        [HttpGet]
        public override Task<IActionResult> Get([FromQuery] TransactionSearchObject? search)
        {
            if (!User.IsInRole("Admin"))
            {
                search ??= new TransactionSearchObject();
                search.UserId = GetCurrentUserId();
            }

            return base.Get(search);
        }

        [HttpGet("{id}")]
        public override async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id);
            EnsureOwnership(result.UserId);
            return Ok(result);
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
            {
                throw new UnauthorizedAccessException();
            }

            return userId;
        }

        private void EnsureOwnership(int resourceUserId)
        {
            if (!User.IsInRole("Admin") && resourceUserId != GetCurrentUserId())
            {
                throw new BusinessException("You are not allowed to access this resource.", 403);
            }
        }
    }
}
