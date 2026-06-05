using ChargeNet.Model.Messages;

namespace ChargeNet.Services.Messaging
{
    public interface INotificationPushPublisher
    {
        Task PublishAsync(NotificationPushMessage message, CancellationToken cancellationToken = default);
    }
}
