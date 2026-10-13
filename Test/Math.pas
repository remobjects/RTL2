// Positive guards: Island Single math uses its native implementation; other
// backends preserve their Double wrappers. Both one-argument Round overloads return Int64.
// All backends round ties to even; Island retains saturating integer conversion.
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
    method RoundMidpointPolicy;
    method RoundDigitsPolicy;
    method BankersRoundPolicy;
    {$IF ISLAND}
    method RoundDoubleSaturation;
    method RoundSingleSaturation;
    {$ENDIF}
    method SingleOverloads;
    method SingleRoundRange;
    method SingleMinMaxSemantics;
    {$IF COOPER OR ECHOES OR TOFFEE}
    method SingleExceptionalCompatibility;
    method SinglePrimitiveCompatibility;
    method SingleDecimalRoundCompatibility;
    {$ENDIF}
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

// Positive guard: the default .NET/IEEE midpoint rule is nearest with ties to
// even for both floating input widths on every backend.
method MathTest.RoundMidpointPolicy;
begin
  var lValues: array of Double := [-4.5, -3.5, -2.5, -1.5, -0.5,
      0.5, 1.5, 2.5, 3.5, 4.5];
  var lExpected: array of Int64 := [-4, -4, -2, -2, 0, 0, 2, 2, 4, 4];
  for i := 0 to length(lValues) - 1 do begin
    Assert.AreEqual(Math.Round(lValues[i]), lExpected[i]);
    Assert.AreEqual(Math.Round(Single(lValues[i])), lExpected[i]);
  end;
end;

// Positive guard: decimal rounding follows .NET's exact scales and 1e16
// cutoff rather than Pow-derived scales or a quotient rounded away from zero.
method MathTest.RoundDigitsPolicy;
begin
  Assert.AreEqual(Math.Round(Double(2.5), 0), Double(2.0));
  Assert.AreEqual(Math.Round(Double(3.5), 0), Double(4.0));
  Assert.AreEqual(Math.Round(Double(-2.5), 0), Double(-2.0));
  Assert.AreEqual(Math.Round(Double(-3.5), 0), Double(-4.0));
  Assert.AreEqual(Math.Round(Double(1.125), 2), Double(1.12));
  Assert.AreEqual(Math.Round(Double(1.375), 2), Double(1.38));
  Assert.AreEqual(Math.Round(Double(-1.125), 2), Double(-1.12));
  Assert.AreEqual(Math.Round(Double(-1.375), 2), Double(-1.38));
  Assert.AreEqual(Math.Round(Double(10000000000000000.0), 15), Double(10000000000000000.0));
  var lZero := Double(0.0);
  var lPositiveInfinity := 1.0 / lZero;
  var lNegativeInfinity := -1.0 / lZero;
  var lInputNaN := lZero / lZero;
  var lNegativeZeroReciprocal := 1.0 / Math.Round(Double(-0.5), 0);
  Assert.IsTrue(lNegativeZeroReciprocal = lNegativeInfinity);
  var lNaN := Math.Round(lInputNaN, 2);
  Assert.IsTrue(lNaN <> lNaN);
  Assert.IsTrue(Math.Round(lPositiveInfinity, 2) = lPositiveInfinity);
  Assert.IsTrue(Math.Round(lNegativeInfinity, 2) = lNegativeInfinity);
end;

// Regression guard: the legacy name must not retain a second midpoint
// implementation that can drift from the public Round contract.
method MathTest.BankersRoundPolicy;
begin
  for each lValue in [Double(-4.5), Double(-3.5), Double(-2.5), Double(-1.5),
      Double(-0.5), Double(0.5), Double(1.5), Double(2.5), Double(3.5), Double(4.5)] do
    Assert.AreEqual(Math.BankersRound(lValue), Math.Round(lValue));
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
  // Cocoa has no primitive typeOf; Java reflects boxed values as java.lang.Long.
  // Keep typed assignments on every backend and metadata checks where supported.
  var lSingleAsInt64: Int64 := lRounded;
  var lDoubleAsInt64: Int64 := lDoubleRounded;
  Assert.AreEqual(lSingleAsInt64, lDoubleAsInt64);
  {$IF ECHOES OR ISLAND}
  Assert.AreEqual(typeOf(Int64), typeOf(lRounded));
  Assert.AreEqual(typeOf(Int64), typeOf(lDoubleRounded));
  {$ENDIF}
  {$IF ISLAND}
  Assert.AreEqual(Math.Round(Single(-2.5)), Int64(-2));
  Assert.AreEqual(Math.Round(Single(2.5)), Int64(2));
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
  // Manufacture IEEE specials independently of Consts so a broken constant or
  // classifier cannot make these exception checks pass with finite overflow.
  var lZero := Single(0.0);
  Assert.Throws(()-> Math.Round(lZero / lZero));
  Assert.Throws(()-> Math.Round(Single(1.0) / lZero));
  Assert.Throws(()-> Math.Round(Single(-1.0) / lZero));
  var lDoubleZero := Double(0.0);
  Assert.Throws(()-> Math.Round(lDoubleZero / lDoubleZero));
  Assert.Throws(()-> Math.Round(1.0 / lDoubleZero));
  Assert.Throws(()-> Math.Round(-1.0 / lDoubleZero));
  {$ENDIF}
end;

