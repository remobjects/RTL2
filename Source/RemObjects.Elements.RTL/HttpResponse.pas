namespace RemObjects.Elements.RTL;

{$DEFINE XML}{$DEFINE JSON}

interface

type
  HttpResponse = public class({$IF ECHOES OR ISLAND}IDisposable{$ENDIF})
  public
    property Headers: not nullable ImmutableDictionary<String,String>; readonly;
    property Code: Int32; readonly;
    property Success: Boolean read (Exception = nil) and (Code < 300);
    property Exception: nullable Exception public read unit write;

    property ContentType: nullable String read Headers["Content-Type"];
    property ContentEncoding: nullable String read Headers["Content-Encoding"];

    method GetContentAsString(aEncoding: Encoding := nil; contentCallback: not nullable HttpContentResponseBlock<String>);
    method GetContentAsBinary(contentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
    {$IF XML}method GetContentAsXml(contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);{$ENDIF}
    {$IF JSON}method GetContentAsJson(contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);{$ENDIF}
    method SaveContentAsFile(aTargetFile: not nullable String; contentCallback: not nullable HttpContentResponseBlock<File>);

    method GetContentAsStringSynchronous(aEncoding: Encoding := nil): not nullable String;
    method GetContentAsBinarySynchronous: not nullable ImmutableBinary;
    method TryGetContentAsBinarySynchronous: nullable ImmutableBinary;
    {$IF XML}method GetContentAsXmlSynchronous: not nullable XmlDocument;{$ENDIF}
    {$IF XML}method TryGetContentAsXmlSynchronous: nullable XmlDocument;{$ENDIF}
    {$IF JSON}method GetContentAsJsonSynchronous: not nullable JsonDocument;{$ENDIF}
    {$IF JSON}method TryGetContentAsJsonSynchronous: nullable JsonDocument;{$ENDIF}
    method SaveContentAsFileSynchronous(aTargetFile: File);

    {$IF ECHOES OR ISLAND}
    method Dispose;
    begin
      {$IF ECHOES}
      (Response as IDisposable):Dispose;
      {$ENDIF}
    end;

    finalizer;
    begin
      Dispose();
    end;
    {$ENDIF}

  assembly

    constructor withException(aException: Exception);

    {$IF COOPER}
    var Connection: java.net.HttpURLConnection;
    constructor(aConnection: java.net.HttpURLConnection);
    {$ELSEIF DARWIN}
    var Data: NSData;
    constructor(aData: NSData; aResponse: NSHTTPURLResponse);
    {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    var Response: System.Net.Http.HttpResponseMessage;
    constructor(aResponse: System.Net.Http.HttpResponseMessage);
    begin
      Response := aResponse;
      Code := Int32(aResponse.StatusCode);
      Headers := new Dictionary<String,String>();
      //var lHeaders := new Dictionary<String,String>;
      //for each k: String in aResponse.Headers.:AllKeys do
        //lHeaders[k.ToString] := aResponse.Headers[k];
      //Headers := lHeaders;
    end;
    {$ELSE}
    var Response: HttpWebResponse;
    constructor(aResponse: HttpWebResponse);
    begin
      Response := aResponse;
      Code := Int32(aResponse.StatusCode);
      Headers := new Dictionary<String,String>();
      var lHeaders := new Dictionary<String,String>;
      for each k: String in aResponse.Headers:AllKeys do
        lHeaders[k.ToString] := aResponse.Headers[k];
      Headers := lHeaders;
    end;
    {$ENDIF}
    {$ELSEIF WEBASSEMBLY}
    var fOriginalRequest: RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest; private;
    constructor(aRequest: RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest);
    {$ELSEIF ISLAND}
    var Data: MemoryStream; readonly;
    {$IF WINDOWS}
    var Request: rtl.HINTERNET;
    constructor(aRequest: rtl.HINTERNET; aCode: Int16; aData: MemoryStream);
    {$ELSEIF LINUX}
    constructor(aCode: Integer; aData: MemoryStream; aHeaders: not nullable Dictionary<String, String>);
    {$ENDIF}
    {$ENDIF}

  end;

  HttpResponseContent<T> = public class
  public
    property Content: nullable T public read unit write;
    property Success: Boolean read self.Exception = nil;
    property Exception: nullable Exception public read unit write;
  end;

  HttpResponseBlock = public block (Response: not nullable HttpResponse);
  HttpContentResponseBlock<T> = public block (ResponseContent: not nullable HttpResponseContent<T>);

implementation

{ HttpResponse }

constructor HttpResponse withException(aException: Exception);
begin
  Exception := aException;
  Headers := new Dictionary<String,String>();
end;

{$IF COOPER}
constructor HttpResponse(aConnection: java.net.HttpURLConnection);
begin
  Connection := aConnection;
  Code := Connection.getResponseCode;
  Headers := new Dictionary<String,String>();
  var i := 0;
  var lHeaders := new Dictionary<String,String>;
  loop begin
    var lKey := Connection.getHeaderFieldKey(i);
    if not assigned(lKey) then break;
    var lValue := Connection.getHeaderField(i);
    lHeaders[lKey] := lValue;
    inc(i);
  end;
  Headers := lHeaders;
end;
{$ELSEIF DARWIN}
constructor HttpResponse(aData: NSData; aResponse: NSHTTPURLResponse);
begin
  Data := aData;
  Code := aResponse.statusCode;
  if defined("TOFFEE") then begin
    Headers := aResponse.allHeaderFields as PlatformDictionary<String,String> as not nullable ImmutableDictionary<String,String>;
  end
  else begin
    var lHeaders := new Dictionary<String,String>;
    for each k in aResponse.allHeaderFields.allKeys do
       lHeaders[k] := aResponse.allHeaderFields[k];
    Headers := lHeaders;
  end;
end;
{$ELSEIF ECHOES}
{$ELSEIF WEBASSEMBLY}
constructor HttpResponse(aRequest: RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest);
begin
  fOriginalRequest := aRequest;
  Code := aRequest.status;
  var lHeaders := new Dictionary<String,String>;
  for each h: String in fOriginalRequest.getAllResponseHeaders:Split(#10) do begin
    var lSplit := h.SplitAtFirstOccurrenceof("=");
    if lSplit.Count = 2 then
      lHeaders[lSplit[0].Trim] := lSplit[1].Trim;
  end;
  Headers := lHeaders;
end;
{$ELSEIF ISLAND}
{$IF WINDOWS}
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
      var lHeaders := new Dictionary<String,String>;
      var lArray := new String(lChars).Split(Environment.LineBreak);
      for each k: String in lArray do begin
        var lPos := k.IndexOf(':');
        if lPos > 0 then begin
          var lKey := k.Substring(0, lPos - 1).Trim;
          var lValue := k.Substring(lPos + 1).Trim;
          // Allow multiple Set-Cookie
          if (lKey = 'Set-Cookie') and Headers.ContainsKey(lKey) then
            lHeaders[lKey] := Headers[lKey]+','+lValue
          else
            lHeaders[lKey] := lValue;
        end;
      end;
      Headers := lHeaders;
    end;
  end;
end;
{$ELSEIF LINUX}
constructor HttpResponse(aCode: Integer; aData: MemoryStream; aHeaders: not nullable Dictionary<String, String>);
begin
  Data := aData;
  Code := aCode;
  Headers := aHeaders;
end;
{$ENDIF}
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
  {$ELSEIF DARWIN}
  var s := new Foundation.NSString withData(Data) encoding(aEncoding.AsNSStringEncoding); // todo: test this
  if assigned(s) then
    contentCallback(new HttpResponseContent<String>(Content := s))
  else
    contentCallback(new HttpResponseContent<String>(Exception := new RTLException("Invalid Encoding")));
  {$ELSEIF ECHOES}
  async begin
    {$IF HTTPCLIENT}
    using lStream := await response.Content.ReadAsStreamAsync() do begin
      using lReader := new System.IO.StreamReader(lStream, aEncoding) do begin
        var responseString := lReader.ReadToEnd();
        contentCallback(new HttpResponseContent<String>(Content := responseString))
      end;
    end;
    {$ELSE}
    using lStream := Response.GetResponseStream() do begin
      using lReader := new System.IO.StreamReader(lStream, aEncoding) do begin
        var responseString := lReader.ReadToEnd();
        contentCallback(new HttpResponseContent<String>(Content := responseString))
      end;
    end;
    {$ENDIF}
  end;
  {$ELSEIF WEBASSEMBLY}
  contentCallback(new HttpResponseContent<String>(Content := fOriginalRequest.responseText));
  {$ELSEIF ISLAND}
  async begin
    var lResponseString := aEncoding.GetString(Data.ToArray);
    contentCallback(new HttpResponseContent<String>(Content := lResponseString));
  end;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembkly")]{$ENDIF}
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
  {$ELSEIF DARWIN}
  contentCallback(new HttpResponseContent<ImmutableBinary>(Content := new ImmutableBinary(Data)));
  {$ELSEIF ECHOES}
  async begin
    var allData := new System.IO.MemoryStream();
    {$IF HTTPCLIENT}
    using lStream := await response.Content.ReadAsStreamAsync() do
      lStream.CopyTo(allData);
    {$ELSE}
    using lStream := Response.GetResponseStream() do
      lStream .CopyTo(allData);
    {$ENDIF}
    contentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
  end;
  {$ELSEIF WEBASSEMBLY}
  raise new NotImplementedException("Binary data is not supported on WebAssembly")
  {$ELSEIF ISLAND}
  async begin
    var allData := new Binary(Data.ToArray);
    contentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
  end;
  {$ENDIF}
end;

{$IF XML}
method HttpResponse.GetContentAsXml(contentCallback: not nullable HttpContentResponseBlock<XmlDocument>);
begin
  {$IF WEBASSEMBLY}
  try
    var document := XmlDocument.FromString(fOriginalRequest.responseText);
    contentCallback(new HttpResponseContent<XmlDocument>(Content := document))
  except
    on E: Exception do
      contentCallback(new HttpResponseContent<XmlDocument>(Exception := E));
  end;
  {$ELSE}
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
  {$ENDIF}
end;
{$ENDIF}

{$IF JSON}
method HttpResponse.GetContentAsJson(contentCallback: not nullable HttpContentResponseBlock<JsonDocument>);
begin
  {$IF WEBASSEMBLY}
  try
    var document :=  JsonDocument.FromString(fOriginalRequest.responseText);
    contentCallback(new HttpResponseContent<JsonDocument>(Content := document))
  except
    on E: Exception do
      contentCallback(new HttpResponseContent<JsonDocument>(Exception := E));
  end;
  {$ELSE}
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
  {$ENDIF}
end;
{$ENDIF}

{$IF WEBASSEMBLY}[Warning("File Access is not supported on WebAssembly")]{$ENDIF}
method HttpResponse.SaveContentAsFile(aTargetFile: not nullable String; contentCallback: not nullable HttpContentResponseBlock<File>);
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
    contentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)));
  end;
  {$ELSEIF DARWIN}
  async begin
    var error: NSError;
    if Data.writeToFile(aTargetFile as NSString) options(NSDataWritingOptions.NSDataWritingAtomic) error(var error) then
      contentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)))
    else
      contentCallback(new HttpResponseContent<File>(Exception := new RTLException withError(error)));
  end;
  {$ELSEIF ECHOES}
  async begin
    try
      {$IF HTTPCLIENT}
      using lStream := await response.Content.ReadAsStreamAsync() do
        using lFileStream := System.IO.File.OpenWrite(aTargetFile) do
          lStream.CopyTo(lFileStream);
      {$ELSE}
      using lStream := Response.GetResponseStream() do
        using lFileStream := System.IO.File.OpenWrite(aTargetFile) do
          lStream.CopyTo(lFileStream);
      {$ENDIF}
      contentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)));
    except
      on E: Exception do
        contentCallback(new HttpResponseContent<File>(Exception := E));
    end;
  end;
  {$ELSEIF WEBASSEMBLY}
  raise new NotImplementedException("File Access is not supported on WebAssembly")
  {$ELSEIF ISLAND}
  async begin
    try
      var lStream := new FileStream(aTargetFile, FileOpenMode.Create or FileOpenMode.ReadWrite);
      Data.CopyTo(lStream);
      Data.Flush;
      contentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)))
    except
      on E: Exception do
        contentCallback(new HttpResponseContent<File>(Exception := E));
    end;
  end;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
