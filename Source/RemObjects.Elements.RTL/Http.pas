namespace RemObjects.Elements.RTL;

interface

{$DEFINE XML}{$DEFINE JSON}

{ Handy test URLs: http://httpbin.org, http://requestb.in }

type
  Http = public static class
  private
    {$IF DARWIN}
    //property Session := NSURLSession.sessionWithConfiguration(NSURLSessionConfiguration.defaultSessionConfiguration); lazy;
    {$ENDIF}
    {$IF ISLAND AND WINDOWS}
    class method CreateSessionForProxy(aProxy: HttpProxySettings): rtl.HINTERNET;
    {$ENDIF}
    {$IF ECHOES AND HTTPCLIENT}
    method HandleEchoesHttpClientException(aException: not nullable Exception; aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
    method UnwrapAggregateException(aException: not nullable System.AggregateException): not nullable Exception;
    {$ENDIF}
    method ExecuteRequestSynchronous(aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
  public
    //method ExecuteRequest(aUrl: not nullable Url; ResponseCallback: not nullable HttpResponseBlock);
    method ExecuteRequest(aRequest: not nullable HttpRequest; aResponseCallback: not nullable HttpResponseBlock);
    method ExecuteRequestSynchronous(aRequest: not nullable HttpRequest): not nullable HttpResponse;
    method TryExecuteRequestSynchronous(aRequest: not nullable HttpRequest): nullable HttpResponse;

    method ExecuteRequestAsString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<String>);
    method ExecuteRequestAsBinary(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
    {$IF XML}method ExecuteRequestAsXml(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);{$ENDIF}
    {$IF JSON}method ExecuteRequestAsJson(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);{$ENDIF}
    method ExecuteRequestAndSaveAsFile(aRequest: not nullable HttpRequest; aTargetFile: not nullable File; contentCallback: not nullable HttpContentResponseBlock<File>);

    {$IF NOT NETFX_CORE}
    method GetString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest): not nullable String;
    method GetBinary(aRequest: not nullable HttpRequest): not nullable ImmutableBinary;
    {$IF XML}method GetXml(aRequest: not nullable HttpRequest): not nullable XmlDocument;{$ENDIF}
    {$IF XML}method TryGetXml(aRequest: not nullable HttpRequest): nullable XmlDocument;{$ENDIF}
    {$IF JSON}method GetJson(aRequest: not nullable HttpRequest): not nullable JsonDocument;{$ENDIF}
    {$IF JSON}method TryGetJson(aRequest: not nullable HttpRequest): nullable JsonDocument;{$ENDIF}
    //todo: method GetAndSaveAsFile(...);
    {$ENDIF}

    {$IF HTTPCLIENT}
    class constructor;
    begin
      ServicePointManager.SecurityProtocol := SecurityProtocolType.Tls11 or SecurityProtocolType.Tls12 or 12288;
    end;
    {$ENDIF}
  end;

implementation

uses
  {$IF ECHOES}
  System.Net,
  {$ENDIF}
  RemObjects.Elements;

{$IF ISLAND AND WINDOWS}
class method Http.CreateSessionForProxy(aProxy: HttpProxySettings): rtl.HINTERNET;
begin
  var lProxyMode := if assigned(aProxy) then aProxy.Mode else HttpProxyMode.System;

  case lProxyMode of
    HttpProxyMode.None:
      result := rtl.WinHTTPOpen('', rtl.WINHTTP_ACCESS_TYPE_NO_PROXY, nil, nil, 0);

    HttpProxyMode.System:
      result := rtl.WinHTTPOpen('', rtl.WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, nil, nil, 0);

    HttpProxyMode.Custom:
      begin
        var lProxyString := RemObjects.Elements.System.String(aProxy.Host + ':' + aProxy.Port.ToString);
        result := rtl.WinHTTPOpen('', rtl.WINHTTP_ACCESS_TYPE_NAMED_PROXY, lProxyString.FirstChar, nil, 0);
      end;
  end;
end;
{$ENDIF}

{$IF ECHOES AND HTTPCLIENT}
method Http.HandleEchoesHttpClientException(aException: not nullable Exception; aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
begin
  var lException: not nullable Exception := if aException is System.AggregateException then UnwrapAggregateException(System.AggregateException(aException)) else aException;

  if lException is System.OperationCanceledException then begin
    var lTimeoutException := new HttpException('Request timed out', aRequest);
    if not aThrowOnError then
      exit new HttpResponse withException(lTimeoutException);
    raise lTimeoutException;
  end;

  if lException is System.Net.Http.HttpRequestException then begin
    var lWebException := System.Net.Http.HttpRequestException(lException);
    if not aThrowOnError then
      exit new HttpResponse withException(lWebException);
    raise new HttpException(lWebException.Message, aRequest);
  end;

  if not aThrowOnError then
    exit new HttpResponse withException(lException);
  raise lException;
end;

method Http.UnwrapAggregateException(aException: not nullable System.AggregateException): not nullable Exception;
begin
  var lFlattened := aException.Flatten();
  if lFlattened.InnerExceptions.Count = 1 then
    exit lFlattened.InnerExceptions[0] as not nullable;
  if lFlattened.InnerExceptions.Count > 1 then
    exit lFlattened as not nullable;
  exit coalesce(aException.InnerException, aException) as not nullable;
end;
{$ENDIF}

method Http.ExecuteRequest(aRequest: not nullable HttpRequest; aResponseCallback: not nullable HttpResponseBlock);
begin
  aRequest.ApplyAuthentication;
  aRequest.DebugLog;

  {$IF COOPER}
  async try
    // Configure proxy
    var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
    var lConnection: java.net.HttpURLConnection;
    case lProxyMode of
      HttpProxyMode.None:
        lConnection := java.net.URL(aRequest.Url).openConnection(java.net.Proxy.NO_PROXY) as java.net.HttpURLConnection;
      HttpProxyMode.System:
        lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection; // Uses default proxy selector
      HttpProxyMode.Custom:
        begin
          var lProxyAddr := new java.net.InetSocketAddress(aRequest.Proxy.Host, aRequest.Proxy.Port);
          var lProxy := new java.net.Proxy(java.net.Proxy.Type.HTTP, lProxyAddr);
          lConnection := java.net.URL(aRequest.Url).openConnection(lProxy) as java.net.HttpURLConnection;
        end;
    end;

    locking aRequest.Monitor do aRequest.fCancelConnection := lConnection;
    if aRequest.Method = HttpRequestMethod.Post then
      lConnection.DoOutput := true;
    lConnection.RequestMethod := aRequest.Method.ToHttpString;
    lConnection.ConnectTimeout := Integer((aRequest.Timeout as Double)*1000);
    for each k in aRequest.Headers.Keys do
      lConnection.setRequestProperty(k, aRequest.Headers[k]);
    if assigned(aRequest.Accept) then
      lConnection.setRequestProperty("Accept", aRequest.Accept);
    if assigned(aRequest.UserAgent) then
      lConnection.setRequestProperty("User-Agent", aRequest.UserAgent);
    if length(aRequest.Content:ContentType) > 0 then
      lConnection.setRequestProperty("Content-Type", aRequest.Content.ContentType);

    if assigned(aRequest.Content) then begin
      lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
      lConnection.getOutputStream().flush();
    end;

    try
      var lResponse := if lConnection.ResponseCode >= 300 then new HttpResponse withException(new HttpException(lConnection.responseCode, aRequest)) else new HttpResponse(lConnection);
      aResponseCallback(lResponse);
    except
      on E: Exception do
        aResponseCallback(new HttpResponse withException(E));
    finally
      locking aRequest.Monitor do aRequest.fCancelConnection := nil;
    end;

  except
    on E: Exception do
      aResponseCallback(new HttpResponse withException(E));
  end;
  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    var lHandler := new System.Net.Http.HttpClientHandler();
    lHandler.ServerCertificateCustomValidationCallback := (sender, cert, chain, sslPolicyErrors) -> begin
      result := if sslPolicyErrors = SslPolicyErrors.None then
        true
      else if assigned(aRequest.VerifyUntrustedCertificate) then
        aRequest.VerifyUntrustedCertificate(new HttpCertificateInfo(cert, chain, sslPolicyErrors))
      else
        false;
    end;
    // Configure proxy settings
    var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
    case lProxyMode of
      HttpProxyMode.None:
        lHandler.UseProxy := false;
      HttpProxyMode.System:
        lHandler.UseProxy := true; // Proxy = null uses system default
      HttpProxyMode.Custom:
        begin
          lHandler.UseProxy := true;
          lHandler.Proxy := new System.Net.WebProxy(aRequest.Proxy.Host, aRequest.Proxy.Port);
        end;
    end;
    var lClient := new System.Net.Http.HttpClient(lHandler);
    var lResponseOwnsClient := false;
    var cts: System.Threading.CancellationTokenSource;
    try
      try
        var lRequestMessage := new System.Net.Http.HttpRequestMessage();
        lRequestMessage.RequestUri := aRequest.Url;
        lRequestMessage.Method := new System.Net.Http.HttpMethod(aRequest.Method.ToHttpString);

        if assigned(aRequest.UserAgent) then
          lRequestMessage.Headers.UserAgent.ParseAdd(aRequest.UserAgent);
        if assigned(aRequest.Content) then begin
          var lContent := new System.Net.Http.ByteArrayContent((aRequest.Content as IHttpRequestContent).GetContentAsArray());
          if length(aRequest.Content.ContentType) > 0 then
            lContent.Headers.ContentType := new System.Net.Http.Headers.MediaTypeHeaderValue(aRequest.Content.ContentType);
          lRequestMessage.Content := lContent;
        end;

        lRequestMessage.Headers.Accept.ParseAdd(aRequest.Accept);
        for each k in aRequest.Headers.Keys do
          lRequestMessage.Headers.Add(k, aRequest.Headers[k]);

        cts := new System.Threading.CancellationTokenSource();
        cts.CancelAfter(TimeSpan.From(aRequest.Timeout));
        locking aRequest.Monitor do aRequest.fCancelSource := cts;

        var lRepsonseMessage := await lClient.SendAsync(lRequestMessage, System.Net.Http.HttpCompletionOption.ResponseHeadersRead, cts.Token);
        locking aRequest.Monitor do aRequest.fCancelSource := nil;
        if lRepsonseMessage.StatusCode ≥ System.Net.HttpStatusCode.Redirect then begin
          var lResponse := new HttpResponse(lRepsonseMessage, new HttpException(lRepsonseMessage.StatusCode as Integer, aRequest), cts, lClient);
          lResponseOwnsClient := true;
          aResponseCallback(lResponse);
        end
        else begin
          var lResponse := new HttpResponse(lRepsonseMessage, cts, lClient);
          lResponseOwnsClient := true;
          aResponseCallback(lResponse);
        end;
      except
        on E: System.OperationCanceledException do
          aResponseCallback(new HttpResponse withException(new HttpException('Request timed out', aRequest)));
        on E: Exception do
          aResponseCallback(new HttpResponse withException(E));
      finally
        locking aRequest.Monitor do aRequest.fCancelSource := nil;
      end;
    finally
      if not lResponseOwnsClient then begin
        lClient:Dispose();
        cts:Dispose();
      end;
    end;
    {$ELSE}
    using lWebRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do try
      // Configure proxy settings
      var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
      case lProxyMode of
        HttpProxyMode.None:
          lWebRequest.Proxy := nil;
        HttpProxyMode.System:
          ; // Default behavior uses system proxy
        HttpProxyMode.Custom:
          lWebRequest.Proxy := new System.Net.WebProxy(aRequest.Proxy.Host, aRequest.Proxy.Port);
      end;
      {$IF NOT NETFX_CORE}
      lWebRequest.AllowAutoRedirect := aRequest.FollowRedirects;
      {$ENDIF}
      lWebRequest.KeepAlive := aRequest.KeepAlive;
      if assigned(aRequest.UserAgent) then
        lWebRequest.UserAgent := aRequest.UserAgent;
      if assigned(aRequest.ContentType) then
        lWebRequest.ContentType := aRequest.ContentType;
      lWebRequest.Method := aRequest.Method.ToHttpString;
      lWebRequest.Timeout := Integer(aRequest.Timeout*1000);
      if assigned(aRequest.Accept) then
        lWebRequest.Accept := aRequest.Accept;

      for each k in aRequest.Headers.Keys do
        lWebRequest.Headers[k] := aRequest.Headers[k];

      if assigned(aRequest.Content) then begin
        {$IF NETSTANDARD}
        // I don't want to mess with BeginGetRequestStream/EndGetRequestStream methods here
        // HttpWebRequest.GetRequestStreamAsync() is not available in WP 8.0
        var lGetRequestStreamTask := System.Threading.Tasks.Task<System.IO.Stream>.Factory.FromAsync(@lWebRequest.BeginGetRequestStream, @lWebRequest.EndGetRequestStream, nil);
        {$ENDIF}
        using stream := {$IF NETSTANDARD} await lGetRequestStreamTask {$ELSEIF NETFX_CORE} await lWebRequest.GetRequestStreamAsync() {$ELSE} lWebRequest.GetRequestStream() {$ENDIF} do begin
          var data := (aRequest.Content as IHttpRequestContent).GetContentAsArray();
          stream.Write(data, 0, data.Length);
          stream.Flush();
          //lWebRequest.ContentLength := data.Length;
        end;
      end;

      locking aRequest.Monitor do aRequest.fCancelWebRequest := lWebRequest;
      lWebRequest.BeginGetResponse( (ar) -> begin
        locking aRequest.Monitor do aRequest.fCancelWebRequest := nil;
        try
          var webResponse := lWebRequest.EndGetResponse(ar) as HttpWebResponse;
          if webResponse.StatusCode >= 300 then begin
            aResponseCallback(new HttpResponse withException(new HttpException(webResponse.StatusCode as Integer, aRequest)));
            (webResponse as IDisposable).Dispose;
          end
          else begin
            aResponseCallback(new HttpResponse(webResponse));
          end;
        except
          on E: WebException do begin
            var lErrorResponse := E.Response as HttpWebResponse;
            if assigned(lErrorResponse) then
              aResponseCallback(new HttpResponse(lErrorResponse, E))
            else
              aResponseCallback(new HttpResponse withException(E));
          end;
          on E: Exception do
            aResponseCallback(new HttpResponse withException(E));
        end;

      end, nil);
    except
      on E: Exception do
        aResponseCallback(new HttpResponse withException(E));
    end;
    {$ENDIF}
  {$ELSEIF DARWIN}
  try
    var nsUrlRequest := new NSMutableURLRequest withURL(aRequest.Url) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);

    //nsUrlRequest.AllowAutoRedirect := aRequest.FollowRedirects;
    nsUrlRequest.allowsCellularAccess := aRequest.AllowCellularAccess;
    nsUrlRequest.HTTPMethod := aRequest.Method.ToHttpString;
    nsUrlRequest.timeoutInterval := aRequest.Timeout as Double;

    if assigned(aRequest.Content) then begin
      if defined("TOFFEE") then
        nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary()
      else
        nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary().ToNSData; {$HINT OPTIMIZE?}
    end;

    for each k in aRequest.Headers.Keys do
      nsUrlRequest.setValue(aRequest.Headers[k]) forHTTPHeaderField(k);
    if assigned(aRequest.Accept) then
      nsUrlRequest.setValue(aRequest.Accept) forHTTPHeaderField("Accept");
    if assigned(aRequest.UserAgent) then
      nsUrlRequest.setValue(aRequest.UserAgent) forHTTPHeaderField("User-Agent");
    if length(aRequest.Content:ContentType) > 0 then
      nsUrlRequest.setValue(aRequest.Content.ContentType) forHTTPHeaderField("Content-Type");

    var lResponse: HttpResponse;
    lResponse := new HttpResponse(aRequest, (aResponse) -> begin
      locking aRequest.Monitor do
        aRequest.fCancelTask := nil;
      var nsHttpUrlResponse := NSHTTPURLResponse(aResponse);
      lResponse.Code := nsHttpUrlResponse.statusCode;
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
        aResponseCallback(lResponse)
      end);
    end);

    // Configure session with proxy settings
    var lConfig := NSURLSessionConfiguration.defaultSessionConfiguration;
    var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
    case lProxyMode of
      HttpProxyMode.None:
        lConfig.connectionProxyDictionary := NSDictionary.dictionaryWithObjects([NSNumber.numberWithBool(false), NSNumber.numberWithBool(false)])
                                                                        forKeys([NSString.stringWithString('HTTPEnable'), NSString.stringWithString('HTTPSEnable')]);
      HttpProxyMode.System:
        ; // Default configuration uses system proxy
      HttpProxyMode.Custom:
        begin
          var lProxyHost := NSString.stringWithString(aRequest.Proxy.Host);
          lConfig.connectionProxyDictionary := NSDictionary.dictionaryWithObjects([NSNumber.numberWithBool(true), lProxyHost, NSNumber.numberWithInt(aRequest.Proxy.Port),
                                                                                    NSNumber.numberWithBool(true), lProxyHost, NSNumber.numberWithInt(aRequest.Proxy.Port)])
                                                                          forKeys([NSString.stringWithString('HTTPEnable'), NSString.stringWithString('HTTPProxy'), NSString.stringWithString('HTTPPort'),
                                                                                   NSString.stringWithString('HTTPSEnable'), NSString.stringWithString('HTTPSProxy'), NSString.stringWithString('HTTPSPort')]);
        end;
    end;
    var lSession := NSURLSession.sessionWithConfiguration(lConfig) &delegate(lResponse) delegateQueue(nil);
    var lRequest := lSession.dataTaskWithRequest(nsUrlRequest);// completionHandler((data, nsUrlResponse, error) -> begin
    lResponse.SetTask(lRequest, lSession);
    locking aRequest.Monitor do
      aRequest.fCancelTask := lRequest;
    lRequest.resume();
  except
    on E: Exception do
      aResponseCallback(new HttpResponse withException(E));
  end;
  {$ELSEIF WEBASSEMBLY}
  var lRequestHandle := GCHandle.Allocate(RemObjects.Elements.WebAssembly.Browser.NewXMLHttpRequest());
  var lRequest := RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest(lRequestHandle.Target);
  lRequest.open(aRequest.Method.ToHttpString, aRequest.Url.ToAbsoluteString, true);
  for each k in aRequest.Headers.Keys do
    lRequest.setRequestHeader(k, aRequest.Headers[k]);
  if assigned(aRequest.Accept) then
    lRequest.setRequestHeader("Accept", aRequest.Accept);
  if assigned(aRequest.UserAgent) then
    lRequest.setRequestHeader("User-Agent", aRequest.UserAgent);
  if length(aRequest.Content:ContentType) > 0 then
    lRequest.setRequestHeader("Content-Type", aRequest.Content.ContentType);

  lRequest.onload := method begin
    //writeLn("Wasm HTTP Success");
    aResponseCallback(new HttpResponse(lRequest));
    lRequestHandle.Dispose();
  end;

  lRequest.onerror := method begin
    //writeLn("Wasm HTTP Error");
    if length(String(lRequest.statusText)) > 0 then
      aResponseCallback(new HttpResponse withException(new RTLException(lRequest.statusText)))
    else
      aResponseCallback(new HttpResponse withException(new RTLException("Request failed without providing an error.")));
    lRequestHandle.Dispose();
  end;
  lRequest.send();
  {$ELSEIF ISLAND}
  async begin
    try
      var lResponse := ExecuteRequestSynchronous(aRequest, true);
      aResponseCallback(lResponse);
    except
      on E: Exception do
        aResponseCallback(new HttpResponse withException(E));
    end;
  end;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.ExecuteRequestSynchronous(aRequest: not nullable HttpRequest): not nullable HttpResponse;
begin
  {$IF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  result := ExecuteRequestSynchronous(aRequest, true) as not nullable;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.TryExecuteRequestSynchronous(aRequest: not nullable HttpRequest): nullable HttpResponse;
begin
  {$IF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  result := ExecuteRequestSynchronous(aRequest, false);
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.ExecuteRequestSynchronous(aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
begin
  aRequest.ApplyAuthentication;
  aRequest.DebugLog;

  {$IF COOPER}
  // Configure proxy
  var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
  var lConnection: java.net.HttpURLConnection;
  case lProxyMode of
    HttpProxyMode.None:
      lConnection := java.net.URL(aRequest.Url).openConnection(java.net.Proxy.NO_PROXY) as java.net.HttpURLConnection;
    HttpProxyMode.System:
      lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection; // Uses default proxy selector
    HttpProxyMode.Custom:
      begin
        var lProxyAddr := new java.net.InetSocketAddress(aRequest.Proxy.Host, aRequest.Proxy.Port);
        var lProxy := new java.net.Proxy(java.net.Proxy.Type.HTTP, lProxyAddr);
        lConnection := java.net.URL(aRequest.Url).openConnection(lProxy) as java.net.HttpURLConnection;
      end;
  end;

  locking aRequest.Monitor do aRequest.fCancelConnection := lConnection;
  try
    if aRequest.Method = HttpRequestMethod.Post then
      lConnection.DoOutput := true;
    lConnection.RequestMethod := aRequest.Method.ToHttpString;
    lConnection.ConnectTimeout := Integer((aRequest.Timeout as Double)*1000);
    for each k in aRequest.Headers.Keys do
      lConnection.setRequestProperty(k, aRequest.Headers[k]);
    if assigned(aRequest.Accept) then
      lConnection.setRequestProperty("Accept", aRequest.Accept);
    if assigned(aRequest.UserAgent) then
      lConnection.setRequestProperty("User-Agent", aRequest.UserAgent);
    if length(aRequest.Content:ContentType) > 0 then
      lConnection.setRequestProperty("Content-Type", aRequest.Content.ContentType);

    if assigned(aRequest.Content) then begin
      lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
      lConnection.getOutputStream().flush();
    end;

    result := new HttpResponse(lConnection);
    if lConnection.ResponseCode >= 300 then begin
      if not aThrowOnError then exit nil;
      raise new HttpException(Integer(lConnection.responseCode), aRequest, result)
    end;
  finally
    locking aRequest.Monitor do aRequest.fCancelConnection := nil;
  end;

  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    var lHandler := new System.Net.Http.HttpClientHandler();
    lHandler.ServerCertificateCustomValidationCallback := (sender, cert, chain, sslPolicyErrors) -> begin
      result := if sslPolicyErrors = SslPolicyErrors.None then
        true
      else if assigned(aRequest.VerifyUntrustedCertificate) then
        aRequest.VerifyUntrustedCertificate(new HttpCertificateInfo(cert, chain, sslPolicyErrors))
      else
        false;
    end;
    // Configure proxy settings
    var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
    case lProxyMode of
      HttpProxyMode.None:
        lHandler.UseProxy := false;
      HttpProxyMode.System:
        lHandler.UseProxy := true; // Proxy = null uses system default
      HttpProxyMode.Custom:
        begin
          lHandler.UseProxy := true;
          lHandler.Proxy := new System.Net.WebProxy(aRequest.Proxy.Host, aRequest.Proxy.Port);
        end;
    end;
    var lClient := new System.Net.Http.HttpClient(lHandler);
    var lResponseOwnsClient := false;
    var lCts: System.Threading.CancellationTokenSource;
    try
      var lRequestMessage := new System.Net.Http.HttpRequestMessage();
      lRequestMessage.RequestUri := aRequest.Url;
      lRequestMessage.Method := new System.Net.Http.HttpMethod(aRequest.Method.ToHttpString);

      if assigned(aRequest.UserAgent) then
        lRequestMessage.Headers.UserAgent.ParseAdd(aRequest.UserAgent);

      if assigned(aRequest.Content) then begin
        var lContent := new System.Net.Http.ByteArrayContent((aRequest.Content as IHttpRequestContent).GetContentAsArray());
        if length(aRequest.Content.ContentType) > 0 then
          lContent.Headers.ContentType := new System.Net.Http.Headers.MediaTypeHeaderValue(aRequest.Content.ContentType);
        lRequestMessage.Content := lContent;
      end;

      lRequestMessage.Headers.Accept.ParseAdd(aRequest.Accept);
      for each k in aRequest.Headers.Keys do
        lRequestMessage.Headers.Add(k, aRequest.Headers[k]);

      lCts := new System.Threading.CancellationTokenSource();
      lCts.CancelAfter(TimeSpan.From(aRequest.Timeout));
      locking aRequest.Monitor do aRequest.fCancelSource := lCts;
      try
        var lResponseMessage := lClient.SendAsync(lRequestMessage, System.Net.Http.HttpCompletionOption.ResponseHeadersRead, lCts.Token).Result;
        locking aRequest.Monitor do aRequest.fCancelSource := nil;
        if (lResponseMessage.StatusCode ≥ System.Net.HttpStatusCode.Redirect) and aThrowOnError then
          raise new HttpException(Integer(lResponseMessage.StatusCode), aRequest);
        result := new HttpResponse(lResponseMessage, lCts, lClient);
        lResponseOwnsClient := true;
      except
        on E: Exception do
          exit HandleEchoesHttpClientException(E, aRequest, aThrowOnError);
      finally
        locking aRequest.Monitor do aRequest.fCancelSource := nil;
      end;
    finally
      if not lResponseOwnsClient then begin
        lClient:Dispose();
        lCts:Dispose();
      end;
    end;
    {$ELSE}
    using webRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do begin
      // Configure proxy settings
      var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
      case lProxyMode of
        HttpProxyMode.None:
          webRequest.Proxy := nil;
        HttpProxyMode.System:
          ; // Default behavior uses system proxy
        HttpProxyMode.Custom:
          webRequest.Proxy := new System.Net.WebProxy(aRequest.Proxy.Host, aRequest.Proxy.Port);
      end;
      {$IF NOT NETFX_CORE}
      webRequest.AllowAutoRedirect := aRequest.FollowRedirects;
      {$ENDIF}
      webRequest.KeepAlive := aRequest.KeepAlive;
      if assigned(aRequest.UserAgent) then
        webRequest.UserAgent := aRequest.UserAgent;
      if assigned(aRequest.ContentType) then
        webRequest.ContentType := aRequest.ContentType;
      webRequest.Method := aRequest.Method.ToHttpString;
      webRequest.Timeout := Integer(aRequest.Timeout*1000);
      if assigned(aRequest.Accept) then
        webRequest.Accept := aRequest.Accept;

      for each k in aRequest.Headers.Keys do
        webRequest.Headers[k] := aRequest.Headers[k];

      if assigned(aRequest.Content) then begin
        using stream := webRequest.GetRequestStream() do begin
          var data := (aRequest.Content as IHttpRequestContent).GetContentAsArray();
          stream.Write(data, 0, data.Length);
          stream.Flush();
        end;
      end;

      locking aRequest.Monitor do aRequest.fCancelWebRequest := webRequest;
      try
        var lWebResponse := webRequest.GetResponse() as HttpWebResponse;
        if (lWebResponse.StatusCode ≥ 300) and aThrowOnError then begin
          var lException := new HttpException(String.Format("Unable to complete request. Error code: {0}", lWebResponse.StatusCode), result);
          (lWebResponse as IDisposable).Dispose;
          raise lException;
        end;
        result := new HttpResponse(lWebResponse);
      except
        on E: System.Net.WebException do begin
          if not aThrowOnError then begin
            if E.Response is HttpWebResponse then
              exit new HttpResponse(E.Response as HttpWebResponse)
            else
              exit new HttpResponse withException(E);
          end
          else begin
            if E.Response is HttpWebResponse then
              raise new HttpException(E.Message, aRequest, new HttpResponse(E.Response as HttpWebResponse))
            else case E.Status of
              WebExceptionStatus.NameResolutionFailure: raise new HttpException($"Could not resolve host name '{aRequest.Url.Host}'", aRequest)
              else raise new HttpException(E.Message, aRequest);
            end;
          end;
        end;
      end;

    end;
    {$ENDIF}
  {$ELSEIF ISLAND AND WINDOWS}
  var lSession := CreateSessionForProxy(aRequest.Proxy);
  if lSession = nil then
    raise new RTLException('Unable to create HTTP session');

  try
    var lFlags := if aRequest.Url.Scheme.EqualsIgnoringCase('https') then rtl.WINHTTP_FLAG_SECURE else 0;
    var lPort := 80;
    if aRequest.Url.Port <> nil then
      lPort := aRequest.Url.Port
    else
      if lFlags <> 0 then
        lPort := 443;
    var lConnect := rtl.WinHttpConnect(lSession, RemObjects.Elements.System.String(aRequest.Url.Host).FirstChar, lPort, 0);
    if lConnect = nil then
      raise new RTLException('Unable to connect to ' + aRequest.Url.Host);

    try
      var lMethod := RemObjects.Elements.System.String(aRequest.Method.ToHttpString);
      var lPath := RemObjects.Elements.System.String(aRequest.Url.PathAndQueryString);
      var lRequest := rtl.WinHttpOpenRequest(lConnect, LMethod.FirstChar, lPath.FirstChar, nil, nil, nil, lFlags);
      if lRequest = nil then
        raise new RTLException('Can not open request to ' + aRequest.Url.Host);

      try
        var lTimeoutMs: rtl.DWORD := rtl.DWORD(aRequest.Timeout * 1000);
        rtl.WinHttpSetOption(lRequest, 5 {WINHTTP_OPTION_SEND_TIMEOUT}, @lTimeoutMs, sizeOf(lTimeoutMs));
        rtl.WinHttpSetOption(lRequest, 8 {WINHTTP_OPTION_RECEIVE_TIMEOUT}, @lTimeoutMs, sizeOf(lTimeoutMs));

        var lHeader: RemObjects.Elements.System.String;
        for each k in aRequest.Headers.Keys do begin
          lHeader := k + ':' + aRequest.Headers[k];
          if not rtl.WinHttpAddRequestHeaders(lRequest, lHeader.FirstChar, high(Cardinal), rtl.WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA) then
            raise new RTLException('Error adding headers to request');
        end;

        var lTotalLength := 0;
        var lData: array of Byte;
        if assigned(aRequest.Content) then begin
          lData := (aRequest.Content as IHttpRequestContent).GetContentAsArray;
          lTotalLength := lData.Length;
        end;

        if not aRequest.FollowRedirects then begin
          var lValue: rtl.DWORD := rtl.WINHTTP_DISABLE_REDIRECTS;
          rtl.WinHttpSetOption(LRequest, rtl.WINHTTP_OPTION_DISABLE_FEATURE, @lValue, sizeOf(lValue));
        end;

        locking aRequest.Monitor do aRequest.fCancelHandle := lRequest;

        if not rtl.WinHttpSendRequest(lRequest, nil, 0, nil, 0, lTotalLength, 0) then
          raise new RTLException('Can not send request to ' + aRequest.Url.Host);

        if lTotalLength > 0 then begin
          var lPassed := 0;
          var lBytes: rtl.DWORD := 0;
          while lPassed < lTotalLength do begin
            if not rtl.WinHttpWriteData(lRequest, @lData[lPassed], lTotalLength, @lBytes) then
              raise new RTLException('Error sending data to ' + aRequest.Url.Host);
            inc(lPassed, lBytes);
          end;
        end;

        if not rtl.WinHttpReceiveResponse(lRequest, nil) then
          raise new RTLException('Can not receive data from ' + aRequest.Url.Host);

        var lStatusCode: rtl.DWORD := 0;
        var lSize: rtl.DWORD := sizeOf(lStatusCode);

        rtl.WinHttpQueryHeaders(lRequest, rtl.WINHTTP_QUERY_STATUS_CODE or rtl.WINHTTP_QUERY_FLAG_NUMBER,
          nil {WINHTTP_HEADER_NAME_BY_INDEX}, @lStatusCode, @lSize, nil {rtl.WINHTTP_NO_HEADER_INDEX});

        var lStream := new MemoryStream();
        var lBuffered: rtl.DWORD := 0;
        if not rtl.WinHttpQueryDataAvailable(lRequest, @lSize) then
          raise new RTLException('Can not get data from ' + aRequest.Url.Host);
        while lSize <> 0 do begin
          var lBuffer := new Byte[lSize];
          if not rtl.WinHttpReadData(lRequest, @lBuffer[0], lSize, @lBuffered) then
            raise new RTLException('Can not get data from ' + aRequest.Url.Host);
          lStream.Write(lBuffer, lBuffered);
          if not rtl.WinHttpQueryDataAvailable(lRequest, @lSize) then
            raise new RTLException('Can not get data from ' + aRequest.Url.Host);
        end;

        try
          result := new HttpResponse(lRequest, lStatusCode, lStream);
          if lStatusCode >= 300 then begin
            if not aThrowOnError then exit nil;
            raise new RTLException(String.Format("Unable to complete request. Error code: {0}", lStatusCode), result)
          end;
        except
          on E: Exception do begin
            if not aThrowOnError then exit nil;
            raise new RTLException(E.Message);
          end;
        end;
      finally
        var lCancelHandle: rtl.HINTERNET;
        locking aRequest.Monitor do begin
          lCancelHandle := aRequest.fCancelHandle;
          aRequest.fCancelHandle := nil;
        end;
        if lCancelHandle <> nil then
          rtl.WinHttpCloseHandle(lCancelHandle);
      end;
    finally
      rtl.WinHttpCloseHandle(lConnect);
    end;
  finally
    rtl.WinHttpCloseHandle(lSession);
  end;
  {$ELSEIF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSEIF ISLAND AND LINUX}
  var lRequest := CurlHelper.EasyInit();
  var lStream := new MemoryStream();
  var lHeaders := new Dictionary<String, String>();
  var lUploadHelper: CurlUploadHelper;
  CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_WRITEFUNCTION, ^void(@CurlHelper.ReceiveData));
  CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_WRITEDATA, ^void(InternalCalls.Cast(lStream)));
  CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_HEADERFUNCTION, ^void(@CurlHelper.ReceiveHeaders));
  CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_HEADERDATA, ^Void(InternalCalls.Cast(lHeaders)));
  CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_TCP_KEEPALIVE, 1);
  CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_NOPROGRESS, 1);
  var lUrl := RemObjects.Elements.System.String(aRequest.Url.ToString).ToAnsiChars(true);
  CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_URL, @lUrl[0]);

  // Configure proxy settings
  var lProxyUrl: array of AnsiChar;
  var lNoProxy: array of AnsiChar;
  var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
  case lProxyMode of
    HttpProxyMode.None: begin
      // Disable proxy by setting NOPROXY to "*" (all hosts bypass proxy)
      lNoProxy := RemObjects.Elements.System.String('*').ToAnsiChars(true);
      CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_NOPROXY, @lNoProxy[0]);
    end;
    HttpProxyMode.System:
      ; // libcurl automatically uses http_proxy/https_proxy environment variables
    HttpProxyMode.Custom: begin
      // Set custom proxy as "host:port" (libcurl defaults to HTTP proxy type)
      lProxyUrl := RemObjects.Elements.System.String(aRequest.Proxy.Host + ':' + aRequest.Proxy.Port.ToString).ToAnsiChars(true);
      CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_PROXY, @lProxyUrl[0]);
    end;
  end;

  if aRequest.FollowRedirects then
    CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_FOLLOWLOCATION, 1);

  var lHeader: RemObjects.Elements.System.String;
  var lHeaderBytes: array of AnsiChar;
  var lHeaderList: ^curl_slist := nil;
  for each k in aRequest.Headers.Keys do begin
    lHeader := k + ':' + aRequest.Headers[k];
    lHeaderBytes := lHeader.ToAnsiChars(true);
    lHeaderList := CurlHelper.SListAppend(lHeaderList, @lHeaderBytes[0]);
  end;
  if assigned(aRequest.Accept) then begin
    lHeader := 'Accept:' + aRequest.Accept;
    lHeaderBytes := lHeader.ToAnsiChars(true);
    lHeaderList := CurlHelper.SListAppend(lHeaderList, @lHeaderBytes[0]);
  end;

  var lTotalLength := 0;
  var lData: array of Byte;
  if assigned(aRequest.Content) then begin
    lData := (aRequest.Content as IHttpRequestContent).GetContentAsArray;
    lTotalLength := lData.Length;
  end;

  case aRequest.Method of
    HttpRequestMethod.Get, HttpRequestMethod.Put, HttpRequestMethod.Delete, HttpRequestMethod.Patch,
    HttpRequestMethod.Options, HttpRequestMethod.Trace:
      CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_HTTPGET, 1);

    HttpRequestMethod.Head: begin
      CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_NOBODY, 1);
      var lMethod := Encoding.UTF8.GetBytes(aRequest.Method.ToHttpString);
      CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_CUSTOMREQUEST, @lMethod[0]);
    end;

    HttpRequestMethod.Post: begin
      CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_POST, 1);
      CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_READFUNCTION, ^void(@CurlHelper.SendData));
      lUploadHelper := new CurlUploadHelper(lData);
      CurlHelper.EasySetOptPointer(lRequest, CURLOption.CURLOPT_READDATA, ^void(InternalCalls.Cast(lUploadHelper)));
      CurlHelper.EasySetOptInteger(lRequest, CURLOption.CURLOPT_POSTFIELDSIZE, lTotalLength);
    end;
  end;

  var lResult := CurlHelper.EasyPerform(lRequest);
  if lResult = CURLCode.CURLE_OK then begin
    var lStatusCode: NativeInt;
    CurlHelper.EasyGetInfo1(lRequest, CURLINFO.CURLINFO_RESPONSE_CODE, @lStatusCode);
    try
      result := new HttpResponse(lStatusCode, lStream, lHeaders);
      if lStatusCode >= 300 then begin
        if not aThrowOnError then exit nil;
        raise new RTLException(String.Format("Unable to complete request. HTTP Error code: {0}", lStatusCode), result)
      end;

    except
      on E: Exception do begin
        if not aThrowOnError then exit nil;
        raise new RTLException(E.Message);
      end;
    end;
  end
  else begin
    if not aThrowOnError then exit nil;
    raise new RTLException(String.Format("Unable to complete request. LibCurl Error code: {0}", lResult), result);
  end;
  {$ELSEIF DARWIN}
  var nsUrlRequest := new NSMutableURLRequest withURL(aRequest.Url) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);

  //nsUrlRequest.AllowAutoRedirect := aRequest.FollowRedirects;
  nsUrlRequest.allowsCellularAccess := aRequest.AllowCellularAccess;
  nsUrlRequest.HTTPMethod := aRequest.Method.ToHttpString;
  nsUrlRequest.timeoutInterval := aRequest.Timeout as Double;

  if assigned(aRequest.Content) then begin
    if defined("TOFFEE") then
      nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary()
    else
      nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary().ToNSData; {$HINT OPTIMIZE?}
  end;

  for each k in aRequest.Headers.Keys do
    nsUrlRequest.setValue(aRequest.Headers[k]) forHTTPHeaderField(k);
  if assigned(aRequest.Accept) then
    nsUrlRequest.setValue(aRequest.Accept) forHTTPHeaderField("Accept");
  if assigned(aRequest.UserAgent) then
    nsUrlRequest.setValue(aRequest.UserAgent) forHTTPHeaderField("User-Agent");
  if length(aRequest.Content:ContentType) > 0 then
    nsUrlRequest.setValue(aRequest.Content.ContentType) forHTTPHeaderField("Content-Type");

  // Configure session with proxy settings
  var lConfig := NSURLSessionConfiguration.defaultSessionConfiguration;
  var lProxyMode := if assigned(aRequest.Proxy) then aRequest.Proxy.Mode else HttpProxyMode.System;
  case lProxyMode of
    HttpProxyMode.None:
      lConfig.connectionProxyDictionary := NSDictionary.dictionaryWithObjects([NSNumber.numberWithBool(false), NSNumber.numberWithBool(false)])
                                                                      forKeys([NSString.stringWithString('HTTPEnable'), NSString.stringWithString('HTTPSEnable')]);
    HttpProxyMode.System:
      ; // Default configuration uses system proxy
    HttpProxyMode.Custom:
      begin
        var lProxyHost := NSString.stringWithString(aRequest.Proxy.Host);
        lConfig.connectionProxyDictionary := NSDictionary.dictionaryWithObjects([NSNumber.numberWithBool(true), lProxyHost, NSNumber.numberWithInt(aRequest.Proxy.Port),
                                                                                  NSNumber.numberWithBool(true), lProxyHost, NSNumber.numberWithInt(aRequest.Proxy.Port)])
                                                                        forKeys([NSString.stringWithString('HTTPEnable'), NSString.stringWithString('HTTPProxy'), NSString.stringWithString('HTTPPort'),
                                                                                 NSString.stringWithString('HTTPSEnable'), NSString.stringWithString('HTTPSProxy'), NSString.stringWithString('HTTPSPort')]);
      end;
  end;

  // Use NSURLSession with semaphore to make sync call
  var lSemaphore := dispatch_semaphore_create(0);
  var lResponseData: NSData;
  var lUrlResponse: NSURLResponse;
  var lError: NSError;

  var lSession := NSURLSession.sessionWithConfiguration(lConfig);
  var lTask := lSession.dataTaskWithRequest(nsUrlRequest) completionHandler((data, response, error) -> begin
    lResponseData := data;
    lUrlResponse := response;
    lError := error;
    dispatch_semaphore_signal(lSemaphore);
  end);
  aRequest.fCancelTask := lTask;
  lTask.resume();
  dispatch_semaphore_wait(lSemaphore, DISPATCH_TIME_FOREVER);
  aRequest.fCancelTask := nil;

  var nsHttpUrlResponse := NSHTTPURLResponse(lUrlResponse);
  if assigned(lResponseData) and assigned(nsHttpUrlResponse) then begin
    if defined("TOFFEE") then
      result := new HttpResponse(lResponseData, nsHttpUrlResponse)
    else
      result := new HttpResponse(lResponseData, nsHttpUrlResponse);
    if nsHttpUrlResponse.statusCode >= 300 then begin
      if aThrowOnError then
        raise new HttpException(nsHttpUrlResponse.statusCode, aRequest, result);
    end;
  end
  else if assigned(lError) then begin
    if not aThrowOnError then exit nil;
    if assigned(nsHttpUrlResponse) then
      raise new HttpException(lError.description, aRequest, new HttpResponse(nil, nsHttpUrlResponse))
    else
      raise new RTLException withError(lError);
  end
  else begin
    if not aThrowOnError then exit nil;
    if assigned(nsHttpUrlResponse) then
      raise new HttpException(String.Format("Request failed without providing an error. Error code: {0}", nsHttpUrlResponse.statusCode), aRequest, new HttpResponse(nil, nsHttpUrlResponse))
    else
      raise new RTLException("Request failed without providing an error.");
  end;
  {$ELSE}
  raise new NotImplementedException("Http.ExecuteRequestSynchronous is not implemented for this platform")
  {$ENDIF}
