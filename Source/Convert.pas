namespace RemObjects.Elements.RTL;

interface

type
  Convert = public static class
  private
    {$IF TOFFEE}
    method TryParseNumber(aValue: not nullable String; aLocale: Locale := nil): NSNumber;
    method TryParseInt32(aValue: not nullable String): nullable Int32;
    method TryParseInt64(aValue: not nullable String): nullable Int64;
    method ParseInt32(aValue: not nullable String): Int32;
    method ParseInt64(aValue: not nullable String): Int64;

    property fCachedInvariantNumberFormatters := new Dictionary<Integer,NSNumberFormatter>; lazy;
    property fCachedCurrentNumberFormatters := new Dictionary<Integer,NSNumberFormatter>; lazy;
    {$ENDIF}

    method TrimLeadingZeros(aValue: not nullable String): not nullable String; inline;
    method DigitForValue(aValue: Int32): Char; inline;
  public
    method ToString(aValue: Boolean): not nullable String;
    method ToString(aValue: Byte; aBase: Integer := 10): not nullable String;
    method ToString(aValue: Int32; aBase: Integer := 10): not nullable String;
    method ToString(aValue: Int64; aBase: Integer := 10): not nullable String;
    {$IF NOT COOPER}
    method ToString(aValue: UInt64; aBase: Integer := 10): not nullable String; // 76887: Cooper: load error with RTL2
    {$ENDIF}
    method ToString(aValue: Double; aDigitsAfterDecimalPoint: Integer := -1; aMinWidth: Integer := 0; aLocale: Locale := nil): not nullable String;
    method ToStringInvariant(aValue: Double; aDigitsAfterDecimalPoint: Integer := -1; aMinWidth: Integer := 0): not nullable String;
    method ToString(aValue: Char): not nullable String;
    method ToString(aValue: Object): not nullable String;

    method ToInt32(aValue: Boolean): Int32;
    method ToInt32(aValue: Byte): Int32;
    method ToInt32(aValue: Int64): Int32;
    method ToInt32(aValue: Double): Int32;
    method ToInt32(aValue: Char): Int32;
    method ToInt32(aValue: not nullable String): Int32;
    method TryToInt32(aValue: nullable String): nullable Int32;

    method ToInt64(aValue: Boolean): Int64;
    method ToInt64(aValue: Byte): Int64;
    method ToInt64(aValue: Int32): Int64;
    method ToInt64(aValue: Double): Int64;
    method ToInt64(aValue: Char): Int64;
    method ToInt64(aValue: not nullable String): Int64;
    method TryToInt64(aValue: nullable String): nullable Int64;

    method ToDouble(aValue: Boolean): Double;
    method ToDouble(aValue: Byte): Double;
    method ToDouble(aValue: Int32): Double;
    method ToDouble(aValue: Int64): Double;
    method TryToDouble(aValue: nullable String; aLocale: Locale := Locale.Current): nullable Double;
    method TryToDoubleInvariant(aValue: nullable String): nullable Double; inline;
    method ToDouble(aValue: not nullable String; aLocale: Locale := Locale.Current): Double;
    method ToDoubleInvariant(aValue: not nullable String): Double; inline;

    method MilisecondsToTimeString(aMS: Double): String;

    method ToByte(aValue: Boolean): Byte;
    method ToByte(aValue: Double): Byte;
    method ToByte(aValue: Int32): Byte;
    method ToByte(aValue: Int64): Byte;
    method ToByte(aValue: Char): Byte;
    method ToByte(aValue: not nullable String): Byte;

    method ToChar(aValue: Boolean): Char;
    method ToChar(aValue: Int32): Char; inline;
    method ToChar(aValue: Int64): Char;
    method ToChar(aValue: Byte): Char; inline;
    method ToChar(aValue: not nullable String): Char;

    method ToBoolean(aValue: Double): Boolean;
    method ToBoolean(aValue: Int32): Boolean;
    method ToBoolean(aValue: Int64): Boolean;
    method ToBoolean(aValue: Byte): Boolean;
    method ToBoolean(aValue: not nullable String): Boolean;

    method ToUtf8Bytes(aValue: not nullable String): array of Byte; inline;
    method Utf8BytesToString(aBytes: array of Byte; aLength: nullable Int32 := nil): String; inline;// aLength breaks when inlined (macOS).

    //method ToHexString(aValue: Int32; aWidth: Integer := 0): not nullable String;
    method ToHexString(aValue: UInt64; aWidth: Integer := 0): not nullable String;
    method ToHexString(aData: array of Byte; aOffset: Integer; aCount: Integer): not nullable String;
    method ToHexString(aData: array of Byte; aCount: Integer): not nullable String;
    method ToHexString(aData: array of Byte): not nullable String;
    method ToHexString(aData: ImmutableBinary): not nullable String;

    method ToOctalString(aValue: UInt64; aWidth: Integer := 0): not nullable String;
    method ToBinaryString(aValue: UInt64; aWidth: Integer := 0): not nullable String;

    method HexStringToUInt32(aValue: not nullable String): UInt32;
    method HexStringToUInt64(aValue: not nullable String): UInt64;
    method TryHexStringToUInt32(aValue: not nullable String): nullable UInt32;
    method TryHexStringToUInt64(aValue: not nullable String): nullable UInt64;
    method HexStringToByteArray(aData: not nullable String): array of Byte;
    method TryBinaryStringToUInt64(aValue: nullable String): nullable UInt64;

    method ToBase64String(S: array of Byte): not nullable String; inline;
    method ToBase64String(S: array of Byte; aStartIndex: Int32; aLength: Int32): not nullable String;
    method Base64StringToByteArray(S: String): array of Byte;
  end;

