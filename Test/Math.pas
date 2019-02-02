namespace Elements.RTL2.Tests.Shared;

interface

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  MathTest = public class(Test)
  private
  protected
  public
    method RoundTest;
  end;

implementation

method MathTest.RoundTest;
begin
 //  const PI: Double = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679;
  var a : Double := 3.141592653589793;//2384626433832795028841971693993751058209749445923078164062862089986280348253421170679;

  Assert.DoesNotThrows(()->  Math.Round(a));
  Assert.AreEqual(Math.Round(a), 3);

 {$if ECHOES or TOFFEE or ISLAND or COOPER}
  Assert.Throws(()->  Math.Round(a,-1));
  Assert.Throws(()->  Math.Round(a,16));
  Assert.AreEqual(Math.Round(a,0), 3.0);
  Assert.AreEqual(Math.Round(a,4), 3.1416);
  Assert.AreEqual(Math.Round(a,9), 3.141592654);
  Assert.AreEqual(Math.Round(a,12), 3.141592653590);
  Assert.AreEqual(Math.Round(a,13), 3.1415926535898);
  Assert.AreEqual(Math.Round(a,14), 3.14159265358979);
  Assert.AreEqual(Math.Round(a,15), 3.141592653589793);
 {$ENDIF}

end;

end.