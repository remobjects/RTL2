namespace RemObjects.Elements.RTL;

{$IF DARWIN}
uses Foundation;

type
  HttpResponse = public partial class(INSURLSessionDelegate, INSURLSessionDataDelegate, INSURLSessionTaskDelegate)
  assembly

    constructor(aRequest: HttpRequest; aGotResponseCallback: block(aResponse: NSHTTPURLResponse));
    begin
      Headers := new;
      Request := aRequest;
      fGotResponseCallback := aGotResponseCallback;
    end;

    method SetTask(aTask: NSURLSessionDataTask; aSession: NSURLSession);
    begin
      locking self do begin
        fTask := aTask;
        fSession := aSession;
      end;
    end;

  private

    property Request: HttpRequest read private write;
    var fTask: NSURLSessionDataTask;
    var fSession: NSURLSession;
    var fGotResponseCallback: block(aResponse: NSHTTPURLResponse); private;

    var fIncomingData: Binary;
    var fBytesReceived: Int64;
    var fBytesExpectedToReceive: nullable Int64;

    var fIncomingDataCallback: block(aData: not nullable ImmutableBinary): HttpStreamCallbackResult;
    var fIncomingDataCompleteCallback: block(aException: nullable Exception);
    var fIncomingDataComplete := new &Event;

    method completeWithException(aException: nullable Exception);
    begin
      Exception := aException;
      fIncomingDataComplete.Set;
      if assigned(fIncomingDataCompleteCallback) then begin
        try
          fIncomingDataCompleteCallback(aException);
        except
        end;
      end;
    end;

    //constructor(aData: NSData; aResponse: NSHTTPURLResponse);
    //begin
      //Data := aData;
      //Code := aResponse.statusCode;
      //if defined("TOFFEE") then begin
        //Headers := aResponse.allHeaderFields as PlatformDictionary<String,String> as not nullable ImmutableDictionary<String,String>;
      //end
      //else begin
        //var lHeaders := new Dictionary<String,String>;
        //for each k in aResponse.allHeaderFields.allKeys do
          //lHeaders[k] := aResponse.allHeaderFields[k];
        //Headers := lHeaders;
      //end;
    //end;

    //
    // INSURLSessionDelegate
    //

    method URLSession(session: NSURLSession) didReceiveChallenge(challenge: NSURLAuthenticationChallenge) completionHandler(completionHandler: block(disposition: NSURLSessionAuthChallengeDisposition; credential: NSURLCredential));
    begin
      //Log($"didReceiveChallenge");
      if (challenge.protectionSpace.authenticationMethod = NSURLAuthenticationMethodServerTrust) and (Request.Url.host = challenge.protectionSpace.host) then begin
        var trustResult: SecTrustResultType := 0;
        var err := SecTrustEvaluate(challenge.protectionSpace.serverTrust, var trustResult);
        var alreadyTrusted := (err = noErr) and (trustResult in [SecTrustResultType.kSecTrustResultProceed, SecTrustResultType.kSecTrustResultUnspecified]);
        if alreadyTrusted then begin
          completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil);
          exit;
        end
        else if assigned(Request.VerifyUntrustedCertificate) and Request.VerifyUntrustedCertificate(HttpCertificateInfo.certificateInfoWithURLAuthenticationChallenge(challenge)) then begin
          completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential.credentialForTrust(challenge.protectionSpace.serverTrust));
          exit;
        end;
      end;
      completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil);
    end;

    //
    // INSURLSessionDataDelegate
    //

    method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didReceiveResponse(aResponse: NSURLResponse) completionHandler(completionHandler: block(disposition: NSURLSessionResponseDisposition));
    begin
      //Log($"didReceiveResponse {aResponse}");
      Code := NSHTTPURLResponse(aResponse):StatusCode;
      fIncomingData := new;
      fBytesReceived := 0;
      fBytesExpectedToReceive := nil;
      if aResponse.expectedContentLength >= 0 then
        fBytesExpectedToReceive := aResponse.expectedContentLength;
      Headers := LoadHeaders(aResponse as NSHTTPURLResponse);
      try
        if assigned(Request.DownloadProgress) then
          Request.DownloadProgress(0, fBytesExpectedToReceive);
        if assigned(fGotResponseCallback) then
          fGotResponseCallback(aResponse as NSHTTPURLResponse);
      except
        on e: Exception do
          completeWithException(e);
      end;
      completionHandler(NSURLSessionResponseDisposition.Allow);
    end;

    method URLSession(session: NSURLSession) task(task: NSURLSessionTask) didSendBodyData(bytesSent: Int64) totalBytesSent(totalBytesSent: Int64) totalBytesExpectedToSend(totalBytesExpectedToSend: Int64);
    begin
      try
        if assigned(Request.UploadProgress) then begin
          var lBytesTotal: nullable Int64 := nil;
          if totalBytesExpectedToSend >= 0 then
            lBytesTotal := totalBytesExpectedToSend;
          Request.UploadProgress(totalBytesSent, lBytesTotal);
        end;
      except
        on e: Exception do begin
          locking self do
            completeWithException(e);
        end;
      end;
    end;

    method URLSession(session: NSURLSession) task(task: NSURLSessionTask) didCompleteWithError(error: nullable NSError);
    begin
      //Log($"didCompleteWithError {error}");
      locking self do begin
        fTask := nil;
        fSession := nil;
        Data := fIncomingData;
        completeWithException(if assigned(error) then new Exception(error.description));
      end;
    end;

    method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didReceiveData(aData: NSData);
    begin
      //Log($"didReceiveData {aData:length}");
      var lCancel := false;
      locking self do begin
        try
          var lData := LoadData(aData);
          fIncomingData.Write(lData.ToArray);
          inc(fBytesReceived, aData.length);
          if assigned(Request.DownloadProgress) then
            Request.DownloadProgress(fBytesReceived, fBytesExpectedToReceive);
          if assigned(fIncomingDataCallback) then
            lCancel := fIncomingDataCallback(lData) = HttpStreamCallbackResult.StopReading;
        except
          on e: Exception do
            completeWithException(e);
        end;
      end;
      if lCancel then
        Cancel();
    end;

  end;

{$ENDIF}

end.
