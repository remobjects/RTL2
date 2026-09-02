namespace Elements.RTL2.ExternalConsumers.Island;

interface

uses
  RemObjects.Elements.RTL;

type
  Program = public static class
  public

    method Main: Integer;
  end;

implementation

method Program.Main: Integer;
begin
  var lUpperLetter: Char := 'A';
  var lLowerLetter: Char := 'z';
  var lDigit: Char := '7';
  var lWhitespace: Char := ' ';

  if (not lUpperLetter.IsLetter) or (not lUpperLetter.IsUpper) or
     (not lLowerLetter.IsLetterOrNumber) or (not lDigit.IsDigit) or
     (not lWhitespace.IsWhitespace) then
    exit 1;

  if (lUpperLetter.ToLower <> 'a') or (lLowerLetter.ToUpper <> 'Z') then
    exit 2;

  writeLn('RTL2 Char extensions resolved from Elements.fx');
end;

end.
