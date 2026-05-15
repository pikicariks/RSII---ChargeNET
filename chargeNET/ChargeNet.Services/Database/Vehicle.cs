using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Vehicle : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [Required, StringLength(50)]
        public string Make { get; set; } = string.Empty;

        [Required, StringLength(50)]
        public string Model { get; set; } = string.Empty;

        public int? Year { get; set; }

        [StringLength(20)]
        public string? LicensePlate { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal? BatteryCapacity { get; set; }           // kWh

        [ForeignKey(nameof(ConnectorType))]
        public int? ConnectorTypeId { get; set; }
        public virtual ConnectorType? ConnectorType { get; set; }
    }
}