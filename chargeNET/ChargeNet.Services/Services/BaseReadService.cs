using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
        where TEntity : BaseEntity
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        protected readonly ChargeNetDbContext _context;
        protected readonly IMapper _mapper;
        protected readonly DbSet<TEntity> _dbSet;
        private const int MaxPageSize = 100;

        public BaseReadService(ChargeNetDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _dbSet = context.Set<TEntity>();
        }

        public virtual async Task<PagedResult<TResponse>> Get(TSearch? search = null)
        {
            search ??= Activator.CreateInstance<TSearch>();

            var page = search.Page < 1 ? 1 : search.Page;
            var pageSize = search.PageSize < 1 ? 20 : Math.Min(search.PageSize, MaxPageSize);

            var query = _dbSet.AsNoTracking().AsQueryable();
            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = query.OrderBy(x => x.Id);

            var totalCount = await query.CountAsync();
            var entities = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<TResponse>
            {
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount,
                Items = entities.Select(MapToResponse).ToList()
            };
        }

        public virtual async Task<TResponse> GetById(int id)
        {
            var query = AddInclude(_dbSet.AsNoTracking().AsQueryable(), null);
            var entity = await query.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
                throw new NotFoundException(typeof(TEntity).Name, id);

            return MapToResponse(entity);
        }

        protected virtual IQueryable<TEntity> AddFilter(IQueryable<TEntity> query, TSearch? search)
        {
            return query;
        }

        protected virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query, TSearch? search)
        {
            return query;
        }

        protected virtual TResponse MapToResponse(TEntity entity)
        {
            if (typeof(TEntity) == typeof(TResponse))
            {
                return (entity as TResponse)!;
            }

            return _mapper.Map<TResponse>(entity);
        }
    }
}
