using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Messages;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using ChargeNet.Services.Invoicing;
using ChargeNet.Services.Messaging;
using ChargeNet.Services.Payment;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace ChargeNet.Services.Services
{
    public class InvoiceService :
        BaseReadService<Invoice, InvoiceResponse, InvoiceSearchObject>,
        IInvoiceService
    {
        private readonly IInvoiceGenerationPublisher _publisher;
        private readonly ILogger<InvoiceService> _logger;

        public InvoiceService(
            ChargeNetDbContext context,
            IMapper mapper,
            IInvoiceGenerationPublisher publisher,
            ILogger<InvoiceService> logger) : base(context, mapper)
        {
            _publisher = publisher;
            _logger = logger;
        }

        public async Task<InvoiceResponse?> CreateForTransactionAsync(
            int transactionId,
            CancellationToken cancellationToken = default)
        {
            var transaction = await _context.Transactions
                .AsNoTracking()
                .FirstOrDefaultAsync(t => t.Id == transactionId, cancellationToken);

            if (transaction == null)
            {
                throw new NotFoundException(nameof(Transaction), transactionId);
            }

            if (transaction.Status != PaymentConstants.TransactionStatuses.Completed)
            {
                return null;
            }

            if (transaction.Type != PaymentConstants.TransactionTypes.TopUp &&
                transaction.Type != PaymentConstants.TransactionTypes.Payment)
            {
                return null;
            }

            var existingInvoice = await _dbSet
                .AsNoTracking()
                .FirstOrDefaultAsync(invoice => invoice.TransactionId == transactionId, cancellationToken);

            if (existingInvoice != null)
            {
                return await GetById(existingInvoice.Id);
            }

            var invoiceDate = DateTime.UtcNow;
            var invoice = new Invoice
            {
                InvoiceNumber = await GenerateInvoiceNumberAsync(invoiceDate.Year, cancellationToken),
                TransactionId = transactionId,
                UserId = transaction.UserId,
                InvoiceDate = invoiceDate,
                DueDate = invoiceDate.AddDays(InvoiceConstants.DueDays),
                TotalAmount = transaction.Amount,
                Currency = transaction.Currency,
                Status = InvoiceConstants.StatusPending,
                CreatedAt = invoiceDate
            };

            _dbSet.Add(invoice);
            await _context.SaveChangesAsync(cancellationToken);

            try
            {
                await _publisher.PublishAsync(new InvoiceGenerationMessage
                {
                    InvoiceId = invoice.Id,
                    TransactionId = transactionId,
                    UserId = transaction.UserId,
                    InvoiceNumber = invoice.InvoiceNumber,
                    IssuedAt = invoice.InvoiceDate
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(
                    ex,
                    "Invoice {InvoiceId} created but message publish failed. PDF generation must be retried manually.",
                    invoice.Id);
            }

            return await GetById(invoice.Id);
        }

        protected override IQueryable<Invoice> AddFilter(IQueryable<Invoice> query, InvoiceSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.TransactionId.HasValue)
            {
                query = query.Where(x => x.TransactionId == search.TransactionId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                query = query.Where(x => x.Status == search.Status);
            }

            if (!string.IsNullOrWhiteSpace(search.InvoiceNumber))
            {
                query = query.Where(x => x.InvoiceNumber.Contains(search.InvoiceNumber));
            }

            if (search.From.HasValue)
            {
                query = query.Where(x => x.InvoiceDate >= search.From.Value);
            }

            if (search.To.HasValue)
            {
                query = query.Where(x => x.InvoiceDate <= search.To.Value);
            }

            return query;
        }

        protected override IQueryable<Invoice> AddInclude(IQueryable<Invoice> query, InvoiceSearchObject? search)
        {
            return query.Include(x => x.User);
        }

        private async Task<string> GenerateInvoiceNumberAsync(int year, CancellationToken cancellationToken)
        {
            var prefix = $"INV-{year}-";
            var count = await _dbSet.CountAsync(
                invoice => invoice.InvoiceNumber.StartsWith(prefix),
                cancellationToken);

            return $"{prefix}{(count + 1):D5}";
        }
    }
}
