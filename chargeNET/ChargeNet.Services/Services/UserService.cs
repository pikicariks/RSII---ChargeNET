using AutoMapper;
using ChargeNet.Model.Exceptions;
using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;
using ChargeNet.Model.Validation;
using ChargeNet.Services.Database;
using ChargeNet.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.Services.Services
{
    public class UserService : BaseCRUDService<User, UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<UserResponse> Insert(UserInsertRequest request)
        {
            NormalizeEmail(request);

            if (await EmailExistsAsync(request.Email))
            {
                throw new BusinessException("A user with this email already exists.", 409);
            }

            return await base.Insert(request);
        }

        public override async Task<UserResponse> Update(int id, UserUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Email))
            {
                request.Email = NormalizeEmail(request.Email);

                if (await EmailExistsAsync(request.Email, id))
                {
                    throw new BusinessException("A user with this email already exists.", 409);
                }
            }

            return await base.Update(id, request);
        }

        protected override IQueryable<User> AddFilter(IQueryable<User> query, UserSearchObject? search)
        {
            if (search == null)
            {
                return query.Where(x => !x.IsDeleted);
            }

            if (!search.IncludeDeleted)
            {
                query = query.Where(x => !x.IsDeleted);
            }

            if (search.IsDeleted.HasValue)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.FullText))
            {
                query = query.Where(x =>
                    x.FirstName.Contains(search.FullText) ||
                    x.LastName.Contains(search.FullText) ||
                    x.Email.Contains(search.FullText));
            }

            if (!string.IsNullOrWhiteSpace(search.Email))
            {
                query = query.Where(x => x.Email.Contains(search.Email));
            }

            if (search.RoleId.HasValue)
            {
                query = query.Where(x => x.RoleId == search.RoleId.Value);
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(x => x.CityId == search.CityId.Value);
            }

            return query;
        }

        protected override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObject? search)
        {
            return query
                .Include(x => x.Role)
                .Include(x => x.City);
        }

        protected override User MapInsert(UserInsertRequest request)
        {
            return new User
            {
                FirstName = request.FirstName.Trim(),
                LastName = request.LastName.Trim(),
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                PhoneNumber = request.PhoneNumber,
                RoleId = request.RoleId,
                CityId = request.CityId,
                Address = request.Address,
                IsDeleted = false
            };
        }

        protected override void MapUpdate(UserUpdateRequest request, User entity)
        {
            if (!string.IsNullOrWhiteSpace(request.FirstName))
            {
                entity.FirstName = request.FirstName.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.LastName))
            {
                entity.LastName = request.LastName.Trim();
            }

            if (!string.IsNullOrWhiteSpace(request.Email))
            {
                entity.Email = request.Email;
            }

            // Password is updated only when explicitly provided.
            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            }

            if (request.PhoneNumber != null)
            {
                entity.PhoneNumber = request.PhoneNumber;
            }

            if (request.RoleId.HasValue)
            {
                entity.RoleId = request.RoleId.Value;
            }

            if (request.CityId.HasValue)
            {
                entity.CityId = request.CityId.Value;
            }

            if (request.Address != null)
            {
                entity.Address = request.Address;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        private static void NormalizeEmail(UserInsertRequest request)
        {
            request.Email = NormalizeEmail(request.Email);
        }

        private static string NormalizeEmail(string email)
        {
            EmailValidation.TryNormalizeAndValidate(email, out var normalizedEmail, out _);
            return normalizedEmail;
        }

        private async Task<bool> EmailExistsAsync(string normalizedEmail, int? excludeUserId = null)
        {
            var query = _context.Users.Where(x => x.Email.ToLower() == normalizedEmail);

            if (excludeUserId.HasValue)
            {
                query = query.Where(x => x.Id != excludeUserId.Value);
            }

            return await query.AnyAsync();
        }
    }
}
