using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace ChargeNet.WebAPI.Services
{
    public class AccessManager
    {
        private readonly ChargeNetDbContext _context;
        private readonly IConfiguration _configuration;

        public AccessManager(ChargeNetDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<AuthResponse> Authenticate(string email, string password)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Email == email && !u.IsDeleted);

            if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                throw new BusinessException("Invalid email or password.", 401);

            var token = GenerateJwtToken(user);

            return new AuthResponse
            {
                Token = token,
                UserId = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role.Name
            };
        }

        public string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings["Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role.Name),
                new Claim("RoleId", user.RoleId.ToString())
            };

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(
                    double.Parse(jwtSettings["TokenExpiryMinutes"] ?? "60")),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}
