using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class BaseCRUDService<T, TInsert, TUpdate> : BaseReadService<T, object>, IBaseCRUDService<T, TInsert, TUpdate>
        where T : class
    {
        public BaseCRUDService(ChargeNetDbContext context) : base(context) { }

        public virtual async Task<T> Insert(TInsert request)
        {
            var entity = MapInsert(request);
            _dbSet.Add(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task<T> Update(int id, TUpdate request)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
                throw new NotFoundException(typeof(T).Name, id);

            MapUpdate(request, entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task Delete(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
                throw new NotFoundException(typeof(T).Name, id);

            // Soft delete for User entities
            if (entity is User user)
            {
                user.IsDeleted = true;
            }
            else
            {
                _dbSet.Remove(entity);
            }

            await _context.SaveChangesAsync();
        }

        protected virtual T MapInsert(TInsert request)
        {
            // Override in derived services to map from request DTO to entity
            throw new NotImplementedException($"MapInsert not implemented for {typeof(T).Name}");
        }

        protected virtual void MapUpdate(TUpdate request, T entity)
        {
            // Override in derived services to map from request DTO to existing entity
            throw new NotImplementedException($"MapUpdate not implemented for {typeof(T).Name}");
        }
    }
}
