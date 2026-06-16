using System.ComponentModel.DataAnnotations;

namespace ChargeNet.Model.Requests
{
    public class PasswordResetRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
    }
}
