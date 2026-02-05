using System.Reflection;
using Microsoft.OpenApi.Models;
using Scalar.AspNetCore;
using T16O.www.Server.Services;

var builder = WebApplication.CreateBuilder(args);

// Add CORS for development (allow any localhost origin)
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

// Add services to the container.
builder.Services.AddScoped<IBubbleMapService, BubbleMapService>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Version = "v1",
        Title = "T16O Bubble Map API",
        Description = "API for retrieving blockchain transaction visualization data. Provides bubble map graph data showing token flows, wallet connections, and transaction patterns on the Solana blockchain.",
        Contact = new OpenApiContact
        {
            Name = "T16O Team"
        }
    });

    // Include XML comments for endpoint descriptions
    var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFilename);
    if (File.Exists(xmlPath))
    {
        options.IncludeXmlComments(xmlPath);
    }
});

var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(options =>
    {
        options.RouteTemplate = "openapi/{documentName}.json";
    });
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "T16O Bubble Map API v1");
    });
    app.MapScalarApiReference(options =>
    {
        options
            .WithTitle("T16O Bubble Map API")
            .WithTheme(ScalarTheme.DeepSpace)
            .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });
}

app.UseHttpsRedirection();

app.UseCors("AllowDemoApp");

app.UseAuthorization();

app.MapControllers();

app.MapFallbackToFile("/index.html");

app.Run();
