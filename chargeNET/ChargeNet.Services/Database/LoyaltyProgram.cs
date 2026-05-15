using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class LoyaltyProgram : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public int Points { get; set; } = 0;

        [StringLength(50)]
        public string? Tier { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal TotalChargedKWh { get; set; } = 0;
    }
}