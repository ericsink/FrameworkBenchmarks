FROM microsoft/dotnet:2.1-sdk-stretch AS build
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.json ./out/appsettings.json

FROM mono:5.12.0.226
ENV ASPNETCORE_URLS http://+:8080
ENV COMPlus_ReadyToRun 0
ENV KestrelTransport Libuv
WORKDIR /app
COPY --from=build /app/out ./

ENTRYPOINT ["mono", "--server", "--gc=sgen", "--gc-params=mode=throughput", "PlatformBenchmarks.exe"]
