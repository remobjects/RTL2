namespace RemObjects.Elements.RTL;

type
  {$IF DARWIN}
  ConnectionDelegate = class(INSURLConnectionDelegate)
  public

    constructor(aRequest: HttpRequest);
    begin
      Request := aRequest;
    end;

    property Done: Boolean read private write;
    property Request: HttpRequest read private write;
    property Error: NSError read private write;
    property Response: NSURLResponse read private write;
    property ResponseData: NSMutableData read private write;

    method connection(connection: NSURLConnection) didFailWithError(aError: NSError);
    begin
      error := aError;
      Done := true;
    end;

    method connectionDidFinishLoading(connection: NSURLConnection);
    begin
      Done := true;
    end;

    method connection(connection: NSURLConnection) didReceiveResponse(aResponse: NSURLResponse);
    begin
      Response := aResponse;
      var lResponseLength := NSInteger(aResponse.expectedContentLength);
      if lResponseLength = -1 then begin
        lResponseLength := 0;
      end;
      responseData := new NSMutableData withCapacity(lResponseLength);
    end;

    method connection(connection: NSURLConnection) didReceiveData(data: NSData);
    begin
      responseData.appendData(data);
    end;

    method connection(connection: NSURLConnection) canAuthenticateAgainstProtectionSpace(protectionSpace: NSURLProtectionSpace): Boolean;
    begin
      result := protectionSpace.authenticationMethod = NSURLAuthenticationMethodServerTrust;
    end;

    method connection(connection: NSURLConnection) didReceiveAuthenticationChallenge(challenge: NSURLAuthenticationChallenge);
    begin
      if (challenge.protectionSpace.authenticationMethod = NSURLAuthenticationMethodServerTrust) and (Request.Url.host = challenge.protectionSpace.host) then begin
        var trustResult: SecTrustResultType := 0;
        var err := SecTrustEvaluate(challenge.protectionSpace.serverTrust, var trustResult);
        var alreadyTrusted := (err = noErr) and (trustResult in [SecTrustResultType.kSecTrustResultProceed, SecTrustResultType.kSecTrustResultUnspecified]);
        if alreadyTrusted then begin
          challenge.sender().performDefaultHandlingForAuthenticationChallenge(challenge);
          exit;
        end
        else if assigned(Request.VerifyUntrustedCertificate) and Request.VerifyUntrustedCertificate(HttpCertificateInfo.certificateInfoWithURLAuthenticationChallenge(challenge)) then begin
          challenge.sender.useCredential(NSURLCredential.credentialForTrust(challenge.protectionSpace.serverTrust)) forAuthenticationChallenge(challenge);
          exit;
        end;
      end;
      challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge);
    end;

  end;
  {$ENDIF}

end.