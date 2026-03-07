using Microsoft.OpenApi.Models;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// CORS — allow any localhost origin (Angular dev server)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowDemoApp", policy =>
    {
        policy.SetIsOriginAllowed(origin =>
                new Uri(origin).Host == "localhost")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Typed HttpClient for upstream API calls
builder.Services.AddHttpClient("UpstreamApi", (sp, client) =>
{
    var config = sp.GetRequiredService<IConfiguration>();
    var baseUrl = config["UpstreamApi:BaseUrl"] ?? "https://svcs.the16oracles.io";
    client.BaseAddress = new Uri(baseUrl);

    var apiKey = config["UpstreamApi:ApiKey"];
    if (!string.IsNullOrEmpty(apiKey))
        client.DefaultRequestHeaders.Add("X-API-Key", apiKey);
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Version = "v1",
        Title = "T16O API",
        Description = "Local proxy API for the T16O cluster map widget demo. Forwards requests to the upstream hosted API with authentication."
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger(options =>
    {
        options.RouteTemplate = "openapi/{documentName}.json";
    });
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "Demo Proxy API v1");
    });
    app.MapScalarApiReference(options =>
    {
        options
            .WithTitle("T16O API")
            .WithTheme(ScalarTheme.DeepSpace)
            .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });
}

app.UseHttpsRedirection();
app.UseCors("AllowDemoApp");

// Shared proxy helper — forwards the incoming query string to an upstream path
async Task<IResult> ProxyToUpstream(HttpContext ctx, IHttpClientFactory httpClientFactory, string upstreamPath)
{
    var client = httpClientFactory.CreateClient("UpstreamApi");
    var requestUri = $"{upstreamPath}{ctx.Request.QueryString}";

    try
    {
        var response = await client.GetAsync(requestUri);
        var content = await response.Content.ReadAsStringAsync();
        var contentType = response.Content.Headers.ContentType?.ToString() ?? "application/json";
        return Results.Content(content, contentType);
    }
    catch (HttpRequestException ex)
    {
        return Results.Json(
            new { error = "Failed to reach upstream API", detail = ex.Message },
            statusCode: StatusCodes.Status502BadGateway);
    }
}

app.MapGet("/api/bubblemap", async (HttpContext ctx, IHttpClientFactory httpClientFactory) =>
        await ProxyToUpstream(ctx, httpClientFactory, "/api/bmap/get"))
    .WithName("GetBubbleMap")
    .WithSummary("Get bubble map graph data for a token or transaction")
    .WithOpenApi();

app.MapGet("/api/bubblemap/wallet-txs", async (HttpContext ctx, IHttpClientFactory httpClientFactory) =>
        await ProxyToUpstream(ctx, httpClientFactory, "/api/bmap/wallet-txs"))
    .WithName("GetWalletTxs")
    .WithSummary("Get wallet transaction history for a specific token")
    .WithOpenApi();

app.Run();
