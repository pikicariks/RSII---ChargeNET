using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChargeNet.Services.Database
{
    public class StationVector : BaseEntity
    {
        [ForeignKey(nameof(ChargingStation))]
        public int ChargingStationId { get; set; }
        public virtual ChargingStation ChargingStation { get; set; } = null!;

        public bool HasCCS { get; set; } = false;
        public bool HasCHAdeMO { get; set; } = false;
        public bool HasType2 { get; set; } = false;

        [Column(TypeName = "decimal(5,2)")]
        public decimal? MaxPowerKW { get; set; }
        public bool IsFastCharger { get; set; } = false;
        public bool HasIndoor { get; set; } = false;
        public bool Has24hAccess { get; set; } = false;

        [Column(TypeName = "decimal(2,1)")]
        public decimal? Rating { get; set; }

        public DateTime? LastComputedAt { get; set; }
    }
}