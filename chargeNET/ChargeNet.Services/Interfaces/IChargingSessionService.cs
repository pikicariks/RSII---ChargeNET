using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IChargingSessionService : IBaseReadService<ChargingSessionResponse, ChargingSessionSearchObject>
    {
        Task<ChargingSessionResponse> Start(ChargingSessionStartRequest request);
        Task<ChargingSessionResponse> Complete(int id, ChargingSessionCompleteRequest request);
    }
}
