FROM microsoft/dotnet:2.1-sdk-stretch AS build
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.json ./out/appsettings.json

FROM debian:stretch AS runtime
RUN apt -yqq update
RUN apt install -yqq apt-transport-https dirmngr
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian preview-stretch main" | tee /etc/apt/sources.list.d/mono-official-preview.list
RUN apt -yqq update
RUN apt -yqq install mono-devel mono-llvm-support 
ENV KestrelTransport Libuv
WORKDIR /app
COPY --from=build /app/out ./

ENTRYPOINT ["mono", "--llvm", "--server", "--gc=sgen", "--gc-params=mode=throughput", "PlatformBenchmarks.exe"]
