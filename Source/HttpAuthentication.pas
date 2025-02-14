namespace RemObjects.Elements.RTL;

type
  IHttpAuthorization = public interface
    method ApplyToRequest(aRequest: HttpRequest);
  end;

  HttpBasicAuthorization = public class(IHttpAuthorization)
  private

    method ApplyToRequest(aRequest: HttpRequest);
    begin
      var lBytes := Encoding.UTF8.GetBytes(Username+":"+Password) includeBOM(false);
      var lBase64 := Convert.ToBase64String(lBytes);
      aRequest.Headers["Authorization"] := "Basic "+lBase64;
    end;

  public

    property Username: String;
    property Password: String;

    constructor(aUsername, aPassword: not nullable String);
    begin
      Username := aUsername;
      Password := aPassword;
    end;

  end;

  HttpBearerAuthorization = public class(IHttpAuthorization)
  private

    method ApplyToRequest(aRequest: HttpRequest);
    begin
      aRequest.Headers["Authorization"] := "Bearer "+Key;
    end;

  public

    property Key: String;

    constructor(aKey: not nullable String);
    begin
      Key := aKey;
    end;

  end;

  HttpHeaderAuthorization = public class(IHttpAuthorization)
  private

    method ApplyToRequest(aRequest: HttpRequest);
    begin
      aRequest.Headers[Name] := Key;
    end;

  public

    property Name: String;
    property Key: String;

    constructor(aName: String; aKey: not nullable String);
    begin
      Name := aName;
      Key := aKey;
    end;

    constructor(aKey: not nullable String);
    begin
      constructor("api-key", aKey);
    end;

  end;

  HttpQueryParameterAuthorization = public class(IHttpAuthorization)
  private

    method ApplyToRequest(aRequest: HttpRequest);
    begin
      if length(aRequest.Url.QueryString) > 0 then
        aRequest.Url := Url.UrlWithString(aRequest.Url.ToAbsoluteString+$"&{name}={key}")
      else
        aRequest.Url := Url.UrlWithString(aRequest.Url.ToAbsoluteString+$"?{name}={key}");
    end;

  public

    property Name: String;
    property Key: String;

    constructor(aName: String; aKey: not nullable String);
    begin
      Name := aName;
      Key := aKey;
    end;

  end;

end.