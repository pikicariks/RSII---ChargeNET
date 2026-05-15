using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class ServiceOrder : BaseEntity
    {
        [ForeignKey(nameof(FaultReport))]
        public int? FaultReportId { get; set; }
        public virtual FaultReport? FaultReport { get; set; }

        [ForeignKey(nameof(ChargingStation))]
        public int ChargingStationId { get; set; }
        public virtual ChargingStation ChargingStation { get; set; } = null!;

        [StringLength(100)]
        public string? AssignedTo { get; set; }

        [Required, StringLength(50)]
        public string Status { get; set; } = string.Empty;

        [StringLength(1000)]
        public string? Notes { get; set; }
    }
}