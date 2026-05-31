namespace ChargeNet.Services.Recommendation
{
    public interface IStationVectorService
    {
        Task EnsureVectorsAsync(CancellationToken cancellationToken = default);
        Task RecomputeAsync(int chargingStationId, CancellationToken cancellationToken = default);
        Task RecomputeAllAsync(CancellationToken cancellationToken = default);
    }
}