end;

{method Http.ExecuteRequest(aUrl: not nullable Url; ResponseCallback: not nullable HttpResponseBlock);
begin
  ExecuteRequest(new HttpRequest(aUrl, HttpRequestMethod.Get), responseCallback);
end;}

method Http.ExecuteRequestAsString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<String>);
begin
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.GetContentAsString(aEncoding, (content) -> begin
        contentCallback(content)
      end);
    end else begin
      contentCallback(new HttpResponseContent<String>(Exception := coalesce(response.Exception, new HttpException(response.Code, aRequest))));
    end;
  end);
end;

{$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembly")]{$ENDIF}
method Http.ExecuteRequestAsBinary(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Binary Data is not supported on WebAssembkly")
  {$ELSE}
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.GetContentAsBinary( (content) -> begin
        contentCallback(content)
      end);
    end else begin
      contentCallback(new HttpResponseContent<ImmutableBinary>(Exception := coalesce(response.Exception, new HttpException(response.Code, aRequest))));
    end;
  end);
  {$ENDIF}
end;

{$IF XML}
method Http.ExecuteRequestAsXml(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);
begin
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.GetContentAsXml( (content) -> begin
        contentCallback(content)
      end);
    end
    else begin
      contentCallback(new HttpResponseContent<XmlDocument>(Exception := coalesce(response.Exception, new HttpException(response.Code, aRequest))));
    end;
  end);
