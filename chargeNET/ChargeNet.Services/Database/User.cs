using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class User : BaseEntity
    {
        [Required, StringLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required, StringLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required, StringLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required, StringLength(500)]
        public string PasswordHash { get; set; } = string.Empty;

        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        [ForeignKey(nameof(Role))]
        public int RoleId { get; set; }
        public virtual Role Role { get; set; } = null!;

        [ForeignKey(nameof(City))]
        public int? CityId { get; set; }
        public virtual City? City { get; set; }

        [StringLength(200)]
        public string? Address { get; set; }

        public byte[]? ProfileImage { get; set; }

        public bool IsDeleted { get; set; } = false;

        // Navigation
        public virtual UserWallet? Wallet { get; set; }
        public virtual LoyaltyProgram? LoyaltyProgram { get; set; }
        public virtual ICollection<Vehicle> Vehicles { get; set; } = new List<Vehicle>();
        public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
        public virtual ICollection<ChargingSession> ChargingSessions { get; set; } = new List<ChargingSession>();
        public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
        public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
        public virtual ICollection<FaultReport> FaultReports { get; set; } = new List<FaultReport>();
        public virtual ICollection<UserStationProfile> UserStationProfiles { get; set; } = new List<UserStationProfile>();
    }
}