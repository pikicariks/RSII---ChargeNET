using System.Text;
using AutoMapper;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Mapping;
using ChargeNet.Services.Messaging;
using ChargeNet.Services.Recommendation;
using ChargeNet.Services.Services;
using ChargeNet.Services.Validators;
using ChargeNet.WebAPI.Filters;
using ChargeNet.WebAPI.Hubs;
using FluentValidation;
using ChargeNet.WebAPI.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddValidatorsFromAssemblyContaining<RegisterRequestValidator>();
builder.Services.AddScoped<FluentValidationActionFilter>();
builder.Services.AddMemoryCache();
builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection(RabbitMqOptions.SectionName));
builder.Services.AddSingleton<RabbitMqPublisher>();
builder.Services.AddSingleton<IInvoiceGenerationPublisher>(sp => sp.GetRequiredService<RabbitMqPublisher>());
builder.Services.AddSingleton<INotificationPushPublisher>(sp => sp.GetRequiredService<RabbitMqPublisher>());

builder.Services.AddControllers(options =>
{
    options.Filters.Add<ExceptionFilter>();
    options.Filters.AddService<FluentValidationActionFilter>();
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' and then your token.",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var connectionString = builder.Configuration.GetConnectionString("ChargeNetDb");
builder.Services.AddDbContext<ChargeNetDbContext>(options =>
    options.UseSqlServer(connectionString));

var mapperLoggerFactory = LoggerFactory.Create(logging => { });
var mapperConfig = new MapperConfiguration(config => config.AddProfile<ChargeNetProfile>(), mapperLoggerFactory);
builder.Services.AddSingleton(mapperConfig.CreateMapper());
builder.Services.AddScoped<ITariffService, TariffService>();
builder.Services.AddScoped<IChargingStationService, ChargingStationService>();
builder.Services.AddScoped<IConnectorService, ConnectorService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IVehicleService, VehicleService>();
builder.Services.AddScoped<IFaultReportService, FaultReportService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IChargingSessionService, ChargingSessionService>();
builder.Services.AddScoped<ITransactionService, TransactionService>();
builder.Services.AddScoped<IInvoiceService, InvoiceService>();
builder.Services.AddSingleton<IRecommendationCacheService, RecommendationCacheService>();
builder.Services.AddScoped<IStationVectorService, StationVectorService>();
builder.Services.AddScoped<IUserProfileService, UserProfileService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

builder.Services.AddScoped<AccessManager>();
builder.Services.AddSingleton<INotificationPushService, NotificationDispatcher>();
builder.Services.AddHostedService<ReservationExpiryService>();
builder.Services.AddHostedService<NotificationPushConsumer>();

builder.Services.AddSignalR();

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

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    path.StartsWithSegments("/hubs/notifications"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            }
        };
    });

Stripe.StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ChargeNetDbContext>();
    await db.Database.MigrateAsync();
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<NotificationHub>("/hubs/notifications");

app.Run();