method HttpResponse.GetContentAsStringSynchronous(aEncoding: Encoding := nil): not nullable String;
begin
  if aEncoding = nil then aEncoding := Encoding.Default;
  {$IF COOPER}
  result := new String(GetContentAsBinarySynchronous().ToArray, aEncoding);
  {$ELSEIF DARWIN}
  var s := new Foundation.NSString withData(Data) encoding(aEncoding.AsNSStringEncoding); // todo: test this
  if assigned(s) then
    exit s as not nullable
  else
    raise new RTLException("Invalid Encoding");
  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    var lTask := response.Content.ReadAsStreamAsync();
    using lStream := lTask.Result do
      using lReader := new System.IO.StreamReader(lStream, aEncoding) do
        result := lReader.ReadToEnd() as not nullable;
    {$ELSE}
    using lStream := Response.GetResponseStream() do
      using lReader := new System.IO.StreamReader(lStream, aEncoding) do
        result := lReader.ReadToEnd() as not nullable;
    {$ENDIF}
  {$ELSEIF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSEIF ISLAND}
  result := aEncoding.GetString(Data.ToArray) as not nullable;
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
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
  {$ELSEIF DARWIN}
  result := Data.mutableCopy as not nullable;
  {$ELSEIF ECHOES}
  var allData := new System.IO.MemoryStream();
  {$IF HTTPCLIENT}
  var lTask := response.Content.ReadAsStreamAsync();
  using lStream := lTask.Result do
    lStream.CopyTo(allData);
  {$ELSE}
  using lStream := Response.GetResponseStream() do
    lStream.CopyTo(allData);
  {$ENDIF}
  result := allData as not nullable;
  {$ELSEIF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSEIF ISLAND}
  result := new Binary(Data.ToArray);
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
method HttpResponse.TryGetContentAsBinarySynchronous: nullable ImmutableBinary;
begin
  {$IF COOPER}
  var allData := new Binary;
  var stream := Connection:InputStream;
  if assigned(stream) then begin
    var data := new Byte[4096];
    var len := stream.read(data);
    while len > 0 do begin
      allData.Write(data, len);
      len := stream.read(data);
    end;
    result := allData as not nullable;
  end;
  {$ELSEIF DARWIN}
  result := Data:mutableCopy;
  {$ELSEIF ECHOES}
    {$IF HTTPCLIENT}
    var lTask := response.Content.ReadAsStreamAsync();
    using lStream := lTask.Result do begin
      if assigned(lStream) then begin
        var allData := new System.IO.MemoryStream();
        lStream.CopyTo(allData);
        result := allData;
      end;
    end;
    {$ELSE}
    using lStream := Response:GetResponseStream do begin
      if assigned(lStream) then begin
        var allData := new System.IO.MemoryStream();
        lStream.CopyTo(allData);
        result := allData;
      end;
    end;
  {$ENDIF}
  {$ELSEIF ISLAND AND WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSEIF ISLAND}
  if assigned(Data) then
    result := new Binary(Data.ToArray);
  {$ENDIF}
