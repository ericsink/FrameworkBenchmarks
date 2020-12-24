using Ben.Http;

var (server, app) = (new HttpServer($"http://+:8080"), new HttpApp());

app.Get("/plaintext", () => "Hello, World!");

app.Get("/json", (req, res) => {
    res.Headers.ContentLength = 27;
    return res.Json(new Note { message = "Hello, World!" });
});

await server.RunAsync(app);

struct Note { public string message { get; set; } }