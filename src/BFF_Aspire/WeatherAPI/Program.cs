var builder = WebApplication.CreateBuilder(args);

var tenantId = builder.Configuration.GetValue<string>("TenantId");
var clientId = builder.Configuration.GetValue<string>("ClientId");

builder.AddServiceDefaults();

builder.Services.AddAuthentication()
    .AddJwtBearer("Bearer", jwtOptions =>
    {
        // The API does not require an app registration of its own, but it does require a registration for the calling app.
        // These attributes can be found in the Entra ID portal when registering the client.
        jwtOptions.Authority = $"https://sts.windows.net/{tenantId}/";
        jwtOptions.Audience = $"api://{clientId}";
    });
builder.Services.AddAuthorization();

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weather-forecast", () =>
{
    Console.WriteLine("You got hit");
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
}).RequireAuthorization();

app.Run();

internal record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
