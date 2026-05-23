namespace ChargeNet.Services.StateMachines
{
    public class TerminalReservationState : BaseReservationState
    {
        public TerminalReservationState(string stateName)
        {
            StateName = stateName;
        }

        protected override string StateName { get; }
    }
}