end;
{$ENDIF}

{$IF JSON}
method Http.ExecuteRequestAsJson(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);
begin
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.GetContentAsJson( (content) -> begin
        contentCallback(content)
      end);
    end
    else begin
      contentCallback(new HttpResponseContent<JsonDocument>(Exception := coalesce(response.Exception, new HttpException(response.Code, aRequest))));
    end;
  end);
end;
{$ENDIF}

{$IF WEBASSEMBLY}[Warning("File Access is not supported on WebAssembkly")]{$ENDIF}
method Http.ExecuteRequestAndSaveAsFile(aRequest: not nullable HttpRequest; aTargetFile: not nullable File; contentCallback: not nullable HttpContentResponseBlock<File>);
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("File Access is not supported on WebAssembkly")
  {$ELSE}
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.SaveContentAsFile(String(aTargetFile), (content) -> begin
        contentCallback(content)
      end);
    end else begin
      contentCallback(new HttpResponseContent<File>(Exception := coalesce(response.Exception, new HttpException(response.Code, aRequest))));
    end;
  end);
  {$ENDIF}
end;

{$IF NOT NETFX_CORE}
{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.GetString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest): not nullable String;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := ExecuteRequestSynchronous(aRequest) do
    result := lResponse.GetContentAsStringSynchronous(aEncoding);
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.GetBinary(aRequest: not nullable HttpRequest): not nullable ImmutableBinary;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := ExecuteRequestSynchronous(aRequest) do
    result := lResponse.GetContentAsBinarySynchronous;
  {$ENDIF}
