using System.Text;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Services;
using ChargeNet.WebAPI.Filters;
using ChargeNet.WebAPI.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// ── Controllers with global exception filter ──
builder.Services.AddControllers(options =>
{
    options.Filters.Add<ExceptionFilter>();
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ── EF Core DB Context ──
var connectionString = builder.Configuration.GetConnectionString("ChargeNetDb");
builder.Services.AddDbContext<ChargeNetDbContext>(options =>
    options.UseSqlServer(connectionString));

// ── DI: Base Services ──
builder.Services.AddScoped(typeof(IBaseReadService<,>), typeof(BaseReadService<,>));
builder.Services.AddScoped(typeof(IBaseCRUDService<,,>), typeof(BaseCRUDService<,,>));

// ── DI: Access Manager ──
builder.Services.AddScoped<AccessManager>();

// ── JWT Authentication ──
var jwtSettings = builder.Configuration.GetSection("Jwt");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings["Key"]!))
        };
    });

var app = builder.Build();

// ── Apply pending migrations & seed on startup ──
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ChargeNetDbContext>();
    await db.Database.MigrateAsync();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
