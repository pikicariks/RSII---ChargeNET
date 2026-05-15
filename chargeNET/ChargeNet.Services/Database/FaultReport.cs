using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class FaultReport : BaseEntity
    {
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [ForeignKey(nameof(ChargingStation))]
        public int ChargingStationId { get; set; }
        public virtual ChargingStation ChargingStation { get; set; } = null!;

        [ForeignKey(nameof(Connector))]
        public int? ConnectorId { get; set; }
        public virtual Connector? Connector { get; set; }

        [Required, StringLength(1000)]
        public string Description { get; set; } = string.Empty;

        public DateTime ReportedAt { get; set; } = DateTime.UtcNow;

        public DateTime? ResolvedAt { get; set; }

        public bool IsResolved { get; set; } = false;

        // Navigation
        public virtual ICollection<ServiceOrder> ServiceOrders { get; set; } = new List<ServiceOrder>();
    }
}