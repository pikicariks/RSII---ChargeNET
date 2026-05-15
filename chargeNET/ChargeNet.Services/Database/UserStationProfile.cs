using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class UserStationProfile : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [ForeignKey(nameof(ChargingStation))]
        public int ChargingStationId { get; set; }
        public virtual ChargingStation ChargingStation { get; set; } = null!;

        public int VisitedCount { get; set; } = 0;

        [Column(TypeName = "decimal(2,1)")]
        public decimal? TotalRating { get; set; }                 // 0.0-5.0

        public DateTime? LastVisitedAt { get; set; }

        [StringLength(20)]
        public string? LikeStatus { get; set; }                   // Liked, Disliked, null
    }
}