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

method LowerChar(aChar: Char): Char;
begin
  {$IF TOFFEE}
  result := chr(toLower(ord(aChar)));
  {$ELSE}
  result := Char.ToLower(aChar);
  {$ENDIF}
end;

implementation

/*{$IF TOFFEE}
static method Char.ToLower(aChar: Char): Char;
begin
end;
{$ENDIF}*/

end.
