using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Database
{
    public static class ChargeNetSeed
    {
        private static readonly DateTime SeedDate = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        public static void Seed(ModelBuilder modelBuilder)
        {
            // ── Roles ──
            modelBuilder.Entity<Role>().HasData(
                new Role { Id = 1, Name = "Admin", Description = "Full system access", CreatedAt = SeedDate },
                new Role { Id = 2, Name = "Technician", Description = "Station technician", CreatedAt = SeedDate },
                new Role { Id = 3, Name = "Driver", Description = "Mobile application user and EV driver", CreatedAt = SeedDate }
            );

            // ── StationStatuses ──
            modelBuilder.Entity<StationStatus>().HasData(
                new StationStatus { Id = 1, Name = "Active", Description = "Operational", CreatedAt = SeedDate },
                new StationStatus { Id = 2, Name = "Inactive", Description = "Temporarily unavailable", CreatedAt = SeedDate },
                new StationStatus { Id = 3, Name = "Maintenance", Description = "Under maintenance", CreatedAt = SeedDate }
            );

            // ── ConnectorTypes ──
            modelBuilder.Entity<ConnectorType>().HasData(
                new ConnectorType { Id = 1, Name = "Type 2", Description = "IEC 62196-2 Type 2 (Mennekes)", PowerRating = 43.0m, CreatedAt = SeedDate },
                new ConnectorType { Id = 2, Name = "CCS", Description = "Combined Charging System (Combo 2)", PowerRating = 350.0m, CreatedAt = SeedDate },
                new ConnectorType { Id = 3, Name = "CHAdeMO", Description = "CHAdeMO DC fast charging", PowerRating = 62.5m, CreatedAt = SeedDate }
            );

            // ── ReservationStatuses ──
            modelBuilder.Entity<ReservationStatus>().HasData(
                new ReservationStatus { Id = 1, Name = "Pending", Description = "Awaiting confirmation", CreatedAt = SeedDate },
                new ReservationStatus { Id = 2, Name = "Confirmed", Description = "Reservation confirmed", CreatedAt = SeedDate },
                new ReservationStatus { Id = 3, Name = "Rejected", Description = "Reservation rejected", CreatedAt = SeedDate },
                new ReservationStatus { Id = 4, Name = "Cancelled", Description = "Cancelled by user", CreatedAt = SeedDate },
                new ReservationStatus { Id = 5, Name = "Completed", Description = "Successfully used", CreatedAt = SeedDate },
                new ReservationStatus { Id = 6, Name = "Expired", Description = "Reservation expired", CreatedAt = SeedDate }
            );

            // ── Countries ──
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "Bosnia and Herzegovina", Code = "BIH", CreatedAt = SeedDate },
                new Country { Id = 2, Name = "Croatia", Code = "HRV", CreatedAt = SeedDate },
                new Country { Id = 3, Name = "Serbia", Code = "SRB", CreatedAt = SeedDate },
                new Country { Id = 4, Name = "Slovenia", Code = "SVN", CreatedAt = SeedDate },
                new Country { Id = 5, Name = "Montenegro", Code = "MNE", CreatedAt = SeedDate },
                new Country { Id = 6, Name = "Germany", Code = "DEU", CreatedAt = SeedDate },
                new Country { Id = 7, Name = "Austria", Code = "AUT", CreatedAt = SeedDate }
            );

            // ── Cities ──
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo", PostalCode = "71000", CountryId = 1, CreatedAt = SeedDate },
                new City { Id = 2, Name = "Banja Luka", PostalCode = "78000", CountryId = 1, CreatedAt = SeedDate },
                new City { Id = 3, Name = "Tuzla", PostalCode = "75000", CountryId = 1, CreatedAt = SeedDate },
                new City { Id = 4, Name = "Mostar", PostalCode = "88000", CountryId = 1, CreatedAt = SeedDate },
                new City { Id = 5, Name = "Zenica", PostalCode = "72000", CountryId = 1, CreatedAt = SeedDate },
                new City { Id = 6, Name = "Zagreb", PostalCode = "10000", CountryId = 2, CreatedAt = SeedDate },
                new City { Id = 7, Name = "Split", PostalCode = "21000", CountryId = 2, CreatedAt = SeedDate }
            );

            // ── Users (admin + demo driver) ──
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    FirstName = "Admin",
                    LastName = "ChargeNET",
                    Email = "admin@chargenet.com",
                    PasswordHash = "$2a$11$PLACEHOLDER_HASH_ADMIN_PASSWORD",
                    RoleId = 1,
                    CityId = 1,
                    CreatedAt = SeedDate
                },
                new User
                {
                    Id = 2,
                    FirstName = "Demo",
                    LastName = "Driver",
                    Email = "demo@chargenet.com",
                    PasswordHash = "$2a$11$PLACEHOLDER_HASH_DEMO_PASSWORD",
                    RoleId = 3,
                    CityId = 1,
                    CreatedAt = SeedDate
                }
            );

            // ── Tariffs ──
            modelBuilder.Entity<Tariff>().HasData(
                new Tariff { Id = 1, Name = "Standard Day", PricePerKWh = 0.25m, IsActive = true, Currency = "EUR", CreatedAt = SeedDate },
                new Tariff { Id = 2, Name = "Night Saver", PricePerKWh = 0.15m, StartHour = new TimeSpan(22, 0, 0), EndHour = new TimeSpan(6, 0, 0), IsActive = true, Currency = "EUR", CreatedAt = SeedDate },
                new Tariff { Id = 3, Name = "Fast Charge Premium", PricePerKWh = 0.45m, PricePerMinute = 0.05m, IsActive = true, Currency = "EUR", CreatedAt = SeedDate }
            );
        }

        public static async Task SeedAsync(ChargeNetDbContext context)
        {
            await context.Database.MigrateAsync();
        }
    }
}
