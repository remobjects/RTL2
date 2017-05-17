namespace RemObjects.Elements.RTL;

interface

type
  {$IF ECHOES}
  PlatformString = public System.String;
  {$ELSEIF TOFFEE}
  PlatformString = public Foundation.NSString;
  {$ELSEIF COOPER}
  PlatformString = public java.lang.String;
  {$ELSEIF ISLAND}
  PlatformString = public RemObjects.Elements.System.String;
  {$ENDIF}

  [assembly:DefaultStringType("RemObjects.Elements.RTL", typeOf(RemObjects.Elements.RTL.String))]

  String = public partial class mapped to PlatformString
  private
    method get_Chars(aIndex: Int32): Char; inline;
  public
    constructor(Value: array of Byte; Encoding: Encoding := nil);
    constructor(Value: array of Char);
    constructor(Value: array of Char; Offset: Integer; Count: Integer);
    constructor(aChar: Char; aCount: Integer);

    class property &Empty: String read "";

    class operator &Add(Value1: String; Value2: String): not nullable String;
    class operator &Add(Value1: String; Value2: Object): not nullable String;
    class operator &Add(Value1: Object; Value2: String): not nullable String;
    class operator Implicit(Value: Char): String;
    class operator Greater(Value1, Value2: String): Boolean;
    class operator Less(Value1, Value2: String): Boolean;
    class operator GreaterOrEqual(Value1, Value2: String): Boolean;
    class operator LessOrEqual(Value1, Value2: String): Boolean;
    class operator Equal(Value1, Value2: String): Boolean;
    class operator NotEqual(Value1, Value2: String): Boolean;

    class method Format(aFormat: String; params aParams: array of Object): not nullable String;
    class method CharacterIsWhiteSpace(Value: Char): Boolean;
    class method CharacterIsLetter(Value: Char): Boolean;
    class method CharacterIsNumber(Value: Char): Boolean;
    class method CharacterIsLetterOrNumber(Value: Char): Boolean;
    class method IsNullOrEmpty(Value: String): Boolean;
    class method IsNullOrWhiteSpace(Value: String): Boolean;
    class method &Join(Separator: nullable String; Values: not nullable array of String): not nullable String;
    class method &Join(Separator: nullable String; Values: not nullable ImmutableList<String>): not nullable String;

    class method Compare(Value1, Value2: String): Integer;

    method CompareTo(Value: String): Integer;
    method CompareToIgnoreCase(Value: String): Integer;
    method &Equals(Value: String): Boolean;
    method EqualsIgnoringCase(Value: String): Boolean;
    method EqualsIgnoringCaseInvariant(Value: String): Boolean;

    class method &Equals(ValueA: String; ValueB: String): Boolean;
    class method EqualsIgnoringCase(ValueA: String; ValueB: String): Boolean;
    class method EqualsIgnoringCaseInvariant(ValueA: String; ValueB: String): Boolean;

    method Contains(Value: String): Boolean; inline;
    method IndexOf(Value: Char): Int32; inline;
    method IndexOf(Value: String): Int32; inline;
    method IndexOf(Value: Char; StartIndex: Integer): Integer; inline;
    method IndexOf(Value: String; StartIndex: Integer): Integer; inline;
    method IndexOfAny(const AnyOf: array of Char): Integer; inline;
    method IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
    method LastIndexOf(Value: Char): Integer; inline;
    method LastIndexOf(Value: String): Int32; inline;
    method LastIndexOf(Value: Char; StartIndex: Integer): Integer;
    method LastIndexOf(const Value: String; StartIndex: Integer): Integer;
    method Substring(StartIndex: Int32): not nullable String; inline;
    method Substring(StartIndex: Int32; aLength: Int32): not nullable String; inline;
    method Split(Separator: not nullable String): not nullable ImmutableList<String>;
    method SplitAtFirstOccurrenceOf(Separator: not nullable String): not nullable ImmutableList<String>;
    method Replace(OldValue, NewValue: String): not nullable String; //inline; //76828: Toffee: Internal error: LPUSH->U95 with inline
    method Replace(aStartIndex: Int32; aLength: Int32; aNewValue: String): not nullable String; //inline; //76828: Toffee: Internal error: LPUSH->U95 with inline
    method Insert(aIndex: Int32; aNewValue: String): not nullable String; inline;
    method PadStart(TotalWidth: Integer): String; inline;
    method PadStart(TotalWidth: Integer; PaddingChar: Char): String;
    method PadEnd(TotalWidth: Integer): String; inline;
    method PadEnd(TotalWidth: Integer; PaddingChar: Char): String;
    method ToLower: not nullable String; inline;
    method ToLowerInvariant: not nullable String; inline;
    method ToLower(aLocale: Locale): not nullable String; inline;
    method ToUpper: not nullable String; inline;
    method ToUpperInvariant: not nullable String; inline;
    method ToUpper(aLocale: Locale): not nullable String; inline;
    method Trim: not nullable String; inline;
    method TrimEnd: not nullable String; inline;
    method TrimStart: not nullable String; inline;
    method Trim(const TrimChars: array of Char): not nullable String;
    method TrimEnd(const TrimChars: array of Char): not nullable String;
    method TrimStart(const TrimChars: array of Char): not nullable String;
    method TrimNewLineCharacters: not nullable String; inline;
    method StartsWith(Value: String): Boolean; inline;
    method StartsWith(Value: String; IgnoreCase: Boolean): Boolean;
    method EndsWith(Value: String): Boolean; inline;
    method EndsWith(Value: String; IgnoreCase: Boolean): Boolean;
    method ToByteArray: not nullable array of Byte;
    method ToByteArray(aEncoding: {not nullable} Encoding): not nullable array of Byte;
    method ToCharArray: not nullable array of Char;

    property Length: Int32 read mapped.Length;
    property Chars[aIndex: Int32]: Char read get_Chars; default; inline;
  end;

