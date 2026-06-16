using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> : IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        Task<TResponse> Insert(TInsert request);
        Task<TResponse> Update(int id, TUpdate request);
        Task Delete(int id);
    }
}
