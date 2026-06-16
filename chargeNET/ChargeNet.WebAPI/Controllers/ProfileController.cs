using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IUserService _userService;

        public ProfileController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var result = await _userService.GetById(GetCurrentUserId());
            return Ok(result);
        }

        [HttpPut("me")]
        public async Task<IActionResult> UpdateMe([FromBody] UserUpdateRequest request)
        {
            request.RoleId = null;
            var result = await _userService.Update(GetCurrentUserId(), request);
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
