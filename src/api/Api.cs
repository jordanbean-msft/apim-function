using System.Collections.Generic;
using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace api
{
  public class Api
  {
    private readonly ILogger _logger;

    public Api(ILoggerFactory loggerFactory)
    {
      _logger = loggerFactory.CreateLogger<Api>();
    }

    [Function("api")]
    public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
    {
      IEnumerable<string> bearerToken = null;
      bool status = req.Headers.TryGetValues("Authorization", out bearerToken);

      if (status == false || bearerToken == null || bearerToken.Count() == 0)
      {
        _logger.LogInformation("No bearer token found");
        return req.CreateResponse(HttpStatusCode.Unauthorized);
      }
      else
      {
        _logger.LogInformation("Bearer token: " + bearerToken.First());
        AccessToken accessToken = JsonSerializer.Deserialize<AccessToken>(System.Convert.FromBase64String(bearerToken.First().Replace("Bearer ", "")));

        _logger.LogInformation("Access token: " + accessToken.TokenSecret);
        if (accessToken.TokenSecret != TokenSecret.Secret)
        {
          return req.CreateResponse(HttpStatusCode.Unauthorized);
        }
      }

      var response = req.CreateResponse(HttpStatusCode.OK);
      response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

      response.WriteString("Welcome to Azure Functions!");

      return response;
    }
  }
}
