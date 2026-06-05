using ChargeNet.Model.Responses;

namespace ChargeNet.Model.Messages
{
    public class NotificationPushMessage
    {
        public NotificationResponse Notification { get; set; } = new();
    }
}
