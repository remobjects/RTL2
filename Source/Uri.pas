namespace RemObjects.Elements.RTL;

type
  Uri = public abstract class
  private
  protected
  public

    class method UriWithString(aUriString: not nullable String): Uri;
    begin
      if aUriString:StartsWith("urn:") then
        result := Urn.UrnWithString(aUriString)
      else
        result := Url.UrlWithString(aUriString);
    end;

    class method TryUriWithString(aUriString: nullable String): Uri;
    begin
      if aUriString:StartsWith("urn:") then
        result := Urn.TryUrnWithString(aUriString)
      else
        result := Url.TryUrlWithString(aUriString);
    end;

  end;

end.