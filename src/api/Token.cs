using System.Collections.Generic;
using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace api
{
  public class Token
  {
    private readonly ILogger _logger;

    public Token(ILoggerFactory loggerFactory)
    {
      _logger = loggerFactory.CreateLogger<Token>();
    }

    [Function("token")]
    public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
    {
      var query = System.Web.HttpUtility.ParseQueryString(req.Url.Query);

      var response = req.CreateResponse(HttpStatusCode.OK);

      AccessToken accessToken = new AccessToken()
      {
        Key = query["key"],
        Secret = query["secret"],
        TokenSecret = TokenSecret.Secret
      };

      response.WriteAsJsonAsync<AccessTokenReturnData>(new AccessTokenReturnData
      {
        Success = true,
        Data = new AccessTokenReturnToken
        {
          Token = System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(JsonSerializer.Serialize(accessToken)))
        },
        Errors = new List<string>()
      });

      return response;
    }
  }
}