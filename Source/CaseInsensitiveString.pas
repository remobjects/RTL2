namespace RemObjects.Elements.RTL;

type
  CaseInsensitiveString = public class
  public

    operator Implicit(aString: nullable String): CaseInsensitiveString;
    begin
      if assigned(aString) then
        result := new CaseInsensitiveString(aString);
    end;

    operator Implicit(aString: CaseInsensitiveString): String;
    begin
      result := aString:fString;
    end;

    operator Equal(a: CaseInsensitiveString; b: String): Boolean;
    begin
      result := a:fString.ToLowerInvariant = b:ToLowerInvariant;
    end;

    operator Equal(a: String; b: CaseInsensitiveString): Boolean;
    begin
      result := a:ToLowerInvariant = b:fString.ToLowerInvariant;
    end;

    operator Equal(a: CaseInsensitiveString; b: CaseInsensitiveString): Boolean;
    begin
      result := a:fString.ToLowerInvariant = b:fString.ToLowerInvariant;
    end;

    operator &In(aLeft: CaseInsensitiveString; aRight: array of String): Boolean;
    begin
      for i: Integer := 0 to length(aRight)-1 do
        if aLeft = aRight[i] then
          exit true;
    end;

    operator &In(aLeft: CaseInsensitiveString; aRight: sequence of String): Boolean;
    begin
      for each i in aRight do
        if aLeft = a then
          exit true;
    end;

  unit
    constructor(aString: not nullable String);
    begin
      fString := aString;
    end;

  private
    fString: String;
  end;

  method caseInsensitive(aString: nullable String): CaseInsensitiveString; public;
  begin
    if assigned(aString) then
      result := new CaseInsensitiveString(aString);
  end;

end.