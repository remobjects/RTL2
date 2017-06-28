namespace RemObjects.Elements.RTL;

type
  Uri = public abstract class
  private
  protected
  public

    class method UriWithString(aUriString: not nullable String): Uri;
    begin
      var p := aUriString.IndexOf(":");
      if p > -1 then begin
        if aUriString.IndexOf("//", p+1) = 0 then
          result := Url.TryUrlWithString(aUriString)
        else
          result := Urn.TryUrnWithString(aUriString);
      end
      else
        raise new UrlParserException("Not a valid URI, '{0}'", aUriString);
    end;

    class method TryUriWithString(aUriString: nullable String): Uri;
    begin
      if assigned(aUriString) then begin
        var p := aUriString.IndexOf(":");
        if p > -1 then begin
          if aUriString.IndexOf("//", p+1) = 0 then
            result := Url.TryUrlWithString(aUriString)
          else
            result := Urn.TryUrnWithString(aUriString);
        end;
      end;
    end;

  end;

end.