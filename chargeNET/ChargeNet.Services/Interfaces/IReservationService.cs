using ChargeNet.Model.Requests;
using ChargeNet.Model.Responses;
using ChargeNet.Model.SearchObjects;

namespace ChargeNet.Services.Interfaces
{
    public interface IReservationService : IBaseCRUDService<ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        Task<ReservationResponse> Confirm(int id);
        Task<ReservationResponse> Cancel(int id);
        Task<ReservationResponse> Complete(int id);
        Task<ReservationResponse> Reject(int id, ReservationRejectRequest request);
        Task<ReservationResponse> Expire(int id);
    }
}
