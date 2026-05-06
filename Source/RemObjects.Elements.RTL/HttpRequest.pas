namespace RemObjects.Elements.RTL;

interface

type
  HttpProxyMode = public enum (None, System, Custom);

  HttpProxySettings = public class
  public
    property Mode: HttpProxyMode := HttpProxyMode.System;
    property Host: String;
    property Port: Integer := 8080;

    constructor;
    constructor(aMode: HttpProxyMode);
    constructor(aHost: String; aPort: Integer);

    class property Default: HttpProxySettings := new HttpProxySettings(HttpProxyMode.System);
  end;

  HttpRequest = public class
  public

    [Obsolete("Use Method")]
    property Mode: HttpRequestMethod read &Method write &Method;
    property &Method: HttpRequestMethod := HttpRequestMethod.Get;
    property Headers: not nullable Dictionary<String,String> := new Dictionary<String,String>; readonly;
    property Content: nullable HttpRequestContent;
    //property ContentType: nullable String read coalesce(fContentType, IHttpRequestContent(Content):ContentType) write fContentType;
    property Url: not nullable Url;
    property FollowRedirects: Boolean := true;
    property AllowCellularAccess: Boolean := true;
    property KeepAlive: Boolean := true;
    property UserAgent: String;
    property Accept: String;

    property Authorization: IHttpAuthorization;

    property Proxy: HttpProxySettings;

    property Timeout: Double := 10.0; // Seconds

    constructor(aUrlString: not nullable String; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
    constructor(aUrl: not nullable Url; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
    operator Implicit(aUrl: not nullable Url): HttpRequest;
    operator Implicit(aString: not nullable String): HttpRequest;

    property VerifyUntrustedCertificate: HttpVerifyUntrustedCertificateBlock;

    [ToString]
    method ToString: String;

    property DebugHeaders: Boolean;
    property DebugPayloads: Boolean;

    method Cancel;

  assembly

    method ApplyAuthentication;

    {$IF ISLAND}
    property Monitor := new Monitor; readonly;
    {$ELSE}
    property Monitor: Object read self;
    {$ENDIF}

    // Platform handle stored here while request is in-flight, for Cancel() support.
    // Protected by Monitor; cleared (and closed/cancelled) by whichever side — Cancel()
    // or the completion path — gets there first.
    {$IF ISLAND AND WINDOWS}
    var fCancelHandle: rtl.HINTERNET;
    {$ELSEIF DARWIN}
    var fCancelTask: NSURLSessionDataTask;
    {$ELSEIF ECHOES}
    var fCancelSource: System.Threading.CancellationTokenSource;
    var fCancelWebRequest: System.Net.HttpWebRequest;
    {$ELSEIF COOPER}
    var fCancelConnection: java.net.HttpURLConnection;
    {$ENDIF}

    method DebugLog;
    begin
      if DebugHeaders then begin
        Log($"> {Url}");
        for each h in Headers.Keys do
          Log($"> {h}={Headers[h]}");
      end;
      if DebugPayloads and assigned(Content) then
        Log($"> {Content}");
    end;

  //private
    //var fContentType: String;
  end;

  HttpVerifyUntrustedCertificateBlock nested in httpRequest = public block(aCertificateInfo: HttpCertificateInfo): Boolean;

  HttpRequestMethod = public enum (Get, Post, Head, Put, Delete, Patch, Options, Trace);

  [Obsolete("Use HttpRequestMethod")]
  HttpRequestMode = public HttpRequestMethod;

extension method HttpRequestMethod.ToHttpString: String; public;

implementation

{ HttpProxySettings }

constructor HttpProxySettings;
begin
  Mode := HttpProxyMode.System;
end;

constructor HttpProxySettings(aMode: HttpProxyMode);
begin
  Mode := aMode;
end;

constructor HttpProxySettings(aHost: String; aPort: Integer);
begin
  Mode := HttpProxyMode.Custom;
  Host := aHost;
  Port := aPort;
end;

{ HttpRequest }

constructor HttpRequest(aUrlString: not nullable String; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
begin
  Url := Url.UrlWithString(aUrlString);
  &Method := aMethod;
end;

constructor HttpRequest(aUrl: not nullable Url; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
begin
  Url := aUrl;
  &Method := aMethod;
end;

operator HttpRequest.Implicit(aUrl: not nullable Url): HttpRequest;
begin
  result := new HttpRequest(aUrl, HttpRequestMethod.Get);
end;

operator HttpRequest.Implicit(aString: not nullable String): HttpRequest;
begin
  result := new HttpRequest(aString, HttpRequestMethod.Get);
end;

method HttpRequest.ToString: String;
begin
  result := Url.ToString();
end;

method HttpRequest.Cancel;
begin
  {$IF ISLAND AND WINDOWS}
  var h: rtl.HINTERNET;
  locking Monitor do begin
    h := fCancelHandle;
    fCancelHandle := nil;
  end;
  if h <> nil then
    rtl.WinHttpCloseHandle(h);
  {$ELSEIF DARWIN}
  var task: NSURLSessionDataTask;
  locking Monitor do begin
    task := fCancelTask;
    fCancelTask := nil;
  end;
  task:cancel();
  {$ELSEIF ECHOES}
  var src: System.Threading.CancellationTokenSource;
  var req: System.Net.HttpWebRequest;
  locking Monitor do begin
    src := fCancelSource;
    fCancelSource := nil;
    req := fCancelWebRequest;
    fCancelWebRequest := nil;
  end;
  src:Cancel();
  req:Abort();
  {$ELSEIF COOPER}
  var conn: java.net.HttpURLConnection;
  locking Monitor do begin
    conn := fCancelConnection;
    fCancelConnection := nil;
  end;
  conn:disconnect();
  {$ENDIF}
end;

method HttpRequest.ApplyAuthentication;
begin
  Authorization:ApplyToRequest(self);
end;

{ HttpRequestMethod }

extension method HttpRequestMethod.ToHttpString: String;
begin
  result := case self of
    HttpRequestMethod.Delete: "DELETE";
    HttpRequestMethod.Get: "GET";
    HttpRequestMethod.Head: "HEAD";
    HttpRequestMethod.Options: "OPTIONS";
    HttpRequestMethod.Patch: "PATCH";
    HttpRequestMethod.Post: "POST";
    HttpRequestMethod.Put: "PUT";
    HttpRequestMethod.Trace: "TRACE";
  end;
end;

end.