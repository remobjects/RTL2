// Positive guards: Single math uses native float APIs where available and
// Double fallbacks otherwise. Both one-argument Round overloads return Int64.
// Island rounds halfway away and saturates; decimal-place overloads return floats.
namespace Elements.RTL2.Tests.Shared;

interface

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  MathTest = public class(Test)
  private
    {$IF ISLAND}
    [DisableInlining]
    class method RoundValues(aInput: array of Double; aOutput: array of Int64);
    [DisableInlining]
    class method RoundValues(aInput: array of Single; aOutput: array of Int64);
    {$ENDIF}
  protected
  public
    method RoundTest;
    {$IF ISLAND}
    method RoundDoubleSaturation;
    method RoundSingleSaturation;
    {$ENDIF}
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

// Positive guard: Single rounding returns the same integer type as Double;
// overloads with a decimal-place argument intentionally remain floating point.
method MathTest.SingleRoundRange;
begin
  var lRounded := Math.Round(Single(2.5));
  var lDoubleRounded := Math.Round(Double(2.5));
  Assert.AreEqual(typeOf(Int64), typeOf(lRounded));
  Assert.AreEqual(typeOf(Int64), typeOf(lDoubleRounded));
  {$IF ISLAND}
  Assert.AreEqual(Math.Round(Single(-2.5)), Int64(-3));
  Assert.AreEqual(Math.Round(Single(2.5)), Int64(3));
  Assert.AreEqual(Math.Round(Single(1.0e30)), Consts.MaxInt64);
  Assert.AreEqual(Math.Round(Single(-1.0e30)), Consts.MinInt64);
  Assert.AreEqual(Math.Round(Single(Consts.NaN)), Int64(0));
  Assert.AreEqual(Math.Round(Single(Consts.PositiveInfinity)), Consts.MaxInt64);
  Assert.AreEqual(Math.Round(Single(Consts.NegativeInfinity)), Consts.MinInt64);
  {$ELSE}
  for each lValue in [Single(-2.5), Single(2.5), Single(-0.5), Single(0.5)] do
    Assert.AreEqual(Math.Round(lValue), Math.Round(Double(lValue)));
  Assert.Throws(()-> Math.Round(Single(Consts.NaN)));
  Assert.Throws(()-> Math.Round(Single(Consts.PositiveInfinity)));
  Assert.Throws(()-> Math.Round(Single(Consts.NegativeInfinity)));
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

{$IF ISLAND}
// Positive guard: the public RTL call retains its Int64 return and vectorizes
// safely across NaN, infinity, overflow, halfway values, and scalar tails.
class method MathTest.RoundValues(aInput: array of Double; aOutput: array of Int64);
begin
  for i := 0 to length(aInput) - 1 do
    aOutput[i] := Math.Round(aInput[i]);
end;

class method MathTest.RoundValues(aInput: array of Single; aOutput: array of Int64);
begin
  for i := 0 to length(aInput) - 1 do
    aOutput[i] := Math.Round(aInput[i]);
end;

// Positive guard: Single rounds before conversion, including adjacent Int64
// boundary values and the 2^23 boundary where adding 0.5 can change integers.
method MathTest.RoundSingleSaturation;
begin
  var lValues: array of Single := [Single(1.25), Single(-2.5), Single(2.5),
    Single(-0.5), Single(0.5), Single(0.0), Single(-0.0),
    Single(0.4999999701976776), Single(-0.4999999701976776),
    Single(0.5000000596046448), Single(-0.5000000596046448),
    Single(Consts.NaN), Single(Consts.PositiveInfinity), Single(Consts.NegativeInfinity),
    Single(9223371487098961920.0), Single(9223372036854775808.0), Single(9223373136366403584.0),
    Single(-9223371487098961920.0), Single(-9223372036854775808.0), Single(-9223373136366403584.0),
    Single(1.0e30), Single(-1.0e30), Single(8388607.5), Single(-8388607.5),
    Single(8388609.0), Single(-8388609.0)];
  var lExpected: array of Int64 := [1, -3, 3, -1, 1, 0, 0, 0, 0, 1, -1,
    0, Consts.MaxInt64, Consts.MinInt64,
    9223371487098961920, Consts.MaxInt64, Consts.MaxInt64,
    -9223371487098961920, Consts.MinInt64, Consts.MinInt64,
    Consts.MaxInt64, Consts.MinInt64, 8388608, -8388608, 8388609, -8388609];
  for n := 0 to 65 do begin
    var lInput := new Single[n];
    var lOutput := new Int64[n];
    for offset := 0 to length(lValues) - 1 do begin
      for i := 0 to n - 1 do
        lInput[i] := lValues[(i + offset) mod length(lValues)];
      RoundValues(lInput, lOutput);
      for i := 0 to n - 1 do
        Assert.AreEqual(lExpected[(i + offset) mod length(lValues)], lOutput[i]);
    end;
  end;
end;

method MathTest.RoundDoubleSaturation;
begin
  // Neighbours of both Int64 boundaries catch rounded constants and poison casts.
  // Values around 2^52 catch the legacy floor(x + 0.5) double-rounding problem.
  var lValues: array of Double := [1.25, -2.5, 2.5, -0.5, 0.5, 0.0, -0.0,
    0.49999999999999994, -0.49999999999999994, 0.5000000000000001, -0.5000000000000001,
    Consts.NaN, Consts.PositiveInfinity, Consts.NegativeInfinity,
    9223372036854774784.0, 9223372036854775808.0, 9223372036854777856.0,
    -9223372036854774784.0, -9223372036854775808.0, -9223372036854777856.0,
    1.0e300, -1.0e300, 4503599627370495.5, -4503599627370495.5,
    4503599627370497.0, -4503599627370497.0];
  var lExpected: array of Int64 := [1, -3, 3, -1, 1, 0, 0, 0, 0, 1, -1,
    0, Consts.MaxInt64, Consts.MinInt64,
    9223372036854774784, Consts.MaxInt64, Consts.MaxInt64,
    -9223372036854774784, Consts.MinInt64, Consts.MinInt64,
    Consts.MaxInt64, Consts.MinInt64, 4503599627370496, -4503599627370496,
    4503599627370497, -4503599627370497];
  for n := 0 to 65 do begin
    var lInput := new Double[n];
    var lOutput := new Int64[n];
    for offset := 0 to length(lValues) - 1 do begin
      for i := 0 to n - 1 do
        lInput[i] := lValues[(i + offset) mod length(lValues)];
      RoundValues(lInput, lOutput);
      for i := 0 to n - 1 do
        Assert.AreEqual(lExpected[(i + offset) mod length(lValues)], lOutput[i]);
    end;
  end;
end;
{$ENDIF}

end.