using System.ComponentModel.DataAnnotations;

namespace ChargeNet.Services.Database
{
    public class ReservationStatus : BaseEntity
    {
        [Required, StringLength(50)]
        public string Name { get; set; } = string.Empty;

        [StringLength(200)]
        public string? Description { get; set; }

        // Navigation
        public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
    }
}