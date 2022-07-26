namespace api
{
  public class AccessTokenReturnData
  {
    public AccessTokenReturnData() { }
    public bool? Success { get; set; }
    public AccessTokenReturnToken? Data { get; set; }
    public List<string>? Errors { get; set; }
  }
}