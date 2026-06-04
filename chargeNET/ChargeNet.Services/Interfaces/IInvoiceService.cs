using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IInvoiceService : IBaseReadService<InvoiceResponse, InvoiceSearchObject>
    {
        Task<InvoiceResponse?> CreateForTransactionAsync(int transactionId, CancellationToken cancellationToken = default);
    }
}
