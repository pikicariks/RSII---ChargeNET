using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class ConnectorType : BaseEntity
    {
        [Required, StringLength(50)]
        public string Name { get; set; } = string.Empty;

        [StringLength(200)]
        public string? Description { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal? PowerRating { get; set; }                // kW

        // Navigation
        public virtual ICollection<Vehicle> Vehicles { get; set; } = new List<Vehicle>();
        public virtual ICollection<Connector> Connectors { get; set; } = new List<Connector>();
    }
}