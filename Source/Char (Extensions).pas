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
  {$IF COOPER}
  result := Character.toLowerCase(aChar);
  {$ELSEIF ECHOES}// OR ISLAND}
  result := Char.ToLower(aChar);
  {$ELSEIF TOFFEE}
  result := chr(toLower(ord(aChar)));
  {$ENDIF}
end;

implementation

/*{$IF TOFFEE}
static method Char.ToLower(aChar: Char): Char;
begin
end;
{$ENDIF}*/

end.
