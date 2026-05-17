namespace ChargeNet.Model.SearchObjects
{
    public class UserSearchObject
    {
        public string? FullText { get; set; }
        public string? Email { get; set; }
        public int? RoleId { get; set; }
        public int? CityId { get; set; }
        public bool? IsDeleted { get; set; }
        public bool IncludeDeleted { get; set; } = false;
    }
}
