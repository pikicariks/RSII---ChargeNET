using ChargeNet.Services.Database;

namespace ChargeNet.Services.StateMachines
{
    public interface IReservationState
    {
        void Confirm(Reservation reservation);
        void Cancel(Reservation reservation);
        void Complete(Reservation reservation);
        void Reject(Reservation reservation, string reason);
        void Expire(Reservation reservation);
    }
}
