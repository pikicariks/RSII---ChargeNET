FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ChargeNet.Worker/ChargeNet.Worker.csproj", "ChargeNet.Worker/"]
COPY ["ChargeNet.Model/ChargeNet.Model.csproj", "ChargeNet.Model/"]
COPY ["ChargeNet.Services/ChargeNet.Services.csproj", "ChargeNet.Services/"]
RUN dotnet restore "ChargeNet.Worker/ChargeNet.Worker.csproj"
COPY . .
WORKDIR "/src/ChargeNet.Worker"
RUN dotnet build "ChargeNet.Worker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ChargeNet.Worker.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ChargeNet.Worker.dll"]
