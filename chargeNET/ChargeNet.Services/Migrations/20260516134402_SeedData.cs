using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ChargeNet.Services.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "ConnectorTypes",
                columns: new[] { "Id", "CreatedAt", "Description", "ModifiedAt", "Name", "PowerRating" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(9534), "IEC 62196-2 Type 2 (Mennekes)", null, "Type 2", 43.0m },
                    { 2, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(316), "Combined Charging System (Combo 2)", null, "CCS", 350.0m },
                    { 3, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(319), "CHAdeMO DC fast charging", null, "CHAdeMO", 62.5m }
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "Id", "Code", "CreatedAt", "ModifiedAt", "Name" },
                values: new object[,]
                {
                    { 1, "BIH", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(2665), null, "Bosnia and Herzegovina" },
                    { 2, "HRV", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3043), null, "Croatia" },
                    { 3, "SRB", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3045), null, "Serbia" },
                    { 4, "SVN", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3046), null, "Slovenia" },
                    { 5, "MNE", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3047), null, "Montenegro" },
                    { 6, "DEU", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3048), null, "Germany" },
                    { 7, "AUT", new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3049), null, "Austria" }
                });

            migrationBuilder.InsertData(
                table: "ReservationStatuses",
                columns: new[] { "Id", "CreatedAt", "Description", "ModifiedAt", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1171), "Awaiting confirmation", null, "Pending" },
                    { 2, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1543), "Reservation confirmed", null, "Confirmed" },
                    { 3, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1546), "Reservation rejected", null, "Rejected" },
                    { 4, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1547), "Cancelled by user", null, "Cancelled" },
                    { 5, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1549), "Successfully used", null, "Completed" },
                    { 6, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(1550), "Reservation expired", null, "Expired" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "ModifiedAt", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(2323), "Full system access", null, "Admin" },
                    { 2, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(2821), "Station technician", null, "Technician" },
                    { 3, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(2823), "Mobile application user and EV driver", null, "Driver" }
                });

            migrationBuilder.InsertData(
                table: "StationStatuses",
                columns: new[] { "Id", "CreatedAt", "Description", "ModifiedAt", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(8042), "Operational", null, "Active" },
                    { 2, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(8412), "Temporarily unavailable", null, "Inactive" },
                    { 3, new DateTime(2026, 5, 16, 13, 44, 1, 272, DateTimeKind.Utc).AddTicks(8414), "Under maintenance", null, "Maintenance" }
                });

            migrationBuilder.InsertData(
                table: "Tariffs",
                columns: new[] { "Id", "CreatedAt", "Currency", "EndHour", "IsActive", "ModifiedAt", "Name", "PricePerKWh", "PricePerMinute", "StartHour", "ValidFrom", "ValidTo" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(7965), "EUR", null, true, null, "Standard Day", 0.25m, null, null, null, null },
                    { 2, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(8576), "EUR", new TimeSpan(0, 6, 0, 0, 0), true, null, "Night Saver", 0.15m, null, new TimeSpan(0, 22, 0, 0, 0), null, null },
                    { 3, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(8914), "EUR", null, true, null, "Fast Charge Premium", 0.45m, 0.05m, null, null, null }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "CountryId", "CreatedAt", "ModifiedAt", "Name", "PostalCode" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(3804), null, "Sarajevo", "71000" },
                    { 2, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4234), null, "Banja Luka", "78000" },
                    { 3, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4236), null, "Tuzla", "75000" },
                    { 4, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4237), null, "Mostar", "88000" },
                    { 5, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4238), null, "Zenica", "72000" },
                    { 6, 2, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4239), null, "Zagreb", "10000" },
                    { 7, 2, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(4240), null, "Split", "21000" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Address", "CityId", "CreatedAt", "Email", "FirstName", "LastName", "ModifiedAt", "PasswordHash", "PhoneNumber", "ProfileImage", "RoleId" },
                values: new object[,]
                {
                    { 1, null, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(6345), "admin@chargenet.com", "Admin", "ChargeNET", null, "$2a$11$PLACEHOLDER_HASH_ADMIN_PASSWORD", null, null, 1 },
                    { 2, null, 1, new DateTime(2026, 5, 16, 13, 44, 1, 273, DateTimeKind.Utc).AddTicks(7353), "demo@chargenet.com", "Demo", "Driver", null, "$2a$11$PLACEHOLDER_HASH_DEMO_PASSWORD", null, null, 3 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "ConnectorTypes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ConnectorTypes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ConnectorTypes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ReservationStatuses",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StationStatuses",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StationStatuses",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StationStatuses",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Tariffs",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: 1);
        }
    }
}
