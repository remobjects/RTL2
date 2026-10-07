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
    class method Max(a,b: Single): Single; mapped to max(a,b);
    class method Max(a,b: Integer): Integer; mapped to max(a,b);
    class method Max(a,b: Int64): Int64; mapped to max(a,b);
    class method Min(a,b: Double): Double; mapped to min(a,b);
    class method Min(a,b: Single): Single; mapped to min(a,b);
    class method Min(a,b: Integer): Integer; mapped to min(a,b);
    class method Min(a,b: Int64): Int64; mapped to min(a,b);
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer;
    class method Sign(d: Single): Integer;
    class method Sin(d: Double): Double; mapped to sin(d);
    class method Sinh(d: Double): Double; mapped to sinh(d);
    class method Sqrt(d: Double): Double; mapped to sqrt(d);
    class method Tan(d: Double): Double; mapped to tan(d);
    class method Tanh(d: Double): Double; mapped to tanh(d);
    class method Truncate(d: Double): Double;
    class method Abs(d: Single): Single; mapped to abs(d);
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
    class method Max(a,b: Single): Single;
    class method Max(a,b: Integer): Integer;
    class method Max(a,b: Int64): Int64;
    class method Min(a,b: Double): Double;
    class method Min(a,b: Single): Single;
    class method Min(a,b: Integer): Integer;
    class method Min(a,b: Int64): Int64;
    class method Pow(x, y: Double): Double;
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer;
    class method Sign(d: Single): Integer;
    class method Sin(x: Double): Double;
    class method Sinh(x: Double): Double;
    class method Sqrt(d: Double): Double;
    class method Tan(d: Double): Double;
    class method Tanh(d: Double): Double;
    class method Truncate(d: Double): Double;
    class method Abs(d: Single): Single;
  end;
  {$ELSEIF ECHOES OR ISLAND}
  Math = public partial class mapped to PlatformMath
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
    class method Max(a,b: Single): Single; mapped to Max(a,b);
    class method Max(a,b: Integer): Integer; mapped to Max(a,b);
    class method Max(a,b: Int64): Int64; mapped to Max(a,b);
    class method Min(a,b: Double): Double; mapped to Min(a,b);
    class method Min(a,b: Single): Single; mapped to Min(a,b);
    class method Min(a,b: Integer): Integer; mapped to Min(a,b);
    class method Min(a,b: Int64): Int64; mapped to Min(a,b);
    class method Pow(x, y: Double): Double; mapped to Pow(x,y);
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer; mapped to Sign(d);
    class method Sign(d: Single): Integer; mapped to Sign(d);
    class method Sin(d: Double): Double; mapped to Sin(d);
    class method Sinh(d: Double): Double; mapped to Sinh(d);
    class method Sqrt(d: Double): Double; mapped to Sqrt(d);
    class method Tan(d: Double): Double; mapped to Tan(d);
    class method Tanh(d: Double): Double; mapped to Tanh(d);
    class method Truncate(d: Double): Double; mapped to Truncate(d);
    {$IF ECHOES}
    class method Abs(d: Single): Single; mapped to Abs(d);
    {$ENDIF}
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
    class method Round(d: Single): Single; mapped to Round(d);
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
    class method Round(d: Single): Single;
    class method Sin(d: Single): Single;
    class method Sinh(d: Single): Single;
    class method Sqrt(d: Single): Single;
    class method Tan(d: Single): Single;
    class method Tanh(d: Single): Single;
    class method Truncate(d: Single): Single;
  end;
  {$ENDIF}

  Math_Extensions = public extension class(Math)
  public

    class method BankersRound(aValue: Double): Int64;
    begin
      //.0 - .4 -> round to zero
      //.6 - .9 -> round away from zero
      //.5 on an even integer part: round away zero
      //.5 on an odd integer part: round to from zero

      var lInteger := Int64(aValue);
      var lDirection := if aValue > 0 then 1 else -1;
      var lEven := (lInteger mod 2) = 0;
      var lLastDigit := Abs(Int64(aValue*10) mod 10);
      result := case lLastDigit of
        0,1,2,3,4: lInteger;
        5: if lEven then lInteger else lInteger+lDirection;
        6,7,8,9: lInteger+lDirection;
      end;
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

  exit Int64(Floor(a + 0.499999999999999999));
