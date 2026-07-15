namespace RemObjects.Elements.RTL;

{$IF ECHOES}
type
  {$IF HTTPCLIENT}
  PlatformResponse = System.Net.Http.HttpResponseMessage;
  {$ELSE}
  PlatformResponse = HttpWebResponse;
  {$ENDIF}

  HttpResponse = public partial class
  assembly

    var Response: PlatformResponse;
    {$IF HTTPCLIENT}
    var fCancelSource: System.Threading.CancellationTokenSource;
    var fClient: System.Net.Http.HttpClient;
    {$ELSE}
    var fCancelWebRequest: System.Net.HttpWebRequest;
    {$ENDIF}

    constructor(aResponse: PlatformResponse);
    begin
      Response := aResponse;
      Code := Int32(aResponse.StatusCode);
      var lHeaders := new Dictionary<String,String>;
      {$IF HTTPCLIENT}
      for each k in aResponse.Headers do
        lHeaders[k.Key] := k.Value.JoinedString(", ");
      for each k in aResponse.Content:Headers do
        lHeaders[k.Key] := k.Value.JoinedString(", ");
      {$ELSE}
      for each k in aResponse.Headers:AllKeys do
        lHeaders[k.ToString] := aResponse.Headers[k];
      {$ENDIF}
      Headers := lHeaders;
    end;

    constructor(aResponse: PlatformResponse; aException: Exception);
    begin
      constructor(aResponse);
      Exception := aException;
    end;

    {$IF HTTPCLIENT}
    constructor(aResponse: PlatformResponse; aCancelSource: System.Threading.CancellationTokenSource; aClient: System.Net.Http.HttpClient);
    begin
      constructor(aResponse);
      fCancelSource := aCancelSource;
      fClient := aClient;
    end;

    constructor(aResponse: PlatformResponse; aException: Exception; aCancelSource: System.Threading.CancellationTokenSource; aClient: System.Net.Http.HttpClient);
    begin
      constructor(aResponse, aCancelSource, aClient);
      Exception := aException;
    end;
    {$ELSE}
    constructor(aResponse: PlatformResponse; aCancelWebRequest: System.Net.HttpWebRequest);
    begin
      constructor(aResponse);
      fCancelWebRequest := aCancelWebRequest;
    end;

    constructor(aResponse: PlatformResponse; aException: Exception; aCancelWebRequest: System.Net.HttpWebRequest);
    begin
      constructor(aResponse, aCancelWebRequest);
      Exception := aException;
    end;
    {$ENDIF}

    method CancelResponse(aCancelTransport: Boolean := true);
    begin
      {$IF HTTPCLIENT}
      var lResponse: PlatformResponse;
      var lCancelSource: System.Threading.CancellationTokenSource;
      var lClient: System.Net.Http.HttpClient;
      locking self do begin
        lResponse := Response;
        Response := nil;
        lCancelSource := fCancelSource;
        fCancelSource := nil;
        lClient := fClient;
        fClient := nil;
      end;
      if aCancelTransport then
        lCancelSource:Cancel();
      (lResponse as IDisposable):Dispose;
      lClient:Dispose();
      lCancelSource:Dispose();
      {$ELSE}
      var lResponse: PlatformResponse;
      var lWebRequest: System.Net.HttpWebRequest;
      locking self do begin
        lResponse := Response;
        Response := nil;
        lWebRequest := fCancelWebRequest;
        fCancelWebRequest := nil;
      end;
      if aCancelTransport then
        lWebRequest:Abort();
      (lResponse as IDisposable):Dispose;
      {$ENDIF}
    end;
    //{$ELSE}
    //var Response: PlatformResponse;
    //constructor(aResponse: PlatformResponse);
    //begin
      //Response := aResponse;
      //Code := Int32(aResponse.StatusCode);
      //Headers := new Dictionary<String,String>();
    //end;

    //constructor(aResponse: PlatformResponse; aException: Exception);
    //begin
      //constructor(aResponse);
      //Exception := aException;
    //end;
    //{$ENDIF HTTPCLIENT}

  end;

{$ENDIF}
end.