namespace ChargeNet.Model.Requests
{
    public class RegisterRequest
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Optional for Swagger/testing. Defaults to 3 (Driver) when omitted.
        /// 1 = Admin, 2 = Technician, 3 = Driver.
        /// </summary>
        public int? RoleId { get; set; }
    }
}