end;

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  if (digits < 0) or (digits > 15) then
    raise new ArgumentException("digits must be between 0 and 15");
  var factor := Pow(10.0, -digits);
  if a > 0 then
    result := Truncate((a / factor)+0.5) * factor
  else
    result := Truncate((a / factor)-0.5) * factor
end;


class method Math.Sign(d: Double): Integer;
begin
  if Consts.IsNaN(d) then
    raise new ArgumentException("Value can not be NaN");

  if d > 0 then exit 1;
  if d < 0 then exit -1;
  exit 0;
end;

class method Math.Sign(d: Single): Integer;
begin
  exit Sign(Double(d));
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

class method Math.Sign(d: Single): Integer;
begin
  exit Sign(Double(d));
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

// Preserve the existing NaN and signed-zero behavior of the Double overloads.
class method Math.Max(a,b: Single): Single;
begin
  exit Single(Max(Double(a), Double(b)));
end;

class method Math.Min(a,b: Single): Single;
begin
  exit Single(Min(Double(a), Double(b)));
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

  exit Int64(Floor(a + 0.499999999999999999));
end;

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  if (digits < 0) or (digits > 15) then
    raise new ArgumentException("digits must be between 0 and 15");
  var factor := Pow(10.0, -digits);
  if a > 0 then
    result := Truncate((a / factor)+0.5) * factor
  else
    result := Truncate((a / factor)-0.5) * factor
end;


class method Math.Abs(d: Single): Single;
begin
  exit rtl.fabsf(d);
end;


 {$ELSEIF ECHOES OR ISLAND}
class method Math.Round(a: Double): Int64;
begin
  if Consts.IsNaN(a) or Consts.IsInfinity(a) then
    raise new ArgumentException("Value can not be rounded to Int64");

  exit Int64(Floor(a + 0.499999999999999999));
end;

class method Math.Round(a : Double; digits :  Integer) : Double;
begin
  {$IF ECHOES}
  result := mapped.Round(a, digits);
  exit;
  {$ELSE}
  if (digits < 0) or (digits > 15) then
    raise new ArgumentException("digits must be between 0 and 15");
  var factor := Pow(10.0, -digits);
  if a > 0 then
    result := Truncate((a / factor)+0.5) * factor
  else
    result := Truncate((a / factor)-0.5) * factor
   {$ENDIF}
end;

{$ENDIF}

{$IF COOPER OR ECHOES OR TOFFEE OR ISLAND}
// Prefer the platform's Single API, including its rounding rules and digit limits.
// If it has none, reuse Double rather than maintain a second implementation.
class method Math.Round(a: Single; digits: Integer): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Round) then
    exit System.MathF.Round(a, digits)
  else
    exit Single(Round(Double(a), digits));
  {$ELSE}
  exit Single(Round(Double(a), digits));
  {$ENDIF}
end;
{$ENDIF}

{$IF COOPER OR ECHOES OR TOFFEE}

