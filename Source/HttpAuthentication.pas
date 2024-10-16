namespace RemObjects.Elements.RTL;

interface

type
  IHttpAuthentication = public interface
    method ApplyToRequest(aRequest: HttpRequest);
  end;

  HttpBasicAuthentication = public class(IHttpAuthentication)
  private
    method ApplyToRequest(aRequest: HttpRequest);
  public
    property Username: String;
    property Password: String;
    constructor(aUsername, aPassword: not nullable String);
  end;

  HttpBearerAuthentication = public class(IHttpAuthentication)
  private
    method ApplyToRequest(aRequest: HttpRequest);
  public
    property Key: String;
    constructor(aKey: not nullable String);
  end;

implementation

{ HttpBasicAuthentication }

constructor HttpBasicAuthentication(aUsername, aPassword: not nullable String);
begin
  Username := aUsername;
  Password := aPassword;
end;

method HttpBasicAuthentication.ApplyToRequest(aRequest: HttpRequest);
begin
  var lBytes := Encoding.UTF8.GetBytes(Username+":"+Password) includeBOM(false);
  var lBase64 := Convert.ToBase64String(lBytes);
  aRequest.Headers["Authorization"] := "Basic "+lBase64;
end;

{ HttpBearerAuthentication }

constructor HttpBearerAuthentication(aKey: not nullable String);
begin
  Key := aKey;
end;

method HttpBearerAuthentication.ApplyToRequest(aRequest: HttpRequest);
begin
  aRequest.Headers["Authorization"] := "Bearer "+Key;
end;

end.