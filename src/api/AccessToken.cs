namespace api
{
  public class AccessToken
  {
    public AccessToken() { }

    public string? Key { get; set; }
    public string? Secret { get; set; }
    public string? TokenSecret { get; set; }
  }
}