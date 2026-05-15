using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Connector : BaseEntity
    {
        [ForeignKey(nameof(ChargingStation))]
        public int ChargingStationId { get; set; }
        public virtual ChargingStation ChargingStation { get; set; } = null!;

        [ForeignKey(nameof(ConnectorType))]
        public int ConnectorTypeId { get; set; }
        public virtual ConnectorType ConnectorType { get; set; } = null!;

        [StringLength(50)]
        public string? Label { get; set; }

        public bool IsAvailable { get; set; } = true;

        [Column(TypeName = "decimal(5,2)")]
        public decimal PowerKW { get; set; }

        // Navigation
        public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
        public virtual ICollection<ChargingSession> ChargingSessions { get; set; } = new List<ChargingSession>();
        public virtual ICollection<FaultReport> FaultReports { get; set; } = new List<FaultReport>();
    }
}