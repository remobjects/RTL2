namespace RemObjects.Elements.RTL;

type
  HttpResponse = public partial class({$IF ECHOES OR ISLAND}IDisposable{$ENDIF})
  public
    property Headers: not nullable ImmutableDictionary<String,String> read private write;
    property Code: Int32 read private write;
    property Success: Boolean read (Exception = nil) and (Code < 300);
    property Exception: nullable Exception public read unit write;

    property ContentType: nullable String read Headers["Content-Type"];
    property ContentEncoding: nullable String read Headers["Content-Encoding"];

    //
    // String
    //

    method GetContentAsString(aEncoding: Encoding := nil; aContentCallback: not nullable HttpContentResponseBlock<String>);
    begin
      if aEncoding = nil then
        aEncoding := Encoding.Default;

      GetContentAsBinary begin
        if aResponseContent.Success then
          aContentCallback(new HttpResponseContent<String>(Content := aEncoding.GetString(aResponseContent.Content.ToArray)))
        else
          aContentCallback(new HttpResponseContent<String>(Exception := aResponseContent.Exception))
      end;
    end;

    method GetContentAsStreamedString(aEncoding: Encoding := nil; aContentCallback: not nullable HttpStringStreamResponseBlock<String>);
    begin
      if aEncoding = nil then
        aEncoding := Encoding.Default;

      GetContentAsStreamedBinary begin
        if aData:Length > 0 then begin
          var s := aEncoding.GetString(aData);
          if assigned(s) then
            aContentCallback(s, aDone);
        end;
      end;
    end;

    method GetContentAsLines(aEncoding: Encoding := nil; aContentCallback: not nullable HttpStringStreamResponseBlock<String>);
    begin
      var lLastIncompleteLine: String;
      GetContentAsStreamedString begin
        if aData:Length > 0 then begin
          Process.ProcessStringToLines(aData) LastIncompleteLogLine(out lLastIncompleteLine) begin
            aContentCallback(aLine, false);
          end;
        end;
        if aDone then
          aContentCallback(nil, true);
      end;
    end;

    {$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
    method GetContentAsStringSynchronous(aEncoding: Encoding := nil): not nullable String;
    begin
      if aEncoding = nil then
        aEncoding := Encoding.Default;

      //{$IF COOPER}
      var lContent := GetContentAsBinarySynchronous();
      result := aEncoding.GetString(lContent.ToArray);
    end;

    //
    // Binary
    //

    {$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembly")]{$ENDIF}
    method GetContentAsBinary(aContentCallback: not nullable HttpContentResponseBlock<ImmutableBinary>);
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
        aContentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
      end;
      {$ELSEIF DARWIN}
      if assigned(Data) then begin
        aContentCallback(new HttpResponseContent<ImmutableBinary>(Content := new ImmutableBinary(Data)));
      end
      else begin
        fIncomingDataComplete.WaitFor;
        aContentCallback(new HttpResponseContent<ImmutableBinary>(Content := new ImmutableBinary(Data)));
      end;
      {$ELSEIF ECHOES}
      async begin
        var allData := new System.IO.MemoryStream();
        using lStream := {$IF HTTPCLIENT}await response.Content.ReadAsStreamAsync(){$ELSE}Response.GetResponseStream(){$ENDIF} do
          lStream.CopyTo(allData);
        aContentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
      end;
      {$ELSEIF WEBASSEMBLY}
      raise new NotImplementedException("Binary data is not supported on WebAssembly")
      {$ELSEIF ISLAND}
      async begin
        var allData := new Binary(Data.ToArray);
        aContentCallback(new HttpResponseContent<ImmutableBinary>(Content := allData));
      end;
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembly")]{$ENDIF}
    method GetContentAsStreamedBinary(aContentCallback: not nullable HttpStringStreamResponseBlock<ImmutableBinary>);
    begin
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
        aContentCallback(allData, true);
        {$HINT implement proper streaming}
      end;
      {$ELSEIF COCOA}
      if assigned(Data) then begin

        aContentCallback(Data, true);

      end
      else begin

        locking self do begin
          if fIncomingData:Length > 0 then
            aContentCallback(fIncomingData, false);
          fIncomingDataCallback := (data) -> begin
            aContentCallback(data, false);
          end;
          fIncomingDataCompleteCallback := (error) -> begin
            aContentCallback(nil, true);
          end;
        end;

      end;
      {$ELSEIF ECHOES}
      async begin
        var allData := new System.IO.MemoryStream();
        using lStream := {$IF HTTPCLIENT}await response.Content.ReadAsStreamAsync(){$ELSE}Response.GetResponseStream(){$ENDIF} do begin
          var lBytesRead: Int64;
          var lBufferSize := 8192; // You can choose an appropriate buffer size
          var lBuffer := new Byte[lBufferSize];
          repeat
            lBytesRead := lStream.Read(lBuffer, 0, lBufferSize);
            if lBytesRead > 0 then begin
              var lData := new ImmutableBinary(lBuffer, 0, lBytesRead);
              aContentCallback(lData, false);
            end;
          until lBytesRead = 0;

          aContentCallback(nil, true);
        end;
        aContentCallback(allData, true);
        {$HINT implement proper streaming}
      end;
      {$ELSEIF WEBASSEMBLY}
      raise new NotImplementedException("Binary data is not supported on WebAssembly")
      {$ELSEIF ISLAND}
      async begin
        var allData := new Binary(Data.ToArray);
        aContentCallback(allData, true);
        {$HINT implement proper streaming}
      end;
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembly")]{$ENDIF}
    method GetContentAsBinarySynchronous: not nullable ImmutableBinary;
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
        if assigned(Data) then
          exit Data as not nullable;
        fIncomingDataComplete.WaitFor;
        if assigned(Data) then
          exit Data as not nullable;
        raise new HttpException($"No data received");
      {$ELSEIF ECHOES}
        var allData := new System.IO.MemoryStream();
        if not assigned(Response) then
          raise new Exception($"No response received from server");
        {$IF HTTPCLIENT}
        var lTask := Response.Content.ReadAsStreamAsync();
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

    {$IF WEBASSEMBLY}[Warning("Binary data is not supported on WebAssembly")]{$ENDIF}
    method TryGetContentAsBinarySynchronous: nullable ImmutableBinary;
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
      if assigned(Data) then
        exit Data;
      fIncomingDataComplete.WaitFor;
      exit Data;
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

    //
    // Xml
    //

    method GetContentAsXml(aContentCallback: not nullable HttpContentResponseBlock<XmlDocument>);
    begin
      {$IF WEBASSEMBLY}
      try
        var document := XmlDocument.FromString(fOriginalRequest.responseText);
        aContentCallback(new HttpResponseContent<XmlDocument>(Content := document))
      except
        on E: Exception do
          aContentCallback(new HttpResponseContent<XmlDocument>(Exception := E));
      end;
      {$ELSE}
      GetContentAsBinary((content) -> begin
        if content.Success then begin
          try
            var document := XmlDocument.FromBinary(content.Content);
            if assigned(document) then
              aContentCallback(new HttpResponseContent<XmlDocument>(Content := document))
            else
              aContentCallback(new HttpResponseContent<XmlDocument>(Exception := new RTLException("Could not parse result as XML.")));
          except
            on E: Exception do
              aContentCallback(new HttpResponseContent<XmlDocument>(Exception := E));
          end;
        end else begin
          aContentCallback(new HttpResponseContent<XmlDocument>(Exception := content.Exception));
        end;
      end);
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
    method GetContentAsXmlSynchronous: not nullable XmlDocument;
    begin
      {$IF WEBASSEMBLY}
      raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
      {$ELSE}
      result := XmlDocument.FromBinary(GetContentAsBinarySynchronous()) as not nullable;
      if not assigned(result) then
        raise new RTLException("Could not parse result as XML.");
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
    method TryGetContentAsXmlSynchronous: nullable XmlDocument;
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

    //
    // Json
    //

    method GetContentAsJson(aContentCallback: not nullable HttpContentResponseBlock<JsonDocument>);
    begin
      {$IF WEBASSEMBLY}
      try
        var document :=  JsonDocument.FromString(fOriginalRequest.responseText);
        aContentCallback(new HttpResponseContent<JsonDocument>(Content := document))
      except
        on E: Exception do
          aContentCallback(new HttpResponseContent<JsonDocument>(Exception := E));
      end;
      {$ELSE}
      GetContentAsBinary((content) -> begin
        if content.Success then begin
          try
            var document := JsonDocument.FromBinary(content.Content);
            aContentCallback(new HttpResponseContent<JsonDocument>(Content := document));
          except
            on E: Exception do
              aContentCallback(new HttpResponseContent<JsonDocument>(Exception := E));
          end;
        end else begin
          aContentCallback(new HttpResponseContent<JsonDocument>(Exception := content.Exception));
        end;
      end);
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("Synchronous requests are not supported on WebAssembly")]{$ENDIF}
    method GetContentAsJsonSynchronous: not nullable JsonDocument;
    begin
      {$IF WEBASSEMBLY}
      raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
      {$ELSE}
      result := JsonDocument.FromBinary(GetContentAsBinarySynchronous());
      {$ENDIF}
    end;

    method TryGetContentAsJsonSynchronous: nullable JsonDocument;
    begin
      {$IF WEBASSEMBLY}
      raise new NotImplementedException("Synchronous requests are not supported on WebAssembly")
      {$ELSE}
      var lBinary := TryGetContentAsBinarySynchronous(); // try?
      if assigned(lBinary) then
        result := JsonDocument.TryFromBinary(lBinary);
      {$ENDIF}
    end;

    //
    // File
    //

    {$IF WEBASSEMBLY}[Warning("File Access is not supported on WebAssembly")]{$ENDIF}
    method SaveContentAsFile(aTargetFile: not nullable String; aContentCallback: not nullable HttpContentResponseBlock<File>);
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
        aContentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)));
      end;
      {$ELSEIF DARWIN}
      async begin
        File.WriteBinary(aTargetFile, data);
        aContentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)))
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
          aContentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)));
        except
          on E: Exception do
            aContentCallback(new HttpResponseContent<File>(Exception := E));
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
          aContentCallback(new HttpResponseContent<File>(Content := File(aTargetFile)))
        except
          on E: Exception do
            aContentCallback(new HttpResponseContent<File>(Exception := E));
        end;
      end;
      {$ENDIF}
    end;

    {$IF WEBASSEMBLY}[Warning("File Access is not supported on WebAssembly")]{$ENDIF}
    method SaveContentAsFileSynchronous(aTargetFile: File);
    begin
      {$IF WEBASSEMBLY}
      raise new NotImplementedException("File Access is not supported on WebAssembly")
      {$ELSE}
      File.WriteBinary(String(aTargetFile), GetContentAsBinarySynchronous());
      {$HINT implement more efficiently}
      {$ENDIF}
    end;

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
    begin
      Exception := aException;
      Headers := new Dictionary<String,String>();
    end;

    {$IF COOPER}
    var Connection: java.net.HttpURLConnection;
    constructor(aConnection: java.net.HttpURLConnection);
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
    var Data: ImmutableBinary;

    constructor(aData: NSData; aResponse: NSHTTPURLResponse);
    begin
      Data := LoadData(aData);
      Headers := LoadHeaders(aResponse);
    end;

    method LoadHeaders(aResponse: NSHTTPURLResponse): not nullable Dictionary<String,String>;
    begin
      Code := aResponse.statusCode;
      if defined("TOFFEE") then begin
        result := aResponse.allHeaderFields as PlatformDictionary<String,String> as not nullable Dictionary<String,String>;
      end
      else begin
        result := new;
        for each k in aResponse.allHeaderFields.allKeys do
          result[k] := aResponse.allHeaderFields[k];
      end;
    end;

    method LoadData(aData: NSData): ImmutableBinary;
    begin
      result := if defined("TOFFEE") then aData else new ImmutableBinary(aData);
    end;
    {$ELSEIF WEBASSEMBLY}
    var fOriginalRequest: RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest; private;
    constructor(aRequest: RemObjects.Elements.WebAssembly.DOM.XMLHttpRequest);
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
    var Data: MemoryStream; readonly;
      {$IF WINDOWS}
      var Request: rtl.HINTERNET;
      constructor(aRequest: rtl.HINTERNET; aCode: Int16; aData: MemoryStream);
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
      constructor(aCode: Integer; aData: MemoryStream; aHeaders: not nullable Dictionary<String, String>);
      begin
        Data := aData;
        Code := aCode;
        Headers := aHeaders;
      end;
      {$ENDIF}
    {$ENDIF ISLAND}

  end;

  HttpResponseContent<T> = public class
  public
    property Content: nullable T public read unit write;
    property Success: Boolean read self.Exception = nil;
    property Exception: nullable Exception public read unit write;
  end;

  HttpResponseBlock = public block (aResponse: not nullable HttpResponse);
  HttpContentResponseBlock<T> = public block (aResponseContent: not nullable HttpResponseContent<T>);
  HttpStringStreamResponseBlock<T> = public block (aData: nullable T; aDone: Boolean);

end.