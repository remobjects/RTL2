namespace RemObjects.Elements.RTL;

type
  HttpFormRequestContent = public class(HttpRequestContent, IHttpRequestContent)
  public

    property ContentType: nullable String read "text/form";

    constructor(aValues: not nullable StringDictionary);
    begin
      var sb := new StringBuilder;
      for each k in aValues.Keys index i do begin
        if i > 0 then
          sb.Append("&");
        sb.Append(Url.AddPercentEncodingsToPath(k));
        sb.Append("=");
        sb.Append(Url.AddPercentEncodingsToPath(aValues[k]));
      end;
      fArray := Encoding.UTF8.GetBytes(sb.ToString);
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