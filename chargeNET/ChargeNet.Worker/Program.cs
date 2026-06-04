using ChargeNet.Services.Database;
using ChargeNet.Services.Messaging;
using ChargeNet.Worker;
using Microsoft.EntityFrameworkCore;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection(RabbitMqOptions.SectionName));

builder.Services.AddDbContext<ChargeNetDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("ChargeNetDb")));

builder.Services.AddHostedService<InvoiceGenerationWorker>();

var host = builder.Build();
host.Run();
