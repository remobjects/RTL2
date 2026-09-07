namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL;

type
  HttpMultipartUploadProbe = public static class
  public

    class method Run(aEndpoint: not nullable String): Integer;
    begin
      var lBoundary := $"----ElementsRTLProbe{Guid.NewGuid.ToString(GuidFormat.Default, false).Replace("-", "")}";
      var lPayload := ##"""
        --{{lBoundary}}
        Content-Disposition: form-data; name="file"; filename="probe.txt"
        Content-Type: text/plain

        Elements RTL multipart probe
        --{{lBoundary}}--
        """:Replace(Environment.LineBreak, #13#10);
      var lRequest := new HttpRequest(Url.UrlWithString(aEndpoint), HttpRequestMethod.Post);
      lRequest.Timeout := 30 Seconds;
      lRequest.Accept := "application/json";
      lRequest.Content := new HttpBinaryRequestContent(Encoding.UTF8.GetBytes(lPayload), $"multipart/form-data; boundary={lBoundary}");
      lRequest.UploadProgress := (aBytesSent, aBytesTotal) -> begin
        writeLn($"upload-progress bytesSent={aBytesSent} bytesTotal={if assigned(aBytesTotal) then valueOrDefault(aBytesTotal).ToString else "<unknown>"}");
      end;
      lRequest.DownloadProgress := (aBytesReceived, aBytesTotal) -> begin
        if aBytesReceived = 0 then
          writeLn($"response-headers bytesExpected={if assigned(aBytesTotal) then valueOrDefault(aBytesTotal).ToString else "<unknown>"}");
      end;

      writeLn($"multipart-upload-probe endpoint={aEndpoint} payloadBytes={length(Encoding.UTF8.GetBytes(lPayload))}");
      using lResponse := Http.TryExecuteRequestSynchronous(lRequest) do begin
        if assigned(lResponse.Exception) then begin
          writeLn($"multipart-upload-probe failed error={lResponse.Exception.Message}");
          exit 1;
        end;
        writeLn($"multipart-upload-probe completed httpStatus={lResponse.Code} body={lResponse.GetContentAsStringSynchronous}");
        result := if lResponse.Success then 0 else 1;
      end;
    end;

    class method RunFileUpload(aEndpoint: not nullable String; aFileName: not nullable String): Integer;
    begin
      const lProbeLogPath = "/private/tmp/rtl2-multipart-upload-probe.log";
      var lApiKey := coalesceEmpty(Environment.EnvironmentVariable["ELEVENLABS_API_KEY"], ""):Trim;
      if (length(lApiKey) = 0) and "/private/tmp/elevenlabs-api-key".FileExists then
        lApiKey := File.ReadText("/private/tmp/elevenlabs-api-key"):Trim;
      if length(lApiKey) = 0 then begin
        writeLn("multipart-file-upload-probe failed: ELEVENLABS_API_KEY is not set");
        exit 2;
      end;

      // Match Campfire's boundary exactly; this probe isolates whether the
      // provider's peer reset is related to the multipart wire shape.
      var lBoundary := $"----CodeBotMusic{Guid.NewGuid.ToString(GuidFormat.Default, false).Replace("-", "")}";
      var lFileBytes := File.ReadBytes(aFileName);
      using lPayload := new MemoryStream do begin
        var lHeader := ##"""
          --{{lBoundary}}
          Content-Disposition: form-data; name="file"; filename="{{Path.GetFileName(aFileName)}}"
          Content-Type: audio/mpeg
          """ + Environment.LineBreak + Environment.LineBreak;
        lHeader := lHeader.Replace(Environment.LineBreak, #13#10);
        var lHeaderBytes := Encoding.UTF8.GetBytes(lHeader);
        lPayload.Write(lHeaderBytes, 0, length(lHeaderBytes));
        lPayload.Write(lFileBytes, 0, length(lFileBytes));
        var lFooterBytes := Encoding.UTF8.GetBytes((Environment.LineBreak + $"--{lBoundary}--" + Environment.LineBreak).Replace(Environment.LineBreak, #13#10));
        lPayload.Write(lFooterBytes, 0, length(lFooterBytes));
        File.WriteBytes("/private/tmp/rtl2-multipart-upload-probe.body", lPayload.ToArray);

        var lRequest := new HttpRequest(Url.UrlWithString(aEndpoint), HttpRequestMethod.Post);
        lRequest.Timeout := 30 Seconds;
        lRequest.Accept := "application/json";
        lRequest.Headers["xi-api-key"] := lApiKey;
        lRequest.Content := new HttpBinaryRequestContent(lPayload.ToArray, $"multipart/form-data; boundary={lBoundary}");
        var lStarted := DateTime.UtcNow;
        lRequest.ResponseHeadersReceived := (aStatusCode, aHeaders, aContentLength) -> begin
          var lContentType := coalesceEmpty(aHeaders["content-type"]);
          var lRequestID := coalesceEmpty(aHeaders["request-id"]);
          var lTraceID := coalesceEmpty(aHeaders["x-trace-id"]);
          File.WriteText(lProbeLogPath, $"file-upload-response-headers elapsedSeconds={Convert.ToStringInvariant((DateTime.UtcNow - lStarted).TotalSeconds, 3)} httpStatus={aStatusCode} contentType={lContentType} requestId={lRequestID} traceId={lTraceID}");
        end;
        lRequest.UploadProgress := (aBytesSent, aBytesTotal) -> begin
          writeLn($"file-upload-progress elapsedSeconds={Convert.ToStringInvariant((DateTime.UtcNow - lStarted).TotalSeconds, 3)} bytesSent={aBytesSent} bytesTotal={if assigned(aBytesTotal) then valueOrDefault(aBytesTotal).ToString else "<unknown>"}");
        end;
        lRequest.DownloadProgress := (aBytesReceived, aBytesTotal) -> begin
          if aBytesReceived = 0 then
            writeLn($"file-upload-response-headers elapsedSeconds={Convert.ToStringInvariant((DateTime.UtcNow - lStarted).TotalSeconds, 3)} bytesExpected={if assigned(aBytesTotal) then valueOrDefault(aBytesTotal).ToString else "<unknown>"}");
        end;

        var lStartMessage := $"multipart-file-upload-probe endpoint={aEndpoint} boundary={lBoundary} file={Path.GetFileName(aFileName)} fileBytes={length(lFileBytes)} payloadBytes={lPayload.Length} apiKeyChars={length(lApiKey)}";
        File.WriteText(lProbeLogPath, lStartMessage);
        writeLn(lStartMessage);
        if aEndpoint = "--dump" then begin
          result := 0;
          exit;
        end;
        using lResponse := Http.TryExecuteRequestSynchronous(lRequest) do begin
          if assigned(lResponse.Exception) then begin
            var lErrorMessage := $"multipart-file-upload-probe failed elapsedSeconds={Convert.ToStringInvariant((DateTime.UtcNow - lStarted).TotalSeconds, 3)} error={lResponse.Exception.Message}";
            File.WriteText(lProbeLogPath, lErrorMessage);
            writeLn(lErrorMessage);
            exit 1;
          end;
          var lCompletionMessage := $"multipart-file-upload-probe completed elapsedSeconds={Convert.ToStringInvariant((DateTime.UtcNow - lStarted).TotalSeconds, 3)} httpStatus={lResponse.Code} body={lResponse.GetContentAsStringSynchronous}";
          File.WriteText(lProbeLogPath, lCompletionMessage);
          writeLn(lCompletionMessage);
          result := if lResponse.Success then 0 else 1;
        end;
      end;
    end;

  end;

end.
