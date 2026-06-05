FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ChargeNet.WebAPI/ChargeNet.WebAPI.csproj", "ChargeNet.WebAPI/"]
COPY ["ChargeNet.Model/ChargeNet.Model.csproj", "ChargeNet.Model/"]
COPY ["ChargeNet.Services/ChargeNet.Services.csproj", "ChargeNet.Services/"]
COPY ["ChargeNet.Common.Services/ChargeNet.Common.Services.csproj", "ChargeNet.Common.Services/"]
RUN dotnet restore "ChargeNet.WebAPI/ChargeNet.WebAPI.csproj"
COPY . .
WORKDIR "/src/ChargeNet.WebAPI"
RUN dotnet build "ChargeNet.WebAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ChargeNet.WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ChargeNet.WebAPI.dll"]
