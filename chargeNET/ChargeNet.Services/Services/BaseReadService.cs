using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
        where TEntity : BaseEntity
        where TResponse : class
        where TSearch : class
    {
        protected readonly ChargeNetDbContext _context;
        protected readonly IMapper _mapper;
        protected readonly DbSet<TEntity> _dbSet;

        public BaseReadService(ChargeNetDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _dbSet = context.Set<TEntity>();
        }

        public virtual async Task<IEnumerable<TResponse>> Get(TSearch? search = null)
        {
            var query = _dbSet.AsNoTracking().AsQueryable();
            query = AddFilter(query, search);
            query = AddInclude(query, search);

            var entities = await query.ToListAsync();
            return entities.Select(MapToResponse);
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
