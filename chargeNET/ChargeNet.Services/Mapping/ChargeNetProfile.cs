using AutoMapper;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;

namespace ChargeNet.Services.Mapping
{
    public class ChargeNetProfile : Profile
    {
        public ChargeNetProfile()
        {
            CreateMap<User, UserResponse>()
                .ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role.Name))
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City != null ? src.City.Name : null));
        }
    }
}
