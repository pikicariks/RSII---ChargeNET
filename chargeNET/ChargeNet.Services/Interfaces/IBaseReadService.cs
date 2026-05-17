namespace ChargeNet.Services.Interfaces
{
    public interface IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TSearch : class
    {
        Task<IEnumerable<TResponse>> Get(TSearch? search = null);
        Task<TResponse> GetById(int id);
    }
}
