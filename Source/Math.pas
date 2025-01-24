﻿namespace RemObjects.Elements.RTL;

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
    class method Log(d: Double): Double; mapped to Log(d);
    class method Log10(d: Double): Double; mapped to Log10(d);
    class method Max(a,b: Double): Double; mapped to Max(a,b);
    class method Max(a,b: Integer): Integer; mapped to Max(a,b);
    class method Max(a,b: Int64): Int64; mapped to Max(a,b);
    class method Min(a,b: Double): Double; mapped to Min(a,b);
    class method Min(a,b: Integer): Integer; mapped to Min(a,b);
    class method Min(a,b: Int64): Int64; mapped to Min(a,b);
    class method Pow(x, y: Double): Double; mapped to Pow(x,y);
    class method Round(a: Double): Int64;
    class method Round(a : Double; digits :  Integer) : Double;
    class method Sign(d: Double): Integer; mapped to Sign(d);
    class method Sin(d: Double): Double; mapped to Sin(d);
    class method Sinh(d: Double): Double; mapped to Sinh(d);
    class method Sqrt(d: Double): Double; mapped to Sqrt(d);
    class method Tan(d: Double): Double; mapped to Tan(d);
    class method Tanh(d: Double): Double; mapped to Tanh(d);
    class method Truncate(d: Double): Double; mapped to Truncate(d);
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
      {$ELSEIF ECHOES}
      exit Double.IsNaN(Value);
      {$ELSEIF TOFFEE}
      exit __inline_isnand(Value) <> 0;
      {$ENDIF}
    end;

    class method IsInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Double.isInfinite(Value);
      {$ELSEIF ECHOES}
      exit Double.IsInfinity(Value);
      {$ELSEIF TOFFEE}
      exit __inline_isinfd(Value) <> 0;
      {$ENDIF}
    end;

    class method IsNegativeInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Value = NegativeInfinity;
      {$ELSEIF ECHOES}
      exit Double.IsNegativeInfinity(Value);
      {$ELSEIF TOFFEE}
      exit (Value = NegativeInfinity) and (not Consts.IsNaN(Value));
      {$ENDIF}
    end;

    class method IsPositiveInfinity(Value: Double): Boolean;
    begin
      {$IF COOPER}
      exit Value = PositiveInfinity;
      {$ELSEIF ECHOES}
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

end.