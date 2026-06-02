namespace ChargeNet.Services.Payment
{
    public static class PaymentConstants
    {
        public static class TransactionTypes
        {
            public const string TopUp = "TopUp";
            public const string Payment = "Payment";
            public const string Refund = "Refund";
        }

        public static class TransactionStatuses
        {
            public const string Pending = "Pending";
            public const string Completed = "Completed";
            public const string Failed = "Failed";
        }

        public const string DefaultCurrency = "EUR";
        public const decimal MinTopUpAmount = 1m;
        public const decimal MaxTopUpAmount = 10000m;
    }
}
