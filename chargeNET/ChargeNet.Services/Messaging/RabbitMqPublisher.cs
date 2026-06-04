using System.Text;
using System.Text.Json;
using ChargeNet.Model.Messages;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace ChargeNet.Services.Messaging
{
    public class RabbitMqPublisher : IInvoiceGenerationPublisher, IAsyncDisposable
    {
        private readonly RabbitMqOptions _options;
        private readonly ILogger<RabbitMqPublisher> _logger;
        private readonly SemaphoreSlim _connectionLock = new(1, 1);
        private IConnection? _connection;
        private IChannel? _channel;

        public RabbitMqPublisher(IOptions<RabbitMqOptions> options, ILogger<RabbitMqPublisher> logger)
        {
            _options = options.Value;
            _logger = logger;
        }

        public async Task PublishAsync(InvoiceGenerationMessage message, CancellationToken cancellationToken = default)
        {
            try
            {
                await EnsureChannelAsync(cancellationToken);

                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));
                await _channel!.BasicPublishAsync(
                    exchange: string.Empty,
                    routingKey: InvoiceQueueConstants.QueueName,
                    mandatory: false,
                    basicProperties: new BasicProperties { Persistent = true },
                    body: body,
                    cancellationToken: cancellationToken);

                _logger.LogInformation(
                    "Published invoice generation message for invoice {InvoiceId}.",
                    message.InvoiceId);
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Failed to publish invoice generation message for invoice {InvoiceId}.",
                    message.InvoiceId);
                throw;
            }
        }

        private async Task EnsureChannelAsync(CancellationToken cancellationToken)
        {
            if (_channel != null && _channel.IsOpen)
            {
                return;
            }

            await _connectionLock.WaitAsync(cancellationToken);
            try
            {
                if (_channel != null && _channel.IsOpen)
                {
                    return;
                }

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

                var factory = new ConnectionFactory
                {
                    HostName = _options.Host,
                    Port = _options.Port,
                    UserName = _options.Username,
                    Password = _options.Password
                };

                _connection = await factory.CreateConnectionAsync(cancellationToken);
                _channel = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);

                await _channel.QueueDeclareAsync(
                    queue: InvoiceQueueConstants.QueueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null,
                    cancellationToken: cancellationToken);
            }
            finally
            {
                _connectionLock.Release();
            }
        }

        public async ValueTask DisposeAsync()
        {
            if (_channel != null)
            {
                await _channel.DisposeAsync();
            }

            if (_connection != null)
            {
                await _connection.DisposeAsync();
            }

            _connectionLock.Dispose();
        }
    }
}
