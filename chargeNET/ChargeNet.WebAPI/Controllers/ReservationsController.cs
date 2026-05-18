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
    public class ReservationsController : ControllerBase
    {
        private readonly IReservationService _reservationService;

        public ReservationsController(IReservationService reservationService)
        {
            _reservationService = reservationService;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] ReservationSearchObject? search)
        {
            if (!User.IsInRole("Admin"))
            {
                search ??= new ReservationSearchObject();
                search.UserId = GetCurrentUserId();
            }

            var result = await _reservationService.Get(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _reservationService.GetById(id);
            EnsureOwnership(result.UserId);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Insert([FromBody] ReservationInsertRequest request)
        {
            if (!User.IsInRole("Admin") || !request.UserId.HasValue)
            {
                request.UserId = GetCurrentUserId();
            }

            var result = await _reservationService.Insert(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ReservationUpdateRequest request)
        {
            var existing = await _reservationService.GetById(id);
            EnsureOwnership(existing.UserId);

            var result = await _reservationService.Update(id, request);
            return Ok(result);
        }

        [HttpPost("{id}/cancel")]
        public async Task<IActionResult> Cancel(int id)
        {
            var existing = await _reservationService.GetById(id);
            EnsureOwnership(existing.UserId);

            var result = await _reservationService.Cancel(id);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _reservationService.Delete(id);
            return NoContent();
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
