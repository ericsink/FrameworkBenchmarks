FROM microsoft/dotnet:2.1-sdk-stretch AS build
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.json ./out/appsettings.json

FROM mono:5.12.0.226 AS runtime
ENV ASPNETCORE_URLS http://+:8080
ENV KestrelTransport Libuv
WORKDIR /app
COPY --from=build /app/out ./
#RUN find /usr/ -name netstandard.dll
#RUN cp /usr/lib/mono/4.7.1-api/Facades/netstandard.dll ./
RUN mkbundle --fetch-target mono-5.10.1-debian-8-x64
RUN mkbundle  --i18n none --cross mono-5.10.1-debian-8-x64 -o PlatformBenchmarks --options --server --options --gc=sgen --options --gc-params=mode=throughput --deps PlatformBenchmarks.exe
RUn ls -l
ENTRYPOINT ["PlatformBenchmarks"]
