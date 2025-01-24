namespace RemObjects.Elements.RTL;

type
  HttpFormRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    property ContentType: nullable String read private write;

    constructor(aValues: not nullable StringDictionary; aEncoding: Encoding := nil; aContentType: nullable String := nil);
    begin
      var sb := new StringBuilder;
      for each k in aValues.Keys index i do begin
        if i > 0 then
          sb.Append("&");
        sb.Append(Url.AddPercentEncodingsToPath(k));
        sb.Append("=");
        sb.Append(Url.AddPercentEncodingsToPath(aValues[k]));
      end;
      fArray := coalesce(aEncoding, Encoding.UTF8).GetBytes(sb.ToString);
      ContentType := coalesce(aContentType, "text/form");
    end;

  private

    var fArray: array of Byte;

    method GetContentAsBinary: ImmutableBinary;
    begin
      result := new ImmutableBinary(fArray);
    end;

    method GetContentAsArray(): array of Byte;
    begin
      result := fArray;
    end;

  end;

end.