end;

{$IF XML}
{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
method HttpResponse.GetContentAsXmlSynchronous: not nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  result := XmlDocument.FromBinary(GetContentAsBinarySynchronous()) as not nullable;
  if not assigned(result) then
    raise new RTLException("Could not parse result as XML.");
  {$ENDIF}
end;

method HttpResponse.TryGetContentAsXmlSynchronous: nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  var lBinary := GetContentAsBinarySynchronous(); // try?
  if assigned(lBinary) then begin
    //var lError: XmlErrorInfo;
    //result := XmlDocument.TryFromBinary(lBinary, out lError) as not nullable;
    result := XmlDocument.TryFromBinary(lBinary, true) as not nullable;
  end;
  {$ENDIF}
end;
{$ENDIF}

{$IF JSON}
{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
method HttpResponse.GetContentAsJsonSynchronous: not nullable JsonDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  result := JsonDocument.FromBinary(GetContentAsBinarySynchronous());
  {$ENDIF}
end;

{$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembkly")]{$ENDIF}
method HttpResponse.TryGetContentAsJsonSynchronous: nullable JsonDocument;
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
  {$ELSE}
  var lBinary := TryGetContentAsBinarySynchronous(); // try?
  if assigned(lBinary) then
    result := JsonDocument.TryFromBinary(lBinary);
  {$ENDIF}
end;
{$ENDIF}

{$IF WEBASSEMBLY}[Warning("File Access is not supported on WebAssembly")]{$ENDIF}
method HttpResponse.SaveContentAsFileSynchronous(aTargetFile: File);
begin
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("File Access is not supported on WebAssembly")
  {$ELSE}
  File.WriteBinary(String(aTargetFile), GetContentAsBinarySynchronous());
  {$HINT implement more efficiently}
  {$ENDIF}
end;

end.