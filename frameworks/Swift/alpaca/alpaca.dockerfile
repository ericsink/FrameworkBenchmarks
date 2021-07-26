FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build

RUN apt-get update -yqq
RUN apt-get install -yqq \
          binutils \
          git \
          gnupg2 \
          libc6-dev \
          libcurl4 \
          libedit2 \
          libgcc-9-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-9-dev \
          libxml2 \
          libz3-dev \
          pkg-config \
          tzdata \
          zlib1g-dev
		  
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
RUN wget -q https://swift.org/builds/swift-5.4.2-release/ubuntu2004/swift-5.4.2-RELEASE/swift-5.4.2-RELEASE-ubuntu20.04.tar.gz
RUN tar xzf swift-5.4.2-RELEASE-ubuntu20.04.tar.gz
RUN cp -rv swift-5.4.2-RELEASE-ubuntu20.04/usr/* /usr/local/
		  
WORKDIR /app
COPY Benchmarks .
RUN dotnet nuget locals all --clear
RUN dotnet publish -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS runtime
WORKDIR /app
COPY --from=build /app/out ./
COPY --from=build /usr/local/ /usr/local

ENV ASPNETCORE_URLS http://+:8080
ENV Logging__LogLevel__Microsoft None

EXPOSE 8080

ENTRYPOINT ["dotnet", "benchmarks.dll"]

