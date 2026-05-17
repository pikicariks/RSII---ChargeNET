using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public abstract class BaseController<TResponse, TSearch> : ControllerBase
        where TResponse : class
        where TSearch : class
    {
        protected readonly IBaseReadService<TResponse, TSearch> _service;

        protected BaseController(IBaseReadService<TResponse, TSearch> service)
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
