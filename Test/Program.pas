namespace Elements.RTL2.Tests.Echoes;

interface

uses
  RemObjects.Elements.EUnit;

implementation

begin
  var lTests := Discovery.DiscoverTests();
  Runner.RunTests(lTests) withListener(Runner.DefaultListener);
end.
