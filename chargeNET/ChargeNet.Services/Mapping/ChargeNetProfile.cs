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

            CreateMap<Tariff, TariffResponse>();

            CreateMap<ChargingStation, ChargingStationResponse>()
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City.Name))
                .ForMember(dest => dest.StatusName, opt => opt.MapFrom(src => src.Status.Name))
                .ForMember(dest => dest.ConnectorCount, opt => opt.MapFrom(src => src.Connectors.Count));

            CreateMap<Connector, ConnectorResponse>()
                .ForMember(dest => dest.ChargingStationName, opt => opt.MapFrom(src => src.ChargingStation.Name))
                .ForMember(dest => dest.ConnectorTypeName, opt => opt.MapFrom(src => src.ConnectorType.Name));
        }
    }
}
