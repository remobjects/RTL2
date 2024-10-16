namespace RemObjects.Elements.RTL;

type
  HttpJsonRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    property ContentType: nullable String; readonly;
    property Json: not nullable JsonDocument; readonly;

    constructor(aJson: not nullable JsonDocument; aContentType: nullable String := nil);
    begin
      ContentType := coalesce(aContentType, "application/json");
      Json := aJson;
    end;

  private

    method GetContentAsBinary: ImmutableBinary;
    begin
      result := new ImmutableBinary(GetContentAsArray);
    end;

    method GetContentAsArray(): array of Byte;
    begin
      result := Encoding.UTF8.GetBytes(Json.ToJsonString(JsonFormat.Minimal));
    end;

  end;

end.