implementation

method Convert.ToString(aValue: Boolean): not nullable String;
begin
  result := if aValue then Consts.TrueString else Consts.FalseString;
end;

method Convert.ToString(aValue: Byte; aBase: Integer := 10): not nullable String;
begin
  case aBase of
    2: result := ToBinaryString(aValue);
    8: result := ToOctalString(aValue);
    10: result := aValue.ToString as String as not nullable;
    16: result := ToHexString(aValue);
    else raise new ConversionException('Unsupported base for ToString.');
  end;
end;

method Convert.ToString(aValue: Int32; aBase: Integer := 10): not nullable String;
begin
  case aBase of
    2: result := ToBinaryString(aValue);
    8: result := ToOctalString(aValue);
    10: result := aValue.ToString as String as not nullable;
    16: result := ToHexString(aValue);
    else raise new ConversionException('Unsupported base for ToString.');
  end;
end;

method Convert.ToString(aValue: Int64; aBase: Integer := 10): not nullable String;
begin
  case aBase of
    2: result := ToBinaryString(aValue);
    8: result := ToOctalString(aValue);
    10: result := aValue.ToString as String as not nullable;
    16: result := ToHexString(aValue);
    else raise new ConversionException('Unsupported base for ToString.');
  end;
end;

{$IF NOT COOPER}
method Convert.ToString(aValue: UInt64; aBase: Integer := 10): not nullable String;
begin
  case aBase of
    2: result := ToBinaryString(aValue);
    8: result := ToOctalString(aValue);
    10: result := aValue.ToString as String as not nullable;
    16: result := ToHexString(aValue);
    else raise new ConversionException('Unsupported base for ToString.');
  end;
end;
{$ENDIF}

method Convert.ToStringInvariant(aValue: Double; aDigitsAfterDecimalPoint: Integer := -1; aMinWidth: Integer := 0): not nullable String;
begin
  result := ToString(aValue, aDigitsAfterDecimalPoint, aMinWidth, Locale.Invariant);
end;

