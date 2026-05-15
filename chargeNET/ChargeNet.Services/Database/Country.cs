using System.ComponentModel.DataAnnotations;

namespace ChargeNet.Services.Database
{
    public class Country : BaseEntity
    {
        [Required, StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required, StringLength(3)]
        public string Code { get; set; } = string.Empty;         // ISO 3166-1 alpha-3

        // Navigation
        public virtual ICollection<City> Cities { get; set; } = new List<City>();
    }
}