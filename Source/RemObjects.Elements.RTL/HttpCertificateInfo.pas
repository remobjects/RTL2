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
    class method certificateInfoWithURLAuthenticationChallenge(challenge: NSURLAuthenticationChallenge): HttpCertificateInfo; assembly;
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

end.