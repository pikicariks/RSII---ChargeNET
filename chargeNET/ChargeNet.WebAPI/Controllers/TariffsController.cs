using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.WebAPI.Controllers;

namespace ChargeNet.WebAPI.Controllers
{
    public class TariffsController : BaseController<Tariff, object>
    {
        public TariffsController(IBaseReadService<Tariff, object> service) : base(service) { }
    }
}
