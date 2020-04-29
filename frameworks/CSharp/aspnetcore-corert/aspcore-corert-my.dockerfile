FROM mcr.microsoft.com/dotnet/core/sdk:3.1.101 AS build
RUN apt-get update
RUN apt-get -yqq install clang zlib1g-dev libkrb5-dev libtinfo5
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out -r linux-x64 /p:IsDatabase=true

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.2 AS runtime
WORKDIR /app
COPY --from=build /app/out ./
COPY Benchmarks/appsettings.mysql.json ./appsettings.json

ENTRYPOINT ["./PlatformBenchmarks", "--server.urls=http://+:8080"]
