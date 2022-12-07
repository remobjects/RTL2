namespace RemObjects.Elements.RTL;

type
  HttpCertificateInfo = public class
  public

    property Subject: String read unit write;
    property Issuer: String read unit write;

    property Expiration: DateTime read unit write;
    property Expired: Boolean read Expiration < DateTime.UtcNow;
    property Sha1: array of Byte read unit write;
    property Data: array of Byte read unit write;

    property Sha1String: String read Convert.ToHexString(Sha1, 0, " ");

  unit

    constructor withSubject(aSubject: String) issuer(aIssuer: String) expiration(aExpiration: DateTime) data(aData: array of Byte);
    begin
      subject := aSubject;
      issuer := aIssuer;
      expiration := aExpiration;
      data := aData;
      sha1 := CalculateSha1();
    end;

    class method certificateInfoWithSubject(aSubject: String) issuer(aIssuer: String) expiration(aExpiration: DateTime) data(data: array of Byte): HttpCertificateInfo;
    begin
      result := new HttpCertificateInfo withSubject(aSubject) issuer(aIssuer) expiration(aExpiration) data(data);
    end;

    method CalculateSha1: array of Byte;
    begin
      {$IF DARWIN}
      Sha1 := new Byte[CC_SHA1_DIGEST_LENGTH];
      CC_SHA1(@Data[0], CC_LONG(length(Data)), @Sha1[0]);
      {$ENDIF}
    end;

    {$IF DARWIN}
    class method certificateInfoWithURLAuthenticationChallenge(challenge: NSURLAuthenticationChallenge): HttpCertificateInfo;
    begin
      var trustRef := challenge.protectionSpace().serverTrust();
      var temp: SecTrustResultType;
      SecTrustEvaluate(trustRef, @temp);
      var count := SecTrustGetCertificateCount(trustRef);
      var &result: id := nil;
      var i := 0;
      while (i < count) and not assigned(result) do begin
        var certRef: SecCertificateRef := SecTrustGetCertificateAtIndex(trustRef, i);
        var subject: CoreFoundation.CFDataRef := SecCertificateCopySubjectSummary(certRef);
        var certData: CoreFoundation.CFDataRef := SecCertificateCopyData(certRef);
        var data := bridge<NSData>(certData);
        var bytes := new Byte[data.length];
        data.getBytes(@bytes[0]) length(data.length);
        &result := self.certificateInfoWithSubject(String(subject)) issuer(nil) expiration(nil) data(bytes);
        CoreFoundation.CFRelease(subject);
        CoreFoundation.CFRelease(certData);
        inc(i);
      end;
      exit &result;
    end;
    {$ENDIF}

  end;

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

  SessionDelegate = class(INSURLSessionDelegate)
  public

    constructor(aRequest: HttpRequest);
    begin
      Request := aRequest;
    end;

    property Request: HttpRequest read private write;

    method URLSession(session: NSURLSession) didReceiveChallenge(challenge: NSURLAuthenticationChallenge) completionHandler(completionHandler: block(disposition: NSURLSessionAuthChallengeDisposition; credential: NSURLCredential));
    begin
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

  end;
  {$ENDIF}

end.