class method Math.Acos(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Acos) then
    exit System.MathF.Acos(d)
  else
    exit Single(System.Math.Acos(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.acosf(d);
  {$ELSE}
  exit Single(Acos(Double(d)));
  {$ENDIF}
end;

class method Math.Asin(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Asin) then
    exit System.MathF.Asin(d)
  else
    exit Single(System.Math.Asin(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.asinf(d);
  {$ELSE}
  exit Single(Asin(Double(d)));
  {$ENDIF}
end;

class method Math.Atan(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Atan) then
    exit System.MathF.Atan(d)
  else
    exit Single(System.Math.Atan(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.atanf(d);
  {$ELSE}
  exit Single(Atan(Double(d)));
  {$ENDIF}
end;

class method Math.Atan2(x,y: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Atan2) then
    exit System.MathF.Atan2(x, y)
  else
    exit Single(Atan2(Double(x), Double(y)));
  {$ELSEIF TOFFEE}
  exit rtl.atan2f(x, y);
  {$ELSE}
  exit Single(Atan2(Double(x), Double(y)));
  {$ENDIF}
end;

class method Math.Ceiling(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Ceiling) then
    exit System.MathF.Ceiling(d)
  else
    exit Single(System.Math.Ceiling(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.ceilf(d);
  {$ELSE}
  exit Single(Ceiling(Double(d)));
  {$ENDIF}
end;

class method Math.Cos(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Cos) then
    exit System.MathF.Cos(d)
  else
    exit Single(System.Math.Cos(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.cosf(d);
  {$ELSE}
  exit Single(Cos(Double(d)));
  {$ENDIF}
end;

class method Math.Cosh(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Cosh) then
    exit System.MathF.Cosh(d)
  else
    exit Single(System.Math.Cosh(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.coshf(d);
  {$ELSE}
  exit Single(Cosh(Double(d)));
  {$ENDIF}
end;

class method Math.Exp(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Exp) then
    exit System.MathF.Exp(d)
  else
    exit Single(System.Math.Exp(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.expf(d);
  {$ELSE}
  exit Single(Exp(Double(d)));
  {$ENDIF}
end;

class method Math.Exp2(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Exp2) then
    exit System.MathF.Exp2(d)
  else
    exit Single(Exp2(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.exp2f(d);
  {$ELSE}
  exit Single(Exp2(Double(d)));
  {$ENDIF}
end;

class method Math.Floor(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Floor) then
    exit System.MathF.Floor(d)
  else
    exit Single(System.Math.Floor(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.floorf(d);
  {$ELSE}
  exit Single(Floor(Double(d)));
  {$ENDIF}
end;

class method Math.Log(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Log) then
    exit System.MathF.Log(d)
  else
    exit Single(System.Math.Log(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.logf(d);
  {$ELSE}
  exit Single(Log(Double(d)));
  {$ENDIF}
end;

class method Math.Log2(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Log2) then
    exit System.MathF.Log2(d)
  else
    exit Single(Log2(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.log2f(d);
  {$ELSE}
  exit Single(Log2(Double(d)));
  {$ENDIF}
end;

class method Math.Log10(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Log10) then
    exit System.MathF.Log10(d)
  else
    exit Single(System.Math.Log10(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.log10f(d);
  {$ELSE}
  exit Single(Log10(Double(d)));
  {$ENDIF}
end;

class method Math.Pow(x,y: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Pow) then
    exit System.MathF.Pow(x, y)
  else
    exit Single(Pow(Double(x), Double(y)));
  {$ELSEIF TOFFEE}
  exit rtl.powf(x, y);
  {$ELSE}
  exit Single(Pow(Double(x), Double(y)));
  {$ENDIF}
end;

class method Math.Round(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Round) then
    exit System.MathF.Round(d)
  else
    exit Single(System.Math.Round(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.roundf(d);
  {$ELSE}
  exit Single(Round(Double(d), 0));
  {$ENDIF}
end;

class method Math.Sin(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Sin) then
    exit System.MathF.Sin(d)
  else
    exit Single(System.Math.Sin(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.sinf(d);
  {$ELSE}
  exit Single(Sin(Double(d)));
  {$ENDIF}
end;

class method Math.Sinh(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Sinh) then
    exit System.MathF.Sinh(d)
  else
    exit Single(System.Math.Sinh(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.sinhf(d);
  {$ELSE}
  exit Single(Sinh(Double(d)));
  {$ENDIF}
end;

class method Math.Sqrt(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Sqrt) then
    exit System.MathF.Sqrt(d)
  else
    exit Single(System.Math.Sqrt(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.sqrtf(d);
  {$ELSE}
  exit Single(Sqrt(Double(d)));
  {$ENDIF}
end;

class method Math.Tan(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Tan) then
    exit System.MathF.Tan(d)
  else
    exit Single(System.Math.Tan(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.tanf(d);
  {$ELSE}
  exit Single(Tan(Double(d)));
  {$ENDIF}
end;

class method Math.Tanh(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Tanh) then
    exit System.MathF.Tanh(d)
  else
    exit Single(System.Math.Tanh(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.tanhf(d);
  {$ELSE}
  exit Single(Tanh(Double(d)));
  {$ENDIF}
end;

class method Math.Truncate(d: Single): Single;
begin
  {$IF ECHOES}
  if exists(System.MathF.Truncate) then
    exit System.MathF.Truncate(d)
  else
    exit Single(System.Math.Truncate(Double(d)));
  {$ELSEIF TOFFEE}
  exit rtl.truncf(d);
  {$ELSE}
  exit Single(Truncate(Double(d)));
  {$ENDIF}
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
  {$IF ECHOES}
  if exists(System.MathF.IEEERemainder) then
    exit System.MathF.IEEERemainder(x, y)
  else
    exit Single(IEEERemainder(Double(x), Double(y)));
  {$ELSEIF TOFFEE}
  exit rtl.remainderf(x, y);
  {$ELSE}
  exit Single(IEEERemainder(Double(x), Double(y)));
  {$ENDIF}
end;

{$ENDIF}

end.