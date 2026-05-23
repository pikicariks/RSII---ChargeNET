using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.StateMachines;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.WebAPI.Services
{
    public class ReservationExpiryService : BackgroundService
    {
        private static readonly TimeSpan ScanInterval = TimeSpan.FromSeconds(60);

        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<ReservationExpiryService> _logger;

        public ReservationExpiryService(
            IServiceScopeFactory scopeFactory,
            ILogger<ReservationExpiryService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessOverdueReservationsAsync(stoppingToken);
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    _logger.LogError(ex, "Reservation expiry scan failed.");
                }

                await Task.Delay(ScanInterval, stoppingToken);
            }
        }

        private async Task ProcessOverdueReservationsAsync(CancellationToken cancellationToken)
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ChargeNetDbContext>();
            var reservationService = scope.ServiceProvider.GetRequiredService<IReservationService>();

            var now = DateTime.UtcNow;
            var overdueIds = await context.Reservations
                .Where(r =>
                    (r.StatusId == ReservationStatusIds.Pending || r.StatusId == ReservationStatusIds.Confirmed) &&
                    r.ReservationEnd < now)
                .OrderBy(r => r.Id)
                .Select(r => r.Id)
                .ToListAsync(cancellationToken);

            if (overdueIds.Count == 0)
            {
                return;
            }

            _logger.LogInformation("Expiring {Count} overdue reservation(s).", overdueIds.Count);

            foreach (var id in overdueIds)
            {
                try
                {
                    await reservationService.Expire(id);
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    _logger.LogWarning(ex, "Failed to expire reservation {ReservationId}.", id);
                }
            }
        }
    }
}
