using ChargeNet.Model.Responses;

namespace ChargeNet.Services.Recommendation
{
    public interface IRecommendationService
    {
        Task<List<RecommendedStationResponse>> GetRecommendationsAsync(
            int userId,
            double latitude,
            double longitude,
            int topN = 10,
            CancellationToken cancellationToken = default);
    }
}
