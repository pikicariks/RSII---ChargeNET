using System.Text;
using System.Text.Json;
using ChargeNet.Model.Enums;
using ChargeNet.Model.Messages;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using ChargeNet.Services.Invoicing;
using ChargeNet.Services.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace ChargeNet.Worker;

public class InvoiceGenerationWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly RabbitMqOptions _rabbitMqOptions;
    private readonly INotificationPushPublisher _notificationPushPublisher;
    private readonly ILogger<InvoiceGenerationWorker> _logger;
    private IConnection? _connection;
    private IChannel? _channel;

    public InvoiceGenerationWorker(
        IServiceScopeFactory scopeFactory,
        IOptions<RabbitMqOptions> rabbitMqOptions,
        INotificationPushPublisher notificationPushPublisher,
        ILogger<InvoiceGenerationWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _rabbitMqOptions = rabbitMqOptions.Value;
        _notificationPushPublisher = notificationPushPublisher;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ConnectAndConsumeAsync(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Invoice generation worker failed. Retrying in 5 seconds.");
                await DisposeConnectionAsync();
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
            }
        }
    }

    private async Task ConnectAndConsumeAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _rabbitMqOptions.Host,
            Port = _rabbitMqOptions.Port,
            UserName = _rabbitMqOptions.Username,
            Password = _rabbitMqOptions.Password
        };

        _connection = await factory.CreateConnectionAsync(stoppingToken);
        _channel = await _connection.CreateChannelAsync(cancellationToken: stoppingToken);

        await _channel.QueueDeclareAsync(
            queue: InvoiceQueueConstants.QueueName,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null,
            cancellationToken: stoppingToken);

        await _channel.BasicQosAsync(0, 1, false, stoppingToken);

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.ReceivedAsync += async (_, eventArgs) =>
        {
            await HandleMessageAsync(eventArgs, stoppingToken);
        };

        await _channel.BasicConsumeAsync(
            queue: InvoiceQueueConstants.QueueName,
            autoAck: false,
            consumer: consumer,
            cancellationToken: stoppingToken);

        _logger.LogInformation("Invoice generation worker is listening on queue '{QueueName}'.", InvoiceQueueConstants.QueueName);

        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task HandleMessageAsync(BasicDeliverEventArgs eventArgs, CancellationToken stoppingToken)
    {
        InvoiceGenerationMessage? message = null;

        try
        {
            var json = Encoding.UTF8.GetString(eventArgs.Body.ToArray());
            message = JsonSerializer.Deserialize<InvoiceGenerationMessage>(json);

            if (message == null)
            {
                throw new InvalidOperationException("Invoice generation message payload is empty.");
            }

            await ProcessInvoiceAsync(message, stoppingToken);
            await _channel!.BasicAckAsync(eventArgs.DeliveryTag, multiple: false, stoppingToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process invoice generation message.");

            if (_channel != null)
            {
                await _channel.BasicNackAsync(
                    eventArgs.DeliveryTag,
                    multiple: false,
                    requeue: true,
                    stoppingToken);
            }
        }
    }

    private async Task ProcessInvoiceAsync(InvoiceGenerationMessage message, CancellationToken stoppingToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ChargeNetDbContext>();

        var invoice = await context.Invoices
            .FirstOrDefaultAsync(i => i.Id == message.InvoiceId, stoppingToken);

        if (invoice == null)
        {
            _logger.LogWarning("Invoice {InvoiceId} was not found.", message.InvoiceId);
            return;
        }

        if (invoice.Status == InvoiceConstants.StatusGenerated)
        {
            _logger.LogInformation("Invoice {InvoiceId} is already generated.", message.InvoiceId);
            return;
        }

        var pdfUrl = $"/invoices/{invoice.InvoiceNumber}.pdf";
        var now = DateTime.UtcNow;

        invoice.PdfUrl = pdfUrl;
        invoice.Status = InvoiceConstants.StatusGenerated;
        invoice.ModifiedAt = now;

        context.Notifications.Add(new Notification
        {
            UserId = message.UserId,
            Title = "Invoice generated",
            Message = $"Your invoice {invoice.InvoiceNumber} is ready for download.",
            NotificationType = nameof(NotificationType.InvoiceGenerated),
            RelatedEntityType = nameof(Invoice),
            RelatedEntityId = invoice.Id,
            CreatedAt = now
        });

        await context.SaveChangesAsync(stoppingToken);

        var savedNotification = await context.Notifications
            .Where(n => n.UserId == message.UserId && n.RelatedEntityId == invoice.Id)
            .OrderByDescending(n => n.Id)
            .FirstAsync(stoppingToken);

        await _notificationPushPublisher.PublishAsync(
            new NotificationPushMessage
            {
                Notification = new NotificationResponse
                {
                    Id = savedNotification.Id,
                    UserId = savedNotification.UserId,
                    Title = savedNotification.Title,
                    Message = savedNotification.Message,
                    NotificationType = savedNotification.NotificationType,
                    IsRead = savedNotification.IsRead,
                    RelatedEntityType = savedNotification.RelatedEntityType,
                    RelatedEntityId = savedNotification.RelatedEntityId,
                    CreatedAt = savedNotification.CreatedAt,
                    ModifiedAt = savedNotification.ModifiedAt
                }
            },
            stoppingToken);

        _logger.LogInformation(
            "Generated invoice PDF for {InvoiceNumber} at {PdfUrl}.",
            invoice.InvoiceNumber,
            pdfUrl);
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        await DisposeConnectionAsync();
        await base.StopAsync(cancellationToken);
    }

    private async Task DisposeConnectionAsync()
    {
        if (_channel != null)
        {
            await _channel.DisposeAsync();
            _channel = null;
        }

        if (_connection != null)
        {
            await _connection.DisposeAsync();
            _connection = null;
        }
    }
}
