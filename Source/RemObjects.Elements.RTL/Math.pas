namespace RemObjects.Elements.RTL;

interface

type
  {$IF JAVA}
  PlatformMath = public java.lang.Math;
  {$ELSEIF ECHOES}
  PlatformMath = public System.Math;
  {$ELSEIF ISLAND}
  PlatformMath = public RemObjects.Elements.System.Math;
  {$ENDIF}

  {$IF COOPER}
  Math = public partial class mapped to PlatformMath
  public
    class method Abs(d: Double): Double; mapped to abs(d);
    class method Abs(i: Int64): Int64;
    class method Abs(i: Integer): Integer;
    class method Acos(d: Double): Double; mapped to acos(d);
    class method Asin(d: Double): Double; mapped to asin(d);
    class method Atan(d: Double): Double; mapped to atan(d);
    class method Atan2(x,y: Double): Double;
    class method Ceiling(a: Double): Double; mapped to ceil(a);
    class method Cos(d: Double): Double; mapped to cos(d);
    class method Cosh(d: Double): Double; mapped to cosh(d);
    class method Exp(d: Double): Double; mapped to exp(d);
    class method Floor(d: Double): Double; mapped to floor(d);
    class method IEEERemainder(x, y: Double): Double; mapped to IEEEremainder(x, y);
    class method Log(d: Double): Double; mapped to log(d);
    class method Log10(d: Double): Double; mapped to log10(d);
    class method Max(a,b: Double): Double; mapped to max(a,b);
    class method Max(a,b: Integer): Integer; mapped to max(a,b);
    class method Max(a,b: Int64): Int64; mapped to max(a,b);
    class method Min(a,b: Double): Double; mapped to min(a,b);
    class method Min(a,b: Integer): Integer; mapped to min(a,b);
    class method Min(a,b: Int64): Int64; mapped to min(a,b);
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer;
    class method Sin(d: Double): Double; mapped to sin(d);
    class method Sinh(d: Double): Double; mapped to sinh(d);
    class method Sqrt(d: Double): Double; mapped to sqrt(d);
    class method Tan(d: Double): Double; mapped to tan(d);
    class method Tanh(d: Double): Double; mapped to tanh(d);
    class method Truncate(d: Double): Double;
  end;
  {$ELSEIF TOFFEE}
  Math = public partial class
  public
    {$WARNING Not implemented for Island yet}
    class method Abs(value: Double): Double;
    class method Abs(i: Int64): Int64;
    class method Abs(i: Integer): Integer;
    class method Acos(d: Double): Double;
    class method Asin(d: Double): Double;
    class method Atan(d: Double): Double;
    class method Atan2(x,y: Double): Double;
    class method Ceiling(d: Double): Double;
    class method Cos(d: Double): Double;
    class method Cosh(d: Double): Double;
    class method Exp(d: Double): Double;
    class method Floor(d: Double): Double;
    class method IEEERemainder(x, y: Double): Double;
    class method Log(a: Double): Double;
    class method Log10(a: Double): Double;
    class method Max(a,b: Double): Double;
    class method Max(a,b: Integer): Integer;
    class method Max(a,b: Int64): Int64;
    class method Min(a,b: Double): Double;
    class method Min(a,b: Integer): Integer;
    class method Min(a,b: Int64): Int64;
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer;
    class method Sin(x: Double): Double;
    class method Sinh(x: Double): Double;
    class method Sqrt(d: Double): Double;
    class method Tan(d: Double): Double;
    class method Tanh(d: Double): Double;
    class method Truncate(d: Double): Double;
  end;
  {$ELSEIF ECHOES OR ISLAND}
  Math = public partial class mapped to PlatformMath
  {$IF ISLAND}
  private
    [SymbolName('llvm.fptosi.sat.i64.f64'), MemoryNone, NoExcept, WillReturn]
    class method SaturateInt64(aValue: Double): Int64; external;
    [SymbolName('llvm.fptosi.sat.i64.f32'), MemoryNone, NoExcept, WillReturn]
    class method SaturateInt64(aValue: Single): Int64; external;
  {$ENDIF}
  public
    class method Abs(d: Double): Double; mapped to Abs(d);
    class method Abs(i: Int64): Int64; mapped to Abs(i);
    class method Abs(i: Integer): Integer; mapped to Abs(i);
    class method Acos(d: Double): Double; mapped to Acos(d);
    class method Asin(d: Double): Double; mapped to Asin(d);
    class method Atan(d: Double): Double; mapped to Atan(d);
    class method Atan2(x,y: Double): Double; mapped to Atan2(x,y);
    class method Ceiling(d: Double): Double; mapped to Ceiling(d);
    class method Cos(d: Double): Double; mapped to Cos(d);
    class method Cosh(d: Double): Double; mapped to Cosh(d);
    class method Exp(d: Double): Double; mapped to Exp(d);
    class method Floor(d: Double): Double; mapped to Floor(d);
    class method IEEERemainder(x, y: Double): Double; mapped to IEEERemainder(x, y);
    {$IF ISLAND}
    class method IEEERemainder(x, y: Single): Single; mapped to IEEERemainder(x, y);
    {$ENDIF}
    class method Log(d: Double): Double; mapped to Log(d);
    class method Log10(d: Double): Double; mapped to Log10(d);
    class method Max(a,b: Double): Double; mapped to Max(a,b);
    {$IF ISLAND}
    class method Max(a,b: Single): Single; mapped to Max(a,b);
    {$ENDIF}
    class method Max(a,b: Integer): Integer; mapped to Max(a,b);
    class method Max(a,b: Int64): Int64; mapped to Max(a,b);
    class method Min(a,b: Double): Double; mapped to Min(a,b);
    {$IF ISLAND}
    class method Min(a,b: Single): Single; mapped to Min(a,b);
    {$ENDIF}
    class method Min(a,b: Integer): Integer; mapped to Min(a,b);
    class method Min(a,b: Int64): Int64; mapped to Min(a,b);
    class method Pow(x, y: Double): Double; mapped to Pow(x,y);
    class method Round(a: Double): Int64; {$IF ISLAND}inline;{$ENDIF}
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer; mapped to Sign(d);
    {$IF ISLAND}
    class method Sign(d: Single): Integer; mapped to Sign(d);
    {$ENDIF}
    class method Sin(d: Double): Double; mapped to Sin(d);
    class method Sinh(d: Double): Double; mapped to Sinh(d);
    class method Sqrt(d: Double): Double; mapped to Sqrt(d);
    class method Tan(d: Double): Double; mapped to Tan(d);
    class method Tanh(d: Double): Double; mapped to Tanh(d);
    class method Truncate(d: Double): Double; mapped to Truncate(d);
    {$IF ISLAND}
    // Keep Single calls in Single precision so Island can use SLEEF vector functions.
    class method Abs(d: Single): Single; mapped to Abs(d);
    class method Acos(d: Single): Single; mapped to Acos(d);
    class method Asin(d: Single): Single; mapped to Asin(d);
    class method Atan(d: Single): Single; mapped to Atan(d);
    class method Atan2(x,y: Single): Single; mapped to Atan2(x,y);
    class method Ceiling(d: Single): Single; mapped to Ceiling(d);
    class method Cos(d: Single): Single; mapped to Cos(d);
    class method Cosh(d: Single): Single; mapped to Cosh(d);
    class method Exp(d: Single): Single; mapped to Exp(d);
    class method Exp2(d: Double): Double; mapped to Exp2(d);
    class method Exp2(d: Single): Single; mapped to Exp2(d);
    class method Floor(d: Single): Single; mapped to Floor(d);
    class method Log(d: Single): Single; mapped to Log(d);
    class method Log2(d: Double): Double; mapped to Log2(d);
    class method Log2(d: Single): Single; mapped to Log2(d);
    class method Log10(d: Single): Single; mapped to Log10(d);
    class method Pow(x,y: Single): Single; mapped to Pow(x,y);
    class method Round(d: Single): Int64; inline;
    class method Sin(d: Single): Single; mapped to Sin(d);
    class method Sinh(d: Single): Single; mapped to Sinh(d);
    class method Sqrt(d: Single): Single; mapped to Sqrt(d);
    class method Tan(d: Single): Single; mapped to Tan(d);
    class method Tanh(d: Single): Single; mapped to Tanh(d);
    class method Truncate(d: Single): Single; mapped to Truncate(d);
    class method fmodf(x,y: Single): Single; mapped to fmodf(x,y);
    {$ENDIF}
  end;
  {$ENDIF}

  {$IF COOPER OR ECHOES OR TOFFEE OR ISLAND}
  Math = public partial class
  public
    class method Round(a: Single; digits: Integer): Single;
  end;
  {$ENDIF}

  {$IF COOPER OR ECHOES OR TOFFEE}
  Math = public partial class
  public
    class method Abs(d: Single): Single;
    class method Min(a,b: Single): Single;
    class method Max(a,b: Single): Single;
    class method Sign(d: Single): Integer;
    class method IEEERemainder(x,y: Single): Single;
    class method Exp2(d: Double): Double;
    class method Log2(d: Double): Double;
    class method Acos(d: Single): Single;
    class method Asin(d: Single): Single;
    class method Atan(d: Single): Single;
    class method Atan2(x,y: Single): Single;
    class method Ceiling(d: Single): Single;
    class method Cos(d: Single): Single;
    class method Cosh(d: Single): Single;
    class method Exp(d: Single): Single;
    class method Exp2(d: Single): Single;
    class method Floor(d: Single): Single;
    class method Log(d: Single): Single;
    class method Log2(d: Single): Single;
    class method Log10(d: Single): Single;
    class method Pow(x,y: Single): Single;
    class method Round(d: Single): Int64;
    class method Sin(d: Single): Single;
    class method Sinh(d: Single): Single;
    class method Sqrt(d: Single): Single;
    class method Tan(d: Single): Single;
    class method Tanh(d: Single): Single;
    class method Truncate(d: Single): Single;
  end;
  {$ENDIF}

  // Centralize the default .NET/IEEE ties-to-even rule so every backend and
  // the decimal-place overloads use the same midpoint policy.
  MathRounding = assembly static class
  private
    // At 2^52 and above every finite Double is already an integer.
    const DoubleIntegralLimit: Double = 4503599627370496.0;
    // .NET only scales values below 1e16.
    const DoubleRoundLimit: Double = 10000000000000000.0;
  assembly
    class method RoundToEven(aValue: Double): Double;
    class method RoundToDigits(aValue: Double; aDigits: Integer): Double;
  end;

  Math_Extensions = public extension class(Math)
  public

    class method BankersRound(aValue: Double): Int64;
    begin
      // Banker's rounding is the canonical Round policy; delegating also keeps
      // its saturation or exceptional-input behavior aligned on each backend.
      result := Math.Round(aValue);
    end;

    class property Fibonacci: sequence of UInt64 read GetFibonacci;

    class method GetFibonacci: sequence of UInt64; iterator; private;
    begin
      var lLast: Int64 := 1;
      var lCurrent: Int64 := 1;
      yield 1;
      yield 1;
      loop begin
        var lTemp := lLast;
        lLast := lCurrent;
        lCurrent := lTemp+lLast;
        if lCurrent < lLast then
          exit;
        yield lCurrent;
      end;
    end;

  end;


  Consts = public static class
  public
    const π = PI;
    const PI: Double = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679;
    const E: Double =  2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274;

    const MaxInt32: Integer =  2147483647; //  0x7fff ffff
    const MinInt32: Integer = -2147483648; // -0x8000_0000
    const MaxInt64: Int64 =  9223372036854775807; //  0x7fff_ffff_ffff_ffff
    const MinInt64: Int64 = -9223372036854775808; // -0x8000_0000_0000_0000
    const MaxByte: Byte = $FF;
    const MinByte: Byte = 0;
    const MaxChar: Char = chr($FFFF);
    const MinChar: Char = chr(0);

    property MaxDouble: Double read {$IF COOPER}Double.MAX_VALUE{$ELSEIF ECHOES}Double.MaxValue{$ELSEIF TOFFEE OR ISLAND}1.7976931348623157E+308{$ELSE}{$ERROR Unsupported Platform}{$ENDIF};
    property MinDouble: Double read {$IF COOPER}-Double.MAX_VALUE{$ELSEIF ECHOES}Double.MinValue{$ELSEIF TOFFEE OR ISLAND}-1.7976931348623157E+308{$ELSE}{$ERROR Unsupported Platform}{$ENDIF};

    // ToffeeV2 defines both TOFFEE and ISLAND, so representation-level
    // constants and classifiers use the native runtime; Math's API stays Toffee-first.
    property PositiveInfinity: Double read {$IF COOPER}Double.POSITIVE_INFINITY{$ELSEIF ECHOES OR ISLAND}Double.PositiveInfinity{$ELSEIF TOFFEE}rtl.INFINITY{$ELSE}{$ERROR Unsupported Platform}{$ENDIF};
    property NegativeInfinity: Double read {$IF COOPER}Double.NEGATIVE_INFINITY{$ELSEIF ECHOES OR ISLAND}Double.NegativeInfinity{$ELSEIF TOFFEE}-INFINITY{$ELSE}{$ERROR Unsupported Platform}{$ENDIF};
    property NaN: Double read {$IF COOPER}Double.NaN{$ELSEIF ECHOES OR ISLAND}Double.NaN{$ELSEIF TOFFEE}rtl.nan{$ELSE}{$ERROR Unsupported Platform}{$ENDIF};

    property TrueString: not nullable String read "True";
    property FalseString: not nullable String read "False";

    class method IsNaN(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Double.isNaN(Value);
      {$ELSEIF ECHOES OR ISLAND}
      exit Double.IsNaN(Value);
      {$ELSEIF TOFFEE}
      exit __inline_isnand(Value) <> 0;
      {$ENDIF}
    end;

    class method IsInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Double.isInfinite(Value);
      {$ELSEIF ECHOES OR ISLAND}
      exit Double.IsInfinity(Value);
      {$ELSEIF TOFFEE}
      exit __inline_isinfd(Value) <> 0;
      {$ENDIF}
    end;

    class method IsNegativeInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Value = NegativeInfinity;
      {$ELSEIF ECHOES OR ISLAND}
      exit Double.IsNegativeInfinity(Value);
      {$ELSEIF TOFFEE}
      exit (Value = NegativeInfinity) and (not Consts.IsNaN(Value));
      {$ENDIF}
    end;

    class method IsPositiveInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Value = PositiveInfinity;
      {$ELSEIF ECHOES OR ISLAND}
      exit Double.IsPositiveInfinity(Value);
      {$ELSEIF TOFFEE}
      exit (Value = PositiveInfinity) and (not Consts.IsNaN(Value));
      {$ENDIF}
    end;
  end;

implementation

class method MathRounding.RoundToEven(aValue: Double): Double;
begin
  {$IF COOPER}
  // Java rint is explicitly nearest-even and preserves signed zero/specials.
  exit PlatformMath.rint(aValue);
  {$ELSEIF TOFFEE}
  // Do not use libc rint: its result follows the process rounding mode.
  var lMagnitude := Math.Abs(aValue);
  if not (lMagnitude < DoubleIntegralLimit) or (aValue = 0) then
    exit aValue;

  var lIntegral := Math.Floor(lMagnitude);
  var lFraction := lMagnitude - lIntegral;
  if (lFraction > 0.5) or
     ((lFraction = 0.5) and ((Int64(lIntegral) and 1) <> 0)) then
    lIntegral := lIntegral + 1;
  // Multiplication copies the input sign onto zero without depending on how a
  // backend lowers unary negation or a conditional result containing zero.
  if lIntegral = 0 then
    exit aValue * 0.0;
  exit if aValue < 0 then -lIntegral else lIntegral;
  {$ELSEIF ECHOES OR ISLAND}
  // Both platform Math implementations expose the default nearest-even rule.
  exit PlatformMath.Round(aValue);
  {$ENDIF}
end;

class method MathRounding.RoundToDigits(aValue: Double; aDigits: Integer): Double;
begin
  if (aDigits < 0) or (aDigits > 15) then
    raise new ArgumentException("digits must be between 0 and 15");

  // Match .NET: large finite values are already too coarse to change, while
  // the unordered comparison returns NaN and infinities unchanged.
  if not (Math.Abs(aValue) < DoubleRoundLimit) then
    exit aValue;

  // The accepted range needs at most fifteen multiplications. Every resulting
  // integer power is exactly representable as Double, unlike a generic Pow.
  var lPower := 1.0;
  for i := 1 to aDigits do
    lPower := lPower * 10.0;
  exit RoundToEven(aValue * lPower) / lPower;
end;

{$IF COOPER}
class method Math.Truncate(d: Double): Double;
begin
  exit iif(d < 0, mapped.ceil(d), mapped.floor(d));
end;

class method Math.Abs(i: Int64): Int64;
begin
  if i = Consts.MinInt64 then
    raise new ArgumentException("Value can not equals minimum value of Int64");

  exit mapped.abs(i);
end;

class method Math.Abs(i: Integer): Integer;
begin
  if i = Consts.MinInt32 then
    raise new ArgumentException("Value can not equals minimum value of Int32");

  exit mapped.abs(i);
end;

class method Math.Atan2(x: Double; y: Double): Double;
begin
  if Consts.IsInfinity(x) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit mapped.atan2(x,y);
end;

class method Math.Pow(x: Double; y: Double): Double;
begin
  {$IF ANDROID}
  if (x = -1) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit mapped.pow(x, y);
  {$ELSE}
  exit mapped.pow(x, y);
  {$ENDIF}
end;

class method Math.Round(a: Double): Int64;
begin
  if Consts.IsNaN(a) or Consts.IsInfinity(a) then
    raise new ArgumentException("Value can not be rounded to Int64");

  exit Int64(MathRounding.RoundToEven(a));
end;

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  result := MathRounding.RoundToDigits(a, digits);
end;


class method Math.Sign(d: Double): Integer;
begin
  if Consts.IsNaN(d) then
    raise new ArgumentException("Value can not be NaN");

  if d > 0 then exit 1;
  if d < 0 then exit -1;
  exit 0;
end;

{$ELSEIF TOFFEE}
class method Math.Sign(d: Double): Integer;
begin
  if Consts.IsNaN(d) then
    raise new ArgumentException("Value can not be NaN");

  if d > 0 then exit 1;
  if d < 0 then exit -1;
  exit 0;
end;

class method Math.Pow(x, y: Double): Double;
begin
  if (x = -1) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit rtl.pow(x,y);
end;

class method Math.Acos(d: Double): Double;
begin
  exit rtl.acos(d);
end;

class method Math.Cos(d: Double): Double;
begin
  exit rtl.cos(d);
end;

class method Math.Ceiling(d: Double): Double;
begin
  exit rtl.ceil(d);
end;

class method Math.Cosh(d: Double): Double;
begin
  exit rtl.cosh(d);
end;

class method Math.Asin(d: Double): Double;
begin
  exit rtl.asin(d);
end;

class method Math.Atan(d: Double): Double;
begin
  exit rtl.atan(d);
end;

class method Math.Atan2(x,y: Double): Double;
begin
  if Consts.IsInfinity(x) and Consts.IsInfinity(y) then
    exit Consts.NaN;

  exit rtl.atan2(x,y);
end;

class method Math.Abs(value: Double): Double;
begin
  exit rtl.fabs(value);
end;

class method Math.Exp(d: Double): Double;
begin
  exit rtl.exp(d);
end;

class method Math.Floor(d: Double): Double;
begin
  exit rtl.floor(d);
end;

class method Math.IEEERemainder(x,y: Double): Double;
begin
  exit rtl.remainder(x,y);
end;

class method Math.Log(a: Double): Double;
begin
  exit rtl.log(a);
end;

class method Math.Log10(a: Double): Double;
begin
  exit rtl.log10(a);
end;

class method Math.Max(a,b: Int64): Int64;
begin
  exit iif(a > b, a, b);
end;

class method Math.Min(a,b: Int64): Int64;
begin
  exit iif(a < b, a, b);
end;

class method Math.Sin(x: Double): Double;
begin
  exit rtl.sin(x);
end;

class method Math.Sinh(x: Double): Double;
begin
  exit rtl.sinh(x);
end;

class method Math.Sqrt(d: Double): Double;
begin
  exit rtl.sqrt(d);
end;

class method Math.Tan(d: Double): Double;
begin
  exit rtl.tan(d);
end;

class method Math.Tanh(d: Double): Double;
begin
  exit rtl.tanh(d);
end;

class method Math.Truncate(d: Double): Double;
begin
  exit rtl.trunc(d);
end;

class method Math.Abs(i: Int64): Int64;
begin
  if i = Consts.MinInt64 then
    raise new ArgumentException("Value can not equals minimum value of Int64");

  exit rtl.llabs(i);
end;

class method Math.Abs(i: Integer): Integer;
begin
  if i = Consts.MinInt32 then
    raise new ArgumentException("Value can not equals minimum value of Int32");

  exit rtl.abs(i);
end;

class method Math.Max(a: Double; b: Double): Double;
begin
  if Consts.IsNaN(a) or Consts.IsNaN(b) then
    exit Consts.NaN;

  exit iif(a > b, a, b);
end;

class method Math.Max(a: Integer; b: Integer): Integer;
begin
  exit iif(a > b, a, b);
end;

class method Math.Min(a: Double; b: Double): Double;
begin
  if Consts.IsNaN(a) or Consts.IsNaN(b) then
    exit Consts.NaN;

  exit iif(a < b, a, b);
end;

class method Math.Min(a: Integer; b: Integer): Integer;
begin
  exit iif(a < b, a, b);
end;

class method Math.Round(a: Double): Int64;
begin
  if Consts.IsNaN(a) or Consts.IsInfinity(a) then
    raise new ArgumentException("Value can not be rounded to Int64");

  exit Int64(MathRounding.RoundToEven(a));
end;

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  result := MathRounding.RoundToDigits(a, digits);
end;



 {$ELSEIF ECHOES OR ISLAND}
class method Math.Round(a: Double): Int64;
begin
  {$IF ISLAND}
  // Round to nearest-even in floating point, then convert without poison:
  // NaN becomes zero; infinities and finite overflow clamp to the Int64 bounds.
  // Keeping this as intrinsics lets LLVM combine and vectorize both operations.
  exit SaturateInt64(PlatformMath.Round(a));
  {$ELSE}
  if Consts.IsNaN(a) or Consts.IsInfinity(a) then
    raise new ArgumentException("Value can not be rounded to Int64");

  exit Int64(PlatformMath.Round(a));
  {$ENDIF}
end;

{$IF ISLAND}
class method Math.Round(d: Single): Int64;
begin
  // Round in Single precision; convert directly with the same nearest-even and
  // saturating conversion policy as Double.
  exit SaturateInt64(PlatformMath.Round(d));
end;
{$ENDIF}

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  {$IF ECHOES}
  result := mapped.Round(a, digits);
  exit;
  {$ELSE}
  result := MathRounding.RoundToDigits(a, digits);
   {$ENDIF}
end;

{$ENDIF}

{$IF COOPER OR ECHOES OR TOFFEE OR ISLAND}
// Preserve the established digit limits and rounding policy. Selecting MathF
// here would make the accepted digit range depend on the target framework.
class method Math.Round(a: Single; digits: Integer): Single;
begin
  exit Single(Round(Double(a), digits));
end;
{$ENDIF}

{$IF COOPER OR ECHOES OR TOFFEE}
// The Single API is portable, but its optimization is Island-specific. Reuse
// each other backend's established Double wrapper so adding overloads does not
// change exceptional-input rules or introduce new native math dependencies.

class method Math.Abs(d: Single): Single;
begin
  exit Single(Abs(Double(d)));
end;

class method Math.Max(a,b: Single): Single;
begin
  exit Single(Max(Double(a), Double(b)));
end;

class method Math.Min(a,b: Single): Single;
begin
  exit Single(Min(Double(a), Double(b)));
end;

class method Math.Sign(d: Single): Integer;
begin
  exit Sign(Double(d));
end;

class method Math.Acos(d: Single): Single;
begin
  exit Single(Acos(Double(d)));
end;

class method Math.Asin(d: Single): Single;
begin
  exit Single(Asin(Double(d)));
end;

class method Math.Atan(d: Single): Single;
begin
  exit Single(Atan(Double(d)));
end;

class method Math.Atan2(x,y: Single): Single;
begin
  exit Single(Atan2(Double(x), Double(y)));
end;

class method Math.Ceiling(d: Single): Single;
begin
  exit Single(Ceiling(Double(d)));
end;

class method Math.Cos(d: Single): Single;
begin
  exit Single(Cos(Double(d)));
end;

class method Math.Cosh(d: Single): Single;
begin
  exit Single(Cosh(Double(d)));
end;

class method Math.Exp(d: Single): Single;
begin
  exit Single(Exp(Double(d)));
end;

class method Math.Exp2(d: Single): Single;
begin
  exit Single(Exp2(Double(d)));
end;

class method Math.Floor(d: Single): Single;
begin
  exit Single(Floor(Double(d)));
end;

class method Math.Log(d: Single): Single;
begin
  exit Single(Log(Double(d)));
end;

class method Math.Log2(d: Single): Single;
begin
  exit Single(Log2(Double(d)));
end;

class method Math.Log10(d: Single): Single;
begin
  exit Single(Log10(Double(d)));
end;

class method Math.Pow(x,y: Single): Single;
begin
  exit Single(Pow(Double(x), Double(y)));
end;

class method Math.Round(d: Single): Int64;
begin
  // Preserve the integer-returning RTL API and the existing platform policy.
  exit Round(Double(d));
end;

class method Math.Sin(d: Single): Single;
begin
  exit Single(Sin(Double(d)));
end;

class method Math.Sinh(d: Single): Single;
begin
  exit Single(Sinh(Double(d)));
end;

class method Math.Sqrt(d: Single): Single;
begin
  exit Single(Sqrt(Double(d)));
end;

class method Math.Tan(d: Single): Single;
begin
  exit Single(Tan(Double(d)));
end;

class method Math.Tanh(d: Single): Single;
begin
  exit Single(Tanh(Double(d)));
end;

class method Math.Truncate(d: Single): Single;
begin
  exit Single(Truncate(Double(d)));
end;

class method Math.Exp2(d: Double): Double;
begin
  exit Pow(2.0, d);
end;

class method Math.Log2(d: Double): Double;
begin
  exit Log(d) / Log(2.0);
end;

class method Math.IEEERemainder(x,y: Single): Single;
begin
  exit Single(IEEERemainder(Double(x), Double(y)));
end;

{$ENDIF}

end.
