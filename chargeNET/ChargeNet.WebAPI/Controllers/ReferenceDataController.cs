using System.ComponentModel.DataAnnotations;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ChargeNet.WebAPI.Controllers
{
    [ApiController]
    [Route("api/reference-data")]
    [Authorize]
    public class ReferenceDataController : ControllerBase
    {
        private readonly ChargeNetDbContext _context;
        private const int MaxPageSize = 100;

        public ReferenceDataController(ChargeNetDbContext context)
        {
            _context = context;
        }

        [HttpGet("countries")]
        public Task<IActionResult> GetCountries([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.Countries.AsNoTracking().OrderBy(x => x.Id),
                query,
                x => new CountryDto(x.Id, x.Name, x.Code));

        [HttpGet("cities")]
        public Task<IActionResult> GetCities([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.Cities.AsNoTracking().Include(x => x.Country).OrderBy(x => x.Id),
                query,
                x => new CityDto(x.Id, x.Name, x.PostalCode, x.CountryId, x.Country.Name));

        [HttpGet("roles")]
        public Task<IActionResult> GetRoles([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.Roles.AsNoTracking().OrderBy(x => x.Id),
                query,
                x => new NamedDescriptionDto(x.Id, x.Name, x.Description));

        [HttpGet("station-statuses")]
        public Task<IActionResult> GetStationStatuses([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.StationStatuses.AsNoTracking().OrderBy(x => x.Id),
                query,
                x => new NamedDescriptionDto(x.Id, x.Name, x.Description));

        [HttpGet("reservation-statuses")]
        public Task<IActionResult> GetReservationStatuses([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.ReservationStatuses.AsNoTracking().OrderBy(x => x.Id),
                query,
                x => new NamedDescriptionDto(x.Id, x.Name, x.Description));

        [HttpGet("connector-types")]
        public Task<IActionResult> GetConnectorTypes([FromQuery] PaginationQuery query) =>
            GetPaged(
                _context.ConnectorTypes.AsNoTracking().OrderBy(x => x.Id),
                query,
                x => new ConnectorTypeDto(x.Id, x.Name, x.Description, x.PowerRating));

        [Authorize(Roles = "Admin")]
        [HttpPost("countries")]
        public async Task<IActionResult> CreateCountry([FromBody] CountryUpsertRequest request)
        {
            var entity = new Country
            {
                Name = request.Name.Trim(),
                Code = request.Code.Trim().ToUpperInvariant()
            };

            _context.Countries.Add(entity);
            await _context.SaveChangesAsync();
            return Ok(new CountryDto(entity.Id, entity.Name, entity.Code));
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("countries/{id:int}")]
        public async Task<IActionResult> UpdateCountry(int id, [FromBody] CountryUpsertRequest request)
        {
            var entity = await _context.Countries.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            entity.Name = request.Name.Trim();
            entity.Code = request.Code.Trim().ToUpperInvariant();
            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(new CountryDto(entity.Id, entity.Name, entity.Code));
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("countries/{id:int}")]
        public async Task<IActionResult> DeleteCountry(int id)
        {
            var entity = await _context.Countries.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            _context.Countries.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("cities")]
        public async Task<IActionResult> CreateCity([FromBody] CityUpsertRequest request)
        {
            var entity = new City
            {
                Name = request.Name.Trim(),
                PostalCode = request.PostalCode.Trim(),
                CountryId = request.CountryId
            };

            _context.Cities.Add(entity);
            await _context.SaveChangesAsync();

            var countryName = await _context.Countries
                .Where(x => x.Id == entity.CountryId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync() ?? string.Empty;

            return Ok(new CityDto(entity.Id, entity.Name, entity.PostalCode, entity.CountryId, countryName));
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("cities/{id:int}")]
        public async Task<IActionResult> UpdateCity(int id, [FromBody] CityUpsertRequest request)
        {
            var entity = await _context.Cities.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            entity.Name = request.Name.Trim();
            entity.PostalCode = request.PostalCode.Trim();
            entity.CountryId = request.CountryId;
            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var countryName = await _context.Countries
                .Where(x => x.Id == entity.CountryId)
                .Select(x => x.Name)
                .FirstOrDefaultAsync() ?? string.Empty;

            return Ok(new CityDto(entity.Id, entity.Name, entity.PostalCode, entity.CountryId, countryName));
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("cities/{id:int}")]
        public async Task<IActionResult> DeleteCity(int id)
        {
            var entity = await _context.Cities.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            _context.Cities.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("roles")]
        public Task<IActionResult> CreateRole([FromBody] NamedDescriptionUpsertRequest request) =>
            CreateNamedEntity(_context.Roles, request);

        [Authorize(Roles = "Admin")]
        [HttpPut("roles/{id:int}")]
        public Task<IActionResult> UpdateRole(int id, [FromBody] NamedDescriptionUpsertRequest request) =>
            UpdateNamedEntity(_context.Roles, id, request);

        [Authorize(Roles = "Admin")]
        [HttpDelete("roles/{id:int}")]
        public Task<IActionResult> DeleteRole(int id) => DeleteNamedEntity(_context.Roles, id);

        [Authorize(Roles = "Admin")]
        [HttpPost("station-statuses")]
        public Task<IActionResult> CreateStationStatus([FromBody] NamedDescriptionUpsertRequest request) =>
            CreateNamedEntity(_context.StationStatuses, request);

        [Authorize(Roles = "Admin")]
        [HttpPut("station-statuses/{id:int}")]
        public Task<IActionResult> UpdateStationStatus(int id, [FromBody] NamedDescriptionUpsertRequest request) =>
            UpdateNamedEntity(_context.StationStatuses, id, request);

        [Authorize(Roles = "Admin")]
        [HttpDelete("station-statuses/{id:int}")]
        public Task<IActionResult> DeleteStationStatus(int id) => DeleteNamedEntity(_context.StationStatuses, id);

        [Authorize(Roles = "Admin")]
        [HttpPost("reservation-statuses")]
        public Task<IActionResult> CreateReservationStatus([FromBody] NamedDescriptionUpsertRequest request) =>
            CreateNamedEntity(_context.ReservationStatuses, request);

        [Authorize(Roles = "Admin")]
        [HttpPut("reservation-statuses/{id:int}")]
        public Task<IActionResult> UpdateReservationStatus(int id, [FromBody] NamedDescriptionUpsertRequest request) =>
            UpdateNamedEntity(_context.ReservationStatuses, id, request);

        [Authorize(Roles = "Admin")]
        [HttpDelete("reservation-statuses/{id:int}")]
        public Task<IActionResult> DeleteReservationStatus(int id) => DeleteNamedEntity(_context.ReservationStatuses, id);

        [Authorize(Roles = "Admin")]
        [HttpPost("connector-types")]
        public async Task<IActionResult> CreateConnectorType([FromBody] ConnectorTypeUpsertRequest request)
        {
            var entity = new ConnectorType
            {
                Name = request.Name.Trim(),
                Description = request.Description?.Trim(),
                PowerRating = request.PowerRating
            };

            _context.ConnectorTypes.Add(entity);
            await _context.SaveChangesAsync();
            return Ok(new ConnectorTypeDto(entity.Id, entity.Name, entity.Description, entity.PowerRating));
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("connector-types/{id:int}")]
        public async Task<IActionResult> UpdateConnectorType(int id, [FromBody] ConnectorTypeUpsertRequest request)
        {
            var entity = await _context.ConnectorTypes.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            entity.Name = request.Name.Trim();
            entity.Description = request.Description?.Trim();
            entity.PowerRating = request.PowerRating;
            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(new ConnectorTypeDto(entity.Id, entity.Name, entity.Description, entity.PowerRating));
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("connector-types/{id:int}")]
        public async Task<IActionResult> DeleteConnectorType(int id)
        {
            var entity = await _context.ConnectorTypes.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            _context.ConnectorTypes.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private static (int Page, int PageSize) NormalizePage(PaginationQuery query)
        {
            var page = query.Page < 1 ? 1 : query.Page;
            var pageSize = query.PageSize < 1 ? 20 : Math.Min(query.PageSize, MaxPageSize);
            return (page, pageSize);
        }

        private async Task<IActionResult> GetPaged<TEntity, TDto>(
            IQueryable<TEntity> query,
            PaginationQuery pageQuery,
            Func<TEntity, TDto> map)
            where TEntity : BaseEntity
        {
            var (page, pageSize) = NormalizePage(pageQuery);
            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new PagedResult<TDto>
            {
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount,
                Items = items.Select(map).ToList()
            });
        }

        private async Task<IActionResult> CreateNamedEntity<T>(
            DbSet<T> set,
            NamedDescriptionUpsertRequest request)
            where T : BaseEntity, new()
        {
            var entity = new T();
            switch (entity)
            {
                case Role role:
                    role.Name = request.Name.Trim();
                    role.Description = request.Description?.Trim();
                    set.Add((T)(object)role);
                    break;
                case StationStatus status:
                    status.Name = request.Name.Trim();
                    status.Description = request.Description?.Trim();
                    set.Add((T)(object)status);
                    break;
                case ReservationStatus reservationStatus:
                    reservationStatus.Name = request.Name.Trim();
                    reservationStatus.Description = request.Description?.Trim();
                    set.Add((T)(object)reservationStatus);
                    break;
                default:
                    return BadRequest();
            }

            await _context.SaveChangesAsync();
            return Ok(new NamedDescriptionDto(entity.Id, request.Name.Trim(), request.Description?.Trim()));
        }

        private async Task<IActionResult> UpdateNamedEntity<T>(
            DbSet<T> set,
            int id,
            NamedDescriptionUpsertRequest request)
            where T : BaseEntity
        {
            var entity = await set.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            switch (entity)
            {
                case Role role:
                    role.Name = request.Name.Trim();
                    role.Description = request.Description?.Trim();
                    break;
                case StationStatus status:
                    status.Name = request.Name.Trim();
                    status.Description = request.Description?.Trim();
                    break;
                case ReservationStatus reservationStatus:
                    reservationStatus.Name = request.Name.Trim();
                    reservationStatus.Description = request.Description?.Trim();
                    break;
                default:
                    return BadRequest();
            }

            entity.ModifiedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(new NamedDescriptionDto(entity.Id, request.Name.Trim(), request.Description?.Trim()));
        }

        private async Task<IActionResult> DeleteNamedEntity<T>(DbSet<T> set, int id)
            where T : BaseEntity
        {
            var entity = await set.FirstOrDefaultAsync(x => x.Id == id);
            if (entity == null)
            {
                return NotFound();
            }

            set.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        public class PaginationQuery
        {
            public int Page { get; set; } = 1;
            public int PageSize { get; set; } = 20;
        }

        public record CountryDto(int Id, string Name, string Code);
        public record CityDto(int Id, string Name, string PostalCode, int CountryId, string CountryName);
        public record NamedDescriptionDto(int Id, string Name, string? Description);
        public record ConnectorTypeDto(int Id, string Name, string? Description, decimal? PowerRating);

        public class CountryUpsertRequest
        {
            [Required]
            [MaxLength(100)]
            public string Name { get; set; } = string.Empty;

            [Required]
            [MaxLength(3)]
            public string Code { get; set; } = string.Empty;
        }

        public class CityUpsertRequest
        {
            [Required]
            [MaxLength(100)]
            public string Name { get; set; } = string.Empty;

            [Required]
            [MaxLength(20)]
            public string PostalCode { get; set; } = string.Empty;

            [Required]
            public int CountryId { get; set; }
        }

        public class NamedDescriptionUpsertRequest
        {
            [Required]
            [MaxLength(50)]
            public string Name { get; set; } = string.Empty;

            [MaxLength(200)]
            public string? Description { get; set; }
        }

        public class ConnectorTypeUpsertRequest
        {
            [Required]
            [MaxLength(50)]
            public string Name { get; set; } = string.Empty;

            [MaxLength(200)]
            public string? Description { get; set; }

            public decimal? PowerRating { get; set; }
        }
    }
}
