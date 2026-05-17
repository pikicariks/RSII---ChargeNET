namespace ChargeNet.Model.Requests
{
    public class UserInsertRequest
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public int RoleId { get; set; } = 3;
        public int? CityId { get; set; }
        public string? Address { get; set; }
    }
}
