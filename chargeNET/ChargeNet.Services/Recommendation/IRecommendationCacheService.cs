using ChargeNet.Model.Responses;

namespace ChargeNet.Services.Recommendation
{
    public interface IRecommendationCacheService
    {
        bool TryGet(
            int userId,
            double latitude,
            double longitude,
            int topN,
            out List<RecommendedStationResponse>? recommendations);

        void Set(
            int userId,
            double latitude,
            double longitude,
            int topN,
            List<RecommendedStationResponse> recommendations);

        void InvalidateUser(int userId);
        void InvalidateAll();
    }
}
