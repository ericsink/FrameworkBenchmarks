
typealias JsonValue = System.Text.Json.Nodes.JsonValue;
typealias JsonArray = System.Text.Json.Nodes.JsonArray;
typealias JsonNode = System.Text.Json.Nodes.JsonNode;
typealias JsonObject = System.Text.Json.Nodes.JsonObject;

enum Constants {
    static let plainTextResponse = try! System.Text.Encoding.UTF8.GetBytes("Hello, World!")
    static let cancellationToken = System.Threading.CancellationToken.None
}

@_cdecl("main")
public func main() {

do 
{
    let f_mapRoutes = try System.Action_1<Microsoft.AspNetCore.Routing.IEndpointRouteBuilder>(
        {
            routes in

            try routes.MapGet("/plaintext")
            {
                context in
                let payloadLength = Constants.plainTextResponse.Length
                let response = context.Response
                response.StatusCode = 200
                response.ContentType = "text/plain"
                response.ContentLength = Int64(payloadLength)

                return try response.Body.WriteAsync(Constants.plainTextResponse, 0, payloadLength, Constants.cancellationToken);
            };
            try routes.MapGet("/json")
            {
                context in

                let response = context.Response
                response.StatusCode = 200
                response.ContentType = "application/json"

                let resp = try JsonObject(options: nil);
                try resp.Add("message", JsonValue.Create("Hello, World!", nil));
                let json_resp = try resp.ToString();
                return try response.WriteAsync(json_resp, Constants.cancellationToken);
            };
        }
        );

    try Microsoft.Extensions.Hosting.Host.CreateDefaultBuilder()
        .ConfigureWebHostDefaults
        {
            webHostBuilder in

            try webHostBuilder
                .Configure
                {
                    app in

                    try app
                        .UseRouting()
                        .UseEndpoints(f_mapRoutes)
                        ;
                }
                ;
        }
        .Build()
        .Run()
        ;
}
catch let e as System.Exception 
{
    try! System.Console.WriteLine(e.ToString());
}
catch
{
    print("Unhandled error of some kind");
}

}

