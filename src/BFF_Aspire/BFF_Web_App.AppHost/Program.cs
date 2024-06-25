using Aspire.Hosting;

var builder = DistributedApplication.CreateBuilder(args);

var tenantId     = builder.AddParameter("TenantId");
var clientId     = builder.AddParameter("ClientId");
var clientSecret = builder.AddParameter("ClientSecret",secret:true);

var weatherapi = builder.AddProject<Projects.WeatherAPI>("weatherapi")
    .WithEnvironment("TenantId",tenantId)
    .WithEnvironment("ClientId",clientId);

builder.AddProject<Projects.BFF_Web_App>("bff-web-app")
    .WithReference(weatherapi)
    .WithEnvironment("TenantId", tenantId)
    .WithEnvironment("ClientId", clientId)
    .WithEnvironment("ClientSecret", clientSecret);

builder.Build().Run();
