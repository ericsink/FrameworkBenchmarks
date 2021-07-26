FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build

WORKDIR /app
COPY Benchmarks .
RUN dotnet nuget locals all --clear
RUN dotnet publish -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS runtime
WORKDIR /app
COPY --from=build /app/out ./

ENV ASPNETCORE_URLS http://+:8080
ENV Logging__LogLevel__Microsoft None

EXPOSE 8080

ENTRYPOINT ["dotnet", "benchmarks.dll"]

