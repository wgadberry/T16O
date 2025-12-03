using T16O.Services;
using T16O.Services.RabbitMQ;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddControllers();

// Configure Database connection string
var dbConnectionString = builder.Configuration["Database:ConnectionString"]
    ?? "Server=localhost;Database=t16o;User=root;Password=rootpassword;Allow User Variables=True;";
builder.Services.AddSingleton(new DatabaseSettings { ConnectionString = dbConnectionString });

// Configure RabbitMQ
var rabbitMqConfig = new RabbitMqConfig
{
    Host = builder.Configuration["RabbitMQ:Host"] ?? "localhost",
    Port = int.Parse(builder.Configuration["RabbitMQ:Port"] ?? "5672"),
    Username = builder.Configuration["RabbitMQ:Username"] ?? "admin",
    Password = builder.Configuration["RabbitMQ:Password"] ?? "admin123",
    VirtualHost = builder.Configuration["RabbitMQ:VirtualHost"] ?? "razorback",
    RpcExchange = builder.Configuration["RabbitMQ:RpcExchange"] ?? "razorback.rpc.topic",
    TaskExchange = builder.Configuration["RabbitMQ:TaskExchange"] ?? "razorback.tasks.topic"
};

builder.Services.AddSingleton(rabbitMqConfig);

// Register RabbitMQ RPC Client as singleton to reuse connections (massive performance boost)
builder.Services.AddSingleton<RabbitMqRpcClient>(sp =>
{
    var config = sp.GetRequiredService<RabbitMqConfig>();
    return new RabbitMqRpcClient(config);
});

// Configure RPC URLs for transaction fetching
var rpcUrls = builder.Configuration.GetSection("Rpc:Urls").Get<string[]>()
    ?? new[] { "https://mainnet.helius-rpc.com/?api-key=YOUR_KEY" };

// Register TransactionFetcher as singleton
builder.Services.AddSingleton<TransactionFetcher>(sp =>
{
    var logger = sp.GetRequiredService<ILogger<TransactionFetcher>>();
    return new TransactionFetcher(rpcUrls, new TransactionFetcherOptions
    {
        MaxConcurrentRequests = 1,
        RateLimitMs = 0,
        MaxRetryAttempts = 3,
        InitialRetryDelayMs = 1000
    }, logger);
});

// Register RequestOrchestrator as singleton
builder.Services.AddSingleton<RequestOrchestrator>(sp =>
{
    var logger = sp.GetRequiredService<ILogger<RequestOrchestrator>>();
    return new RequestOrchestrator(dbConnectionString, rpcUrls, rabbitMqConfig, new TransactionFetcherOptions
    {
        MaxConcurrentRequests = 1,
        RateLimitMs = 0,
        MaxRetryAttempts = 3,
        InitialRetryDelayMs = 1000
    }, logger);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();
app.MapRazorPages()
   .WithStaticAssets();
app.MapControllers();

app.Run();

/// <summary>
/// Simple settings class for database connection
/// </summary>
public class DatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
}
