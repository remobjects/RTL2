namespace RemObjects.Elements.RTL;

type
  Urn = public class(Uri)
  private
    fUrnString: String;

    constructor (aUrnString: not nullable String);
    begin
      fUrnString := aUrnString;
    end;

  protected
  public


    [ToString]
    method ToString: String; override;
    begin
      result := fUrnString;
    end;

    class method UrnWithString(aUrnString: not nullable String): Urn;
    begin
      result := new Urn(aUrnString);
    end;

    class method TryUrnWithString(aUrnString: nullable String): Urn;
    begin
      if length(aUrnString) > 0 then
        result := new Urn(aUrnString);
    end;

  end;

end.