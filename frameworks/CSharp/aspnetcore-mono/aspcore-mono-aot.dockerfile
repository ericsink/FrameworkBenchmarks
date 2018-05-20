FROM microsoft/dotnet:2.1-sdk-stretch AS build
WORKDIR /app
COPY PlatformBenchmarks .
RUN dotnet publish -c Release -o out
COPY Benchmarks/appsettings.json ./out/appsettings.json

FROM mono:5.12.0.226 AS runtime
# Install Mono llvm
RUN apt update -yqq && apt install -yqq apt-transport-https dirmngr
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian nightly-stretch main" | tee /etc/apt/sources.list.d/mono-official-nightly.list
RUN echo "deb https://download.mono-project.com/repo/debian preview-stretch main" | tee /etc/apt/sources.list.d/mono-official-preview.list
RUN echo "deb http://ftp.us.debian.org/debian unstable main contrib non-free" >> /etc/apt/sources.list.d/unstable.list
RUN apt update -yqq
RUN apt-get install -yqq libstdc++6 mono-llvm-tools mono-runtime-common mono-gac mono-llvm-support
RUN dpkg-reconfigure libmono-corlib4.5-cil

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
