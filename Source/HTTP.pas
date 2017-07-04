namespace RemObjects.Elements.RTL;

{$IF NOT (ISLAND AND LINUX)}

interface

{$DEFINE XML}{$DEFINE JSON}

{ Handy test URLs: http://httpbin.org, http://requestb.in }

type
  HttpRequest = public class
  public
    property Mode: HttpRequestMode := HttpRequestMode.Get;
    property Headers: not nullable Dictionary<String,String> := new Dictionary<String,String>; readonly;
    property Content: nullable HttpRequestContent;
    property Url: not nullable Url;
    property FollowRedirects: Boolean := true;
    property AllowCellularAccess: Boolean := true;

    constructor(aUrl: not nullable Url); // log
    constructor(aUrl: not nullable Url; aMode: HttpRequestMode); // log  := HttpRequestMode.Ge
    operator Implicit(aUrl: not nullable Url): HttpRequest;

    [ToString]
    method ToString: String;
  end;

  HttpRequestMode = public enum (Get, Post, Head, Put, Delete, Patch, Options, Trace);

  IHttpRequestContent = assembly interface
    method GetContentAsBinary(): ImmutableBinary;
    method GetContentAsArray(): array of Byte;
  end;

  HttpRequestContent = public class
  public
    operator Implicit(aBinary: not nullable ImmutableBinary): HttpRequestContent;
    operator Implicit(aString: not nullable String): HttpRequestContent;
  end;

  HttpBinaryRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  unit
    property Binary: ImmutableBinary unit read private write;
    property &Array: array of Byte unit read private write;
    method GetContentAsBinary: ImmutableBinary;
    method GetContentAsArray(): array of Byte;
  public
    constructor(aBinary: not nullable ImmutableBinary);
    constructor(aArray: not nullable array of Byte);
    constructor(aString: not nullable String; aEncoding: Encoding);
  end;

  HttpResponse = public class
  unit
    constructor withException(anException: Exception);

    {$IF COOPER}
    var Connection: java.net.HttpURLConnection;
    constructor(aConnection: java.net.HttpURLConnection);
    {$ELSEIF ECHOES}
    var Response: HttpWebResponse;
    constructor(aResponse: HttpWebResponse);
    {$ELSEIF ISLAND AND WINDOWS}
    var Request: rtl.HINTERNET;
    var Data: MemoryStream; readonly;
    constructor(aRequest: rtl.HINTERNET; aCode: Int16; aData: MemoryStream);
    {$ELSEIF TOFFEE}
    var Data: NSData;
    constructor(aData: NSData; aResponse: NSHTTPURLResponse);
    {$ENDIF}

  public
    property Headers: not nullable Dictionary<String,String>; readonly; //todo: list itself should be read-only
    property Code: Int32; readonly;
    property Success: Boolean read self.Exception = nil;
    property Exception: Exception public read unit write;

    method GetContentAsString(aEncoding: Encoding := nil; contentCallback: not nullable HttpContentResponseBlock<String>);
    method GetContentAsBinary(contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
    {$IF XML}method GetContentAsXml(contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);{$ENDIF}
    {$IF JSON}method GetContentAsJson(contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);{$ENDIF}
    method SaveContentAsFile(aTargetFile: File; contentCallback: not nullable HttpContentResponseBlock<File>);

    {$IF NOT NETSTANDARD}
    method GetContentAsStringSynchronous(aEncoding: Encoding := nil): not nullable String;
    method GetContentAsBinarySynchronous: not nullable ImmutableBinary;
    {$IF XML}method GetContentAsXmlSynchronous: not nullable XmlDocument;{$ENDIF}
    {$IF XML}method TryGetContentAsXmlSynchronous: nullable XmlDocument;{$ENDIF}
    {$IF JSON}method GetContentAsJsonSynchronous: not nullable JsonDocument;{$ENDIF}
    {$IF JSON}method TryGetContentAsJsonSynchronous: nullable JsonDocument;{$ENDIF}
    method SaveContentAsFileSynchronous(aTargetFile: File);
    {$ENDIF}
  end;

  HttpResponseContent<T> = public class
  public
    property Content: T public read unit write;
    property Success: Boolean read self.Exception = nil;
    property Exception: Exception public read unit write;
  end;

  HttpResponseBlock = public block (Response: HttpResponse);
  HttpContentResponseBlock<T> = public block (ResponseContent: HttpResponseContent<T>);

  Http = public static class
  private
    {$IF TOFFEE}
    property Session := NSURLSession.sessionWithConfiguration(NSURLSessionConfiguration.defaultSessionConfiguration); lazy;
    {$ENDIF}
    method StringForRequestType(aMode: HttpRequestMode): String;
    {$IF NOT NETSTANDARD}
    method ExecuteRequestSynchronous(aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
    {$ENDIF}
    {$IF ISLAND AND WINDOWS}
    property Session := rtl.WinHTTPOpen('', rtl.WINHTTP_ACCESS_TYPE_NO_PROXY, nil, nil, 0); lazy;
    {$ENDIF}
  public
    //method ExecuteRequest(aUrl: not nullable Url; ResponseCallback: not nullable HttpResponseBlock);
    method ExecuteRequest(aRequest: not nullable HttpRequest; ResponseCallback: not nullable HttpResponseBlock);
    {$IF NOT NETSTANDARD}
    method ExecuteRequestSynchronous(aRequest: not nullable HttpRequest): not nullable HttpResponse;
    method TryExecuteRequestSynchronous(aRequest: not nullable HttpRequest): nullable HttpResponse;
    {$ENDIF}

    method ExecuteRequestAsString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<String>);
    method ExecuteRequestAsBinary(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
    {$IF XML}method ExecuteRequestAsXml(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);{$ENDIF}
    {$IF JSON}method ExecuteRequestAsJson(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);{$ENDIF}
    method ExecuteRequestAndSaveAsFile(aRequest: not nullable HttpRequest; aTargetFile: not nullable File; contentCallback: not nullable HttpContentResponseBlock<File>);

    {$IF NOT ECHOES OR (NOT NETSTANDARD AND NOT NETFX_CORE)}
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

{ HttpRequest }

constructor HttpRequest(aUrl: not nullable Url);
begin
  Url := aUrl;
  Mode := HttpRequestMode.Get;
end;

constructor HttpRequest(aUrl: not nullable Url; aMode: HttpRequestMode);
begin
  Url := aUrl;
  Mode := aMode;
end;

operator HttpRequest.Implicit(aUrl: not nullable Url): HttpRequest;
begin
  result := new HttpRequest(aUrl, HttpRequestMode.Get);
end;

method HttpRequest.ToString: String;
begin
  result := Url.ToString();
end;

{ HttpRequestContent }

operator HttpRequestContent.Implicit(aBinary: not nullable ImmutableBinary): HttpRequestContent;
begin
  result := new HttpBinaryRequestContent(aBinary);
end;

operator HttpRequestContent.Implicit(aString: not nullable String): HttpRequestContent;
begin
  result := new HttpBinaryRequestContent(aString, Encoding.UTF8);
end;

{ HttpBinaryRequestContent }

constructor HttpBinaryRequestContent(aBinary: not nullable ImmutableBinary);
begin
  Binary := aBinary;
end;

constructor HttpBinaryRequestContent(aArray: not nullable array of Byte);
begin
  &Array := aArray;
end;

constructor HttpBinaryRequestContent(aString: not nullable String; aEncoding: Encoding);
begin
  if aEncoding = nil then aEncoding := Encoding.Default;
  &Array := aString.ToByteArray(aEncoding);
end;

method HttpBinaryRequestContent.GetContentAsBinary(): ImmutableBinary;
begin
  if assigned(Binary) then begin
    result := Binary;
  end
  else if assigned(&Array) then begin
    Binary := new ImmutableBinary(&Array);
    result := Binary;
  end;
end;

method HttpBinaryRequestContent.GetContentAsArray: array of Byte;
begin
  if assigned(&Array) then
    result := &Array
  else if assigned(Binary) then
    result := Binary.ToArray();
end;

{ HttpResponse }

constructor HttpResponse withException(anException: Exception);
begin
  self.Exception := anException;
  Headers := new Dictionary<String,String>();
end;

{$IF COOPER}
constructor HttpResponse(aConnection: java.net.HttpURLConnection);
begin
  Connection := aConnection;
  Code := Connection.getResponseCode;
  Headers := new Dictionary<String,String>();
  var i := 0;
  loop begin
    var lKey := Connection.getHeaderFieldKey(i);
    if not assigned(lKey) then break;
    var lValue := Connection.getHeaderField(i);
    Headers[lKey] := lValue;
    inc(i);
  end;
end;
{$ELSEIF ECHOES}
constructor HttpResponse(aResponse: HttpWebResponse);
begin
  Response := aResponse;
  Code := Int32(aResponse.StatusCode);
  Headers := new Dictionary<String,String>();
  {$IF NETSTANDARD}
  for each k: String in aResponse.Headers:AllKeys do
    Headers[k.ToString] := aResponse.Headers[k];
  {$ELSE}
  for each k: String in aResponse.Headers:Keys do
    Headers[k.ToString] := aResponse.Headers[k];
  {$ENDIF}
end;
{$ELSEIF ISLAND AND WINDOWS}
constructor HttpResponse(aRequest: rtl.HINTERNET; aCode: Int16; aData: MemoryStream);
begin
  Request := aRequest;
  Code := aCode;
  Data := aData;
  Headers := new Dictionary<String, String>();
  var lSize: rtl.DWORD := 0;
  rtl.WinHttpQueryHeaders(Request, rtl.WINHTTP_QUERY_RAW_HEADERS_CRLF, nil {rtl.WINHTTP_HEADER_NAME_BY_INDEX}, nil, @lSize, nil {rtl.WINHTTP_NO_HEADER_INDEX});
  if lSize > 0 then begin
    var lChars := new Char[lSize / sizeOf(Char)];
    if rtl. WinHttpQueryHeaders(Request, rtl.WINHTTP_QUERY_RAW_HEADERS_CRLF, nil {WINHTTP_HEADER_NAME_BY_INDEX}, @lChars[0], @lSize, nil {WINHTTP_NO_HEADER_INDEX}) then begin
      var lHeaders := new String(lChars);
      var lArray := lHeaders.Split(Environment.LineBreak);
      for each k: String in lArray do begin
        var lPos := k.IndexOf(':');
        if lPos > 0 then begin
          var lKey := k.Substring(0, lPos - 1).Trim;
          var lValue := k.Substring(lPos + 1).Trim;
          Headers.Add(lKey, lValue);
        end;
      end;
    end;
  end;
end;
{$ELSEIF TOFFEE}
constructor HttpResponse(aData: NSData; aResponse: NSHTTPURLResponse);
begin
  Data := aData;
  Code := aResponse.statusCode;
  Headers := aResponse.allHeaderFields as not nullable Dictionary<String,String>; // why is this cast needed?
end;
{$ENDIF}

method HttpResponse.GetContentAsString(aEncoding: Encoding := nil; contentCallback: not nullable HttpContentResponseBlock<String>);
begin
  if aEncoding = nil then aEncoding := Encoding.Default;
  {$IF COOPER}
  GetContentAsBinary( (content) -> begin
    if content.Success then
      contentCallback(new HttpResponseContent<String>(Content := new String(content.Content.ToArray, aEncoding)))
    else
      contentCallback(new HttpResponseContent<String>(Exception := content.Exception))
  end);
  {$ELSEIF ECHOES}
  async begin
    var responseString := new System.IO.StreamReader(Response.GetResponseStream(), aEncoding).ReadToEnd();
    contentCallback(new HttpResponseContent<String>(Content := responseString))
  end;
  {$ELSEIF ISLAND AND WINDOWS}
  Task.Run(() -> begin
    var lResponseString := aEncoding.GetString(Data.ToArray);
    contentCallback(new HttpResponseContent<String>(Content := lResponseString));
  end);
  {$ELSEIF TOFFEE}
  var s := new Foundation.NSString withData(Data) encoding(aEncoding.AsNSStringEncoding); // todo: test this
  if assigned(s) then
    contentCallback(new HttpResponseContent<String>(Content := s))
  else
    contentCallback(new HttpResponseContent<String>(Exception := new RTLException("Invalid Encoding")));
  {$ENDIF}
end;

method HttpResponse.GetContentAsBinary(contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
begin
  // maybe delegsate to GetContentAsBinarySynchronous?
  {$IF COOPER}
  async begin
    var allData := new Binary;
    var stream := if connection.getResponseCode > 400 then Connection.ErrorStream else Connection.InputStream;
    var data := new Byte[4096];
    var len := stream.read(data);
    while len > 0 do begin
      allData.Write(data, len);
      len := stream.read(data);
    end;
    contentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
  end;
  {$ELSEIF ECHOES}
  async begin
    var allData := new System.IO.MemoryStream();
    Response.GetResponseStream().CopyTo(allData);
    contentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
  end;
  {$ELSEIF ISLAND AND WINDOWS}
  Task.Run(() -> begin
    var allData := new Binary(Data.ToArray);
    contentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
  end);
  {$ELSEIF TOFFEE}
  contentCallback(new HttpResponseContent<ImmutableBinary>(Content := Data.mutableCopy));
  {$ENDIF}
end;

{$IF XML}
method HttpResponse.GetContentAsXml(contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);
begin
  GetContentAsBinary((content) -> begin
    if content.Success then begin
      try
        var document := XmlDocument.FromBinary(content.Content);
        if assigned(document) then
          contentCallback(new HttpResponseContent<XmlDocument>(Content := document))
        else
        contentCallback(new HttpResponseContent<XmlDocument>(Exception := new RTLException("Could not parse result as XML.")));
      except
        on E: Exception do
          contentCallback(new HttpResponseContent<XmlDocument>(Exception := E));
      end;
    end else begin
      contentCallback(new HttpResponseContent<XmlDocument>(Exception := content.Exception));
    end;
  end);
end;
{$ENDIF}

{$IF JSON}
method HttpResponse.GetContentAsJson(contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);
begin
  GetContentAsBinary((content) -> begin
    if content.Success then begin
      try
        var document := JsonDocument.FromBinary(content.Content);
        contentCallback(new HttpResponseContent<JsonDocument>(Content := document));
      except
        on E: Exception do
          contentCallback(new HttpResponseContent<JsonDocument>(Exception := E));
      end;
    end else begin
      contentCallback(new HttpResponseContent<JsonDocument>(Exception := content.Exception));
    end;
  end);
end;
{$ENDIF}

method HttpResponse.SaveContentAsFile(aTargetFile: File; contentCallback: not nullable HttpContentResponseBlock<File>);
begin
  {$IF COOPER}
  async begin
    var allData := new java.io.FileOutputStream(aTargetFile);
    var stream := Connection.InputStream;
    var data := new Byte[4096];
    var len := stream.read(data);
    while len > 0 do begin
      allData.write(data, 0, len);
      len := stream.read(data);
    end;
    contentCallback(new HttpResponseContent<File>(Content := aTargetFile));
  end;
  {$ELSEIF ECHOES}
  {$IF NETSTANDARD}
  try
    using responseStream := Response.GetResponseStream() do begin
      var storageFile := Windows.Storage.ApplicationData.Current.LocalFolder.CreateFileAsync(aTargetFile.Name, Windows.Storage.CreationCollisionOption.ReplaceExisting).Await();

      using fileStream := await System.IO.WindowsRuntimeStorageExtensions.OpenStreamForWriteAsync(storageFile) do begin
        await responseStream.CopyToAsync(fileStream);
      end;
    end;
    contentCallback(new HttpResponseContent<File>(Content := aTargetFile));
  except
    on E: Exception do
      contentCallback(new HttpResponseContent<File>(Exception := E));
  end;
  {$ELSE}
  async begin
    try
      using responseStream := Response.GetResponseStream() do
        using fileStream := System.IO.File.OpenWrite(aTargetFile) do
          responseStream.CopyTo(fileStream);
      contentCallback(new HttpResponseContent<File>(Content := aTargetFile));
    except
      on E: Exception do
        contentCallback(new HttpResponseContent<File>(Exception := E));
    end;
  end;
  {$ENDIF}
  {$ELSEIF ISLAND AND WINDOWS}
  Task.Run(() -> begin
    try
      var lStream := new FileStream(aTargetFile, FileOpenMode.Create or FileOpenMode.ReadWrite);
      Data.CopyTo(lStream);
      Data.Flush;
      contentCallback(new HttpResponseContent<File>(Content := aTargetFile))
    except
      on E: Exception do
        contentCallback(new HttpResponseContent<File>(Exception := E));
    end;
  end);
  {$ELSEIF TOFFEE}
  async begin
    var error: NSError;
    if Data.writeToFile(aTargetFile) options(NSDataWritingOptions.NSDataWritingAtomic) error(var error) then
      contentCallback(new HttpResponseContent<File>(Content := aTargetFile))
    else
      contentCallback(new HttpResponseContent<File>(Exception := new RTLException withError(error)));
  end;
  {$ENDIF}
end;

{$IF NOT NETSTANDARD}
method HttpResponse.GetContentAsStringSynchronous(aEncoding: Encoding := nil): not nullable String;
begin
  if aEncoding = nil then aEncoding := Encoding.Default;
  {$IF COOPER}
  result := new String(GetContentAsBinarySynchronous().ToArray, aEncoding);
  {$ELSEIF ECHOES}
  result := new System.IO.StreamReader(Response.GetResponseStream(), aEncoding).ReadToEnd() as not nullable;
  {$ELSEIF ISLAND AND WINDOWS}
  result := aEncoding.GetString(Data.ToArray) as not nullable;
  {$ELSEIF TOFFEE}
  var s := new Foundation.NSString withData(Data) encoding(aEncoding.AsNSStringEncoding); // todo: test this
  if assigned(s) then
    exit s as not nullable
  else
    raise new RTLException("Invalid Encoding");
  {$ENDIF}
end;

method HttpResponse.GetContentAsBinarySynchronous: not nullable ImmutableBinary;
begin
  {$IF COOPER}
  var allData := new Binary;
  var stream := Connection.InputStream;
  var data := new Byte[4096];
  var len := stream.read(data);
  while len > 0 do begin
    allData.Write(data, len);
    len := stream.read(data);
  end;
  result := allData as not nullable;
  {$ELSEIF ECHOES}
  var allData := new System.IO.MemoryStream();
  Response.GetResponseStream().CopyTo(allData);
  result := allData as not nullable;
  {$ELSEIF ISLAND AND WINDOWS}
  result := new Binary(Data.ToArray);
  {$ELSEIF TOFFEE}
  result := Data.mutableCopy as not nullable;
  {$ENDIF}
end;

{$IF XML}
method HttpResponse.GetContentAsXmlSynchronous: not nullable XmlDocument;
begin
  result := XmlDocument.FromBinary(GetContentAsBinarySynchronous()) as not nullable;
  if not assigned(result) then
    raise new RTLException("Could not parse result as XML.");
end;

method HttpResponse.TryGetContentAsXmlSynchronous: nullable XmlDocument;
begin
  var lBinary := GetContentAsBinarySynchronous(); // try?
  if assigned(lBinary) then begin
    //var lError: XmlErrorInfo;
    //result := XmlDocument.TryFromBinary(lBinary, out lError) as not nullable;
    result := XmlDocument.TryFromBinary(lBinary, true) as not nullable;
  end;
end;
{$ENDIF}

{$IF JSON}
method HttpResponse.GetContentAsJsonSynchronous: not nullable JsonDocument;
begin
  result := JsonDocument.FromBinary(GetContentAsBinarySynchronous());
end;

method HttpResponse.TryGetContentAsJsonSynchronous: nullable JsonDocument;
begin
  var lBinary := GetContentAsBinarySynchronous(); // try?
  if assigned(lBinary) then
    result := JsonDocument.TryFromBinary(lBinary);
end;
{$ENDIF}

method HttpResponse.SaveContentAsFileSynchronous(aTargetFile: File);
begin
  File.WriteBinary(aTargetFile, GetContentAsBinarySynchronous());
  {$HINT implement mor eefficiently}
end;
{$ENDIF}

{ Http }

method Http.StringForRequestType(aMode: HttpRequestMode): String;
begin
  case aMode of
    HttpRequestMode.Get: result := 'GET';
    HttpRequestMode.Post: result := 'POST';
    HttpRequestMode.Head: result := 'HEAD';
    HttpRequestMode.Put: result := 'PUT';
    HttpRequestMode.Delete: result := 'DELETE';
    HttpRequestMode.Patch: result := 'PATCH';
    HttpRequestMode.Options: result := 'OPTIONS';
    HttpRequestMode.Trace: result := 'TRACE';
  end;
end;

method Http.ExecuteRequest(aRequest: not nullable HttpRequest; ResponseCallback: not nullable HttpResponseBlock);
begin
  {$IF COOPER}
  async try
    var lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection;

    lConnection.RequestMethod := StringForRequestType(aRequest.Mode);
    for each k in aRequest.Headers.Keys do
      lConnection.setRequestProperty(k, aRequest.Headers[k]);

    if assigned(aRequest.Content) then begin
      lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
      lConnection.getOutputStream().flush();
    end;

    try
      var lResponse := if lConnection.ResponseCode >= 300 then new HttpResponse withException(new IOException("Unable to complete request. Error code: {0}", lConnection.responseCode)) else new HttpResponse(lConnection);
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
  using webRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do try
    {$IF NOT NETFX_CORE}
    webRequest.AllowAutoRedirect := aRequest.FollowRedirects;
    {$ENDIF}
    webRequest.Method := StringForRequestType(aRequest.Mode);

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
        var response := if webResponse.StatusCode >= 300 then new HttpResponse withException(new IOException("Unable to complete request. Error code: {0}", webResponse.StatusCode)) else new HttpResponse(webResponse);
        ResponseCallback(response);
      except
        on E: Exception do
          ResponseCallback(new HttpResponse withException(E));
      end;

    end, nil);
  except
    on E: Exception do
      ResponseCallback(new HttpResponse withException(E));
  end;
  {$ELSEIF ISLAND AND WINDOWS}
  Task.Run(() -> begin
    try
      var lResponse := ExecuteRequestSynchronous(aRequest, true);
      ResponseCallback(lResponse);
    except
      on E: Exception do
        ResponseCallback(new HttpResponse withException(E));
    end;
  end);
  {$ELSEIF TOFFEE}
  try
    var nsUrlRequest := new NSMutableURLRequest withURL(aRequest.Url) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);

    //nsUrlRequest.AllowAutoRedirect := aRequest.FollowRedirects;
    nsUrlRequest.allowsCellularAccess := aRequest.AllowCellularAccess;
    nsUrlRequest.HTTPMethod := StringForRequestType(aRequest.Mode);

    if assigned(aRequest.Content) then
      nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary();

    for each k in aRequest.Headers.Keys do
      nsUrlRequest.setValue(aRequest.Headers[k]) forHTTPHeaderField(k);

    var lRequest := Session.dataTaskWithRequest(nsUrlRequest) completionHandler((data, nsUrlResponse, error) -> begin

      var nsHttpUrlResponse := NSHTTPURLResponse(nsUrlResponse);
      if assigned(data) and assigned(nsHttpUrlResponse) and not assigned(error) then begin
        var response := if nsHttpUrlResponse.statusCode >= 300 then new HttpResponse withException(new IOException("Unable to complete request. Error code: {0}", nsHttpUrlResponse.statusCode)) else new HttpResponse(data, nsHttpUrlResponse);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end else if assigned(error) then begin
        var response := new HttpResponse(new RTLException withError(error));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end else begin
        var response := new HttpResponse(new RTLException("Request failed without providing an error."));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> responseCallback(response));
      end;

    end);
    lRequest.resume();
  except
    on E: Exception do
      ResponseCallback(new HttpResponse withException(E));
  end;
  {$ENDIF}
end;

{$IF NOT NETSTANDARD}
method Http.ExecuteRequestSynchronous(aRequest: not nullable HttpRequest): not nullable HttpResponse;
begin
  result := ExecuteRequestSynchronous(aRequest, true) as not nullable;
end;

method Http.TryExecuteRequestSynchronous(aRequest: not nullable HttpRequest): nullable HttpResponse;
begin
  result := ExecuteRequestSynchronous(aRequest, false);
end;

method Http.ExecuteRequestSynchronous(aRequest: not nullable HttpRequest; aThrowOnError: Boolean): nullable HttpResponse;
begin
  {$IF COOPER}
  var lConnection := java.net.URL(aRequest.Url).openConnection as java.net.HttpURLConnection;

  lConnection.RequestMethod := StringForRequestType(aRequest.Mode);
  for each k in aRequest.Headers.Keys do
    lConnection.setRequestProperty(k, aRequest.Headers[k]);

  if assigned(aRequest.Content) then begin
    lConnection.getOutputStream().write((aRequest.Content as IHttpRequestContent).GetContentAsArray());
    lConnection.getOutputStream().flush();
  end;

  result := new HttpResponse(lConnection);
  if lConnection.ResponseCode >= 300 then begin
    if not aThrowOnError then exit nil;
    raise new HttpException(String.Format("Unable to complete request. Error code: {0}", lConnection.responseCode), result)
  end;

  {$ELSEIF ECHOES}
  using webRequest := System.Net.WebRequest.Create(aRequest.Url) as HttpWebRequest do begin
    {$IF NOT NETFX_CORE}
    webRequest.AllowAutoRedirect := aRequest.FollowRedirects;
    {$ENDIF}
    webRequest.Method := StringForRequestType(aRequest.Mode);

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
      var webResponse := webRequest.GetResponse() as HttpWebResponse;
      result := new HttpResponse(webResponse);
      if webResponse.StatusCode >= 300 then begin
        if not aThrowOnError then exit nil;
        raise new HttpException(String.Format("Unable to complete request. Error code: {0}", webResponse.StatusCode), result)
      end;
    except
      on E: System.Net.WebException do begin
        if not aThrowOnError then exit nil;
        if E.Response is HttpWebResponse then
          raise new HttpException(E.Message, new HttpResponse(E.Response as HttpWebResponse))
        else
          raise new HttpException(E.Message);
      end;
    end;

  end;
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

  var lMethod := RemObjects.Elements.System.String(StringForRequestType(aRequest.Mode));
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
  {$ELSEIF TOFFEE}
  var nsUrlRequest := new NSMutableURLRequest withURL(aRequest.Url) cachePolicy(NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData) timeoutInterval(30);

  //nsUrlRequest.AllowAutoRedirect := aRequest.FollowRedirects;
  nsUrlRequest.allowsCellularAccess := aRequest.AllowCellularAccess;
  nsUrlRequest.HTTPMethod := StringForRequestType(aRequest.Mode);

  if assigned(aRequest.Content) then
    nsUrlRequest.HTTPBody := (aRequest.Content as IHttpRequestContent).GetContentAsBinary();

  for each k in aRequest.Headers.Keys do
    nsUrlRequest.setValue(aRequest.Headers[k]) forHTTPHeaderField(k);

  var nsUrlResponse : NSURLResponse;
  var error: NSError;
  {$HIDE W28}
  // we're aware it's deprecated. but async calls do have their use in console apps.
  var data := NSURLConnection.sendSynchronousRequest(nsUrlRequest) returningResponse(var nsUrlResponse) error(var error);
  {$SHOW W28}

  var nsHttpUrlResponse := NSHTTPURLResponse(nsUrlResponse);
  if assigned(data) and assigned(nsHttpUrlResponse) and not assigned(error) then begin
    result := new HttpResponse(data, nsHttpUrlResponse);
    if nsHttpUrlResponse.statusCode >= 300 then begin
      if not aThrowOnError then exit nil;
      raise new HttpException(String.Format("Unable to complete request. Error code: {0}", nsHttpUrlResponse.statusCode), result)
    end;
  end
  else if assigned(error) then begin
    if not aThrowOnError then exit nil;
    if assigned(nsHttpUrlResponse) then
      raise new HttpException(error.description, new HttpResponse(nil, nsHttpUrlResponse))
    else
      raise new RTLException withError(error);
  end
  else begin
    if not aThrowOnError then exit nil;
    if assigned(nsHttpUrlResponse) then
      raise new HttpException(String.Format("Request failed without providing an error. Error code: {0}", nsHttpUrlResponse.statusCode), new HttpResponse(nil, nsHttpUrlResponse))
    else
      raise new RTLException("Request failed without providing an error.");
  end;
  {$ENDIF}
end;
{$ENDIF}

{method Http.ExecuteRequest(aUrl: not nullable Url; ResponseCallback: not nullable HttpResponseBlock);
begin
  ExecuteRequest(new HttpRequest(aUrl, HttpRequestMode.Get), responseCallback);
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

method Http.ExecuteRequestAsBinary(aRequest: not nullable HttpRequest; contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
begin
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.GetContentAsBinary( (content) -> begin
        contentCallback(content)
      end);
    end else begin
      contentCallback(new HttpResponseContent<ImmutableBinary>(Exception := response.Exception));
    end;
  end);
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

method Http.ExecuteRequestAndSaveAsFile(aRequest: not nullable HttpRequest; aTargetFile: not nullable File; contentCallback: not nullable HttpContentResponseBlock<File>);
begin
  Http.ExecuteRequest(aRequest, (response) -> begin
    if response.Success then begin
      response.SaveContentAsFile(aTargetFile, (content) -> begin
        contentCallback(content)
      end);
    end else begin
      contentCallback(new HttpResponseContent<File>(Exception := response.Exception));
    end;
  end);
end;

{$IF NOT ECHOES OR (NOT NETSTANDARD AND NOT NETFX_CORE)}
method Http.GetString(aEncoding: Encoding := nil; aRequest: not nullable HttpRequest): not nullable String;
begin
  result := ExecuteRequestSynchronous(aRequest).GetContentAsStringSynchronous(aEncoding);
end;

method Http.GetBinary(aRequest: not nullable HttpRequest): not nullable ImmutableBinary;
begin
  result := ExecuteRequestSynchronous(aRequest).GetContentAsBinarySynchronous;
end;

{$IF XML}
method Http.GetXml(aRequest: not nullable HttpRequest): not nullable XmlDocument;
begin
  result := ExecuteRequestSynchronous(aRequest).GetContentAsXmlSynchronous;
end;

method Http.TryGetXml(aRequest: not nullable HttpRequest): nullable XmlDocument;
begin
  var lRequest := TryExecuteRequestSynchronous(aRequest);
  if assigned(lRequest) then
    result := lRequest.TryGetContentAsXmlSynchronous;
end;
{$ENDIF}

{$IF JSON}
method Http.GetJson(aRequest: not nullable HttpRequest): not nullable JsonDocument;
begin
  result := ExecuteRequestSynchronous(aRequest).GetContentAsJsonSynchronous;
end;

method Http.TryGetJson(aRequest: not nullable HttpRequest): nullable JsonDocument;
begin
  var lRequest := TryExecuteRequestSynchronous(aRequest);
  if assigned(lRequest) then
    result := lRequest.TryGetContentAsJsonSynchronous;
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

{$ENDIF}

end.