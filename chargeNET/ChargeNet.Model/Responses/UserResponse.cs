namespace ChargeNet.Model.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public string? Address { get; set; }
        public string? ProfileImageBase64 { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
    }
}