{$IF COOPER OR ECHOES OR TOFFEE}
// Negative guard: a new Single overload must not bypass the established Double
// wrapper's exceptional-input policy by calling a new platform entry point.
method MathTest.SingleExceptionalCompatibility;
begin
  var lValues: array of Single := [Single(0.0), Single(-0.0), Single(1.0), Single(-1.0),
      Single(0.5), Single(-0.5), Single(Consts.NaN),
      Single(Consts.PositiveInfinity), Single(Consts.NegativeInfinity)];
  for each lA in lValues do
    for each lB in lValues do begin
      var lExpected := Single(Math.Atan2(Double(lA), Double(lB)));
      var lActual := Math.Atan2(lA, lB);
      if Consts.IsNaN(lExpected) then
        Assert.IsTrue(Consts.IsNaN(lActual))
      else begin
        Assert.AreEqual(lActual, lExpected);
        if lExpected = 0 then
          Assert.AreEqual(1.0 / Double(lActual), 1.0 / Double(lExpected));
      end;
      lExpected := Single(Math.Pow(Double(lA), Double(lB)));
      lActual := Math.Pow(lA, lB);
      if Consts.IsNaN(lExpected) then
        Assert.IsTrue(Consts.IsNaN(lActual))
      else begin
        Assert.AreEqual(lActual, lExpected);
        if lExpected = 0 then
          Assert.AreEqual(1.0 / Double(lActual), 1.0 / Double(lExpected));
      end;
    end;

  // These expectations are independent of the Double result, so a shared
  // accidental change cannot conceal the wrapper policies that triggered this test.
  {$IF COOPER OR TOFFEE}
  Assert.IsTrue(Consts.IsNaN(Math.Atan2(Single(Consts.PositiveInfinity), Single(Consts.PositiveInfinity))));
  {$ENDIF}
  {$IF TOFFEE}
  Assert.IsTrue(Consts.IsNaN(Math.Pow(Single(-1.0), Single(Consts.PositiveInfinity))));
  Assert.IsTrue(Consts.IsNaN(Math.Pow(Single(-1.0), Single(Consts.NegativeInfinity))));
  {$ENDIF}
  Assert.IsTrue(Consts.IsNaN(Math.Pow(Single(-1.0), Single(0.5))));
  Assert.AreEqual(Math.Pow(Single(-2.0), Single(3.0)), Single(-8.0));
  Assert.AreEqual(Math.Atan2(Single(1.0), Single(1.0)), Single(Consts.PI / 4.0));
end;

// Positive guard: primitive Single overloads use the same established wrappers,
// including absolute signed zero and Sign's exceptional-input behavior.
method MathTest.SinglePrimitiveCompatibility;
begin
  for each lValue in [Single(0.0), Single(-0.0), Single(1.0), Single(-1.0),
      Single(0.5), Single(-0.5), Single(Consts.NaN),
      Single(Consts.PositiveInfinity), Single(Consts.NegativeInfinity)] do begin
    var lExpected := Single(Math.Abs(Double(lValue)));
    var lActual := Math.Abs(lValue);
    if Consts.IsNaN(lExpected) then
      Assert.IsTrue(Consts.IsNaN(lActual))
    else begin
      Assert.AreEqual(lActual, lExpected);
      if lExpected = 0 then
        Assert.AreEqual(1.0 / Double(lActual), 1.0 / Double(lExpected));
    end;
    if Consts.IsNaN(lValue) then begin
      Assert.Throws(()-> Math.Sign(Double(lValue)));
      Assert.Throws(()-> Math.Sign(lValue));
    end
    else begin
      Assert.AreEqual(Math.Sign(lValue), Math.Sign(Double(lValue)));
    end;
  end;
end;

// Negative guard: MathF.Round accepts at most six digits on .NET, whereas the
// established Double API accepts fifteen. Overload resolution must not reduce
// that range or change halfway handling depending on the target framework.
method MathTest.SingleDecimalRoundCompatibility;
begin
  for each lValue in [Single(-2.5), Single(2.5), Single(-1.125), Single(1.125), Single(0.0)] do
    for each lDigits in [0, 2, 6, 7, 15] do
      Assert.AreEqual(Math.Round(lValue, lDigits), Single(Math.Round(Double(lValue), lDigits)));
  Assert.AreEqual(Math.Round(Single(2.0), 7), Single(2.0));
  Assert.Throws(()-> Math.Round(Single(1.0), -1));
  Assert.Throws(()-> Math.Round(Single(1.0), 16));
end;
{$ENDIF}

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

// Positive guard: native Island, including ToffeeV2, must execute the runtime
// classifiers. Legacy Toffee retains its separate inline-libc route.
method MathTest.FloatingPointClassification;
begin
  var lZero := Double(0.0);
  var lNaN := lZero / lZero;
  var lPositiveInfinity := 1.0 / lZero;
  var lNegativeInfinity := -1.0 / lZero;
  Assert.IsTrue(Consts.IsNaN(lNaN));
  Assert.IsFalse(Consts.IsNaN(1.0));
  Assert.IsTrue(Consts.IsInfinity(lPositiveInfinity));
  Assert.IsTrue(Consts.IsInfinity(lNegativeInfinity));
  Assert.IsFalse(Consts.IsInfinity(1.0));
  Assert.IsFalse(Consts.IsInfinity(Consts.MaxDouble));
  Assert.IsTrue(Consts.IsPositiveInfinity(lPositiveInfinity));
  Assert.IsFalse(Consts.IsPositiveInfinity(lNegativeInfinity));
  Assert.IsTrue(Consts.IsNegativeInfinity(lNegativeInfinity));
  Assert.IsFalse(Consts.IsNegativeInfinity(lPositiveInfinity));
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
  var lExpected: array of Int64 := [1, -2, 2, 0, 0, 0, 0, 0, 0, 1, -1,
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
  var lExpected: array of Int64 := [1, -2, 2, 0, 0, 0, 0, 0, 0, 1, -1,
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
