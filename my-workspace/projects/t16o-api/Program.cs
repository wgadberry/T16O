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
    options.AddSecurityDefinition("ClientCredentials", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.ApiKey,
        In = ParameterLocation.Header,
        Name = "X-Client-Id",
        Description = "Client identifier"
    });
    options.AddSecurityDefinition("ClientSecret", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.ApiKey,
        In = ParameterLocation.Header,
        Name = "X-Client-Secret",
        Description = "Client secret"
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "ClientCredentials" }
            },
            Array.Empty<string>()
        },
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "ClientSecret" }
            },
            Array.Empty<string>()
        }
    });
});

// Build client credentials lookup from config
var clientCredentials = builder.Configuration
    .GetSection("Clients")
    .GetChildren()
    .ToDictionary(
        c => c["ClientId"] ?? "",
        c => c["ClientSecret"] ?? "",
        StringComparer.OrdinalIgnoreCase);

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

// Client credentials auth middleware
app.Use(async (ctx, next) =>
{
    var path = ctx.Request.Path.Value ?? "";
    if (path.StartsWith("/openapi", StringComparison.OrdinalIgnoreCase) ||
        path.StartsWith("/swagger", StringComparison.OrdinalIgnoreCase) ||
        path.StartsWith("/scalar", StringComparison.OrdinalIgnoreCase))
    {
        await next();
        return;
    }

    var clientId = ctx.Request.Headers["X-Client-Id"].FirstOrDefault();
    var clientSecret = ctx.Request.Headers["X-Client-Secret"].FirstOrDefault();

    if (string.IsNullOrEmpty(clientId) || string.IsNullOrEmpty(clientSecret) ||
        !clientCredentials.TryGetValue(clientId, out var expectedSecret) ||
        !string.Equals(clientSecret, expectedSecret, StringComparison.Ordinal))
    {
        ctx.Response.StatusCode = StatusCodes.Status401Unauthorized;
        await ctx.Response.WriteAsJsonAsync(new { error = "Invalid or missing client credentials" });
        return;
    }

    await next();
});

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
