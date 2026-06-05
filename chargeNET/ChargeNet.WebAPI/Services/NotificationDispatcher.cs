using ChargeNet.Model.Responses;
using ChargeNet.Services.Interfaces;
using ChargeNet.WebAPI.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace ChargeNet.WebAPI.Services
{
    public class NotificationDispatcher : INotificationPushService
    {
        public const string ReceiveNotificationMethod = "ReceiveNotification";
        public const string SystemAnnouncementMethod = "SystemAnnouncement";

        private readonly IHubContext<NotificationHub> _hubContext;

        public NotificationDispatcher(IHubContext<NotificationHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public Task PushToUserAsync(int userId, NotificationResponse notification, CancellationToken cancellationToken = default)
        {
            return _hubContext.Clients
                .Group($"user:{userId}")
                .SendAsync(ReceiveNotificationMethod, notification, cancellationToken);
        }

        public Task PushToAllAsync(string title, string message, CancellationToken cancellationToken = default)
        {
            return _hubContext.Clients.All.SendAsync(
                SystemAnnouncementMethod,
                new { title, message },
                cancellationToken);
        }
    }
}
