using BFF_Web_App;
using BFF_Web_App.Client.Pages;
using BFF_Web_App.Client.Weather;
using BFF_Web_App.Components;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.FluentUI.AspNetCore.Components;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http;
using Yarp.ReverseProxy.Transforms;

var builder = WebApplication.CreateBuilder(args);

var tenantId     = builder.Configuration.GetValue<string>("TenantId");
var clientId     = builder.Configuration.GetValue<string>("ClientId");
var clientSecret = builder.Configuration.GetValue<string>("ClientSecret");

builder.AddServiceDefaults();

builder.Services.AddAuthentication("MicrosoftOidc")
    .AddOpenIdConnect("MicrosoftOidc", oidcOptions =>
    {
        oidcOptions.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        oidcOptions.CallbackPath = new PathString("/signin-oidc");
        //oidcOptions.SignedOutCallbackPath = new PathString("/signout-callback-oidc");
        oidcOptions.Scope.Add($"api://{clientId}/Weather.Get");
        oidcOptions.Authority = $"https://login.microsoftonline.com/{tenantId}/v2.0/";

        oidcOptions.ClientId = clientId;
        oidcOptions.ClientSecret = clientSecret;

        oidcOptions.ResponseType = OpenIdConnectResponseType.Code;
        oidcOptions.MapInboundClaims = false;
        oidcOptions.TokenValidationParameters.NameClaimType = JwtRegisteredClaimNames.Name;
        oidcOptions.TokenValidationParameters.RoleClaimType = "role";
    })
    .AddCookie("Cookies");

builder.Services.ConfigureCookieOidcRefresh("Cookies", "MicrosoftOidc");

builder.Services.AddAuthorization();

builder.Services.AddCascadingAuthenticationState();

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();
builder.Services.AddFluentUIComponents();

builder.Services.AddScoped<AuthenticationStateProvider, PersistingAuthenticationStateProvider>();

builder.Services.AddHttpForwarderWithServiceDiscovery();
builder.Services.AddHttpContextAccessor();

builder.Services.AddHttpClient<IWeatherForecaster, ServerWeatherForecaster>(httpClient =>
{
    httpClient.BaseAddress = new("https://weatherapi");
});

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();

    //To make https work
    app.UseForwardedHeaders(new ForwardedHeadersOptions
    {
        ForwardedHeaders = ForwardedHeaders.XForwardedProto
    });
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(BFF_Web_App.Client._Imports).Assembly);

if (app.Environment.IsDevelopment())
{
    app.MapForwarder("/weather-forecast", "https://localhost:5041", transformBuilder =>
    {
        transformBuilder.AddRequestTransform(async transformContext =>
        {
            var accessToken = await transformContext.HttpContext.GetTokenAsync("access_token");
            transformContext.ProxyRequest.Headers.Authorization = new("Bearer", accessToken);
        });
    }).RequireAuthorization();
}
else
{
    app.MapForwarder("/weather-forecast", "http://weatherapi", transformBuilder =>
    {
        transformBuilder.AddRequestTransform(async transformContext =>
        {
            var accessToken = await transformContext.HttpContext.GetTokenAsync("access_token");
            transformContext.ProxyRequest.Headers.Authorization = new("Bearer", accessToken);
        });
    }).RequireAuthorization();
}

app.MapGroup("/authentication").MapLoginAndLogout();

app.Run();
