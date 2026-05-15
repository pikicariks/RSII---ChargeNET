using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class ChargingStation : BaseEntity
    {
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required, StringLength(200)]
        public string Address { get; set; } = string.Empty;

        [ForeignKey(nameof(City))]
        public int CityId { get; set; }
        public virtual City City { get; set; } = null!;

        [Column(TypeName = "decimal(9,6)")]
        public decimal? Latitude { get; set; }

        [Column(TypeName = "decimal(9,6)")]
        public decimal? Longitude { get; set; }

        [ForeignKey(nameof(Status))]
        public int StatusId { get; set; }
        public virtual StationStatus Status { get; set; } = null!;

        public byte[]? Image { get; set; }

        // Recommender attributes
        public bool HasCCS { get; set; } = false;
        public bool HasCHAdeMO { get; set; } = false;
        public bool HasType2 { get; set; } = false;

        [Column(TypeName = "decimal(5,2)")]
        public decimal? MaxPowerKW { get; set; }
        public bool IsFastCharger { get; set; } = false;
        public bool HasIndoor { get; set; } = false;
        public bool Has24hAccess { get; set; } = false;

        [Column(TypeName = "decimal(2,1)")]
        public decimal? Rating { get; set; }                     // 0.0-5.0

        // Navigation
        public virtual ICollection<Connector> Connectors { get; set; } = new List<Connector>();
        public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
        public virtual ICollection<FaultReport> FaultReports { get; set; } = new List<FaultReport>();
        public virtual ICollection<ServiceOrder> ServiceOrders { get; set; } = new List<ServiceOrder>();
        public virtual StationVector? StationVector { get; set; }
        public virtual ICollection<UserStationProfile> UserStationProfiles { get; set; } = new List<UserStationProfile>();
    }
}