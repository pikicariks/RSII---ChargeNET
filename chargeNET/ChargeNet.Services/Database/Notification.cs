using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Notification : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [Required, StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required, StringLength(1000)]
        public string Message { get; set; } = string.Empty;

        [Required, StringLength(50)]
        public string NotificationType { get; set; } = string.Empty;

        public bool IsRead { get; set; } = false;

        [StringLength(50)]
        public string? RelatedEntityType { get; set; }

        public int? RelatedEntityId { get; set; }
    }
}