method Convert.ToString(aValue: Double; aDigitsAfterDecimalPoint: Integer := -1; aMinWidth: Integer := 0; aLocale: Locale := nil): not nullable String;
begin
  if Consts.IsNegativeInfinity(aValue) then
    exit "-Infinity";

  if Consts.IsPositiveInfinity(aValue) then
    exit "Infinity";

  if Consts.IsNaN(aValue) then
    exit "NaN";

  {$IF COOPER}
  if aLocale = nil then aLocale := Locale.Current;
  var DecFormat := java.text.DecimalFormat(java.text.DecimalFormat.getInstance(aLocale));
  var FloatPattern := if aDigitsAfterDecimalPoint < 0 then "#.###############" else if aDigitsAfterDecimalPoint = 0 then "0" else "0."+new String('0', aDigitsAfterDecimalPoint);
  DecFormat.applyPattern(FloatPattern);
  result := DecFormat.format(aValue) as not nullable;
  {$ELSEIF TOFFEE}

  var numberFormatter: NSNumberFormatter;

  method SetupNumberFormatter;
  begin
    numberFormatter.numberStyle := NSNumberFormatterStyle.DecimalStyle;
    numberFormatter.usesSignificantDigits := false;
    if aDigitsAfterDecimalPoint ≥ 0 then begin
      numberFormatter.maximumFractionDigits := aDigitsAfterDecimalPoint;
      numberFormatter.minimumFractionDigits := aDigitsAfterDecimalPoint;
    end
    else begin
      numberFormatter.maximumFractionDigits := 20;
      numberFormatter.minimumFractionDigits := 0;
    end;
  end;

  if aLocale = nil then begin
    numberFormatter := fCachedCurrentNumberFormatters[aDigitsAfterDecimalPoint];
    if not assigned(numberFormatter) then begin
      numberFormatter := new NSNumberFormatter();
      SetupNumberFormatter();
      numberFormatter.locale := Locale.Current;
      fCachedCurrentNumberFormatters[aDigitsAfterDecimalPoint] := numberFormatter;
    end;
  end
  else if aLocale = Locale.Invariant then begin
    numberFormatter := fCachedInvariantNumberFormatters[aDigitsAfterDecimalPoint];
    if not assigned(numberFormatter) then begin
      numberFormatter := new NSNumberFormatter();
      SetupNumberFormatter();
      numberFormatter.locale := Locale.Invariant;
      numberFormatter.usesGroupingSeparator := false; // only for invariant
      fCachedCurrentNumberFormatters[aDigitsAfterDecimalPoint] := numberFormatter;
    end;
  end
  else begin
    numberFormatter := new NSNumberFormatter();
    SetupNumberFormatter();
  end;

  result := numberFormatter.stringFromNumber(aValue) as not nullable;
  {$ELSEIF ECHOES}
  if aLocale = nil then aLocale := Locale.Current;
  if aDigitsAfterDecimalPoint < 0 then
    result := System.Convert.ToString(aValue, aLocale) as not nullable
  else
    result := aValue.ToString("0."+new String('0', aDigitsAfterDecimalPoint), aLocale) as not nullable
  {$ELSEIF ISLAND}
  if aLocale = nil then aLocale := Locale.Current;
  if aDigitsAfterDecimalPoint < 0 then
    result := aValue.ToString(aLocale) as not nullable
  else
    result := aValue.ToString(aDigitsAfterDecimalPoint, aLocale) as not nullable
  {$ENDIF}

  if aMinWidth > 0 then
    result := result.PadStart(aMinWidth, ' ')
  else if aMinWidth > 0 then
    result := result.PadEnd(aMinWidth, ' ');
end;

method Convert.ToString(aValue: Char): not nullable String;
begin
  //74584: Two more bogus nullable warnings
  result := String(aValue);
end;

method Convert.ToString(aValue: Object): not nullable String;
begin
  //74584: Two more bogus nullable warnings
  result := coalesce(aValue:ToString, '');
end;

method Convert.ToInt32(aValue: Boolean): Int32;
begin
  result := if aValue then 1 else 0;
end;

method Convert.ToInt32(aValue: Byte): Int32;
begin
  result := Int32(aValue);
end;

method Convert.ToInt32(aValue: Int64): Int32;
begin
  if (aValue > Consts.MaxInt32) or (aValue < Consts.MinInt32) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Int32");

  result := Int32(aValue);
end;

method Convert.ToInt32(aValue: Double): Int32;
begin
  var Number := Math.Round(aValue);

  if (Number > Consts.MaxInt32) or (Number < Consts.MinInt32) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Int32");

  exit Int32(Number);
end;

method Convert.ToInt32(aValue: Char): Int32;
begin
  result := ord(aValue);
end;

