namespace RemObjects.Elements.RTL;

type
  HttpJsonRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    property Json: not nullable JsonDocument; readonly;
    property Encoding: Encoding; readonly;

    constructor(aJson: not nullable JsonDocument; aEncoding: Encoding := nil; aContentType: nullable String := nil);
    begin
      //var ContentType: integer;
      //ContentType
      Encoding := coalesce(aEncoding, Encoding.UTF8);
      ContentType := coalesce(aContentType, "application/json");
      Json := aJson;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := $"<HttpJsonRequestContent {ContentType}: {Json}>";
    end;

  private

    method GetContentAsBinary: ImmutableBinary;
    begin
      result := new ImmutableBinary(GetContentAsArray);
    end;

    method GetContentAsArray(): array of Byte;
    begin
      result := Encoding.GetBytes(Json.ToJsonString(JsonFormat.Minimal));
    end;

  end;

end.