﻿namespace RemObjects.Elements.RTL;

type
  IHttpRequestContent = assembly interface
    method GetContentAsBinary: ImmutableBinary;
    method GetContentAsArray: array of Byte;
  end;

  HttpRequestContent = public class
  public

    operator Implicit(aBinary: not nullable ImmutableBinary): HttpRequestContent;
    begin
      result := new HttpBinaryRequestContent(aBinary);
    end;

    operator Implicit(aString: not nullable String): HttpRequestContent;
    begin
      result := new HttpBinaryRequestContent(aString, Encoding.UTF8);
    end;

  end;

  HttpBinaryRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    constructor(aBinary: not nullable ImmutableBinary);
    begin
      Binary := aBinary;
    end;

    constructor(aArray: not nullable array of Byte);
    begin
      &Array := aArray;
    end;

    constructor(aString: not nullable String; aEncoding: Encoding);
    begin
      if aEncoding = nil then aEncoding := Encoding.Default;
      &Array := aString.ToByteArray(aEncoding);
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