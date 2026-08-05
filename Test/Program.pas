namespace RemObjects.Elements.RTL.Tests;

interface

uses
  RemObjects.Elements.EUnit;

type
  Program = public static class
  public
    method Main(aArguments: array of String): Integer;
  end;

implementation

method Program.Main(aArguments: array of String): Integer;
begin
  var lTests := Discovery.DiscoverTests();
  var lTestResult := Runner.RunTests(lTests) withListener(Runner.DefaultListener);
  result := if lTestResult.State = TestState.Succeeded then 0 else 1;
end;

end.
