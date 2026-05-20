using System.Text.RegularExpressions;

namespace ChargeNet.Model.Validation
{
    public static class EmailValidation
    {
        private const int MaxLength = 100;

        private static readonly Regex EmailRegex = new(
            @"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$",
            RegexOptions.Compiled | RegexOptions.CultureInvariant | RegexOptions.IgnoreCase);

        public static bool TryNormalizeAndValidate(string? email, out string normalizedEmail, out string? errorMessage)
        {
            normalizedEmail = string.Empty;

            if (string.IsNullOrWhiteSpace(email))
            {
                errorMessage = "Email is required.";
                return false;
            }

            normalizedEmail = email.Trim().ToLowerInvariant();

            if (normalizedEmail.Length > MaxLength)
            {
                errorMessage = $"Email must not exceed {MaxLength} characters.";
                return false;
            }

            if (!EmailRegex.IsMatch(normalizedEmail))
            {
                errorMessage = "Email format is invalid.";
                return false;
            }

            errorMessage = null;
            return true;
        }
    }
}
