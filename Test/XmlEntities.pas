namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  XmlEntities = public class(Test)
  public

    method Parsing;
    begin
      var xml := XmlDocument.FromString('<foo attr="test &amp; test"/>');
      writeLn(xml);
    end;
    
  end;

end.
