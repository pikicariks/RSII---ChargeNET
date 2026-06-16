using ChargeNet.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class ReportsController : ControllerBase
    {
        private readonly ChargeNetDbContext _context;

        public ReportsController(ChargeNetDbContext context)
        {
            _context = context;
        }

        [HttpGet("revenue.pdf")]
        public async Task<IActionResult> RevenuePdf([FromQuery] DateTime from, [FromQuery] DateTime to)
        {
            var start = from.Date;
            var end = to.Date.AddDays(1).AddTicks(-1);

            var transactions = await _context.Transactions
                .AsNoTracking()
                .Include(x => x.User)
                .Where(x =>
                    x.Status == "Completed" &&
                    x.CreatedAt >= start &&
                    x.CreatedAt <= end)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            var total = transactions.Sum(x => x.Amount);
            var bytes = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(24);
                    page.Size(PageSizes.A4);
                    page.DefaultTextStyle(TextStyle.Default.FontSize(10));
                    page.Header().Column(column =>
                    {
                        column.Item().Text("ChargeNET Revenue Report").SemiBold().FontSize(18);
                        column.Item().Text($"Range: {start:yyyy-MM-dd} to {to.Date:yyyy-MM-dd}").FontColor(Colors.Grey.Darken2);
                        column.Item().Text($"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC").FontColor(Colors.Grey.Darken2);
                        column.Item().Text($"Total revenue: {total:F2} EUR").SemiBold();
                    });

                    page.Content().PaddingTop(12).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(55);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                        });

                        static IContainer HeaderCell(IContainer c) =>
                            c.Background(Colors.Grey.Lighten3).PaddingVertical(4).PaddingHorizontal(6);
                        static IContainer BodyCell(IContainer c) =>
                            c.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(3).PaddingHorizontal(6);

                        table.Header(header =>
                        {
                            header.Cell().Element(HeaderCell).Text("Id").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Date").SemiBold();
                            header.Cell().Element(HeaderCell).Text("User").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Type").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Status").SemiBold();
                            header.Cell().Element(HeaderCell).AlignRight().Text("Amount").SemiBold();
                        });

                        foreach (var tx in transactions)
                        {
                            table.Cell().Element(BodyCell).Text(tx.Id.ToString());
                            table.Cell().Element(BodyCell).Text(tx.CreatedAt.ToString("yyyy-MM-dd"));
                            table.Cell().Element(BodyCell).Text(tx.User.Email);
                            table.Cell().Element(BodyCell).Text(tx.Type);
                            table.Cell().Element(BodyCell).Text(tx.Status);
                            table.Cell().Element(BodyCell).AlignRight().Text($"{tx.Amount:F2} {tx.Currency}");
                        }
                    });
                });
            }).GeneratePdf();

            var fileName = $"revenue-report-{start:yyyyMMdd}-{to.Date:yyyyMMdd}.pdf";
            return File(bytes, "application/pdf", fileName);
        }

        [HttpGet("sessions.pdf")]
        public async Task<IActionResult> SessionsPdf([FromQuery] DateTime from, [FromQuery] DateTime to)
        {
            var start = from.Date;
            var end = to.Date.AddDays(1).AddTicks(-1);

            var sessions = await _context.ChargingSessions
                .AsNoTracking()
                .Include(x => x.User)
                .Include(x => x.Connector)
                    .ThenInclude(x => x.ChargingStation)
                .Where(x =>
                    x.StartTime >= start &&
                    x.StartTime <= end)
                .OrderByDescending(x => x.StartTime)
                .ToListAsync();

            var completed = sessions.Count(x => x.EndTime.HasValue);
            var totalEnergy = sessions.Sum(x => x.EnergyConsumedKWh ?? 0m);

            var bytes = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(24);
                    page.Size(PageSizes.A4);
                    page.DefaultTextStyle(TextStyle.Default.FontSize(10));
                    page.Header().Column(column =>
                    {
                        column.Item().Text("ChargeNET Charging Sessions Report").SemiBold().FontSize(18);
                        column.Item().Text($"Range: {start:yyyy-MM-dd} to {to.Date:yyyy-MM-dd}").FontColor(Colors.Grey.Darken2);
                        column.Item().Text($"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC").FontColor(Colors.Grey.Darken2);
                        column.Item().Text($"Completed sessions: {completed}, total energy: {totalEnergy:F2} kWh").SemiBold();
                    });

                    page.Content().PaddingTop(12).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(40);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn(2);
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                            columns.RelativeColumn();
                        });

                        static IContainer HeaderCell(IContainer c) =>
                            c.Background(Colors.Grey.Lighten3).PaddingVertical(4).PaddingHorizontal(6);
                        static IContainer BodyCell(IContainer c) =>
                            c.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(3).PaddingHorizontal(6);

                        table.Header(header =>
                        {
                            header.Cell().Element(HeaderCell).Text("Id").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Start").SemiBold();
                            header.Cell().Element(HeaderCell).Text("User").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Station").SemiBold();
                            header.Cell().Element(HeaderCell).Text("Connector").SemiBold();
                            header.Cell().Element(HeaderCell).AlignRight().Text("kWh").SemiBold();
                            header.Cell().Element(HeaderCell).AlignRight().Text("Cost").SemiBold();
                        });

                        foreach (var session in sessions)
                        {
                            table.Cell().Element(BodyCell).Text(session.Id.ToString());
                            table.Cell().Element(BodyCell).Text(session.StartTime.ToString("yyyy-MM-dd HH:mm"));
                            table.Cell().Element(BodyCell).Text(session.User.Email);
                            table.Cell().Element(BodyCell).Text(session.Connector.ChargingStation.Name);
                            table.Cell().Element(BodyCell).Text(session.Connector.Label ?? "-");
                            table.Cell().Element(BodyCell).AlignRight().Text(session.EnergyConsumedKWh.HasValue ? $"{session.EnergyConsumedKWh.Value:F2}" : "-");
                            table.Cell().Element(BodyCell).AlignRight().Text(session.Cost.HasValue ? $"{session.Cost.Value:F2} EUR" : "-");
                        }
                    });
                });
            }).GeneratePdf();

            var fileName = $"sessions-report-{start:yyyyMMdd}-{to.Date:yyyyMMdd}.pdf";
            return File(bytes, "application/pdf", fileName);
        }
    }
}
