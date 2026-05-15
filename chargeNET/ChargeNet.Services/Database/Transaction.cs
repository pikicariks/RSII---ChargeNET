using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Transaction : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [ForeignKey(nameof(ChargingSession))]
        public int? ChargingSessionId { get; set; }
        public virtual ChargingSession? ChargingSession { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [Required, StringLength(3)]
        public string Currency { get; set; } = "EUR";

        [Required, StringLength(50)]
        public string Type { get; set; } = string.Empty;          // Payment, Refund, TopUp

        [Required, StringLength(50)]
        public string Status { get; set; } = string.Empty;        // Pending, Completed, Failed

        [StringLength(100)]
        public string? StripePaymentIntentId { get; set; }

        // Navigation
        public virtual Invoice? Invoice { get; set; }
    }
}