using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ChargingSessionsController : ControllerBase
    {
        private readonly IChargingSessionService _chargingSessionService;

        public ChargingSessionsController(IChargingSessionService chargingSessionService)
        {
            _chargingSessionService = chargingSessionService;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] ChargingSessionSearchObject? search)
        {
            if (!User.IsInRole("Admin"))
            {
                search ??= new ChargingSessionSearchObject();
                search.UserId = GetCurrentUserId();
            }

            var result = await _chargingSessionService.Get(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _chargingSessionService.GetById(id);
            EnsureOwnership(result.UserId);
            return Ok(result);
        }

        [HttpPost("start")]
        public async Task<IActionResult> Start([FromBody] ChargingSessionStartRequest request)
        {
            if (!User.IsInRole("Admin") || !request.UserId.HasValue)
            {
                request.UserId = GetCurrentUserId();
            }

            var result = await _chargingSessionService.Start(request);
            return Ok(result);
        }

        [HttpPost("{id}/complete")]
        public async Task<IActionResult> Complete(int id, [FromBody] ChargingSessionCompleteRequest request)
        {
            var existing = await _chargingSessionService.GetById(id);
            EnsureOwnership(existing.UserId);

            var result = await _chargingSessionService.Complete(id, request);
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
