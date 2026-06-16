using ChargeNet.Model.Requests;
using ChargeNet.Model.Validation;
using ChargeNet.Services.Database;
using ChargeNet.WebAPI.Services;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AccessManager _accessManager;
        private readonly ChargeNetDbContext _context;
        private readonly IMemoryCache _memoryCache;
        private const int PasswordResetTokenExpiryMinutes = 15;

        public AuthController(AccessManager accessManager, ChargeNetDbContext context, IMemoryCache memoryCache)
        {
            _accessManager = accessManager;
            _context = context;
            _memoryCache = memoryCache;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            EmailValidation.TryNormalizeAndValidate(request.Email, out var normalizedEmail, out _);

            var emailExists = await _context.Users.AnyAsync(u =>
                u.Email.ToLower() == normalizedEmail && !u.IsDeleted);
            if (emailExists)
                return Conflict(new { message = "A user with this email already exists." });

            if (request.RoleId.HasValue && request.RoleId.Value != 3)
                return BadRequest(new { message = "Self-registration supports Driver role only." });

            var user = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Email = normalizedEmail,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                PhoneNumber = request.PhoneNumber,
                RoleId = 3
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            _context.UserWallets.Add(new UserWallet { UserId = user.Id });
            _context.LoyaltyPrograms.Add(new LoyaltyProgram { UserId = user.Id });
            await _context.SaveChangesAsync();

            var authResponse = await _accessManager.Authenticate(request.Email, request.Password);
            return Ok(authResponse);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var authResponse = await _accessManager.Authenticate(request.Email, request.Password);
            return Ok(authResponse);
        }

        [HttpPost("password-reset/request")]
        public async Task<IActionResult> RequestPasswordReset([FromBody] PasswordResetRequest request)
        {
            EmailValidation.TryNormalizeAndValidate(request.Email, out var normalizedEmail, out _);

            var userExists = await _context.Users.AnyAsync(u =>
                u.Email.ToLower() == normalizedEmail && !u.IsDeleted);

            string? resetToken = null;
            if (userExists)
            {
                resetToken = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
                _memoryCache.Set(
                    BuildPasswordResetCacheKey(normalizedEmail),
                    resetToken,
                    TimeSpan.FromMinutes(PasswordResetTokenExpiryMinutes));
            }

            return Ok(new
            {
                message = "If an account with this email exists, a password reset token has been generated.",
                resetToken,
                expiresInMinutes = PasswordResetTokenExpiryMinutes
            });
        }

        [HttpPost("password-reset/confirm")]
        public async Task<IActionResult> ConfirmPasswordReset([FromBody] PasswordResetConfirmRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
            {
                return BadRequest(new { message = "New password must be at least 8 characters." });
            }

            EmailValidation.TryNormalizeAndValidate(request.Email, out var normalizedEmail, out _);
            var cacheKey = BuildPasswordResetCacheKey(normalizedEmail);

            if (!_memoryCache.TryGetValue<string>(cacheKey, out var expectedToken) ||
                !string.Equals(expectedToken, request.ResetToken?.Trim(), StringComparison.Ordinal))
            {
                return BadRequest(new { message = "Invalid or expired password reset token." });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email.ToLower() == normalizedEmail && !u.IsDeleted);
            if (user == null)
            {
                return BadRequest(new { message = "Invalid or expired password reset token." });
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _memoryCache.Remove(cacheKey);

            return Ok(new { message = "Password has been reset successfully." });
        }

        private static string BuildPasswordResetCacheKey(string normalizedEmail)
        {
            return $"auth:password-reset:{normalizedEmail}";
        }
    }
}
