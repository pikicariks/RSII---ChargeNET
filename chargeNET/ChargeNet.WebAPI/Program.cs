using ChargeNet.Services.Database;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ── EF Core DB Context ──
var connectionString = builder.Configuration.GetConnectionString("ChargeNetDb");
builder.Services.AddDbContext<ChargeNetDbContext>(options =>
    options.UseSqlServer(connectionString));

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
app.MapControllers();

app.Run();