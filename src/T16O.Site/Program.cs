using T16O.Services.RabbitMQ;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// Configure Database connection string
var dbConnectionString = builder.Configuration["Database:ConnectionString"]
    ?? "Server=localhost;Database=solana_events;User=root;Password=rootpassword;Allow User Variables=True;";
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

app.Run();

/// <summary>
/// Simple settings class for database connection
/// </summary>
public class DatabaseSettings
{
    public string ConnectionString { get; set; } = string.Empty;
}
