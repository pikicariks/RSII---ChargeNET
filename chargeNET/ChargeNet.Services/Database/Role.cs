using System.ComponentModel.DataAnnotations;

namespace ChargeNet.Services.Database
{
    public class Role : BaseEntity
    {
        [Required, StringLength(50)]
        public string Name { get; set; } = string.Empty;

        [StringLength(200)]
        public string? Description { get; set; }

        // Navigation
        public virtual ICollection<User> Users { get; set; } = new List<User>();
    }
}