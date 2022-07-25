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

      response.WriteAsJsonAsync<ReturnData>(new ReturnData
      {
        Success = true,
        Data = new ReturnToken
        {
          Token = System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(JsonSerializer.Serialize(accessToken)))
        },
        Errors = new List<string>()
      });

      return response;
    }
  }

  public class AccessToken
  {
    public AccessToken() { }

    public string Key { get; set; }
    public string Secret { get; set; }
    public string TokenSecret { get; set; }
  }

  public class ReturnToken
  {
    public ReturnToken() { }
    public string Token { get; set; }
  }

  public class ReturnData
  {
    public ReturnData() { }
    public bool Success { get; set; }
    public ReturnToken Data { get; set; }
    public List<string> Errors { get; set; }
  }
}
