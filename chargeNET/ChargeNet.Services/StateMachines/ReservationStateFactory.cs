namespace ChargeNet.Services.StateMachines
{
    public static class ReservationStateFactory
    {
        public static IReservationState Create(int statusId)
        {
            return statusId switch
            {
                ReservationStatusIds.Pending => new PendingState(),
                ReservationStatusIds.Confirmed => new ConfirmedState(),
                ReservationStatusIds.Rejected => new TerminalReservationState("Rejected"),
                ReservationStatusIds.Cancelled => new TerminalReservationState("Cancelled"),
                ReservationStatusIds.Completed => new TerminalReservationState("Completed"),
                ReservationStatusIds.Expired => new TerminalReservationState("Expired"),
                _ => throw new InvalidOperationException($"Unknown reservation status id: {statusId}.")
            };
        }
    }
}
