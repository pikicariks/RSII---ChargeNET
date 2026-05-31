using System.Collections.Concurrent;
using ChargeNet.Model.Responses;
using Microsoft.Extensions.Caching.Memory;

namespace ChargeNet.Services.Recommendation
{
    public class RecommendationCacheService : IRecommendationCacheService
    {
        private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(15);
        private readonly IMemoryCache _memoryCache;
        private readonly ConcurrentDictionary<int, ConcurrentDictionary<string, byte>> _keysByUser = new();

        public RecommendationCacheService(IMemoryCache memoryCache)
        {
            _memoryCache = memoryCache;
        }

        public bool TryGet(
            int userId,
            double latitude,
            double longitude,
            int topN,
            out List<RecommendedStationResponse>? recommendations)
        {
            var cacheKey = BuildKey(userId, latitude, longitude, topN);
            return _memoryCache.TryGetValue(cacheKey, out recommendations);
        }

        public void Set(
            int userId,
            double latitude,
            double longitude,
            int topN,
            List<RecommendedStationResponse> recommendations)
        {
            var cacheKey = BuildKey(userId, latitude, longitude, topN);
            _memoryCache.Set(cacheKey, recommendations, CacheDuration);

            var keys = _keysByUser.GetOrAdd(userId, _ => new ConcurrentDictionary<string, byte>());
            keys.TryAdd(cacheKey, 0);
        }

        public void InvalidateUser(int userId)
        {
            if (!_keysByUser.TryRemove(userId, out var keys))
            {
                return;
            }

            foreach (var cacheKey in keys.Keys)
            {
                _memoryCache.Remove(cacheKey);
            }
        }

        public void InvalidateAll()
        {
            foreach (var userId in _keysByUser.Keys.ToList())
            {
                InvalidateUser(userId);
            }
        }

        private static string BuildKey(int userId, double latitude, double longitude, int topN)
        {
            var roundedLatitude = Math.Round(latitude, 4);
            var roundedLongitude = Math.Round(longitude, 4);
            return $"recommendations:{userId}:{roundedLatitude:F4}:{roundedLongitude:F4}:{topN}";
        }
    }
}
