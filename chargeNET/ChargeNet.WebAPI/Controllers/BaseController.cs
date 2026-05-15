using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public abstract class BaseController<T, TSearch> : ControllerBase
        where T : class
        where TSearch : class
    {
        protected readonly IBaseReadService<T, TSearch> _service;

        protected BaseController(IBaseReadService<T, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual async Task<IActionResult> Get([FromQuery] TSearch? search)
        {
            var result = await _service.Get(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById(int id)
        {
            var result = await _service.GetById(id);
            return Ok(result);
        }
    }
}
