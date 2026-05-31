namespace ChargeNet.Services.Recommendation
{
    public interface IUserProfileService
    {
        Task<UserRecommendationProfile> GetProfileAsync(
            int userId,
            double latitude,
            double longitude,
            CancellationToken cancellationToken = default);

        Task UpdateProfileAsync(int userId, CancellationToken cancellationToken = default);
    }
}
