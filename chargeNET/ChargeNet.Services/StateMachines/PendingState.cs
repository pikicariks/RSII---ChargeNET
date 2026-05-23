using ChargeNet.Services.Database;

namespace ChargeNet.Services.StateMachines
{
    public class PendingState : BaseReservationState
    {
        protected override string StateName => "Pending";

        public override void Confirm(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Confirmed;
            reservation.RejectionReason = null;

            if (reservation.Connector != null)
            {
                reservation.Connector.IsAvailable = false;
            }
        }

        public override void Cancel(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Cancelled;
            FreeConnector(reservation);
        }

        public override void Reject(Reservation reservation, string reason)
        {
            reservation.StatusId = ReservationStatusIds.Rejected;
            reservation.RejectionReason = reason;
            FreeConnector(reservation);
        }

        public override void Expire(Reservation reservation)
        {
            reservation.StatusId = ReservationStatusIds.Expired;
            FreeConnector(reservation);
        }
    }
}
