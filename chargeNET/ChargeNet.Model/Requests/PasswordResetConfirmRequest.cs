using System.ComponentModel.DataAnnotations;

namespace ChargeNet.Model.Requests
{
    public class PasswordResetConfirmRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string ResetToken { get; set; } = string.Empty;

        [Required]
        [MinLength(8)]
        public string NewPassword { get; set; } = string.Empty;
    }
}
