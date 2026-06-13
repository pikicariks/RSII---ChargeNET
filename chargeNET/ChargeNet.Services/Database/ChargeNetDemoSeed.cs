using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Payment;
using ChargeNet.Services.Recommendation;
using ChargeNet.Services.StateMachines;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace ChargeNet.Services.Database
{
    /// <summary>
    /// Runtime demo data for seminar defense — Sarajevo stations, sessions, transactions.
    /// Idempotent: skips when stations prefixed with "ChargeNET " already exist.
    /// </summary>
    public static class ChargeNetDemoSeed
    {
        public const string DemoPassword = "Demo1234!";
        private const string StationPrefix = "ChargeNET ";

        private sealed record DemoStationDef(
            string Suffix,
            string Address,
            decimal Lat,
            decimal Lng,
            bool IsFast,
            decimal MaxPowerKw,
            bool HasCcs,
            bool HasType2,
            decimal Rating);

        private static readonly DemoStationDef[] SarajevoStations =
        [
            new("Baščaršija", "Obala Kulina bana 1", 43.859m, 18.431m, true, 150m, true, true, 4.8m),
            new("Ilidža", "Butmirska cesta 14", 43.828m, 18.310m, true, 120m, true, true, 4.5m),
            new("Marijin Dvor", "Trg BiH 1", 43.856m, 18.413m, false, 43m, false, true, 4.6m),
            new("Novo Sarajevo", "Zmaja od Bosne 8", 43.848m, 18.377m, false, 22m, false, true, 4.2m),
            new("Airport", "Kurta Schorka 36", 43.825m, 18.331m, true, 180m, true, false, 4.7m),
            new("University", "Zmaja od Bosne 33", 43.856m, 18.395m, false, 43m, false, true, 4.4m),
            new("Otoka", "Ferhadija 12", 43.872m, 18.325m, false, 22m, false, true, 4.1m),
            new("Dobrinja", "Butmirska cesta 1", 43.824m, 18.356m, true, 50m, true, true, 4.3m),
            new("Grbavica", "Grbavička 20", 43.863m, 18.405m, false, 43m, false, true, 4.0m),
            new("Vogošća", "Muhameda ef. Pandže 15", 43.879m, 18.351m, true, 75m, true, true, 4.5m),
        ];

        public static async Task SeedAsync(IServiceProvider services, CancellationToken cancellationToken = default)
        {
            var context = services.GetRequiredService<ChargeNetDbContext>();
            var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger("ChargeNetDemoSeed");

            await FixDemoPasswordsAsync(context, cancellationToken);

            if (await context.ChargingStations.AnyAsync(
                    s => s.Name.StartsWith(StationPrefix), cancellationToken))
            {
                logger.LogInformation("Demo stations already present — skipping demo seed.");
                return;
            }

            logger.LogInformation("Seeding ChargeNET demo data (Sarajevo stations, sessions, …)");

            var now = DateTime.UtcNow;
            var admin = await context.Users.FirstAsync(u => u.Email == "admin@chargenet.com", cancellationToken);
            var driverA = await EnsureUserAsync(
                context,
                email: "demo@chargenet.com",
                firstName: "Demo",
                lastName: "Driver",
                roleId: 3,
                cityId: 1,
                cancellationToken);

            var driverB = await EnsureUserAsync(
                context,
                email: "driver.b@chargenet.com",
                firstName: "Amira",
                lastName: "Hadžić",
                roleId: 3,
                cityId: 1,
                cancellationToken);

            await EnsureWalletAsync(context, driverA.Id, 52.50m, cancellationToken);
            await EnsureWalletAsync(context, driverB.Id, 78.25m, cancellationToken);

            var stations = new List<(ChargingStation Station, Connector Type2, Connector Ccs)>();
            foreach (var def in SarajevoStations)
            {
                var station = new ChargingStation
                {
                    Name = $"{StationPrefix}{def.Suffix}",
                    Address = def.Address,
                    CityId = 1,
                    Latitude = def.Lat,
                    Longitude = def.Lng,
                    StatusId = 1,
                    IsFastCharger = def.IsFast,
                    MaxPowerKW = def.MaxPowerKw,
                    HasCCS = def.HasCcs,
                    HasType2 = def.HasType2,
                    Has24hAccess = def.Suffix is "Airport" or "Baščaršija",
                    Rating = def.Rating,
                    CreatedAt = now,
                };
                context.ChargingStations.Add(station);
                await context.SaveChangesAsync(cancellationToken);

                var type2 = new Connector
                {
                    ChargingStationId = station.Id,
                    ConnectorTypeId = 1,
                    Label = "T2-A",
                    PowerKW = def.IsFast ? 43m : 22m,
                    IsAvailable = true,
                    CreatedAt = now,
                };
                var ccs = new Connector
                {
                    ChargingStationId = station.Id,
                    ConnectorTypeId = 2,
                    Label = "CCS-1",
                    PowerKW = def.MaxPowerKw,
                    IsAvailable = true,
                    CreatedAt = now,
                };
                context.Connectors.AddRange(type2, ccs);
                await context.SaveChangesAsync(cancellationToken);
                stations.Add((station, type2, ccs));
            }

            // Budget driver — slow/cheap stations, standard tariff.
            var budgetStations = stations.Where(s => !s.Station.IsFastCharger).Take(4).ToList();
            for (var i = 0; i < budgetStations.Count; i++)
            {
                var (station, type2, _) = budgetStations[i];
                await AddCompletedSessionAsync(
                    context,
                    userId: driverA.Id,
                    connector: type2,
                    tariffId: 1,
                    energyKwh: 18m + i * 2,
                    daysAgo: 28 - i * 5,
                    cancellationToken);
            }

            // Premium driver — fast CCS stations, premium tariff.
            var fastStations = stations.Where(s => s.Station.IsFastCharger).Take(4).ToList();
            for (var i = 0; i < fastStations.Count; i++)
            {
                var (station, _, ccs) = fastStations[i];
                await AddCompletedSessionAsync(
                    context,
                    userId: driverB.Id,
                    connector: ccs,
                    tariffId: 3,
                    energyKwh: 32m + i * 3,
                    daysAgo: 25 - i * 4,
                    cancellationToken);
            }

            // Top-up transactions for wallet history.
            await AddTopUpTransactionAsync(context, driverA.Id, 100m, now.AddDays(-30), cancellationToken);
            await AddTopUpTransactionAsync(context, driverB.Id, 120m, now.AddDays(-30), cancellationToken);

            // Reservations for mobile history tab.
            var pendingStation = stations[2].Station;
            var pendingConnector = stations[2].Type2;
            context.Reservations.Add(new Reservation
            {
                UserId = driverA.Id,
                ChargingStationId = pendingStation.Id,
                ConnectorId = pendingConnector.Id,
                ReservationStart = now.AddHours(2),
                ReservationEnd = now.AddHours(4),
                StatusId = ReservationStatusIds.Confirmed,
                CreatedAt = now.AddDays(-1),
            });
            context.Reservations.Add(new Reservation
            {
                UserId = driverA.Id,
                ChargingStationId = stations[4].Station.Id,
                ConnectorId = stations[4].Ccs.Id,
                ReservationStart = now.AddDays(-10),
                ReservationEnd = now.AddDays(-10).AddHours(2),
                StatusId = ReservationStatusIds.Cancelled,
                CreatedAt = now.AddDays(-11),
            });

            // Fault reports for admin D6.
            context.FaultReports.Add(new FaultReport
            {
                UserId = driverA.Id,
                ChargingStationId = stations[0].Station.Id,
                ConnectorId = stations[0].Ccs.Id,
                Description = "CCS connector intermittent — cuts power after 5 minutes.",
                ReportedAt = now.AddDays(-3),
                IsResolved = false,
                CreatedAt = now.AddDays(-3),
            });
            context.FaultReports.Add(new FaultReport
            {
                UserId = driverB.Id,
                ChargingStationId = stations[1].Station.Id,
                ConnectorId = stations[1].Type2.Id,
                Description = "Display panel offline — station still charges.",
                ReportedAt = now.AddDays(-14),
                IsResolved = true,
                ResolvedAt = now.AddDays(-12),
                CreatedAt = now.AddDays(-14),
            });

            // Vehicles for M6.
            context.Vehicles.Add(new Vehicle
            {
                UserId = driverA.Id,
                Make = "Renault",
                Model = "Zoe",
                Year = 2021,
                LicensePlate = "A01-K-123",
                BatteryCapacity = 52m,
                ConnectorTypeId = 1,
                CreatedAt = now,
            });
            context.Vehicles.Add(new Vehicle
            {
                UserId = driverB.Id,
                Make = "Tesla",
                Model = "Model 3",
                Year = 2023,
                LicensePlate = "S02-T-456",
                BatteryCapacity = 75m,
                ConnectorTypeId = 2,
                CreatedAt = now,
            });

            // Notifications for M7.
            context.Notifications.Add(new Notification
            {
                UserId = driverA.Id,
                Title = "Reservation confirmed",
                Message = "Your reservation at ChargeNET Marijin Dvor is confirmed.",
                NotificationType = "ReservationConfirmed",
                IsRead = false,
                CreatedAt = now.AddHours(-2),
            });
            context.Notifications.Add(new Notification
            {
                UserId = driverB.Id,
                Title = "Session complete",
                Message = "Charging finished at ChargeNET Ilidža. €14.40 debited from wallet.",
                NotificationType = "SessionComplete",
                IsRead = true,
                CreatedAt = now.AddDays(-2),
            });

            await context.SaveChangesAsync(cancellationToken);

            var vectorService = services.GetRequiredService<IStationVectorService>();
            await vectorService.EnsureVectorsAsync(cancellationToken);

            var profileService = services.GetRequiredService<IUserProfileService>();
            await profileService.UpdateProfileAsync(driverA.Id, cancellationToken);
            await profileService.UpdateProfileAsync(driverB.Id, cancellationToken);

            var invoiceService = services.GetRequiredService<IInvoiceService>();
            var paymentTxIds = await context.Transactions
                .Where(t => t.Type == PaymentConstants.TransactionTypes.Payment &&
                            t.Status == PaymentConstants.TransactionStatuses.Completed)
                .Select(t => t.Id)
                .ToListAsync(cancellationToken);
            foreach (var txId in paymentTxIds)
            {
                await invoiceService.CreateForTransactionAsync(txId, cancellationToken);
            }

            logger.LogInformation(
                "Demo seed complete: {Count} stations, drivers {A} / {B}. Password: {Password}",
                stations.Count,
                driverA.Email,
                driverB.Email,
                DemoPassword);
        }

        private static async Task FixDemoPasswordsAsync(
            ChargeNetDbContext context,
            CancellationToken cancellationToken)
        {
            var hash = BCrypt.Net.BCrypt.HashPassword(DemoPassword);
            var users = await context.Users
                .Where(u => u.Email == "admin@chargenet.com" ||
                            u.Email == "demo@chargenet.com" ||
                            u.Email == "driver.b@chargenet.com")
                .ToListAsync(cancellationToken);

            foreach (var user in users)
            {
                if (user.PasswordHash.Contains("PLACEHOLDER", StringComparison.Ordinal) ||
                    user.Email is "admin@chargenet.com" or "demo@chargenet.com")
                {
                    user.PasswordHash = hash;
                    user.ModifiedAt = DateTime.UtcNow;
                }
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        private static async Task<User> EnsureUserAsync(
            ChargeNetDbContext context,
            string email,
            string firstName,
            string lastName,
            int roleId,
            int cityId,
            CancellationToken cancellationToken)
        {
            var existing = await context.Users.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
            if (existing != null)
            {
                return existing;
            }

            var user = new User
            {
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(DemoPassword),
                RoleId = roleId,
                CityId = cityId,
                CreatedAt = DateTime.UtcNow,
            };
            context.Users.Add(user);
            await context.SaveChangesAsync(cancellationToken);

            context.UserWallets.Add(new UserWallet
            {
                UserId = user.Id,
                Balance = 0m,
                CreatedAt = DateTime.UtcNow,
            });
            await context.SaveChangesAsync(cancellationToken);
            return user;
        }

        private static async Task EnsureWalletAsync(
            ChargeNetDbContext context,
            int userId,
            decimal balance,
            CancellationToken cancellationToken)
        {
            var wallet = await context.UserWallets.FirstOrDefaultAsync(w => w.UserId == userId, cancellationToken);
            if (wallet == null)
            {
                wallet = new UserWallet { UserId = userId, Balance = balance, CreatedAt = DateTime.UtcNow };
                context.UserWallets.Add(wallet);
            }
            else
            {
                wallet.Balance = balance;
                wallet.ModifiedAt = DateTime.UtcNow;
            }

            await context.SaveChangesAsync(cancellationToken);
        }

        private static async Task AddCompletedSessionAsync(
            ChargeNetDbContext context,
            int userId,
            Connector connector,
            int tariffId,
            decimal energyKwh,
            int daysAgo,
            CancellationToken cancellationToken)
        {
            var tariff = await context.Tariffs.FirstAsync(t => t.Id == tariffId, cancellationToken);
            var start = DateTime.UtcNow.AddDays(-daysAgo).AddHours(-2);
            var end = start.AddMinutes(45);
            var cost = Math.Round(energyKwh * tariff.PricePerKWh, 2, MidpointRounding.AwayFromZero);

            var session = new ChargingSession
            {
                UserId = userId,
                ConnectorId = connector.Id,
                TariffId = tariffId,
                StartTime = start,
                EndTime = end,
                EnergyConsumedKWh = energyKwh,
                Cost = cost,
                CreatedAt = start,
                ModifiedAt = end,
            };
            context.ChargingSessions.Add(session);
            await context.SaveChangesAsync(cancellationToken);

            context.Transactions.Add(new Transaction
            {
                UserId = userId,
                ChargingSessionId = session.Id,
                Amount = cost,
                Currency = PaymentConstants.DefaultCurrency,
                Type = PaymentConstants.TransactionTypes.Payment,
                Status = PaymentConstants.TransactionStatuses.Completed,
                CreatedAt = end,
            });
            await context.SaveChangesAsync(cancellationToken);
        }

        private static async Task AddTopUpTransactionAsync(
            ChargeNetDbContext context,
            int userId,
            decimal amount,
            DateTime createdAt,
            CancellationToken cancellationToken)
        {
            context.Transactions.Add(new Transaction
            {
                UserId = userId,
                Amount = amount,
                Currency = PaymentConstants.DefaultCurrency,
                Type = PaymentConstants.TransactionTypes.TopUp,
                Status = PaymentConstants.TransactionStatuses.Completed,
                CreatedAt = createdAt,
            });
            await context.SaveChangesAsync(cancellationToken);
        }
    }
}
