using System.Text;
using System.Text.Json;
using ChargeNet.Model.Messages;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Messaging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace ChargeNet.WebAPI.Services
{
    public class NotificationPushConsumer : BackgroundService
    {
        private readonly INotificationPushService _notificationPushService;
        private readonly RabbitMqOptions _rabbitMqOptions;
        private readonly ILogger<NotificationPushConsumer> _logger;
        private IConnection? _connection;
        private IChannel? _channel;

        public NotificationPushConsumer(
            INotificationPushService notificationPushService,
            IOptions<RabbitMqOptions> rabbitMqOptions,
            ILogger<NotificationPushConsumer> logger)
        {
            _notificationPushService = notificationPushService;
            _rabbitMqOptions = rabbitMqOptions.Value;
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
                    _logger.LogError(ex, "Notification push consumer failed. Retrying in 5 seconds.");
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
                queue: NotificationQueueConstants.QueueName,
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
                queue: NotificationQueueConstants.QueueName,
                autoAck: false,
                consumer: consumer,
                cancellationToken: stoppingToken);

            _logger.LogInformation(
                "Notification push consumer is listening on queue '{QueueName}'.",
                NotificationQueueConstants.QueueName);

            await Task.Delay(Timeout.Infinite, stoppingToken);
        }

        private async Task HandleMessageAsync(BasicDeliverEventArgs eventArgs, CancellationToken stoppingToken)
        {
            try
            {
                var json = Encoding.UTF8.GetString(eventArgs.Body.ToArray());
                var message = JsonSerializer.Deserialize<NotificationPushMessage>(json);

                if (message?.Notification == null)
                {
                    throw new InvalidOperationException("Notification push message payload is empty.");
                }

                await _notificationPushService.PushToUserAsync(
                    message.Notification.UserId,
                    message.Notification,
                    stoppingToken);

                await _channel!.BasicAckAsync(eventArgs.DeliveryTag, multiple: false, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process notification push message.");

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
}