end;

{$IF XML}
{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.GetXml(aRequest: not nullable HttpRequest): not nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := ExecuteRequestSynchronous(aRequest) do
    result := lResponse.GetContentAsXmlSynchronous;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.TryGetXml(aRequest: not nullable HttpRequest): nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := TryExecuteRequestSynchronous(aRequest) do
    result := lResponse:TryGetContentAsXmlSynchronous;
  {$ENDIF}
end;
{$ENDIF}

{$IF JSON}
{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.GetJson(aRequest: not nullable HttpRequest): not nullable JsonDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := ExecuteRequestSynchronous(aRequest) do
    result := lResponse.GetContentAsJsonSynchronous;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
method Http.TryGetJson(aRequest: not nullable HttpRequest): nullable JsonDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembkly")
  {$ELSE}
  using lResponse := TryExecuteRequestSynchronous(aRequest) do
    result := lResponse:TryGetContentAsJsonSynchronous;
  {$ENDIF}
end;
{$ENDIF}
{$ENDIF}

(*

{$IF NETSTANDARD}
class method Http.InternalDownload(anUrl: Url): System.Threading.Tasks.Task<System.Net.HttpWebResponse>;
begin
  var Request: System.Net.HttpWebRequest := System.Net.WebRequest.CreateHttp(anUrl);
  Request.Method := "GET";
  Request.AllowReadStreamBuffering := true;

  var TaskComplete := new System.Threading.Tasks.TaskCompletionSource<System.Net.HttpWebResponse>;

  Request.BeginGetResponse(x -> begin
                             try
                              var ResponseRequest := System.Net.HttpWebRequest(x.AsyncState);
                              var Response := System.Net.HttpWebResponse(ResponseRequest.EndGetResponse(x));
                              TaskComplete.TrySetResult(Response);
                             except
                               on E: Exception do
                                TaskComplete.TrySetException(E);
                             end;
                           end, Request);
  exit TaskComplete.Task;
end;
{$ENDIF}

class method Http.Download(anUrl: Url): HttpResponse<ImmutableBinary>;
begin
  try
  {$IF COOPER}
  {$ELSEIF NETSTANDARD}
    var Response := InternalDownload(anUrl).Result;

    if Response.StatusCode <> System.Net.HttpStatusCode.OK then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Unable to download data, Response: " + Response.StatusDescription));

    var Stream := Response.GetResponseStream;

    if Stream = nil then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));

    var Content := new Binary;
    var Buffer := new Byte[16 * 1024];
    var Readed: Integer := Stream.Read(Buffer, 0, Buffer.Length);

    while Readed > 0 do begin
      Content.Write(Buffer, Readed);
      Readed := Stream.Read(Buffer, 0, Buffer.Length);
    end;

    if Content.Length = 0 then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));

    exit new HttpResponse<ImmutableBinary>(Content);
  {$ELSEIF NETFX_CORE}
    var Client := new System.Net.Http.HttpClient;

    var Content := Client.GetByteArrayAsync(anUrl).Result;

    if Content = nil then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));

    if Content.Length = 0 then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));


    exit new HttpResponse<ImmutableBinary>(new ImmutableBinary(Content));
  {$ELSEIF ECHOES}
  using lClient: System.Net.WebClient := new System.Net.WebClient() do begin
    var Content := lClient.DownloadData(anUrl);

    if Content = nil then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));

    if Content.Length = 0 then
      exit new HttpResponse<ImmutableBinary> withException(new SugarException("Content is empty"));

    exit new HttpResponse<ImmutableBinary>(new ImmutableBinary(Content));
  end;
  {$ELSEIF TOFFEE}
  var lError: NSError := nil;
  var lRequest := new NSURLRequest withURL(anUrl) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);
  var lResponse: NSURLResponse;

  var lData := NSURLConnection.sendSynchronousRequest(lRequest) returningResponse(var lResponse) error(var lError);

  if lError <> nil then
    exit new HttpResponse<ImmutableBinary> withException(Exception(new SugarNSErrorException(lError)));

  if NSHTTPURLResponse(lResponse).statusCode <> 200 then
    exit new HttpResponse<ImmutableBinary> withException(Exception(new SugarIOException(" . Error code: {0}", NSHTTPURLResponse(lResponse).statusCode)));

  exit new HttpResponse<ImmutableBinary>(ImmutableBinary(NSMutableData.dataWithData(lData)));
  {$ENDIF}
  except
    on E: Exception do begin
      var Actual := E;

      {$IF NETSTANDARD}
      if E is AggregateException then
        Actual := AggregateException(E).InnerException;
      {$ENDIF}

      exit new HttpResponse<ImmutableBinary> withException(Actual);
    end;
  end;
end;
*)

end.
