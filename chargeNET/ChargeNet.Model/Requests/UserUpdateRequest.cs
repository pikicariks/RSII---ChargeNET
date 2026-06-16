namespace ChargeNet.Model.Requests
{
    public class UserUpdateRequest
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? PhoneNumber { get; set; }
        public int? RoleId { get; set; }
        public int? CityId { get; set; }
        public string? Address { get; set; }
        public string? ProfileImageBase64 { get; set; }
        public bool ClearProfileImage { get; set; } = false;
    }
}
