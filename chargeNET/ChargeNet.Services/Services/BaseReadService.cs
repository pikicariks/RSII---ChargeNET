using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class BaseReadService<T, TSearch> : IBaseReadService<T, TSearch> where T : class where TSearch : class
    {
        protected readonly ChargeNetDbContext _context;
        protected readonly DbSet<T> _dbSet;

        public BaseReadService(ChargeNetDbContext context)
        {
            _context = context;
            _dbSet = context.Set<T>();
        }

        public virtual async Task<IEnumerable<T>> Get(TSearch? search = null)
        {
            return await _dbSet.AsNoTracking().ToListAsync();
        }

        public virtual async Task<T> GetById(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
                throw new NotFoundException(typeof(T).Name, id);

            return entity;
        }
    }
}
