using ChargeNet.Model.Responses;

namespace ChargeNet.Services.Interfaces
{
    public interface INotificationPushService
    {
        Task PushToUserAsync(int userId, NotificationResponse notification, CancellationToken cancellationToken = default);

        Task PushToAllAsync(string title, string message, CancellationToken cancellationToken = default);
    }
}