method Convert.ToInt32(aValue: not nullable String): Int32;
begin
  {$IF COOPER}
  exit Integer.parseInt(aValue);
  {$ELSEIF TOFFEE}
  exit ParseInt32(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  for i: Int32 := 0 to length(aValue)-1 do
    if Char.IsWhiteSpace(aValue[i]) then // TryParse ignores whitespace, we wanna fail
      raise new FormatException("Unable to convert string '{0}' to Int32.", aValue);
  exit Int32.Parse(aValue);
  {$ENDIF}
end;

method Convert.TryToInt32(aValue: nullable String): nullable Int32;
begin
  if length(aValue) = 0 then
    exit nil;

  {$IF COOPER}
  try
    exit Integer.parseInt(aValue);
  except
    on E: NumberFormatException do
      exit nil;
  end;
  {$ELSEIF TOFFEE}
  exit TryParseInt32(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  for i: Int32 := 0 to length(aValue)-1 do
    if Char.IsWhiteSpace(aValue[i]) then // TryParse ignores whitespace, we wanna fail
      exit nil;
  var lResult: Int32;
  if Int32.TryParse(aValue, out lResult) then
    exit lResult
  else
    exit nil;
  {$ENDIF}
end;

method Convert.DigitForValue(aValue: Int32): Char;
begin
  result := chr(55 + aValue + (((aValue - 10) shr 31) and -7)); // don't ask me how this works but it does.
end;

method Convert.TrimLeadingZeros(aValue: not nullable String): not nullable String;
begin
  for i: Int32 := 0 to length(aValue)-1 do
    if aValue[i] ≠ '0' then exit aValue.Substring(i);
  exit "";
end;

method Convert.ToHexString(aValue: UInt64; aWidth: Integer := 0): not nullable String;
begin
  var lWidth := aWidth;
  if (lWidth < 1) or (lWidth > 64/4) then lWidth := 64/4;
  result := '';
  for i: Integer := lWidth-1 downto 0 do
    result := result + DigitForValue(aValue shr (i*4) and $0f);
  if aWidth = 0 then
    result := TrimLeadingZeros(result);
  if length(result) = 0 then
    result := "0";
end;

method Convert.ToOctalString(aValue: UInt64; aWidth: Integer := 0): not nullable String;
begin
  var lWidth := aWidth;
  if (lWidth < 1) or (lWidth > 64/3) then lWidth := 64/3;
  result := '';
  for i: Integer := lWidth-1 downto 0 do
    result := result + DigitForValue(aValue shr (i*3) and $07);
  if aWidth = 0 then
    result := TrimLeadingZeros(result);
  if length(result) = 0 then
    result := "0";
end;

method Convert.ToBinaryString(aValue: UInt64; aWidth: Integer := 0): not nullable String;
begin
  var lWidth := aWidth;
  if (lWidth < 1) or (lWidth > 64) then lWidth := 64;
  result := '';
  for i: Integer := lWidth-1 downto 0 do
    result := result + DigitForValue(aValue shr i and $01);
  if aWidth = 0 then
    result := TrimLeadingZeros(result);
  if length(result) = 0 then
    result := "0";
end;

method Convert.ToHexString(aData: array of Byte; aOffset: Integer; aCount: Integer): not nullable String;
begin
  if (length(aData) = 0) or (aCount = 0) then
    exit '';

  RangeHelper.Validate(new Range(aOffset, aCount), aData.Length);

  var Chars := new Char[aCount * 2];
  var Num: Integer;

  for i: Integer := 0 to aCount - 1 do begin
    Num := aData[aOffset + i] shr 4;
    Chars[i * 2] := chr(55 + Num + (((Num - 10) shr 31) and -7));
    Num := aData[aOffset + i] and $F;
    Chars[i * 2 + 1] := chr(55 + Num + (((Num - 10) shr 31) and -7));
  end;

  exit new String(Chars);
end;

method Convert.ToHexString(aData: array of Byte; aCount: Integer): not nullable String;
begin
  result := ToHexString(aData, 0, aCount);
end;

method Convert.ToHexString(aData: array of Byte): not nullable String;
begin
  result := ToHexString(aData, 0, length(aData));
end;

method Convert.ToHexString(aData: ImmutableBinary): not nullable String;
begin
  result := ToHexString(aData.ToArray())
end;

method Convert.HexStringToByteArray(aData: not nullable String): array of Byte;

  method HexValue(C: Char): Integer;
  begin
    var Value := ord(C);
    result := Value - (if Value < 58 then 48 else if Value < 97 then 55 else 87);

    if (result > 15) or (result < 0) then
      raise new FormatException("{0}. Invalid character: [{1}]", RTLErrorMessages.FORMAT_ERROR, C);
  end;

begin
  if length(aData) = 0 then
    exit [];

  if aData.Length mod 2 = 1 then
    raise new FormatException("{0}. {1}", RTLErrorMessages.FORMAT_ERROR, "Hex string can not have odd number of chars.");

  result := new Byte[aData.Length shr 1];

  for i: Integer := 0 to result.Length - 1 do
    result[i] := Byte((HexValue(aData[i shl 1]) shl 4) + HexValue(aData[(i shl 1) + 1]));
end;

method Convert.HexStringToUInt32(aValue: not nullable String): UInt32;
begin
  {$IF COOPER}
  result := Integer.parseInt(aValue, 16);
  {$ELSEIF ECHOES}
  result := Int32.Parse(aValue, System.Globalization.NumberStyles.HexNumber);
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.Convert.HexStringToUInt64(aValue) as Int32;
  {$ELSEIF TOFFEE}
  var lScanner: NSScanner := NSScanner.scannerWithString(aValue);
  lScanner.scanHexInt(var result);
  {$ENDIF}
end;

method Convert.HexStringToUInt64(aValue: not nullable String): UInt64;
begin
  {$IF COOPER}
  result := Long.parseLong(aValue, 16);
  {$ELSEIF ECHOES}
  result := Int64.Parse(aValue, System.Globalization.NumberStyles.HexNumber);
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.Convert.HexStringToUInt64(aValue);
  {$ELSEIF TOFFEE}
  var lScanner: NSScanner := NSScanner.scannerWithString(aValue);
  lScanner.scanHexLongLong(var result);
  {$ENDIF}
end;

method Convert.TryHexStringToUInt32(aValue: not nullable String): nullable UInt32;
begin
  {$IF COOPER}
  try
    result := Integer.parseInt(aValue, 16);
  except
    on E: NumberFormatException do;
  end;
  {$ELSEIF ECHOES}
  if Int32.TryParse(aValue, System.Globalization.NumberStyles.HexNumber, System.Globalization.CultureInfo.InvariantCulture, out var lValue) then
    result := lValue
  {$ELSEIF ISLAND}
  if RemObjects.Elements.System.Convert.TryHexStringToUInt64(aValue, out var lValue) then
    result := lValue as Int32;
  {$ELSEIF TOFFEE}
  var lScanner: NSScanner := NSScanner.scannerWithString(aValue);
  var lValue: UInt32;
  if lScanner.scanHexInt(var lValue) then
    result := lValue;
  {$ENDIF}
end;

method Convert.TryHexStringToUInt64(aValue: not nullable String): nullable UInt64;
begin
  {$IF COOPER}
  try
    result := Long.parseLong(aValue, 16);
  except
    on E: NumberFormatException do;
  end;
  {$ELSEIF ECHOES}
    if Int64.TryParse(aValue, System.Globalization.NumberStyles.HexNumber, System.Globalization.CultureInfo.InvariantCulture, out var lValue) then
    result := lValue
  {$ELSEIF ISLAND}
  if RemObjects.Elements.System.Convert.TryHexStringToUInt64(aValue, out var lValue) then
    result := lValue;
  {$ELSEIF TOFFEE}
  var lScanner: NSScanner := NSScanner.scannerWithString(aValue);
  var lValue: UInt64;
  if lScanner.scanHexLongLong(var lValue) then
    result := lValue;
  {$ENDIF}
end;

method Convert.TryBinaryStringToUInt64(aValue: nullable String): nullable UInt64;
begin
  aValue := aValue:Trim;
  var len := length(aValue);
  if 0 < len ≤ 64 then begin
    var lResult: UInt64 := 0;
    var lDigits: array of Char := aValue.ToCharArray();
    for i: Integer := len-1 downto 0 do begin
      case lDigits[i] of
        '0':;
        '1': lResult := lResult + (1 shl (len-i-1));
        else exit nil;
      end;
    end;
    result := lResult;
  end;
end;

method Convert.ToBase64String(S: array of Byte): not nullable String;
begin
  result := ToBase64String(S, 0, length(S));
end;

method Convert.ToBase64String(S: array of Byte; aStartIndex: Int32; aLength: Int32): not nullable String;
  const Codes64: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
begin
  var sb := new StringBuilder();
  var a: Int32 := 0;
  var b: Int32 := 0;
  var x: Byte;
  for i: Int32 := aStartIndex to (aStartIndex + aLength) - 1 do begin
    x := S[i];
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      sb.Append(Codes64[x]);
    end;
  end;

  if a > 0 then begin
    x := b shl (6 - a);
    sb.Append(Codes64[x]);
  end;
  var lRemainder := sb.Length mod 4;
  if lRemainder > 0 then
    sb.Append('=', (4-lRemainder));
  result := sb.ToString as not nullable;
end;

method convert.Base64StringToByteArray(S: String): array of Byte;
  const Codes64: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
begin
  var a := 0;
  var b := 0;
  var x: Int32;
  var lIndex := 0;
  var lTmp := new Byte[S.Length];
  for i: Int32 := 0 to S.Length - 1 do begin
    x := Codes64.IndexOf(S[i]);
    if x >= 0 then begin
      b := b * 64 + x;
      a := a + 6;
      if a >= 8 then begin
        a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        lTmp[lIndex] := x;
        inc(lIndex);
      end;
    end
    else
      exit nil;
  end;

  result := new Byte[lIndex];
  for j: Int32 := 0 to lIndex - 1 do
    result[j] := lTmp[j];
end;


method Convert.ToInt64(aValue: Boolean): Int64;
begin
  result := if aValue then 1 else 0;
end;

method Convert.ToInt64(aValue: Byte): Int64;
begin
  result := Int64(aValue);
end;

method Convert.ToInt64(aValue: Int32): Int64;
begin
  result := Int64(aValue);
end;

method Convert.ToInt64(aValue: Double): Int64;
begin
  if (aValue > Consts.MaxInt64) or (aValue < Consts.MinInt64) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Int64");

  exit Math.Round(aValue);
end;

method Convert.ToInt64(aValue: Char): Int64;
begin
  exit ord(aValue);
end;

method Convert.ToInt64(aValue: not nullable String): Int64;
begin
  if String.IsNullOrWhiteSpace(aValue) then
    raise new FormatException("Unable to convert string '{0}' to int64.", aValue);

  {$IF COOPER}
  exit Long.parseLong(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  for i: Int32 := 0 to length(aValue)-1 do
    if Char.IsWhiteSpace(aValue[i]) then // TryParse ignores whitespace, we wanna fail
      raise new FormatException("Unable to convert string '{0}' to Int64.", aValue);
  exit Int64.Parse(aValue);
  {$ELSEIF TOFFEE}
  exit ParseInt64(aValue);
  {$ENDIF}
end;

method Convert.TryToInt64(aValue: nullable String): nullable Int64;
begin
  if length(aValue) = 0 then
    exit nil;

  {$IF COOPER}
  try
    exit Long.parseLong(aValue);
  except
    on E: NumberFormatException do
      exit nil;
  end;
  {$ELSEIF ECHOES OR ISLAND}
  for i: Int32 := 0 to length(aValue)-1 do
    if Char.IsWhiteSpace(aValue[i]) then // TryParse ignores whitespace, we wanna fail
      exit nil;
  var lResult: Int64;
  if Int64.TryParse(aValue, out lResult) then
    exit lResult
  else
    exit nil;
  {$ELSEIF TOFFEE}
  exit TryParseInt64(aValue);
  {$ENDIF}
end;

method Convert.ToDouble(aValue: Boolean): Double;
begin
  result := if aValue then 1 else 0;
end;

method Convert.ToDouble(aValue: Byte): Double;
begin
  result := Double(aValue);
end;

method Convert.ToDouble(aValue: Int32): Double;
begin
  result := Double(aValue);
end;

method Convert.ToDouble(aValue: Int64): Double;
begin
  result := Double(aValue);
end;

method Convert.ToDoubleInvariant(aValue: not nullable String): Double;
begin
  result := ToDouble(aValue, Locale.Invariant);
end;

method Convert.TryToDoubleInvariant(aValue: nullable String): nullable Double;
begin
  result := TryToDouble(aValue, Locale.Invariant);
end;

method Convert.ToDouble(aValue: not nullable String; aLocale: Locale): Double;
begin
  var lResult := TryToDouble(aValue, aLocale);
  if assigned(lResult) then
    result := lResult
  else
    raise new FormatException(String.Format("Invalid double value '{0}' for locale {1}", aValue, aLocale.Identifier));
end;

method Convert.TryToDouble(aValue: nullable String; aLocale: Locale): nullable Double;
begin
  if String.IsNullOrWhiteSpace(aValue) then
    exit nil;

  {$IF COOPER}
  var DecFormat: java.text.DecimalFormat := java.text.DecimalFormat(java.text.DecimalFormat.getInstance(aLocale));
  var Position := new java.text.ParsePosition(0);
  aValue := aValue.Trim.ToUpper;
  // E+ is not accepted, just E or E-
  aValue := aValue.Replace('E+', 'E');
  {$IF ANDROID}
  if aValue.Length > 1 then begin
    var DecimalIndex := aValue.IndexOf(".");
    if DecimalIndex = -1 then
      DecimalIndex := aValue.Length;

    aValue := aValue[0] + aValue.Substring(1, DecimalIndex - 1).Replace(",", "") + aValue.Substring(DecimalIndex);
  end;
  {$ENDIF}

  if aValue.StartsWith("+") then aValue := aValue.Substring(1);
  result := DecFormat.parse(aValue, Position):doubleValue;

  if Position.Index < aValue.Length then
    exit nil;

  if Consts.IsInfinity(result) or Consts.IsNaN(result) then
    exit nil;
  {$ELSEIF TOFFEE}
  var Number := TryParseNumber(aValue, aLocale);
  exit Number:doubleValue;
  {$ELSEIF ECHOES}
  var lResult: Double;
  if Double.TryParse(aValue, System.Globalization.NumberStyles.Any, aLocale, out lResult) then
    exit valueOrDefault(lResult);
  {$ELSEIF ISLAND}
  var lResult: Double;
  if Double.TryParse(aValue, aLocale, out lResult) then
    exit valueOrDefault(lResult);
  {$ENDIF}
end;

method Convert.MilisecondsToTimeString(aMS: Double): String;
begin
  var lValue := aMS as Int64;
  var lMilliSeconds := lValue mod 1000;
  var lSeconds := lValue div 1000;
  var lMinutes := lSeconds div 60;
  lSeconds := lSeconds mod 60;
  var lHours := lMinutes div 60;
  lMinutes := lMinutes mod 60;
  result := "";
  if lHours > 0 then
    result := result+lHours.ToString+":";
  if lMinutes > 0 then begin
    var lMinutesString := if length(result) > 0 then Convert.ToString(lMinutes).PadStart(2, '0') else lMinutes.ToString;
    result := result+lMinutesString+":";
  end;
  var lSecondsString := if length(result) > 0 then Convert.ToString(lSeconds).PadStart(2, '0') else lSeconds.ToString;
  result := result+lSecondsString+".";
  result := result+Convert.ToString(lMilliSeconds).PadStart(3, '0');
end;

//
//
//

method Convert.ToByte(aValue: Boolean): Byte;
begin
  result := if aValue then 1 else 0;
end;

method Convert.ToByte(aValue: Double): Byte;
begin
  var Number := Math.Round(aValue);

  if (Number > 255) or (Number < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Byte");

  exit Byte(Number);
end;

method Convert.ToByte(aValue: Int32): Byte;
begin
  if (aValue > 255) or (aValue < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Byte");

  exit Byte(aValue);
end;

method Convert.ToByte(aValue: Int64): Byte;
begin
  if (aValue > 255) or (aValue < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Byte");

  exit Byte(aValue);
end;

method Convert.ToByte(aValue: Char): Byte;
begin
  var Number := Convert.ToInt32(aValue);
  if (Number > 255) or (Number < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Byte");

  result := ord(aValue);
end;

method Convert.ToByte(aValue: not nullable String): Byte;
begin
  if aValue = nil then
    exit 0;

  if String.IsNullOrWhiteSpace(aValue) then
    raise new FormatException("Unable to convert string '{0}' to byte.", aValue);

  {$IF COOPER}
  exit Byte.parseByte(aValue);
  {$ELSEIF ECHOES}
  exit System.Convert.ToByte(aValue);
  {$ELSEIF ISLAND}
  var lNumber: Int64;
  if not RemObjects.Elements.System.Convert.TryParseInt64(aValue, out lNumber, true) then
    raise new FormatException("Unable to convert string '{0}' to byte.", aValue);
  exit ToByte(lNumber);
  {$ELSEIF TOFFEE}
  var Number: Int32 := ParseInt32(aValue);
  exit ToByte(Number);
  {$ENDIF}
end;

method Convert.ToChar(aValue: Boolean): Char;
begin
  result := ToChar(ToInt32(aValue));
end;

method Convert.ToChar(aValue: Int32): Char;
begin
  if (aValue > Consts.MaxChar) or (aValue < Consts.MinChar) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Char");

  result := chr(aValue);
end;

method Convert.ToChar(aValue: Int64): Char;
begin
  if (aValue < 0) and (aValue ≥ -32768) then
    exit char(Int32(aValue)); // Values from -32768 through -1 are treated the same as values in the range +32768 through +65535.

  if (aValue > Consts.MaxChar) or (aValue < Consts.MinChar) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.TYPE_RANGE_ERROR, "Char");

  result := chr(aValue);
end;

method Convert.ToChar(aValue: Byte): Char;
begin
  result := chr(aValue);
end;

method Convert.ToChar(aValue: not nullable String): Char;
begin
  ArgumentNullException.RaiseIfNil(aValue, "aValue");

  if aValue.Length <> 1 then
    raise new FormatException("Unable to convert string '{0}' to char.", aValue);

  exit aValue[0];
end;

method Convert.ToBoolean(aValue: Double): Boolean;
begin
  exit if aValue = 0 then false else true;
end;

method Convert.ToBoolean(aValue: Int32): Boolean;
begin
  exit if aValue = 0 then false else true;
end;

method Convert.ToBoolean(aValue: Int64): Boolean;
begin
  exit if aValue = 0 then false else true;
end;

method Convert.ToBoolean(aValue: Byte): Boolean;
begin
  exit if aValue = 0 then false else true;
end;

method Convert.ToBoolean(aValue: not nullable String): Boolean;
begin
  if (aValue = nil) or (aValue.EqualsIgnoringCaseInvariant(Consts.FalseString)) then
    exit false;

  if aValue.EqualsIgnoringCaseInvariant(Consts.TrueString) then
    exit true;

  raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
end;

method Convert.ToUtf8Bytes(aValue: not nullable String): array of Byte;
begin
  result := Encoding.UTF8.GetBytes(aValue) includeBOM(false);
end;

method Convert.Utf8BytesToString(aBytes: array of Byte; aLength: nullable Int32 := nil): String;
begin
  var len := coalesce(aLength, length(aBytes));
  result := Encoding.UTF8.GetString(aBytes, 0, len);
end;

{$IF TOFFEE}
method Convert.TryParseNumber(aValue: not nullable String; aLocale: Locale := nil): NSNumber;
begin
  if String.IsNullOrEmpty(aValue) then
    exit nil;

  var Formatter := new NSNumberFormatter;
  Formatter.numberStyle := NSNumberFormatterStyle.NSNumberFormatterDecimalStyle;
  Formatter.locale := aLocale;
  if (aValue as PlatformString).rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet).location ≠ NSNotFound then // NSNumberFormatter ignores (some) whitespace, we wanna fail
    exit nil;
  if aValue.StartsWith("+") and not aValue.Contains("-") then // NSNumberFormatter doesn't like +, strip it;
    aValue := aValue.Substring(1);
  result := Formatter.numberFromString(aValue);
end;

method Convert.TryParseInt32(aValue: not nullable String): nullable Int32;
begin
  var i64 := TryParseInt64(aValue);
  if assigned(i64) then begin
    if (i64 > Consts.MaxInt32) or (i64 < Consts.MinInt32) then
      exit nil;
    exit Int32(i64);
  end;
end;

method Convert.TryParseInt64(aValue: not nullable String): nullable Int64;
begin
  var Number := TryParseNumber(aValue, Locale.Invariant);

  if Number = nil then
    exit nil;

  var obj: id := Number;
  var NumberType := CFNumberGetType(CFNumberRef(obj));

  if NumberType in [CFNumberType.kCFNumberIntType, CFNumberType.kCFNumberNSIntegerType, CFNumberType.kCFNumberSInt8Type, CFNumberType.kCFNumberSInt32Type,
                    CFNumberType.kCFNumberSInt16Type, CFNumberType.kCFNumberShortType, CFNumberType.kCFNumberSInt64Type, CFNumberType.kCFNumberCharType] then
    exit Number.longLongValue;
end;

method Convert.ParseInt32(aValue: not nullable String): Int32;
begin
  var Number := TryParseInt32(aValue);
  if not assigned(Number) then
    raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
  exit Number as not nullable;
end;

method Convert.ParseInt64(aValue: not nullable String): Int64;
begin
  var Number := TryParseInt64(aValue);
  if not assigned(Number) then
    raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
  exit Number as not nullable;
end;
{$ENDIF}

end.