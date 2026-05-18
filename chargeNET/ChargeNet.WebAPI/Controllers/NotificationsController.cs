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
    public class NotificationsController :
        BaseCRUDController<NotificationResponse, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        private readonly INotificationService _notificationService;

        public NotificationsController(INotificationService service) : base(service)
        {
            _notificationService = service;
        }

        [HttpGet]
        public override Task<IActionResult> Get([FromQuery] NotificationSearchObject? search)
        {
            if (!User.IsInRole("Admin"))
            {
                search ??= new NotificationSearchObject();
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

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override Task<IActionResult> Insert([FromBody] NotificationInsertRequest request)
        {
            return base.Insert(request);
        }

        [HttpPut("{id}")]
        public override async Task<IActionResult> Update(int id, [FromBody] NotificationUpdateRequest request)
        {
            var existing = await _service.GetById(id);
            EnsureOwnership(existing.UserId);
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            var existing = await _service.GetById(id);
            EnsureOwnership(existing.UserId);
            return await base.Delete(id);
        }

        [HttpPatch("{id}/mark-read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var existing = await _service.GetById(id);
            EnsureOwnership(existing.UserId);

            var result = await _notificationService.MarkAsRead(id);
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
