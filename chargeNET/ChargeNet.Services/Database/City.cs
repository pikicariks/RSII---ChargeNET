using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class City : BaseEntity
    {
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required, StringLength(20)]
        public string PostalCode { get; set; } = string.Empty;

        [ForeignKey(nameof(Country))]
        public int CountryId { get; set; }
        public virtual Country Country { get; set; } = null!;

        // Navigation
        public virtual ICollection<User> Users { get; set; } = new List<User>();
        public virtual ICollection<ChargingStation> ChargingStations { get; set; } = new List<ChargingStation>();
    }
}