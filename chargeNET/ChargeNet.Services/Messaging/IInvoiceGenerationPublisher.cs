using ChargeNet.Model.Messages;

namespace ChargeNet.Services.Messaging
{
    public interface IInvoiceGenerationPublisher
    {
        Task PublishAsync(InvoiceGenerationMessage message, CancellationToken cancellationToken = default);
    }
}
