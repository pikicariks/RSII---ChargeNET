using ChargeNet.Services.Database;

namespace ChargeNet.Services.StateMachines
{
    public class ConfirmedState : BaseReservationState
    {
        protected override string StateName => "Confirmed";

        public override void Complete(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Completed;
            FreeConnector(reservation);
        }

        public override void Cancel(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Cancelled;
            FreeConnector(reservation);
        }

        public override void Expire(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Expired;
            FreeConnector(reservation);
        }
    }
}
