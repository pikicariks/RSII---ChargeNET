namespace ChargeNet.Model.SearchObjects
{
    public abstract class BaseSearchObject
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}
