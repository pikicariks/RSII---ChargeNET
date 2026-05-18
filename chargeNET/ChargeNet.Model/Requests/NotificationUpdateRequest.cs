namespace ChargeNet.Model.Requests
{
    public class NotificationUpdateRequest
    {
        public string? Title { get; set; }
        public string? Message { get; set; }
        public string? NotificationType { get; set; }
        public bool? IsRead { get; set; }
        public string? RelatedEntityType { get; set; }
        public bool ClearRelatedEntityType { get; set; }
        public int? RelatedEntityId { get; set; }
        public bool ClearRelatedEntityId { get; set; }
    }
}
