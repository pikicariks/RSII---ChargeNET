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
    public class TariffService : BaseCRUDService<Tariff, TariffResponse, TariffSearchObject, TariffInsertRequest, TariffUpdateRequest>, ITariffService
    {
        public TariffService(ChargeNetDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<TariffResponse> Insert(TariffInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
            {
                throw new ValidationException("Tariff Name is required.");
            }

            var exists = await _context.Tariffs.AnyAsync(x => x.Name == request.Name);
            if (exists)
            {
                throw new BusinessException("A tariff with this name already exists.", 409);
            }

            return await base.Insert(request);
        }

        public override async Task<TariffResponse> Update(int id, TariffUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                var exists = await _context.Tariffs.AnyAsync(x => x.Id != id && x.Name == request.Name);
                if (exists)
                {
                    throw new BusinessException("A tariff with this name already exists.", 409);
                }
            }

            return await base.Update(id, request);
        }

        protected override IQueryable<Tariff> AddFilter(IQueryable<Tariff> query, TariffSearchObject? search)
        {
            if (search == null)
            {
                return query;
            }

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (!string.IsNullOrWhiteSpace(search.Currency))
            {
                query = query.Where(x => x.Currency == search.Currency);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            if (search.ValidAt.HasValue)
            {
                var date = search.ValidAt.Value;
                query = query.Where(x =>
                    (!x.ValidFrom.HasValue || x.ValidFrom.Value <= date) &&
                    (!x.ValidTo.HasValue || x.ValidTo.Value >= date));
            }

            return query;
        }

        protected override Tariff MapInsert(TariffInsertRequest request)
        {
            return new Tariff
            {
                Name = request.Name.Trim(),
                PricePerKWh = request.PricePerKWh,
                PricePerMinute = request.PricePerMinute,
                Currency = request.Currency.Trim().ToUpperInvariant(),
                StartHour = request.StartHour,
                EndHour = request.EndHour,
                IsActive = request.IsActive,
                ValidFrom = request.ValidFrom,
                ValidTo = request.ValidTo
            };
        }

        protected override void MapUpdate(TariffUpdateRequest request, Tariff entity)
        {
            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                entity.Name = request.Name.Trim();
            }

            if (request.PricePerKWh.HasValue)
            {
                entity.PricePerKWh = request.PricePerKWh.Value;
            }

            if (request.PricePerMinute.HasValue)
            {
                entity.PricePerMinute = request.PricePerMinute.Value;
            }
            else if (request.ClearPricePerMinute)
            {
                entity.PricePerMinute = null;
            }

            if (!string.IsNullOrWhiteSpace(request.Currency))
            {
                entity.Currency = request.Currency.Trim().ToUpperInvariant();
            }

            if (request.StartHour.HasValue)
            {
                entity.StartHour = request.StartHour.Value;
            }
            else if (request.ClearStartHour)
            {
                entity.StartHour = null;
            }

            if (request.EndHour.HasValue)
            {
                entity.EndHour = request.EndHour.Value;
            }
            else if (request.ClearEndHour)
            {
                entity.EndHour = null;
            }

            if (request.IsActive.HasValue)
            {
                entity.IsActive = request.IsActive.Value;
            }

            if (request.ValidFrom.HasValue)
            {
                entity.ValidFrom = request.ValidFrom.Value;
            }
            else if (request.ClearValidFrom)
            {
                entity.ValidFrom = null;
            }

            if (request.ValidTo.HasValue)
            {
                entity.ValidTo = request.ValidTo.Value;
            }
            else if (request.ClearValidTo)
            {
                entity.ValidTo = null;
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }
    }
}
