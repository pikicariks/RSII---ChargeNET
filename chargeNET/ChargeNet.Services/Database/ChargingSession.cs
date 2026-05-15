using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class ChargingSession : BaseEntity
    {
        [ForeignKey(nameof(Reservation))]
        public int? ReservationId { get; set; }
        public virtual Reservation? Reservation { get; set; }

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        [ForeignKey(nameof(Connector))]
        public int ConnectorId { get; set; }
        public virtual Connector Connector { get; set; } = null!;

        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal? EnergyConsumedKWh { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Cost { get; set; }

        [ForeignKey(nameof(Tariff))]
        public int TariffId { get; set; }
        public virtual Tariff Tariff { get; set; } = null!;

        // Navigation
        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }
}