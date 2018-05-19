# ASP.NET Core Tests on Mono and Linux

See [ASP.NET Core](https://github.com/aspnet) and [Mono](https://www.mono-project.com/) for more information.

This includes tests for plaintext and json serialization.

## Infrastructure Software Versions

**Language**

* C# 7.2

**Platforms**

* Mono (Linux)

**Web Servers**

* [Kestrel](https://github.com/aspnet/KestrelHttpServer)

**Web Stack**

* ASP.NET Core
* ASP.NET Core MVC

## Paths & Source for Tests

* [Plaintext](PlatformBenchmarks/BenchmarkApplication.Plaintext.cs): "/plaintext"
* [JSON Serialization](PlatformBenchmarks/BenchmarkApplication.Json.cs): "/json"
* [Fortunes](PlatformBenchmarks/BenchmarkApplication.Fortunes.cs): "/fortunes"