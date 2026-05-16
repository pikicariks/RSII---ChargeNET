using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Database
{
    public class ChargeNetDbContext : DbContext
    {
        public ChargeNetDbContext(DbContextOptions<ChargeNetDbContext> options) : base(options) { }

        // Lookup Tables
        public DbSet<Country> Countries { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<StationStatus> StationStatuses { get; set; }
        public DbSet<ConnectorType> ConnectorTypes { get; set; }
        public DbSet<ReservationStatus> ReservationStatuses { get; set; }

        // Core Entities
        public DbSet<User> Users { get; set; }
        public DbSet<UserWallet> UserWallets { get; set; }
        public DbSet<Vehicle> Vehicles { get; set; }
        public DbSet<ChargingStation> ChargingStations { get; set; }
        public DbSet<Connector> Connectors { get; set; }
        public DbSet<Tariff> Tariffs { get; set; }
        public DbSet<Reservation> Reservations { get; set; }
        public DbSet<ChargingSession> ChargingSessions { get; set; }
        public DbSet<FaultReport> FaultReports { get; set; }
        public DbSet<ServiceOrder> ServiceOrders { get; set; }
        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<LoyaltyProgram> LoyaltyPrograms { get; set; }

        // Recommendation Tables
        public DbSet<UserStationProfile> UserStationProfiles { get; set; }
        public DbSet<StationVector> StationVectors { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            ChargeNetSeed.Seed(modelBuilder);
            base.OnModelCreating(modelBuilder);

            // ── Country ──
            modelBuilder.Entity<Country>(e =>
            {
                e.HasIndex(c => c.Name).IsUnique();
                e.HasIndex(c => c.Code).IsUnique();
                e.HasMany(c => c.Cities).WithOne(c => c.Country).HasForeignKey(c => c.CountryId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── City ──
            modelBuilder.Entity<City>(e =>
            {
                e.HasMany(c => c.Users).WithOne(u => u.City).HasForeignKey(u => u.CityId).OnDelete(DeleteBehavior.SetNull);
                e.HasMany(c => c.ChargingStations).WithOne(s => s.City).HasForeignKey(s => s.CityId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── Role ──
            modelBuilder.Entity<Role>(e =>
            {
                e.HasIndex(r => r.Name).IsUnique();
                e.HasMany(r => r.Users).WithOne(u => u.Role).HasForeignKey(u => u.RoleId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── StationStatus ──
            modelBuilder.Entity<StationStatus>(e =>
            {
                e.HasIndex(s => s.Name).IsUnique();
                e.HasMany(s => s.ChargingStations).WithOne(cs => cs.Status).HasForeignKey(cs => cs.StatusId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── ConnectorType ──
            modelBuilder.Entity<ConnectorType>(e =>
            {
                e.HasIndex(ct => ct.Name).IsUnique();
                e.HasMany(ct => ct.Vehicles).WithOne(v => v.ConnectorType).HasForeignKey(v => v.ConnectorTypeId).OnDelete(DeleteBehavior.SetNull);
                e.HasMany(ct => ct.Connectors).WithOne(c => c.ConnectorType).HasForeignKey(c => c.ConnectorTypeId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── ReservationStatus ──
            modelBuilder.Entity<ReservationStatus>(e =>
            {
                e.HasIndex(rs => rs.Name).IsUnique();
                e.HasMany(rs => rs.Reservations).WithOne(r => r.Status).HasForeignKey(r => r.StatusId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── User ──
            modelBuilder.Entity<User>(e =>
            {
                e.HasIndex(u => u.Email).IsUnique();
                e.Property(u => u.IsDeleted).HasDefaultValue(false);
                e.HasOne(u => u.Role).WithMany(r => r.Users).HasForeignKey(u => u.RoleId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(u => u.City).WithMany(c => c.Users).HasForeignKey(u => u.CityId).OnDelete(DeleteBehavior.SetNull);
            });

            // ── UserWallet (1-to-1 with User) ──
            modelBuilder.Entity<UserWallet>(e =>
            {
                e.HasIndex(w => w.UserId).IsUnique();
                e.HasIndex(w => w.StripeCustomerId).IsUnique().HasFilter("[StripeCustomerId] IS NOT NULL");
                e.HasOne(w => w.User).WithOne(u => u.Wallet).HasForeignKey<UserWallet>(w => w.UserId).OnDelete(DeleteBehavior.Cascade);
            });

            // ── Vehicle ──
            modelBuilder.Entity<Vehicle>(e =>
            {

                e.HasIndex(v => v.LicensePlate).IsUnique().HasFilter("[LicensePlate] IS NOT NULL");
                e.HasOne(v => v.User).WithMany(u => u.Vehicles).HasForeignKey(v => v.UserId).OnDelete(DeleteBehavior.Cascade);
                e.HasOne(v => v.ConnectorType).WithMany(ct => ct.Vehicles).HasForeignKey(v => v.ConnectorTypeId).OnDelete(DeleteBehavior.SetNull);
            });

            // ── ChargingStation ──
            modelBuilder.Entity<ChargingStation>(e =>
            {
                e.HasOne(cs => cs.City).WithMany(c => c.ChargingStations).HasForeignKey(cs => cs.CityId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(cs => cs.Status).WithMany(ss => ss.ChargingStations).HasForeignKey(cs => cs.StatusId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── Connector ──
            modelBuilder.Entity<Connector>(e =>
            {
                e.HasOne(c => c.ChargingStation).WithMany(cs => cs.Connectors).HasForeignKey(c => c.ChargingStationId).OnDelete(DeleteBehavior.Cascade);
                e.HasOne(c => c.ConnectorType).WithMany(ct => ct.Connectors).HasForeignKey(c => c.ConnectorTypeId).OnDelete(DeleteBehavior.Restrict);
                e.HasIndex(c => new { c.ChargingStationId, c.ConnectorTypeId, c.Label }).IsUnique().HasFilter("[Label] IS NOT NULL");
            });

            // ── Tariff ──
            modelBuilder.Entity<Tariff>(e =>
            {
                e.HasIndex(t => t.Name).IsUnique();
            });

            // ── Reservation ──
            modelBuilder.Entity<Reservation>(e =>
            {
                e.HasOne(r => r.User).WithMany(u => u.Reservations).HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(r => r.ChargingStation).WithMany(cs => cs.Reservations).HasForeignKey(r => r.ChargingStationId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(r => r.Connector).WithMany(c => c.Reservations).HasForeignKey(r => r.ConnectorId).OnDelete(DeleteBehavior.SetNull);
                e.HasOne(r => r.Status).WithMany(rs => rs.Reservations).HasForeignKey(r => r.StatusId).OnDelete(DeleteBehavior.Restrict);
                e.HasIndex(r => new { r.UserId, r.StatusId });
            });

            // ── ChargingSession ──
            modelBuilder.Entity<ChargingSession>(e =>
            {
                e.HasOne(cs => cs.Reservation).WithMany(r => r.ChargingSessions).HasForeignKey(cs => cs.ReservationId).OnDelete(DeleteBehavior.SetNull);
                e.HasOne(cs => cs.User).WithMany(u => u.ChargingSessions).HasForeignKey(cs => cs.UserId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(cs => cs.Connector).WithMany(c => c.ChargingSessions).HasForeignKey(cs => cs.ConnectorId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(cs => cs.Tariff).WithMany(t => t.ChargingSessions).HasForeignKey(cs => cs.TariffId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── FaultReport ──
            modelBuilder.Entity<FaultReport>(e =>
            {
                e.HasOne(f => f.User).WithMany(u => u.FaultReports).HasForeignKey(f => f.UserId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(f => f.ChargingStation).WithMany(cs => cs.FaultReports).HasForeignKey(f => f.ChargingStationId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(f => f.Connector).WithMany(c => c.FaultReports).HasForeignKey(f => f.ConnectorId).OnDelete(DeleteBehavior.SetNull);
            });

            // ── ServiceOrder ──
            modelBuilder.Entity<ServiceOrder>(e =>
            {
                e.HasOne(so => so.FaultReport).WithMany(f => f.ServiceOrders).HasForeignKey(so => so.FaultReportId).OnDelete(DeleteBehavior.SetNull);
                e.HasOne(so => so.ChargingStation).WithMany(cs => cs.ServiceOrders).HasForeignKey(so => so.ChargingStationId).OnDelete(DeleteBehavior.Restrict);
            });

            // ── Transaction ──
            modelBuilder.Entity<Transaction>(e =>
            {
                e.HasOne(t => t.User).WithMany(u => u.Transactions).HasForeignKey(t => t.UserId).OnDelete(DeleteBehavior.Restrict);
                e.HasOne(t => t.ChargingSession).WithMany(cs => cs.Transactions).HasForeignKey(t => t.ChargingSessionId).OnDelete(DeleteBehavior.SetNull);
                e.HasIndex(t => t.StripePaymentIntentId).IsUnique().HasFilter("[StripePaymentIntentId] IS NOT NULL");
            });

            // ── Invoice ──
            modelBuilder.Entity<Invoice>(e =>
            {
                e.HasIndex(i => i.InvoiceNumber).IsUnique();
                e.HasOne(i => i.Transaction).WithOne(t => t.Invoice).HasForeignKey<Invoice>(i => i.TransactionId).OnDelete(DeleteBehavior.Cascade);
                e.HasOne(i => i.User).WithMany(u => u.Invoices).HasForeignKey(i => i.UserId).OnDelete(DeleteBehavior.Restrict);
                e.HasIndex(i => new { i.UserId, i.Status });
            });

            // ── Notification ──
            modelBuilder.Entity<Notification>(e =>
            {
                e.HasOne(n => n.User).WithMany(u => u.Notifications).HasForeignKey(n => n.UserId).OnDelete(DeleteBehavior.Cascade);
            });

            // ── LoyaltyProgram (1-to-1 with User) ──
            modelBuilder.Entity<LoyaltyProgram>(e =>
            {
                e.HasIndex(lp => lp.UserId).IsUnique();
                e.HasOne(lp => lp.User).WithOne(u => u.LoyaltyProgram).HasForeignKey<LoyaltyProgram>(lp => lp.UserId).OnDelete(DeleteBehavior.Cascade);
            });

            // ── UserStationProfile ──
            modelBuilder.Entity<UserStationProfile>(e =>
            {
                e.HasIndex(usp => new { usp.UserId, usp.ChargingStationId }).IsUnique();
                e.HasOne(usp => usp.User).WithMany(u => u.UserStationProfiles).HasForeignKey(usp => usp.UserId).OnDelete(DeleteBehavior.Cascade);
                e.HasOne(usp => usp.ChargingStation).WithMany(cs => cs.UserStationProfiles).HasForeignKey(usp => usp.ChargingStationId).OnDelete(DeleteBehavior.Cascade);
            });

            // ── StationVector (1-to-1 with ChargingStation) ──
            modelBuilder.Entity<StationVector>(e =>
            {
                e.HasIndex(sv => sv.ChargingStationId).IsUnique();
                e.HasOne(sv => sv.ChargingStation).WithOne(cs => cs.StationVector).HasForeignKey<StationVector>(sv => sv.ChargingStationId).OnDelete(DeleteBehavior.Cascade);
            });
        }
    }
}
