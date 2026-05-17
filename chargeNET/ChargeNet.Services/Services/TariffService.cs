using AutoMapper;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;

namespace ChargeNet.Services.Services
{
    public class TariffService : BaseReadService<Tariff, Tariff, object>, ITariffService
    {
        public TariffService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
