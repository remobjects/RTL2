namespace RemObjects.Elements.RTL;

{$IF COCOA}
type
  HttpResponse = public partial class(INSURLSessionDelegate, INSURLSessionDataDelegate, INSURLSessionTaskDelegate)
  assembly

    constructor(aRequest: HttpRequest; aGotResponseCallback: block(aResponse: NSHTTPURLResponse));
    begin
      Headers := new;
      Request := aRequest;
      fGotResponseCallback := aGotResponseCallback;
    end;

  private

    property Request: HttpRequest read private write;
    var fGotResponseCallback: block(aResponse: NSHTTPURLResponse); private;

    var fIncomingData: Binary;

    var fIncomingDataCallback: block(aData: not nullable Binary);
    var fIncomingDataCompleteCallback: block(aException: nullable Exception);
    var fIncomingDataComplete := new &Event;

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
      Log($"didReceiveChallenge");
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

    method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didReceiveResponse(response: NSURLResponse) completionHandler(completionHandler: block(disposition: NSURLSessionResponseDisposition));
    begin
      //Log($"didReceiveResponse {response}");
      fIncomingData := new;
      Headers := (response as NSHTTPURLResponse).allHeaderFields as PlatformDictionary<String,String> as not nullable ImmutableDictionary<String,String>;
      if assigned(fGotResponseCallback) then
        fGotResponseCallback(response as NSHTTPURLResponse);
      completionHandler(NSURLSessionResponseDisposition.Allow);
    end;

    method URLSession(session: NSURLSession) task(task: NSURLSessionTask) didCompleteWithError(error: nullable NSError);
    begin
      //Log($"didCompleteWithError {error}");
      locking self do begin
        Data := fIncomingData;
        Exception := if assigned(error) then new Exception(error.description);
        fIncomingDataComplete.Set;
        if assigned(fIncomingDataCompleteCallback) then
          fIncomingDataCompleteCallback(Exception);
      end;
    end;

    method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didReceiveData(aData: NSData);
    begin
      // Handle incoming data incrementally here.
      // Convert NSData to a suitable string format if needed, or process raw bytes.
      locking self do begin
        fIncomingData.Write(aData);
        if assigned(fIncomingDataCallback) then
          fIncomingDataCallback(aData);
        //Log($"length(fIncomingData) {fIncomingData.Length}");
      end;
      //var receivedString := new NSString withData(aData) encoding(NSStringEncoding.UTF8StringEncoding);
      //Log('Received data: ' + receivedString);
    end;

    //[Optional] method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) willCacheResponse(proposedResponse: NSCachedURLResponse) completionHandler(completionHandler: block(cachedResponse: NSCachedURLResponse));
    //[Optional] method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didBecomeStreamTask(streamTask: NSURLSessionStreamTask);
    //[Optional] method URLSession(session: NSURLSession) dataTask(dataTask: NSURLSessionDataTask) didBecomeDownloadTask(downloadTask: NSURLSessionDownloadTask);

    //method URLSession(session: NSURLSession) task(task: NSURLSessionTask) didCompleteWithError(error: NSError);
    //begin
      //if error <> nil then
        //Log('Task completed with error: ' + error.localizedDescription)
      //else
        //Log('Task completed successfully.');
    //end;

  end;

{$ENDIF}

end.