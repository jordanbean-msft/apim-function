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
    public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
    {
      IEnumerable<string>? bearerToken = null;
      bool status = req.Headers.TryGetValues("Authorization", out bearerToken);

      if (status == false || bearerToken == null || bearerToken.Count() == 0)
      {
        _logger.LogInformation("No bearer token found");
        return req.CreateResponse(HttpStatusCode.Unauthorized);
      }
      else
      {
        AccessToken? accessToken = JsonSerializer.Deserialize<AccessToken>(System.Convert.FromBase64String(bearerToken.First().Replace("Bearer ", "")));

        if (accessToken == null || accessToken.TokenSecret != TokenSecret.Secret)
        {
          return req.CreateResponse(HttpStatusCode.Unauthorized);
        }
      }

      var response = req.CreateResponse(HttpStatusCode.OK);

      response.WriteAsJsonAsync(new
      {
        question = "What kind of bear is best?",
        answer = "False, black bear!"
      });

      return response;
    }
  }
}
