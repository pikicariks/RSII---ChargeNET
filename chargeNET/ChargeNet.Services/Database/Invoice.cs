using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Invoice : BaseEntity
    {
        [Required, StringLength(50)]
        public string InvoiceNumber { get; set; } = string.Empty; // Auto-generated: INV-{year}-{seq}

        [ForeignKey(nameof(Transaction))]
        public int TransactionId { get; set; }
        public virtual Transaction Transaction { get; set; } = null!;

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public DateTime InvoiceDate { get; set; } = DateTime.UtcNow;
        public DateTime DueDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        [Required, StringLength(3)]
        public string Currency { get; set; } = "EUR";

        [StringLength(500)]
        public string? PdfUrl { get; set; }

        [Required, StringLength(50)]
        public string Status { get; set; } = "Pending";
    }
}