{$GLOBALS ON}
var
  // from https://msdn.microsoft.com/en-us/library/system.Char.iswhitespace%28v=vs.110%29.aspx
  WhiteSpaceCharacters: array of Char :=
        [#$0020, #$1680, #$2000, #$2001, #$2002, #$2003, #$2004, #$2005, #$2006, #$2007, #$2008, #$2009, #$200A, #$202F, #$205F, #$3000, //space separators
         #$2028, //Line Separator
         #$2029, //Paragraph Separator
         #$0009, #$000A, #$000B, #$000C, #$000D,#$0085, #$00A0,  // other special symbols
         #$FFEF];

implementation

{$IF COOPER OR TOFFEE}
function CharIsAnyOf(Value: Char; AnyOf: array of Char): Boolean;
begin
  for each c: Char in AnyOf do
    if c = Value then
      exit true;

  result := false;
end;
{$ENDIF}

constructor String(Value: array of Byte; Encoding: Encoding := nil);
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Encoding = nil then
    Encoding := Encoding.Default;

  exit Encoding.GetString(Value);
end;

constructor String(Value: array of Char);
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  {$IF COOPER}
  result := new PlatformString(Value);
  {$ELSEIF ECHOES}
  result := new PlatformString(Value);
  {$ELSEIF ISLAND}
  result := PlatformString.FromCharArray(Value);
  {$ELSEIF TOFFEE}
  result := new PlatformString withCharacters(Value) length(length(Value));
  {$ENDIF}
end;

constructor String(Value: array of Char; Offset: Integer; Count: Integer);
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Count = 0 then
    exit "";

  RangeHelper.Validate(new Range(Offset, Count), Value.Length);

  {$IF COOPER}
  result := new PlatformString(Value, Offset, Count);
  {$ELSEIF ECHOES}
  result := new PlatformString(Value, Offset, Count);
  {$ELSEIF ISLAND}
  result := PlatformString.FromPChar((@Value)+Offset*sizeOf(Char), Count);
  {$ELSEIF TOFFEE}
  result := new PlatformString withCharacters(@Value[Offset]) length(Count);
  {$ENDIF}
end;

constructor String(aChar: Char; aCount: Integer);
begin
  {$IF COOPER}
  var chars := new Char[aCount];
  for i: Integer := 0 to aCount-1 do
    chars[i] := aChar;
  result := new PlatformString(chars);
  {$ELSEIF ECHOES}
  result := new PlatformString(aChar, aCount);
  {$ELSEIF ISLAND}
  result := PlatformString.FromRepeatedChar(aChar, aCount);
  {$ELSEIF TOFFEE}
  result := PlatformString("").stringByPaddingToLength(aCount) withString(PlatformString.stringWithFormat("%c", aChar)) startingAtIndex(0);
  {$ENDIF}
end;

method String.get_Chars(aIndex: Int32): Char;
begin
  {$IF COOPER}
  result := mapped.charAt(aIndex);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped[aIndex];
  {$ELSEIF TOFFEE}
  result := mapped.characterAtIndex(aIndex);
  {$ENDIF}
end;

class operator String.Add(Value1: String; Value2: String): not nullable String;
begin
  if not assigned(Value1) then exit coalesce(Value2, "");
  if not assigned(Value2) then exit Value1 as not nullable;
  result := (PlatformString(Value1)+PlatformString(Value2)) as not nullable;
end;

class operator String.Add(Value1: String; Value2: Object): not nullable String;
begin
  result := (Value1 + coalesce(Value2, "").ToString) as not nullable;
end;

class operator String.Add(Value1: Object; Value2: String): not nullable String;
begin
  result := (coalesce(Value1, "").ToString + Value2) as not nullable;
end;

class operator String.Implicit(Value: Char): String;
begin
  {$IF COOPER}
  exit new PlatformString(Value);
  {$ELSEIF ECHOES}
  exit new PlatformString(Value, 1);
  {$ELSEIF ISLAND}
  exit PlatformString.FromChar(Value);
  {$ELSEIF TOFFEE}
  if Value = #0 then
    exit NSString.stringWithFormat(#0) as not nullable;

  exit NSString.stringWithFormat("%c", Value) as not nullable;
  {$ENDIF}
end;

class method String.Compare(Value1: String; Value2: String): Integer;
begin
  if not assigned(Value1) and not assigned(Value2) then
    exit 0;

  if not assigned(Value1) then
    exit -1;

  if not assigned(Value2) then
    exit 1;

  exit Value1.CompareTo(Value2);
end;

class operator String.Equal(Value1: String; Value2: String): Boolean;
begin
  if not assigned(Value1) and not assigned(Value2) then
    exit true;

  if not assigned(Value1) or not assigned(Value2) then
    exit false;

  exit Value1.CompareTo(Value2) = 0;
end;

class operator String.NotEqual(Value1: String; Value2: String): Boolean;
begin
  exit Compare(Value1, Value2) <> 0;
end;

class operator String.Greater(Value1: String; Value2: String): Boolean;
begin
  exit Compare(Value1, Value2) > 0;
end;

class operator String.Less(Value1: String; Value2: String): Boolean;
begin
  exit Compare(Value1, Value2) < 0;
end;

class operator String.GreaterOrEqual(Value1: String; Value2: String): Boolean;
begin
  exit Compare(Value1, Value2) >= 0;
end;

class operator String.LessOrEqual(Value1: String; Value2: String): Boolean;
begin
  exit Compare(Value1, Value2) <= 0;
end;

class method String.Format(aFormat: String; params aParams: array of Object): not nullable String;
begin
  exit StringFormatter.FormatString(aFormat, aParams);
end;

class method String.CharacterIsWhiteSpace(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isWhitespace(Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := Char.IsWhiteSpace(Value);
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.whitespaceAndNewlineCharacterSet.characterIsMember(Value);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
class method String.CharacterIsLetter(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isLetter(Value);
  {$ELSEIF ECHOES}
  result := Char.IsLetter(Value);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.letterCharacterSet.characterIsMember(Value);
  {$ENDIF}
end;

class method String.CharacterIsNumber(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isDigit(Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := Char.IsNumber(Value);
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.decimalDigitCharacterSet.characterIsMember(Value);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
class method String.CharacterIsLetterOrNumber(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isLetterOrDigit(Value);
  {$ELSEIF ECHOES}
  result := Char.IsLetter(Value) or Char.IsNumber(Value);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.alphanumericCharacterSet.characterIsMember(Value);
  {$ENDIF}
end;

class method String.IsNullOrEmpty(Value: String): Boolean;
begin
  exit (Value = nil) or (Value.Length = 0);
end;

class method String.IsNullOrWhiteSpace(Value: String): Boolean;
begin
  if Value = nil then
    exit true;

  for i: Integer := 0 to Value.Length-1 do
    if not CharacterIsWhiteSpace(Value.Chars[i]) then
      exit false;

  exit true;
end;

method String.CompareTo(Value: String): Integer;
begin
  if Value = nil then
    exit 1;

  {$IF COOPER}
  exit mapped.compareTo(Value);
  {$ELSEIF ECHOES}
  exit mapped.Compare(mapped, Value, StringComparison.Ordinal);
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.String.Compare(mapped, Value);
  {$ELSEIF TOFFEE}
  exit mapped.compare(Value);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.CompareToIgnoreCase(Value: String): Integer;
begin
  {$IF COOPER}
  exit mapped.compareToIgnoreCase(Value);
  {$ELSEIF ECHOES}
  exit mapped.Compare(mapped, Value, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  exit mapped.caseInsensitiveCompare(Value);
  {$ENDIF}
end;

method String.Equals(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equals(Value); {$HINT needs to take locale into account!}
  {$ELSEIF ECHOES}
  exit mapped.Equals(Value, StringComparison.Ordinal);
  {$ELSEIF ISLAND}
  exit mapped.Equals(Value);
  {$ELSEIF TOFFEE}
  exit mapped.compare(Value) = 0;
  {$ENDIF}
end;

method String.EqualsIgnoringCase(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equalsIgnoreCase(Value); {$HINT needs to take locale into account!}
  {$ELSEIF ECHOES}
  exit mapped.Equals(Value, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  exit mapped.EqualsIgnoreCase(Value);
  {$ELSEIF TOFFEE}
  exit mapped.caseInsensitiveCompare(Value) = 0;
  {$ENDIF}
end;

method String.EqualsIgnoringCaseInvariant(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equalsIgnoreCase(Value); // aready invariant, on Java
  {$ELSEIF ECHOES}
  {$IF NETSTANDARD}
  exit mapped.Equals(Value, StringComparison.OrdinalIgnoreCase); {$HINT TODO}
  {$ELSE}
  exit mapped.Equals(Value, StringComparison.InvariantCultureIgnoreCase);
  {$ENDIF}
  {$ELSEIF ISLAND}
  exit mapped.EqualsIgnoreCaseInvariant(Value);
  {$ELSEIF TOFFEE}
  // RemObjects.Elements.System.length as workaround for issue in 8.3; not needed in 8.4
  exit mapped.compare(Value) options(NSStringCompareOptions.CaseInsensitiveSearch) range(NSMakeRange(0, RemObjects.Elements.System.length(self))) locale(Locale.Invariant) = 0;
  {$ENDIF}
end;

class method String.Equals(ValueA: String; ValueB: String): Boolean;
begin
  if ValueA = ValueB then exit true;
  if (ValueA = nil) or (ValueB = nil) then exit false;
  result := ValueA.Equals(ValueB);
end;

class method String.EqualsIgnoringCase(ValueA: String; ValueB: String): Boolean;
begin
  if ValueA = ValueB then exit true;
  if (ValueA = nil) or (ValueB = nil) then exit false;
  result := ValueA.EqualsIgnoringCase(ValueB);
end;

class method String.EqualsIgnoringCaseInvariant(ValueA: String; ValueB: String): Boolean;
begin
  if ValueA = ValueB then exit true;
  if (ValueA = nil) or (ValueB = nil) then exit false;
  result := ValueA.EqualsIgnoringCaseInvariant(ValueB);
end;

method String.Contains(Value: String): Boolean;
begin
  if Value.Length = 0 then
    exit true;

  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Contains(Value);
  {$ELSEIF TOFFEE}
  exit mapped.rangeOfString(Value).location <> NSNotFound;
  {$ENDIF}
end;

method String.IndexOf(Value: Char): Int32;
begin
  result := IndexOf(Value, 0);
end;

method String.IndexOf(Value: String): Int32;
begin
  result := IndexOf(Value, 0);
end;

method String.IndexOf(Value: Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := mapped.IndexOf(Value, StartIndex);
  {$ELSEIF TOFFEE}
  result := IndexOf(NSString.stringWithFormat("%c", Value), StartIndex);
  {$ENDIF}
end;

method String.IndexOf(Value: String; StartIndex: Integer): Integer;
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Value.Length = 0 then
    exit 0;

  {$IF COOPER OR ECHOES OR ISLAND}
  result := mapped.IndexOf(Value, StartIndex);
  {$ELSEIF TOFFEE}
  var r := mapped.rangeOfString(Value) options(NSStringCompareOptions.NSLiteralSearch) range(NSMakeRange(StartIndex, mapped.length - StartIndex));
  result := if r.location = NSNotFound then -1 else r.location;
  {$ENDIF}
end;

method String.IndexOfAny(const AnyOf: array of Char): Integer;
begin
  {$IF COOPER OR TOFFEE}
  result := IndexOfAny(AnyOf, 0);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.IndexOfAny(AnyOf);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER}
  for i: Integer := StartIndex to mapped.length - 1 do begin
     for each c: Char in AnyOf do begin
       if mapped.charAt(i) = c then
         exit i;
     end;
  end;
  result := -1;
  {$ELSEIF ECHOES}// OR ISLAND}
  result := mapped.IndexOfAny(AnyOf, StartIndex);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  var lChars := NSCharacterSet.characterSetWithCharactersInString(new PlatformString withCharacters(AnyOf) length(AnyOf.length));
  var r := mapped.rangeOfCharacterFromSet(lChars) options(NSStringCompareOptions.NSLiteralSearch) range(NSMakeRange(StartIndex, mapped.length - StartIndex));
  result := if r.location = NSNotFound then -1 else r.location;
  {$ENDIF}
end;

method String.LastIndexOf(Value: Char): Integer;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := mapped.LastIndexOf(Value);
  {$ELSEIF TOFFEE}
  result := LastIndexOf(NSString.stringWithFormat("%c", Value));
  {$ENDIF}
end;

method String.LastIndexOf(Value: String): Int32;
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Value.Length = 0 then
    exit mapped.length - 1;

  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.LastIndexOf(Value);
  {$ELSEIF TOFFEE}
  var r := mapped.rangeOfString(Value) options(NSStringCompareOptions.NSBackwardsSearch);
  exit if (r.location = NSNotFound) and (r.length = 0) then -1 else Int32(r.location);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.LastIndexOf(Value: Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER OR ECHOES}// OR ISLAND}
  result := mapped.LastIndexOf(Value, StartIndex);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  result := LastIndexOf(NSString.stringWithFormat("%c", Value), StartIndex);
  {$ENDIF}
end;

method String.LastIndexOf(const Value: String; StartIndex: Integer): Integer;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := mapped.LastIndexOf(Value, StartIndex);
  if (result = StartIndex) and (Value.Length > 1) then
    result := -1;
  {$ELSEIF TOFFEE}
  var r:= mapped.rangeOfString(Value) options(NSStringCompareOptions.NSLiteralSearch or NSStringCompareOptions.NSBackwardsSearch) range(NSMakeRange(0, StartIndex + 1));
  exit if (r.location = NSNotFound) and (r.length = 0) then -1 else Int32(r.location);
  {$ENDIF}
end;

method String.Substring(StartIndex: Int32): not nullable String;
begin
  if (StartIndex < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "StartIndex");

  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Substring(StartIndex) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.substringFromIndex(StartIndex) as not nullable;
  {$ENDIF}
end;

method String.Substring(StartIndex: Int32; aLength: Int32): not nullable String;
begin
  if (StartIndex < 0) or (aLength < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "StartIndex and Length");

  {$IF COOPER}
  exit mapped.substring(StartIndex, StartIndex + aLength) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Substring(StartIndex, aLength) as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.substringWithRange(Foundation.NSMakeRange(StartIndex, aLength));
  {$ENDIF}
end;

method String.Split(Separator: not nullable String): not nullable ImmutableList<String>;
begin
  if IsNullOrEmpty(Separator) then
    exit new ImmutableList<String>(self);

  {$IF COOPER}
  //exit mapped.split(java.util.regex.Pattern.quote(Separator)) as not nullable;
  //Custom implementation because `mapped.split` strips empty oparts at the end, making it incomopatible with the other three platfroms.
  var lResult := new List<String>;
  var i := 0;
  var lSeparatorLength := Separator.Length;
  loop begin
    var p := IndexOf(Separator, i);
    if p > -1 then begin
      var lPart := self.Substring(i, p-i);
      lResult.Add(lPart);
      i := p+lSeparatorLength;
    end
    else begin
      var lPart := self.Substring(i);
      lResult.Add(lPart);
      break;
    end;
  end;
  result := lResult as not nullable;
  {$ELSEIF ECHOES}
  result := mapped.Split([Separator], StringSplitOptions.None).ToList() as not nullable;
  {$ELSEIF ISLAND}
  result := mapped.Split(Separator).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.componentsSeparatedByString(Separator);
  {$ENDIF}
end;

method String.SplitAtFirstOccurrenceOf(Separator: not nullable String): not nullable ImmutableList<String>;
begin
  var p := IndexOf(Separator);
  if p > -1 then
    result := new ImmutableList<String>(Substring(0, p), Substring(p+Separator.Length))
  else
    result := new ImmutableList<String>(self);
end;

method String.Replace(OldValue: String; NewValue: String): not nullable String;
begin
  if IsNullOrEmpty(OldValue) then
    raise new ArgumentNullException("OldValue");

  if NewValue = nil then
    NewValue := "";
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.Replace(OldValue, NewValue) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.stringByReplacingOccurrencesOfString(OldValue) withString(NewValue);
  {$ENDIF}
end;

method String.Replace(aStartIndex: Int32; aLength: Int32; aNewValue: String): not nullable String;
begin
  if aNewValue = nil then
    aNewValue := "";
  {$IF COOPER}
  exit mapped.substring(0, aStartIndex)+aNewValue+mapped.substring(aStartIndex+aLength) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(aStartIndex, aLength).Insert(aStartIndex, aNewValue) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.stringByReplacingCharactersInRange(NSMakeRange(aStartIndex, aLength)) withString(aNewValue);
  {$ENDIF}
end;

method String.Insert(aIndex: Int32; aNewValue: String): not nullable String;
begin
  result := Replace(aIndex, 0, aNewValue);
end;

{$IF COOPER}
function StringOfChar(Value: Char; Count: Integer): String;
begin
  var sb := new StringBuilder(Count);
  for i: Integer := 0 to Count - 1 do
    sb.append(Value);

  result := sb.toString;
end;
{$ENDIF}

method String.PadStart(TotalWidth: Integer): String;
begin
  result := PadStart(TotalWidth, ' ');
end;

method String.PadStart(TotalWidth: Integer; PaddingChar: Char): String;
begin
  {$IF COOPER}
  var lTotal := TotalWidth - mapped.length;
  if lTotal < 0 then
    result := self
  else
    result := StringOfChar(PaddingChar, lTotal) + self;
  {$ELSEIF ECHOES}
  result := mapped.PadLeft(TotalWidth, PaddingChar);
  {$ELSEIF ISLAND}
  result := mapped.PadStart(TotalWidth, PaddingChar);
  {$ELSEIF TOFFEE}
  var lTotal: Integer := TotalWidth - mapped.length;
  if lTotal > 0 then begin
    var lChars := NSString.stringWithFormat("%c", PaddingChar);
    lChars := lChars.stringByPaddingToLength(lTotal) withString(PaddingChar) startingAtIndex(0);
    result := lChars + self;
  end
  else
    result := self;
  {$ENDIF}
end;

method String.PadEnd(TotalWidth: Integer): String;
begin
  result := PadEnd(TotalWidth, ' ');
end;

method String.PadEnd(TotalWidth: Integer; PaddingChar: Char): String;
begin
  {$IF COOPER}
  var lTotal := TotalWidth - mapped.length;
  if lTotal < 0 then
    result := self
  else
    result := self + StringOfChar(PaddingChar, lTotal);
  {$ELSEIF ECHOES}
  result := mapped.PadRight(TotalWidth, PaddingChar);
  {$ELSEIF ISLAND}
  result := mapped.PadEnd(TotalWidth, PaddingChar);
  {$ELSEIF TOFFEE}
  result := mapped.stringByPaddingToLength(TotalWidth) withString(PaddingChar) startingAtIndex(0);
  {$ENDIF}
end;

method String.ToLower: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(Locale.Current) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToLower as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseString;
  {$ENDIF}
end;

method String.ToLowerInvariant: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(Locale.Invariant) as not nullable;
  {$ELSEIF ECHOES}
  exit mapped.ToLowerInvariant as not nullable;
  {$ELSEIF ISLAND}
  exit mapped.ToLower(true) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseStringWithLocale(Locale.Invariant);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.ToLower(aLocale: Locale): not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(aLocale) as not nullable;
  {$ELSEIF ECHOES}
  {$IF NETSTANDARD}
  exit mapped.ToLower as not nullable; {$HINT TODO}
  {$ELSE}
  exit mapped.ToLower(aLocale) as not nullable;
  {$ENDIF}
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseStringWithLocale(aLocale);
  {$ENDIF}
end;

method String.ToUpper: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(Locale.Current) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToUpper as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseString;
  {$ENDIF}
end;

method String.ToUpperInvariant: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(Locale.Invariant) as not nullable;
  {$ELSEIF ECHOES}
  exit mapped.ToUpperInvariant as not nullable;
  {$ELSEIF ISLAND}
  exit mapped.ToUpper(true) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseStringWithLocale(Locale.Invariant);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.ToUpper(aLocale: Locale): not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(aLocale) as not nullable;
  {$ELSEIF ECHOES}
  {$IF NETSTANDARD}
  exit mapped.ToUpper as not nullable; {$HINT TODO}
  {$ELSE}
  exit mapped.ToUpper(aLocale) as not nullable;
  {$ENDIF}
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseStringWithLocale(aLocale);
  {$ENDIF}
end;

//
// Trim
//

method String.Trim: not nullable String;
begin
  {$IF COOPER}
  result := Trim(WhiteSpaceCharacters);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.Trim() as not nullable; // .NET Trim() does include CR/LF and Unicode whitespace
  {$ELSEIF TOFFEE}
  result := mapped.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet);
  {$ENDIF}
end;

method String.TrimStart: not nullable String;
begin
  {$IF COOPER OR TOFFEE}
  result := TrimStart(WhiteSpaceCharacters);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.TrimStart() as not nullable; // .NET Trim() does include CR/LF and Unicode whitespace
  {$ENDIF}
end;

method String.TrimEnd: not nullable String;
begin
  {$IF COOPER OR TOFFEE}
  result := TrimEnd(WhiteSpaceCharacters);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.TrimEnd() as not nullable;
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
method String.Trim(const TrimChars: array of Char): not nullable String;
begin
  {$IF COOPER}
  var lStr := TrimStart(TrimChars);
  result := lStr.TrimEnd(TrimChars);
  {$ELSEIF ECHOES}
  result := mapped.Trim(TrimChars) as not nullable;
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("`String.Trim(array of char)` is not implemented for Island yet.");
  {$ELSEIF TOFFEE}
  var lCharset := NSCharacterSet.characterSetWithCharactersInString(new PlatformString withCharacters(TrimChars) length(TrimChars.length));
  result := mapped.stringByTrimmingCharactersInSet(lCharset);
  {$ENDIF}
end;

method String.TrimStart(const TrimChars: array of Char): not nullable String;
begin
  {$IF COOPER OR TOFFEE}
  var len := RemObjects.Elements.System.length(self);
  result := self;
  if len > 0 then begin
    var i: Integer := 0;
    while (i < len-1) and CharIsAnyOf(self[i], TrimChars) do
      inc(i);
    if i > 0 then
      result := Substring(i) as not nullable;
  end;
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.TrimStart(TrimChars) as not nullable;
  {$ENDIF}
end;

method String.TrimEnd(const TrimChars: array of Char): not nullable String;
begin
  {$IF COOPER OR TOFFEE}
  var len := RemObjects.Elements.System.length(self);
  result := self;
  if len > 0 then begin
    var i: Integer := len-1;
    while (i ≥ 0) and CharIsAnyOf(self[i], TrimChars) do
      dec(i);
    if i+1 < len then
      result := Substring(0, i+1) as not nullable;
  end;
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.TrimEnd(TrimChars) as not nullable;
  {$ENDIF}
end;


method String.TrimNewLineCharacters: not nullable String;
begin
  result := Trim([#13, #10]);
end;

method String.StartsWith(Value: String): Boolean;
begin
  result := StartsWith(Value, False);
end;

method String.StartsWith(Value: String; IgnoreCase: Boolean): Boolean;
begin
   if Value.Length = 0 then
    exit true;

  {$IF COOPER}
  if IgnoreCase then
    result := mapped.regionMatches(IgnoreCase, 0, Value, 0, Value.length)
  else
    result := mapped.StartsWith(Value);
  {$ELSEIF ECHOES}
  if IgnoreCase then
    result := mapped.StartsWith(Value, StringComparison.OrdinalIgnoreCase)
  else
    result := mapped.StartsWith(Value);
  {$ELSEIF ISLAND}
  if IgnoreCase then
    result := mapped.ToLower().StartsWith(Value.ToLower(), false)
  else
    result := mapped.StartsWith(Value, false);
  {$ELSEIF TOFFEE}
  if Value.Length > mapped.length then
    result := false
  else begin
    if IgnoreCase then
      result := (mapped.compare(Value) options(NSStringCompareOptions.NSCaseInsensitiveSearch) range(NSMakeRange(0, Value.length)) = NSComparisonResult.NSOrderedSame)
    else
      result := mapped.hasPrefix(Value);
  end;
  {$ENDIF}
end;

method String.EndsWith(Value: String): Boolean;
begin
  result := EndsWith(Value, False);
end;

method String.EndsWith(Value: String; IgnoreCase: Boolean): Boolean;
begin
  if Value.Length = 0 then
    exit true;

  {$IF COOPER}
  if IgnoreCase then
    result := mapped.toUpperCase.endsWith(PlatformString(Value).toUpperCase)
  else
    result := mapped.endsWith(Value);
  {$ELSEIF ECHOES}
  if IgnoreCase then
    result := mapped.EndsWith(Value, StringComparison.OrdinalIgnoreCase)
  else
    result := mapped.EndsWith(Value);
  {$ELSEIF ISLAND}
  if IgnoreCase then
    result := mapped.ToLower().EndsWith(Value.ToLower(), false)
  else
    result := mapped.EndsWith(Value, false);
  {$ELSEIF TOFFEE}
  if Value.Length > mapped.length then
    result := false
  else begin
    if IgnoreCase then
      result := (mapped.compare(Value) options(NSStringCompareOptions.NSCaseInsensitiveSearch) range(NSMakeRange(mapped.length - Value.length, Value.length)) = NSComparisonResult.NSOrderedSame)
    else
      result := mapped.hasSuffix(Value);
  end;
  {$ENDIF}
end;

method String.ToCharArray: not nullable array of Char;
begin
  {$IF COOPER}
  exit mapped.ToCharArray as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToCharArray as not nullable;
  {$ELSEIF TOFFEE}
  result := new Char[mapped.length];
  mapped.getCharacters(result) range(NSMakeRange(0, mapped.length));
  {$ENDIF}
end;

method String.ToByteArray: not nullable array of Byte;
begin
  {$IF COOPER}
  exit mapped.getBytes("UTF-8") as not nullable;
  {$ELSEIF ECHOES}
  exit System.Text.Encoding.UTF8.GetBytes(mapped) as not nullable;
  {$ELSEIF ISLAND}
  exit TextConvert.StringToUTF8(mapped) as not nullable;
  {$ELSEIF TOFFEE}
  var Data := Binary(mapped.dataUsingEncoding(NSStringEncoding.NSUTF8StringEncoding));
  exit Data.ToArray as not nullable;
  {$ENDIF}
end;

method String.ToByteArray(aEncoding: {not nullable} Encoding): not nullable array of Byte;
begin
  result := aEncoding.GetBytes(self);
end;

class method String.Join(Separator: nullable String; Values: not nullable array of String): not nullable String;
begin
  {$IF COOPER}
  var sb := new StringBuilder;
  for i: Integer := 0 to length(Values)-1 do begin
     if (i ≠ 0) and assigned(Separator) then
      sb.append(Separator);
    sb.append(Values[i]);
  end;
  result := sb.toString as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  result := PlatformString.Join(Separator, Values) as not nullable;
  {$ELSEIF TOFFEE}
  var lArray := new NSMutableArray withCapacity(Values.length);
  for i: Integer := 0 to Values.length - 1 do
    lArray.addObject(Values[i]);

  result := lArray.componentsJoinedByString(Separator);
  {$ENDIF}
end;

class method String.&Join(Separator: nullable String; Values: not nullable ImmutableList<String>): not nullable String;
begin
  {$IF COOPER}
  var sb := new StringBuilder;
  for i: Integer := 0 to Values.Count-1 do begin
     if (i ≠ 0) and assigned(Separator) then
      sb.append(Separator);
    sb.append(Values[i]);
  end;
  result := sb.toString as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  result := PlatformString.Join(Separator, Values.ToArray) as not nullable;
  {$ELSEIF TOFFEE}
  result := (Values as NSArray).componentsJoinedByString(Separator);
  {$ENDIF}
end;


end.