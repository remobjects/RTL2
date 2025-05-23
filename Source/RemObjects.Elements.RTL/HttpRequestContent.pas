﻿namespace RemObjects.Elements.RTL;

type
  IHttpRequestContent = assembly interface
    method GetContentAsBinary: ImmutableBinary;
    method GetContentAsArray: array of Byte;
    property ContentType: nullable String read;
  end;

  HttpRequestContent = public abstract class
  public

    property ContentType: nullable String read protected write;

    operator Implicit(aBinary: not nullable ImmutableBinary): HttpRequestContent;
    begin
      result := new HttpBinaryRequestContent(aBinary);
    end;

    operator Implicit(aString: not nullable String): HttpRequestContent;
    begin
      result := new HttpBinaryRequestContent(aString, Encoding.UTF8);
    end;

    operator Implicit(aJson: not nullable JsonNode): HttpRequestContent;
    begin
      result := new HttpJsonRequestContent(aJson, Encoding.UTF8);
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := $"<HttpRequestContent {ContentType}>";
    end;

  end;

  HttpBinaryRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    constructor(aBinary: not nullable ImmutableBinary; aContentType: nullable String := nil);
    begin
      Binary := aBinary;
      ContentType := aContentType;
    end;

    constructor(aArray: not nullable array of Byte; aContentType: nullable String := nil);
    begin
      &Array := aArray;
      ContentType := aContentType;
    end;

    constructor(aString: not nullable String; aEncoding: nullable Encoding := nil; aContentType: nullable String := nil);
    begin
      if aEncoding = nil then aEncoding := Encoding.Default;
      &Array := aString.ToByteArray(aEncoding);
      ContentType := aContentType;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := $"<HttpBinaryRequestContent {ContentType}: {if assigned(Binary) then Convert.ToHexString(Binary.ToArray) else Convert.ToHexString(&Array)}>";
    end;

  private

    property Binary: ImmutableBinary unit read private write;
    property &Array: array of Byte unit read private write;

    method GetContentAsBinary: ImmutableBinary;
    begin
      if assigned(Binary) then begin
        result := Binary;
      end
      else if assigned(&Array) then begin
        Binary := new ImmutableBinary(&Array);
        result := Binary;
      end;
    end;

    method GetContentAsArray: array of Byte;
    begin
      if assigned(&Array) then
        result := &Array
      else if assigned(Binary) then
        result := Binary.ToArray();
    end;

  end;

end.