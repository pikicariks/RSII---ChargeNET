using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [Authorize]
    public class VehiclesController : BaseCRUDController<VehicleResponse, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        public VehiclesController(IVehicleService service) : base(service)
        {
        }

        [HttpGet]
        public override Task<IActionResult> Get([FromQuery] VehicleSearchObject? search)
        {
            if (!User.IsInRole("Admin"))
            {
                search ??= new VehicleSearchObject();
                search.UserId = GetCurrentUserId();
            }

            return base.Get(search);
        }

        [HttpGet("{id}")]
        public override async Task<IActionResult> GetById(int id)
        {
            var result = (await _service.GetById(id)) as VehicleResponse;
            EnsureOwnership(result!.UserId);
            return Ok(result);
        }

        [HttpPost]
        public override Task<IActionResult> Insert([FromBody] VehicleInsertRequest request)
        {
            if (!User.IsInRole("Admin") || !request.UserId.HasValue)
            {
                request.UserId = GetCurrentUserId();
            }

            return base.Insert(request);
        }

        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] VehicleUpdateRequest request)
        {
            var existing = (await _service.GetById(id)) as VehicleResponse;
            EnsureOwnership(existing!.UserId);
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            var existing = (await _service.GetById(id)) as VehicleResponse;
            EnsureOwnership(existing!.UserId);
            return await base.Delete(id);
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
