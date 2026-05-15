using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Tariff : BaseEntity
    {
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Column(TypeName = "decimal(10,4)")]
        public decimal PricePerKWh { get; set; }

        [Column(TypeName = "decimal(10,4)")]
        public decimal? PricePerMinute { get; set; }

        [Required, StringLength(3)]
        public string Currency { get; set; } = "EUR";

        public TimeSpan? StartHour { get; set; }
        public TimeSpan? EndHour { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }

        // Navigation
        public virtual ICollection<ChargingSession> ChargingSessions { get; set; } = new List<ChargingSession>();
    }
}