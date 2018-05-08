namespace RemObjects.Elements.RTL;

method &write(aMessage: String; params aParams: array of Object); public; inline;
begin
  if length(aParams) > 0 then
    RemObjects.Elements.System.write(String.Format(aMessage, aParams))
  else
    RemObjects.Elements.System.write(aMessage);
end;

method writeLn(aMessage: String; params aParams: array of Object); public; inline;
begin
  if length(aParams) > 0 then
    RemObjects.Elements.System.writeLn(String.Format(aMessage, aParams))
  else
    RemObjects.Elements.System.writeLn(aMessage);
end;

end.