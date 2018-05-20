FROM microsoft/dotnet:2.1-sdk-stretch AS build
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.json ./out/appsettings.json

FROM mono:5.12.0.226 AS runtime
# Install Mono llvm
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt install apt-transport-https
RUN "deb https://download.mono-project.com/repo/debian nightly-jessie main" | tee /etc/apt/sources.list.d/mono-official-nightly.list
RUN "deb https://download.mono-project.com/repo/debian preview-jessie main" | tee /etc/apt/sources.list.d/mono-official-preview.list
RUN apt update -yqq
RUN apt-get install -yqq mono-llvm-tools
RUN dpkg-reconfigure libmono-corlib4.5-cil

ENV ASPNETCORE_URLS http://+:8080
ENV KestrelTransport Libuv
WORKDIR /app
COPY --from=build /app/out ./

ENTRYPOINT ["mono", "--llvm", "--server", "--gc=sgen", "--gc-params=mode=throughput", "PlatformBenchmarks.exe"]
