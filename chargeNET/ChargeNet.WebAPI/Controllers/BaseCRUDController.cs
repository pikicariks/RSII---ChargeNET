using ChargeNet.Services.Interfaces;
using ChargeNet.Model.SearchObjects;
using Microsoft.AspNetCore.Mvc;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public abstract class BaseCRUDController<TResponse, TSearch, TInsert, TUpdate> : BaseController<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        protected readonly IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> _crudService;

        protected BaseCRUDController(IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> service)
            : base(service)
        {
            _crudService = service;
        }

        [HttpPost]
        public virtual async Task<IActionResult> Insert([FromBody] TInsert request)
        {
            var result = await _crudService.Insert(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(int id, [FromBody] TUpdate request)
        {
            var result = await _crudService.Update(id, request);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            await _crudService.Delete(id);
            return NoContent();
        }
    }
}
