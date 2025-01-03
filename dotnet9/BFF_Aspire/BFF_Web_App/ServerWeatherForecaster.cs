using Microsoft.AspNetCore.Authentication;
using BFF_Web_App.Client.Weather;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace BFF_Web_App;

internal sealed class ServerWeatherForecaster(HttpClient httpClient, IHttpContextAccessor httpContextAccessor) : IWeatherForecaster
{
    public async Task<IEnumerable<WeatherForecast>> GetWeatherForecastAsync()
    {
        var httpContext = httpContextAccessor.HttpContext ??
            throw new InvalidOperationException("No HttpContext available from the IHttpContextAccessor!");

        var accessToken = await httpContext.GetTokenAsync(CookieAuthenticationDefaults.AuthenticationScheme, "access_token") ?? 
            throw new InvalidOperationException("No access_token was saved"); ;

        using var requestMessage = new HttpRequestMessage(HttpMethod.Get, "/weather-forecast");
        requestMessage.Headers.Authorization = new("Bearer", accessToken);
        using var response = await httpClient.SendAsync(requestMessage);

        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<WeatherForecast[]>() ??
            throw new IOException("No weather forecast!");
    }
}
