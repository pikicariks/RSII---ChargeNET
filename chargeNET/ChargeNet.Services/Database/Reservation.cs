using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class Reservation : BaseEntity
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

        public DateTime ReservationStart { get; set; }
        public DateTime ReservationEnd { get; set; }

        [ForeignKey(nameof(Status))]
        public int StatusId { get; set; }
        public virtual ReservationStatus Status { get; set; } = null!;

        [StringLength(500)]
        public string? RejectionReason { get; set; }

        // Navigation
        public virtual ICollection<ChargingSession> ChargingSessions { get; set; } = new List<ChargingSession>();
    }
}