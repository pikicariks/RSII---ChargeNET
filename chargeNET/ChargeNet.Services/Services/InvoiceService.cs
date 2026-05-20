using AutoMapper;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class InvoiceService :
        BaseReadService<Invoice, InvoiceResponse, InvoiceSearchObject>,
        IInvoiceService
    {
        public InvoiceService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
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
    }
}
