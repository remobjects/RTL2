namespace RemObjects.Elements.RTL;

interface

/*type
  CharExtensions = public extension record (Char) // E36 Interface type expected, found "Char"
  private
  protected
  public
    {$IF TOFFEE}
    static method ToLower(aChar: Char): Char;
    {$ENDIF}
  end;*/

{$GLOBALS ON}

method LowerChar(aChar: Char): Char; assembly;
begin
  {$IF COOPER}
  result := Character.toLowerCase(aChar);
  {$ELSEIF ECHOES}// OR ISLAND}
  result := Char.ToLower(aChar);
  {$ELSEIF ISLAND}
  result := aChar.ToLower();
  {$ELSEIF TOFFEE}
  result := chr(tolower(ord(aChar)));
  {$ENDIF}
end;

method UpperChar(aChar: Char): Char; assembly;
begin
  {$IF COOPER}
  result := Character.toUpperCase(aChar);
  {$ELSEIF ECHOES}// OR ISLAND}
  result := Char.ToUpper(aChar);
  {$ELSEIF ISLAND}
  result := aChar.ToUpper();
  {$ELSEIF TOFFEE}
  result := chr(toupper(ord(aChar)));
  {$ENDIF}
end;

implementation

/*{$IF TOFFEE}
static method Char.ToLower(aChar: Char): Char;
begin
end;
{$ENDIF}*/

end.