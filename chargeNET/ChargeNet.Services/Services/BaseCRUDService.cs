using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class BaseCRUDService<TEntity, TResponse, TSearch, TInsert, TUpdate> :
        BaseReadService<TEntity, TResponse, TSearch>,
        IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate>
        where TEntity : BaseEntity
        where TResponse : class
        where TSearch : class
    {
        public BaseCRUDService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper) { }

        public virtual async Task<TResponse> Insert(TInsert request)
        {
            var entity = MapInsert(request);
            _dbSet.Add(entity);
            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public virtual async Task<TResponse> Update(int id, TUpdate request)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
                throw new NotFoundException(typeof(TEntity).Name, id);

            MapUpdate(request, entity);
            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public virtual async Task Delete(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
                throw new NotFoundException(typeof(TEntity).Name, id);

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

        protected virtual TEntity MapInsert(TInsert request)
        {
            // Override in derived services to map from request DTO to entity
            throw new NotImplementedException($"MapInsert not implemented for {typeof(TEntity).Name}");
        }

        protected virtual void MapUpdate(TUpdate request, TEntity entity)
        {
            // Override in derived services to map from request DTO to existing entity
            throw new NotImplementedException($"MapUpdate not implemented for {typeof(TEntity).Name}");
        }
    }
}
