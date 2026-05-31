using System.Security.Claims;
using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Recommendation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RecommendationsController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;

        public RecommendationsController(IRecommendationService recommendationService)
        {
            _recommendationService = recommendationService;
        }

        [HttpGet]
        public async Task<IActionResult> Get(
            [FromQuery] double lat,
            [FromQuery] double lng,
            [FromQuery] int topN = 10)
        {
            var result = await _recommendationService.GetRecommendationsAsync(
                GetCurrentUserId(),
                lat,
                lng,
                topN);

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
