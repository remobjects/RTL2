namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit;

type
  JsonTests = public class(Test)
  public

    method Floats;
    begin
      var f := JsonFloatValue(12.18688);
      Check.AreEqual(f.ToString, "12.18688");
      Check.AreEqual(f.ToJson, "12.18688");
      Check.AreNotEqual(f.ToJson, "12.187");
    end;

  end;


end.