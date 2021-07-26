
using System;
using System.Text.Json.Nodes;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;

static class Constants {
    public static byte[] plainTextResponse = System.Text.Encoding.UTF8.GetBytes("Hello, World!");
    public static System.Threading.CancellationToken cancellationToken = System.Threading.CancellationToken.None;
}

static class foo
{
public static void Main() 
{
    Action<Microsoft.AspNetCore.Routing.IEndpointRouteBuilder> f_mapRoutes =
        routes =>
        {
            routes.MapGet("/plaintext",
                context =>
            {
                var payloadLength = Constants.plainTextResponse.Length;
                var response = context.Response;
                response.StatusCode = 200;
                response.ContentType = "text/plain";
                response.ContentLength = payloadLength;

                return response.Body.WriteAsync(Constants.plainTextResponse, 0, payloadLength, Constants.cancellationToken);
            });
            routes.MapGet("/json",
                context =>
            {

                var response = context.Response;
                response.StatusCode = 200;
                response.ContentType = "application/json";

                var resp = new JsonObject();
                resp.Add("message", JsonValue.Create("Hello, World!"));
                var json_resp = resp.ToString();
                return response.WriteAsync(json_resp, Constants.cancellationToken);
            });
        };

    Microsoft.Extensions.Hosting.Host.CreateDefaultBuilder()
        .ConfigureWebHostDefaults(
            webHostBuilder =>
        {
            webHostBuilder
                .Configure(
                    app =>
                {

                    app
                        .UseRouting()
                        .UseEndpoints(f_mapRoutes)
                        ;
                })
                ;
        })
        .Build()
        .Run()
        ;
}

}



