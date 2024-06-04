namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  JsonTests = public class(Test)
  public

    method Floats;
    begin
      var f := JsonFloatValue(12.18688);
      Check.AreEqual(f.ToString, "12.18688");
      Check.AreEqual(f.ToJsonString, "12.18688");
      Check.AreNotEqual(f.ToJsonString, "12.187");
    end;

    method TryFromAString;
    begin
      var lJson := JsonDocument.TryFromString("");
      Check.IsNil(lJson);
    end;

  end;


end.