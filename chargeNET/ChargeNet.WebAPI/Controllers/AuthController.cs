using ChargeNet.Model.Requests;
using ChargeNet.Model.Validation;
using ChargeNet.Services.Database;
using ChargeNet.WebAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AccessManager _accessManager;
        private readonly ChargeNetDbContext _context;

        public AuthController(AccessManager accessManager, ChargeNetDbContext context)
        {
            _accessManager = accessManager;
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            EmailValidation.TryNormalizeAndValidate(request.Email, out var normalizedEmail, out _);

            var emailExists = await _context.Users.AnyAsync(u =>
                u.Email.ToLower() == normalizedEmail && !u.IsDeleted);
            if (emailExists)
                return Conflict(new { message = "A user with this email already exists." });

            var user = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Email = normalizedEmail,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                PhoneNumber = request.PhoneNumber,
                RoleId = 1
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
    }
}
