﻿namespace RemObjects.Elements.RTL;

interface

type
  HttpRequest = public class
  public

    [Obsolete("Use Method")]
    property Mode: HttpRequestMethod read &Method write &Method;
    property &Method: HttpRequestMethod := HttpRequestMethod.Get;
    property Headers: not nullable Dictionary<String,String> := new Dictionary<String,String>; readonly;
    property Content: nullable HttpRequestContent;
    property ContentType: nullable String read coalesce(fContentType, IHttpRequestContent(Content):ContentType) write fContentType;
    property Url: not nullable Url;
    property FollowRedirects: Boolean := true;
    property AllowCellularAccess: Boolean := true;
    property UserAgent: String;
    property Accept: String;

    property Authentication: IHttpAuthentication;

    property Timeout: Double := 10.0; // Seconds

    constructor(aUrlString: not nullable String; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
    constructor(aUrl: not nullable Url; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
    operator Implicit(aUrl: not nullable Url): HttpRequest;

    property VerifyUntrustedCertificate: HttpVerifyUntrustedCertificateBlock;

    [ToString]
    method ToString: String;

  assembly
    method ApplyAuthehtication;

  private
    var fContentType: String;
  end;

  HttpVerifyUntrustedCertificateBlock nested in httpRequest = public block(aCertificateInfo: HttpCertificateInfo): Boolean;

  HttpRequestMethod = public enum (Get, Post, Head, Put, Delete, Patch, Options, Trace);

  [Obsolete("Use HttpRequestMethod")]
  HttpRequestMode = public HttpRequestMethod;

extension method HttpRequestMethod.ToHttpString: String; public;

implementation

{ HttpRequest }

constructor HttpRequest(aUrlString: not nullable String; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
begin
  Url := Url.UrlWithString(aUrlString);
  &Method := aMethod;
end;

constructor HttpRequest(aUrl: not nullable Url; aMethod: HttpRequestMethod := HttpRequestMethod.Get);
begin
  Url := aUrl;
  &Method := aMethod;
end;

operator HttpRequest.Implicit(aUrl: not nullable Url): HttpRequest;
begin
  result := new HttpRequest(aUrl, HttpRequestMethod.Get);
end;

method HttpRequest.ToString: String;
begin
  result := Url.ToString();
end;

method HttpRequest.ApplyAuthehtication;
begin
  Authentication:ApplyToRequest(self);
end;

{ HttpRequestMethod }

extension method HttpRequestMethod.ToHttpString: String;
begin
  result := case self of
    HttpRequestMethod.Delete: "DELETE";
    HttpRequestMethod.Get: "GET";
    HttpRequestMethod.Head: "HEAD";
    HttpRequestMethod.Options: "OPTIONS";
    HttpRequestMethod.Patch: "PATCH";
    HttpRequestMethod.Post: "POST";
    HttpRequestMethod.Put: "PUT";
    HttpRequestMethod.Trace: "TRACE";
  end;
end;

end.