// Positive guards: Single math uses native float APIs where available and
// Double fallbacks otherwise, without routing floating-point Round through Int64.
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
    method SingleOverloads;
    method SingleRoundRange;
    method SingleMinMaxSemantics;
    method FloatingPointClassification;
    method IEEERemainderSemantics;
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

method MathTest.SingleOverloads;
begin
  var lA: Single := -2.5;
  var lB: Single := 4.0;
  Assert.AreEqual(Math.Abs(lA), Single(2.5));
  Assert.AreEqual(Math.Min(lA, lB), lA);
  Assert.AreEqual(Math.Max(lA, lB), lB);
  Assert.AreEqual(Math.Ceiling(lA), Single(-2.0));
  Assert.AreEqual(Math.Floor(lA), Single(-3.0));
  Assert.AreEqual(Math.Truncate(lA), Single(-2.0));
  Assert.AreEqual(Math.Sqrt(lB), Single(2.0));
  Assert.AreEqual(Math.Pow(lB, Single(2.0)), Single(16.0));
  Assert.AreEqual(Math.Exp2(Single(3.0)), Single(8.0));
  Assert.AreEqual(Math.Log2(Single(8.0)), Single(3.0));
  Assert.AreEqual(Math.Sign(lA), -1);
  Assert.AreEqual(Math.IEEERemainder(Single(7.0), Single(2.0)), Single(-1.0));
  Assert.AreEqual(Math.Round(Single(1.234), 2), Single(1.23));
  Assert.Throws(()-> Math.Round(lA, -1));
end;

method MathTest.SingleRoundRange;
begin
  // These finite Singles are already integral, but lie outside Int64's range.
  var lLarge: Single := 1.0e30;
  Assert.AreEqual(Math.Round(lLarge), lLarge);
  Assert.AreEqual(Math.Round(-lLarge), -lLarge);
  Assert.IsTrue(Consts.IsNaN(Math.Round(Single(Consts.NaN))));
  Assert.AreEqual(Math.Round(Single(Consts.PositiveInfinity)), Single(Consts.PositiveInfinity));
  Assert.AreEqual(Math.Round(Single(Consts.NegativeInfinity)), Single(Consts.NegativeInfinity));
  {$IF ECHOES}
  // Match the platform's floating-point rounding, including halfway values.
  Assert.AreEqual(Math.Round(Single(-2.5)), Single(-2.0));
  {$ELSEIF TOFFEE}
  Assert.AreEqual(Math.Round(Single(-2.5)), rtl.roundf(Single(-2.5)));
  {$ENDIF}
end;

// Positive guard: adding Single overloads preserves each platform's existing
// Double min/max behavior for NaNs and both signs of zero.
method MathTest.SingleMinMaxSemantics;
begin
  var lValues: array of Single := [Single(0.0), Single(-0.0), Single(Consts.NaN), Single(-2.0), Single(3.0)];
  for each lA in lValues do
    for each lB in lValues do begin
      var lActual := Math.Min(lA, lB);
      var lExpected := Single(Math.Min(Double(lA), Double(lB)));
      if Consts.IsNaN(lExpected) then
        Assert.IsTrue(Consts.IsNaN(lActual))
      else begin
        Assert.AreEqual(lActual, lExpected);
        if lExpected = 0 then
          Assert.AreEqual(1.0 / Double(lActual), 1.0 / Double(lExpected));
      end;
      lActual := Math.Max(lA, lB);
      lExpected := Single(Math.Max(Double(lA), Double(lB)));
      if Consts.IsNaN(lExpected) then
        Assert.IsTrue(Consts.IsNaN(lActual))
      else begin
        Assert.AreEqual(lActual, lExpected);
        if lExpected = 0 then
          Assert.AreEqual(1.0 / Double(lActual), 1.0 / Double(lExpected));
      end;
    end;
end;

// Positive guard: Island must execute the floating-point classification methods;
// their former conditional branches omitted Island and always returned false.
method MathTest.FloatingPointClassification;
begin
  Assert.IsTrue(Consts.IsNaN(Consts.NaN));
  Assert.IsFalse(Consts.IsNaN(1.0));
  Assert.IsTrue(Consts.IsInfinity(Consts.PositiveInfinity));
  Assert.IsTrue(Consts.IsInfinity(Consts.NegativeInfinity));
  Assert.IsFalse(Consts.IsInfinity(1.0));
  Assert.IsTrue(Consts.IsPositiveInfinity(Consts.PositiveInfinity));
  Assert.IsFalse(Consts.IsPositiveInfinity(Consts.NegativeInfinity));
  Assert.IsTrue(Consts.IsNegativeInfinity(Consts.NegativeInfinity));
  Assert.IsFalse(Consts.IsNegativeInfinity(Consts.PositiveInfinity));
end;

// Negative guard: the platform mapping must preserve IEEE ties and signed zero
// for both overloads, rather than rounding a quotient halfway away from zero.
method MathTest.IEEERemainderSemantics;
begin
  Assert.AreEqual(Math.IEEERemainder(Double(5), Double(2)), Double(1));
  Assert.AreEqual(Math.IEEERemainder(Double(7), Double(2)), Double(-1));
  Assert.AreEqual(Math.IEEERemainder(Single(5), Single(2)), Single(1));
  Assert.AreEqual(Math.IEEERemainder(Single(-7), Single(-2)), Single(1));
  Assert.AreEqual(1.0 / Math.IEEERemainder(Double(-6), Double(2)), Consts.NegativeInfinity);
  Assert.AreEqual(1.0 / Double(Math.IEEERemainder(Single(-6), Single(2))), Consts.NegativeInfinity);
  Assert.IsTrue(Consts.IsNaN(Math.IEEERemainder(Double(1), Double(0))));
  Assert.IsTrue(Consts.IsNaN(Math.IEEERemainder(Consts.PositiveInfinity, Double(2))));
  Assert.AreEqual(Math.IEEERemainder(Double(3), Consts.PositiveInfinity), Double(3));
end;

end.