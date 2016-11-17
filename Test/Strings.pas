namespace Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit;

type
  Strings = public class(Test)
  public
    method FirstTest;
    begin
      Assert.IsTrue(true);
    end;
  end;

end.
