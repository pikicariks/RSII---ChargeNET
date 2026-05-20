using AutoMapper;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class TransactionService :
        BaseReadService<Transaction, TransactionResponse, TransactionSearchObject>,
        ITransactionService
    {
        public TransactionService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Transaction> AddFilter(IQueryable<Transaction> query, TransactionSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.ChargingSessionId.HasValue)
            {
                query = query.Where(x => x.ChargingSessionId == search.ChargingSessionId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Type))
            {
                query = query.Where(x => x.Type == search.Type);
            }

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                query = query.Where(x => x.Status == search.Status);
            }

            if (search.From.HasValue)
            {
                query = query.Where(x => x.CreatedAt >= search.From.Value);
            }

            if (search.To.HasValue)
            {
                query = query.Where(x => x.CreatedAt <= search.To.Value);
            }

            return query;
        }

        protected override IQueryable<Transaction> AddInclude(IQueryable<Transaction> query, TransactionSearchObject? search)
        {
            return query
                .Include(x => x.User)
                .Include(x => x.Invoice);
        }
    }
}
