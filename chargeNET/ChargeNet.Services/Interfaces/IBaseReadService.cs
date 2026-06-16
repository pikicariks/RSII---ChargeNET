using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        Task<PagedResult<TResponse>> Get(TSearch? search = null);
        Task<TResponse> GetById(int id);
    }
}
