namespace RemObjects.Elements.RTL;

interface

{$DEFINE XML}{$DEFINE JSON}

{ Handy test URLs: http://httpbin.org, http://requestb.in }

type
  Http = public static class
  private
    {$IF DARWIN}
    //property Session := NSURLSession.sessionWithConfiguration(NSURLSessionConfiguration.defaultSessionConfiguration); lazy;
    {$ELSEIF ISLAND AND WINDOWS}
    property Session := rtl.WinHTTPOpen('', rtl.WINHTTP_ACCESS_TYPE_NO_PROXY, nil, nil, 0); lazy;
    {$ENDIF}
    method ExecuteRequestSynchronous(aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
  public
    //method ExecuteRequest(aUrl: not nullable Url; ResponseCallback: not nullable HttpResponseBlock);
    method ExecuteRequest(aRequest: not nullable HttpRequest; ResponseCallback: not nullable HttpResponseBlock);
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
  end;

implementation

uses
  {$IF ECHOES}
  System.Net,
  {$ENDIF}
  RemObjects.Elements;

{ Http }

method Http.ExecuteRequest(aRequest: not nullable HttpRequest; ResponseCallback: not nullable HttpResponseBlock);
begin
  aRequest.ApplyAuthehtication;

  {$IF COOPER}
  async try
    var lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection;

    if aRequest.Method = HttpRequestMethod.Post then
      lConnection.DoOutput := true;
    lConnection.RequestMethod := aRequest.Method.ToHttpString;
    lConnection.ConnectTimeout := Integer(aRequest.Timeout*1000);
    for each k in aRequest.Headers.Keys do
      lConnection.setRequestProperty(k, aRequest.Headers[k]);
    if assigned(aRequest.Accept) then
      lConnection.setRequestProperty("Accept", aRequest.Accept);
    if assigned(aRequest.UserAgent) then
      lConnection.setRequestProperty("User-Agent", aRequest.UserAgent);
    if assigned(aRequest.ContentType) then
      lConnection.setRequestProperty("Content-Type", aRequest.ContentType);

    if assigned(aRequest.Content) then begin
      lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
      lConnection.getOutputStream().flush();
    end;

    try
      var lResponse := if lConnection.ResponseCode >= 300 then new HttpResponse withException(new HttpException(lConnection.responseCode, aRequest)) else new HttpResponse(lConnection);
      responseCallback(lResponse);
    except
      on E: Exception do
        responseCallback(new HttpResponse withException(E));
    end;

  except
    on E: Exception do
      ResponseCallback(new HttpResponse withException(E));
  end;
  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    using lClient := new System.Net.Http.HttpClient() do begin
      try
        var lRequestMessage := new System.Net.Http.HttpRequestMessage();
        lRequestMessage.RequestUri := aRequest.Url;
        lRequestMessage.Method := new System.Net.Http.HttpMethod(aRequest.Method.ToHttpString);

        if assigned(aRequest.UserAgent) then
          lRequestMessage.Headers.UserAgent.ParseAdd(aRequest.UserAgent);
        if assigned(aRequest.ContentType) then
          lRequestMessage.Content := new System.Net.Http.ByteArrayContent((aRequest.Content as IHttpRequestContent).GetContentAsArray());
        lRequestMessage.Content.Headers.ContentType := new System.Net.Http.Headers.MediaTypeHeaderValue(aRequest.ContentType);
        lRequestMessage.Headers.Accept.ParseAdd(aRequest.Accept);

        for each k in aRequest.Headers.Keys do
          lRequestMessage.Headers.Add(k, aRequest.Headers[k]);

        var cts := new System.Threading.CancellationTokenSource();
        cts.CancelAfter(TimeSpan.FromSeconds(aRequest.Timeout));

        var lRepsonseMessage := await lClient.SendAsync(lRequestMessage, cts.Token);
        if lRepsonseMessage.StatusCode ≥ System.Net.HttpStatusCode.Redirect then begin
          ResponseCallback(new HttpResponse withException(new HttpException(lRepsonseMessage.StatusCode as Integer, aRequest)));
        end
        else begin
          ResponseCallback(new HttpResponse(lRepsonseMessage));
        end;
      except
        on E: System.OperationCanceledException do
          ResponseCallback(new HttpResponse withException(new HttpException('Request timed out', aRequest)));
        on E: Exception do
          ResponseCallback(new HttpResponse withException(E));
      end;
    end;
    {$ELSE}
    using webRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do try
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
      {$IF NETSTANDARD}
        // I don't want to mess with BeginGetRequestStream/EndGetRequestStream methods here
        // HttpWebRequest.GetRequestStreamAsync() is not available in WP 8.0
        var getRequestStreamTask := System.Threading.Tasks.Task<System.IO.Stream>.Factory.FromAsync(@webRequest.BeginGetRequestStream, @webRequest.EndGetRequestStream, nil);
      {$ENDIF}
        using stream :=
          {$IF NETSTANDARD}
          await getRequestStreamTask
          {$ELSEIF NETFX_CORE}
          await webRequest.GetRequestStreamAsync()
          {$ELSE}
          webRequest.GetRequestStream()
          {$ENDIF}
      do begin
          var data := (aRequest.Content as IHttpRequestContent).GetContentAsArray();
          stream.Write(data, 0, data.Length);
          stream.Flush();
          //webRequest.ContentLength := data.Length;
        end;
      end;

      webRequest.BeginGetResponse( (ar) -> begin

        try
          var webResponse := webRequest.EndGetResponse(ar) as HttpWebResponse;
          if webResponse.StatusCode >= 300 then begin
            ResponseCallback(new HttpResponse withException(new HttpException(webResponse.StatusCode as Integer, aRequest)));
            (webResponse as IDisposable).Dispose;
          end
          else begin
            ResponseCallback(new HttpResponse(webResponse));
          end;
        except
          on E: Exception do
            ResponseCallback(new HttpResponse withException(E));
        end;

      end, nil);
    except
      on E: Exception do
        ResponseCallback(new HttpResponse withException(E));
    end;
    {$ENDIF}
  {$ELSEIF DARWIN}
  try
    var nsUrlRequest := new NSMutableURLRequest withURL(aRequest.Url) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);

    //nsUrlRequest.AllowAutoRedirect := aRequest.FollowRedirects;
    nsUrlRequest.allowsCellularAccess := aRequest.AllowCellularAccess;
    nsUrlRequest.HTTPMethod := aRequest.Method.ToHttpString;
    nsUrlRequest.timeoutInterval := aRequest.Timeout;

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
    if assigned(aRequest.ContentType) then
      nsUrlRequest.setValue(aRequest.ContentType) forHTTPHeaderField("Content-Type");

    var lDelegate := new SessionDelegate(aRequest);
    var lSession := NSURLSession.sessionWithConfiguration(NSURLSessionConfiguration.defaultSessionConfiguration) &delegate(lDelegate) delegateQueue(nil);
    var lRequest := lSession.dataTaskWithRequest(nsUrlRequest) completionHandler((data, nsUrlResponse, error) -> begin

      var nsHttpUrlResponse := NSHTTPURLResponse(nsUrlResponse);
      if assigned(data) and assigned(nsHttpUrlResponse) and not assigned(error) then begin
        var response := if nsHttpUrlResponse.statusCode >= 300 then new HttpResponse withException(new HttpException(nsHttpUrlResponse.statusCode, aRequest)) else new HttpResponse(data, nsHttpUrlResponse);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end else if assigned(error) then begin
        var response := new HttpResponse withException(new RTLException withError(error));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end else begin
        var response := new HttpResponse withException(new RTLException("Request failed without providing an error."));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end;
      //lSession.

    end);
    lRequest.resume();
  except
    on E: Exception do
      ResponseCallback(new HttpResponse withException(E));
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
  if assigned(aRequest.ContentType) then
    lRequest.setRequestHeader("Content-Type", aRequest.ContentType);

  lRequest.onload := method begin
    //writeLn("Wasm HTTP Success");
    responseCallback(new HttpResponse(lRequest));
    lRequestHandle.Dispose();
  end;

  lRequest.onerror := method begin
    //writeLn("Wasm HTTP Error");
    if length(String(lRequest.statusText)) > 0 then
      responseCallback(new HttpResponse withException(new RTLException(lRequest.statusText)))
    else
      responseCallback(new HttpResponse withException(new RTLException("Request failed without providing an error.")));
    lRequestHandle.Dispose();
  end;
  lRequest.send();
  {$ELSEIF ISLAND}
  async begin
    try
      var lResponse := ExecuteRequestSynchronous(aRequest, true);
      ResponseCallback(lResponse);
    except
      on E: Exception do
        ResponseCallback(new HttpResponse withException(E));
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
  aRequest.ApplyAuthehtication;

  {$IF COOPER}
  var lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection;

  if aRequest.Method = HttpRequestMethod.Post then
    lConnection.DoOutput := true;
  lConnection.RequestMethod := aRequest.Method.ToHttpString;
  lConnection.ConnectTimeout := Integer(aRequest.Timeout*1000);
  for each k in aRequest.Headers.Keys do
    lConnection.setRequestProperty(k, aRequest.Headers[k]);
  if assigned(aRequest.Accept) then
    lConnection.setRequestProperty("Accept", aRequest.Accept);
  if assigned(aRequest.UserAgent) then
    lConnection.setRequestProperty("User-Agent", aRequest.UserAgent);
  if assigned(aRequest.ContentType) then
    lConnection.setRequestProperty("Content-Type", aRequest.ContentType);

  if assigned(aRequest.Content) then begin
    lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
    lConnection.getOutputStream().flush();
  end;

  result := new HttpResponse(lConnection);
  if lConnection.ResponseCode >= 300 then begin
    if not aThrowOnError then exit nil;
    raise new HttpException(String.Format("Unable to complete request. Error code: {0}", lConnection.responseCode), aRequest, result)
  end;

  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    using lClient := new System.Net.Http.HttpClient() do begin
      var lRequestMessage := new System.Net.Http.HttpRequestMessage();
      lRequestMessage.RequestUri := aRequest.Url;
      lRequestMessage.Method := new System.Net.Http.HttpMethod(aRequest.Method.ToHttpString);

      if assigned(aRequest.UserAgent) then
        lRequestMessage.Headers.UserAgent.ParseAdd(aRequest.UserAgent);
      if assigned(aRequest.ContentType) then
        lRequestMessage.Content.Headers.ContentType := new System.Net.Http.Headers.MediaTypeHeaderValue(aRequest.ContentType);
      lRequestMessage.Headers.Accept.ParseAdd(aRequest.Accept);

      for each k in aRequest.Headers.Keys do
        lRequestMessage.Headers.Add(k, aRequest.Headers[k]);

      if assigned(aRequest.Content) then
        lRequestMessage.Content := new System.Net.Http.ByteArrayContent((aRequest.Content as IHttpRequestContent).GetContentAsArray());

      try
        var lResponseMessage := lClient.SendAsync(lRequestMessage).Result;
        if (lResponseMessage.StatusCode ≥ System.Net.HttpStatusCode.Redirect) and aThrowOnError then
          raise new HttpException(String.Format("Unable to complete request. Error code: {0}", lResponseMessage.StatusCode), nil);
        result := new HttpResponse(lResponseMessage);
      except
        on E: System.AggregateException do begin
          var webEx := E.InnerException as System.Net.Http.HttpRequestException;
          if assigned(webEx) and not aThrowOnError then begin
            exit new HttpResponse withException(webEx);
          end
          else begin
            raise new HttpException(webEx.Message, aRequest);
          end;
        end;
      end;
    end;
    {$ELSE}
    using webRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do begin
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
  var lFlags := if aRequest.Url.Scheme.EqualsIgnoringCase('https') then rtl.WINHTTP_FLAG_SECURE else 0;
  var lPort := 80;
  if aRequest.Url.Port <> nil then
    lPort := aRequest.Url.Port
  else
    if lFlags <> 0 then
      lPort := 443;
  var lConnect := rtl.WinHttpConnect(Session, RemObjects.Elements.System.String(aRequest.Url.Host).FirstChar, lPort, 0);
  if lConnect = nil then
    raise new RTLException('Unable to connect to ' + aRequest.Url.Host);

  var lMethod := RemObjects.Elements.System.String(aRequest.Method.ToHttpString);
  var lPath := RemObjects.Elements.System.String(aRequest.Url.PathAndQueryString);
  var lRequest := rtl.WinHttpOpenRequest(lConnect, LMethod.FirstChar, lPath.FirstChar, nil, nil, nil, lFlags);
  if lRequest = nil then
    raise new RTLException('Can not open request to ' + aRequest.Url.Host);

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
  nsUrlRequest.timeoutInterval := aRequest.Timeout;

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
  if assigned(aRequest.ContentType) then
    nsUrlRequest.setValue(aRequest.ContentType) forHTTPHeaderField("Content-Type");

  {$HIDE W28}
  // we're aware it's deprecated. but async calls do have their use in console apps.
  var lDelegate := new ConnectionDelegate(aRequest);
  var lConnection := new NSURLConnection withRequest(nsUrlRequest) &delegate(lDelegate);
  lConnection.start;
  while not lDelegate.Done do
    NSRunLoop.currentRunLoop.runMode(NSDefaultRunLoopMode) beforeDate(NSDate.distantFuture);
  var data := lDelegate.ResponseData;
  var nsUrlResponse := lDelegate.Response;
  var error := lDelegate.Error;
  _ := lConnection;
  //NSURLConnection.sendSynchronousRequest(nsUrlRequest) returningResponse(var nsUrlResponse) error(var error);
  {$SHOW W28}

  var nsHttpUrlResponse := NSHTTPURLResponse(nsUrlResponse);
  if assigned(data) and assigned(nsHttpUrlResponse) then begin
    if defined("TOFFEE") then
      result := new HttpResponse(data, nsHttpUrlResponse)
    else
      result := new HttpResponse(data, nsHttpUrlResponse);
    if nsHttpUrlResponse.statusCode >= 300 then begin
      if aThrowOnError then
        raise new HttpException(String.Format("Unable to complete request. Error code: {0}", nsHttpUrlResponse.statusCode), aRequest, result)
    end;
  end
  else if assigned(error) then begin
    if not aThrowOnError then exit nil;
    if assigned(nsHttpUrlResponse) then
      raise new HttpException(error.description, aRequest, new HttpResponse(nil, nsHttpUrlResponse))
    else
      raise new RTLException withError(error);
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
      contentCallback(new HttpResponseContent<String>(Exception := response.Exception));
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
      contentCallback(new HttpResponseContent<ImmutableBinary>(Exception := response.Exception));
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
    end else begin
      contentCallback(new HttpResponseContent<XmlDocument>(Exception := response.Exception));
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
    end else begin
      contentCallback(new HttpResponseContent<JsonDocument>(Exception := response.Exception));
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
      contentCallback(new HttpResponseContent<File>(Exception := response.Exception));
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
    exit new HttpResponse<ImmutableBinary> withException(Exception(new SugarIOException("Unable to complete request. Error code: {0}", NSHTTPURLResponse(lResponse).statusCode)));

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