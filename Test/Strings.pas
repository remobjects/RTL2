namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit;

type
  Strings = public class(Test)
  public
    method FirstTest;
    begin
      Check.IsTrue(true);
    end;
  end;

end.