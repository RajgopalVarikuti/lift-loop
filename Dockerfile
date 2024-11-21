#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src

ENV http_proxy=http://cloudproxy.zf-world.com:5000
ENV https_proxy=http://cloudproxy.zf-world.com:5000
ENV no_proxy=localhost,127.0.0.1,.zf-world.com,10.0.0.0/8,.zf.com,aroapp.io

COPY ["tvs.planner/tvs.planner.csproj", "tvs.planner/"]
RUN dotnet restore "tvs.planner/tvs.planner.csproj"
COPY . .
WORKDIR "/src/tvs.planner"
RUN dotnet build "tvs.planner.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "tvs.planner.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "tvs.planner.dll"]