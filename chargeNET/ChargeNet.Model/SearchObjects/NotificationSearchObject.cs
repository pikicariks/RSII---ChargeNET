namespace ChargeNet.Model.SearchObjects
{
    public class NotificationSearchObject
    {
        public int? UserId { get; set; }
        public bool? IsRead { get; set; }
        public string? NotificationType { get; set; }
        public string? FullText { get; set; }
    }
}
