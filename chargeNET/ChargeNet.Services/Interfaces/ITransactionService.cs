using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface ITransactionService : IBaseReadService<TransactionResponse, TransactionSearchObject>
    {
    }
}
