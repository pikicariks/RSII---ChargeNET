using AutoMapper;
using ChargeNet.Model.Responses;
using ChargeNet.Services.Database;
using System;

namespace ChargeNet.Services.Mapping
{
    public class ChargeNetProfile : Profile
    {
        public ChargeNetProfile()
        {
            CreateMap<User, UserResponse>()
                .ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role.Name))
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City != null ? src.City.Name : null))
                .ForMember(dest => dest.ProfileImageBase64, opt => opt.MapFrom(src =>
                    src.ProfileImage != null ? Convert.ToBase64String(src.ProfileImage) : null));

            CreateMap<Tariff, TariffResponse>();

            CreateMap<ChargingStation, ChargingStationResponse>()
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City.Name))
                .ForMember(dest => dest.StatusName, opt => opt.MapFrom(src => src.Status.Name))
                .ForMember(dest => dest.ConnectorCount, opt => opt.MapFrom(src => src.Connectors.Count));

            CreateMap<Connector, ConnectorResponse>()
                .ForMember(dest => dest.ChargingStationName, opt => opt.MapFrom(src => src.ChargingStation.Name))
                .ForMember(dest => dest.ConnectorTypeName, opt => opt.MapFrom(src => src.ConnectorType.Name));

            CreateMap<Vehicle, VehicleResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ConnectorTypeName, opt => opt.MapFrom(src => src.ConnectorType != null ? src.ConnectorType.Name : null));

            CreateMap<FaultReport, FaultReportResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ChargingStationName, opt => opt.MapFrom(src => src.ChargingStation.Name))
                .ForMember(dest => dest.ConnectorLabel, opt => opt.MapFrom(src => src.Connector != null ? src.Connector.Label : null));

            CreateMap<Notification, NotificationResponse>();

            CreateMap<Reservation, ReservationResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ChargingStationName, opt => opt.MapFrom(src => src.ChargingStation.Name))
                .ForMember(dest => dest.ConnectorLabel, opt => opt.MapFrom(src => src.Connector != null ? src.Connector.Label : null))
                .ForMember(dest => dest.StatusName, opt => opt.MapFrom(src => src.Status.Name));

            CreateMap<ChargingSession, ChargingSessionResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ConnectorLabel, opt => opt.MapFrom(src => src.Connector.Label ?? string.Empty))
                .ForMember(dest => dest.ChargingStationId, opt => opt.MapFrom(src => src.Connector.ChargingStationId))
                .ForMember(dest => dest.ChargingStationName, opt => opt.MapFrom(src => src.Connector.ChargingStation.Name))
                .ForMember(dest => dest.TariffName, opt => opt.MapFrom(src => src.Tariff.Name));

            CreateMap<Transaction, TransactionResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.HasInvoice, opt => opt.MapFrom(src => src.Invoice != null));

            CreateMap<Invoice, InvoiceResponse>()
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email));
        }
    }
}
