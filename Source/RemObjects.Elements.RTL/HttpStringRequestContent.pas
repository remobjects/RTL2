namespace RemObjects.Elements.RTL;

type
  HttpStringRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    property String: not nullable String; readonly;
    property Encoding: Encoding; readonly;

    constructor(aString: not nullable String; aEncoding: Encoding := nil; aContentType: nullable String := nil);
    begin
      Encoding := coalesce(aEncoding, Encoding.UTF8);
      ContentType := coalesce(aContentType, "application/json");
      String := aString;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := $"<HttpStringRequestContent {ContentType}: {String}>";
    end;

  private

    method GetContentAsBinary: ImmutableBinary;
    begin
      result := new ImmutableBinary(GetContentAsArray);
    end;

    method GetContentAsArray(): array of Byte;
    begin
      result := Encoding.GetBytes(String);
    end;

  end;

end.