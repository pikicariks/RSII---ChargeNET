namespace ChargeNet.Services.Interfaces
{
    public interface IBaseCRUDService<T, TInsert, TUpdate> : IBaseReadService<T, object>
        where T : class
    {
        Task<T> Insert(TInsert request);
        Task<T> Update(int id, TUpdate request);
        Task Delete(int id);
    }
}
