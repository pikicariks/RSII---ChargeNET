namespace ChargeNet.Services.Interfaces
{
    public interface IBaseReadService<T, TSearch> where T : class where TSearch : class
    {
        Task<IEnumerable<T>> Get(TSearch? search = null);
        Task<T> GetById(int id);
    }
}
