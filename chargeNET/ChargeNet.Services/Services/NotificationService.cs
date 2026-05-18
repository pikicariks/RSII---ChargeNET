using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class NotificationService :
        BaseCRUDService<Notification, NotificationResponse, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>,
        INotificationService
    {
        public NotificationService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<NotificationResponse> Insert(NotificationInsertRequest request)
        {
            var userExists = await _context.Users.AnyAsync(x => x.Id == request.UserId && !x.IsDeleted);
            if (!userExists)
            {
                throw new ValidationException($"User with id {request.UserId} does not exist.");
            }

            return await base.Insert(request);
        }

        public async Task<NotificationResponse> MarkAsRead(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity == null)
            {
                throw new NotFoundException(nameof(Notification), id);
            }

            entity.IsRead = true;
            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return await GetById(id);
        }

        protected override IQueryable<Notification> AddFilter(IQueryable<Notification> query, NotificationSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(x => x.IsRead == search.IsRead.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.NotificationType))
            {
                query = query.Where(x => x.NotificationType == search.NotificationType);
            }

            if (!string.IsNullOrWhiteSpace(search.FullText))
            {
                query = query.Where(x => x.Title.Contains(search.FullText) || x.Message.Contains(search.FullText));
            }

            return query;
        }

        protected override Notification MapInsert(NotificationInsertRequest request)
        {
            return new Notification
            {
                UserId = request.UserId,
                Title = request.Title.Trim(),
                Message = request.Message.Trim(),
                NotificationType = request.NotificationType.Trim(),
                RelatedEntityType = request.RelatedEntityType,
                RelatedEntityId = request.RelatedEntityId,
                IsRead = false
            };
        }

        protected override void MapUpdate(NotificationUpdateRequest request, Notification entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Title))
            {
                entity.Title = request.Title.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.Message))
            {
                entity.Message = request.Message.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.NotificationType))
            {
                entity.NotificationType = request.NotificationType.Trim();
            }

            if (request.IsRead.HasValue)
            {
                entity.IsRead = request.IsRead.Value;
            }

            if (request.RelatedEntityType != null)
            {
                entity.RelatedEntityType = request.RelatedEntityType;
            }
            else if (request.ClearRelatedEntityType)
            {
                entity.RelatedEntityType = null;
            }

            if (request.RelatedEntityId.HasValue)
            {
                entity.RelatedEntityId = request.RelatedEntityId.Value;
            }
            else if (request.ClearRelatedEntityId)
            {
                entity.RelatedEntityId = null;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }
    }
}
