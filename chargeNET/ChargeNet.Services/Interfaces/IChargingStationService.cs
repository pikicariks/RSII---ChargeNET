using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IChargingStationService :
        IBaseCRUDService<ChargingStationResponse, ChargingStationSearchObject, ChargingStationInsertRequest, ChargingStationUpdateRequest>
    {
    }
}
