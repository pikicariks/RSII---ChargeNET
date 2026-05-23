using ChargeNet.Model.Exceptions;
using ChargeNet.Services.Database;

namespace ChargeNet.Services.StateMachines
{
    public abstract class BaseReservationState : IReservationState
    {
        protected abstract string StateName { get; }

        public virtual void Confirm(Reservation reservation) =>
            ThrowInvalidTransition(nameof(Confirm));

        public virtual void Cancel(Reservation reservation) =>
            ThrowInvalidTransition(nameof(Cancel));

        public virtual void Complete(Reservation reservation) =>
            ThrowInvalidTransition(nameof(Complete));

        public virtual void Reject(Reservation reservation, string reason) =>
            ThrowInvalidTransition(nameof(Reject));

        public virtual void Expire(Reservation reservation) =>
            ThrowInvalidTransition(nameof(Expire));

        protected static void FreeConnector(Reservation reservation)
        {
            if (reservation.Connector != null)
            {
                reservation.Connector.IsAvailable = true;
            }
        }

        protected void ThrowInvalidTransition(string action)
        {
            throw new BusinessException(
                $"Cannot {action} a reservation in '{StateName}' status.",
                400);
        }
    }
}
