using ChargeNet.Model.Responses;
using ChargeNet.Services.Interfaces;

namespace ChargeNet.Services.Services
{
    public class NullNotificationPushService : INotificationPushService
    {
        public Task PushToAllAsync(string title, string message, CancellationToken cancellationToken = default) =>
            Task.CompletedTask;

        public Task PushToUserAsync(int userId, NotificationResponse notification, CancellationToken cancellationToken = default) =>
            Task.CompletedTask;
    }
}
