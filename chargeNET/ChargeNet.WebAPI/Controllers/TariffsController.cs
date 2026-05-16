using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace ChargeNet.WebAPI.Controllers
{
    [Authorize]
    public class TariffsController : BaseController<Tariff, object>
    {
        public TariffsController(IBaseReadService<Tariff, object> service) : base(service) { }
    }
}
