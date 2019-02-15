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
    method get_FirstLine: String;
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
    class method &Join(aSeparator: nullable String; Values: not nullable array of String): not nullable String;
    class method &Join(aSeparator: nullable String; Values: not nullable ImmutableList<String>): not nullable String;

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
    method IndexOfIgnoringCase(Value: Char): Int32; inline;
    method IndexOfIgnoringCase(Value: String): Int32; inline;
    method IndexOf(Value: Char; StartIndex: Integer): Integer; inline;
    method IndexOf(Value: String; StartIndex: Integer): Integer; inline;
    method IndexOfIgnoringCase(Value: Char; StartIndex: Integer): Integer; inline;
    method IndexOfIgnoringCase(Value: String; StartIndex: Integer): Integer; inline;
    method IndexOfAny(const AnyOf: array of Char): Integer; inline;
    method IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
    method LastIndexOf(Value: Char): Integer; inline;
    method LastIndexOf(Value: String): Int32; inline;
    method LastIndexOf(Value: Char; StartIndex: Integer): Integer;
    method LastIndexOf(const Value: String; StartIndex: Integer): Integer;
    method Substring(StartIndex: Int32): not nullable String; inline;
    method Substring(StartIndex: Int32; aLength: Int32): not nullable String; inline;
    method SubstringToFirstOccurrenceOf(aSeparator: not nullable String): not nullable String;
    method SubstringFromFirstOccurrenceOf(aSeparator: not nullable String): not nullable String;
    method SubstringToLastOccurrenceOf(aSeparator: not nullable String): not nullable String;
    method SubstringFromLastOccurrenceOf(aSeparator: not nullable String): not nullable String;
    method Split(aSeparator: not nullable String; aRemoveEmptyEntries: Boolean := false): not nullable ImmutableList<String>;
    method SplitAtFirstOccurrenceOf(aSeparator: not nullable String): not nullable ImmutableList<String>;
    method SplitAtLastOccurrenceOf(aSeparator: not nullable String): not nullable ImmutableList<String>;
    method Replace(OldValue, NewValue: String): not nullable String; //inline; //76828: Toffee: Internal error: LPUSH->U95 with inline
    method Replace(aStartIndex: Int32; aLength: Int32; aNewValue: String): not nullable String; //inline; //76828: Toffee: Internal error: LPUSH->U95 with inline
    method &Remove(aStartIndex: Int32; aLength: Int32): not nullable String; //inline; //76828: Toffee: Internal error: LPUSH->U95 with inline
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
    method StartsWith(Value: Char): Boolean; inline;
    method StartsWith(Value: String): Boolean; inline;
    method StartsWith(Value: String; IgnoreCase: Boolean): Boolean;
    method EndsWith(Value: Char): Boolean; inline;
    method EndsWith(Value: String): Boolean; inline;
    method EndsWith(Value: String; IgnoreCase: Boolean): Boolean;
    method ToByteArray: not nullable array of Byte;
    method ToByteArray(aEncoding: not nullable Encoding): not nullable array of Byte;
    method ToCharArray: not nullable array of Char;

    property Length: Int32 read mapped.Length;
    property Chars[aIndex: Int32]: Char read get_Chars; default; inline;

    property FirstLine: String read get_FirstLine;

    //[&Sequence]
    //method GetSequence: sequence of Char; iterator;
    //begin
      //for i: Integer := 0 to Length-1 do
        //yield Chars[i];
    //end;

    {$IF COOPER}
    operator Implicit(aCharSequence: CharSequence): String;
    operator Implicit(aString: String): CharSequence;
    {$ENDIF}
  end;

{$GLOBALS ON}
var
  // from https://msdn.microsoft.com/en-us/library/system.Char.iswhitespace%28v=vs.110%29.aspx
  WhiteSpaceCharacters: array of Char :=
        [#$0020, #$1680, #$2000, #$2001, #$2002, #$2003, #$2004, #$2005, #$2006, #$2007, #$2008, #$2009, #$200A, #$202F, #$205F, #$3000, //space separators
         #$2028, //Line aSeparator
         #$2029, //Paragraph aSeparator
         #$0009, #$000A, #$000B, #$000C, #$000D,#$0085, #$00A0,  // other special symbols
         #$FFEF]; public;

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
  {$ELSEIF TOFFEE}
  result := new PlatformString withCharacters(Value) length(RemObjects.Oxygene.System.length(Value));
  {$ELSEIF ECHOES}
  result := new PlatformString(Value);
  {$ELSEIF ISLAND}
  result := PlatformString.FromCharArray(Value);
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
  {$ELSEIF TOFFEE}
  result := new PlatformString withCharacters(@Value[Offset]) length(Count);
  {$ELSEIF ECHOES}
  result := new PlatformString(Value, Offset, Count);
  {$ELSEIF ISLAND}
  result := PlatformString.FromPChar((@Value)+Offset/*sizeOf(Char)*/, Count);
  {$ENDIF}
end;

constructor String(aChar: Char; aCount: Integer);
begin
  {$IF COOPER}
  var chars := new Char[aCount];
  for i: Integer := 0 to aCount-1 do
    chars[i] := aChar;
  result := new PlatformString(chars);
  {$ELSEIF TOFFEE}
  result := PlatformString("").stringByPaddingToLength(aCount) withString(PlatformString.stringWithFormat("%c", aChar)) startingAtIndex(0);
  {$ELSEIF ECHOES}
  result := new PlatformString(aChar, aCount);
  {$ELSEIF ISLAND}
  result := PlatformString.FromRepeatedChar(aChar, aCount);
  {$ENDIF}
end;

method String.get_Chars(aIndex: Int32): Char;
begin
  {$IF COOPER}
  result := mapped.charAt(aIndex);
  {$ELSEIF TOFFEE}
  result := mapped.characterAtIndex(aIndex);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped[aIndex];
  {$ENDIF}
end;

method String.get_FirstLine: String;
begin
  var p := IndexOfAny([#13, #10]);
  if p > -1 then
    exit Substring(0, p);
  exit self;
end;

class operator String.Add(Value1: String; Value2: String): not nullable String;
begin
  if not assigned(Value1) then exit coalesce(Value2, "");
  if not assigned(Value2) then exit Value1 as not nullable;
  result := (PlatformString(Value1)+PlatformString(Value2)) as String as not nullable;
end;

class operator String.Add(Value1: String; Value2: Object): not nullable String;
begin
  result := (Value1 + coalesce(String(Value2:ToString), String(""))) as not nullable;
end;

class operator String.Add(Value1: Object; Value2: String): not nullable String;
begin
  result := (String(coalesce(String(Value1:ToString),String(""))) + Value2) as not nullable;
end;

class operator String.Implicit(Value: Char): String;
begin
  {$IF COOPER}
  exit new PlatformString(Value);
  {$ELSEIF TOFFEE}
  if Value = #0 then
    exit NSString.stringWithFormat(#0) as not nullable;
  exit NSString.stringWithFormat("%c", Value) as not nullable;
  {$ELSEIF ECHOES}
  exit new PlatformString(Value, 1);
  {$ELSEIF ISLAND}
  exit PlatformString.FromChar(Value);
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
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.whitespaceAndNewlineCharacterSet.characterIsMember(Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := Char.IsWhiteSpace(Value);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
class method String.CharacterIsLetter(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isLetter(Value);
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.letterCharacterSet.characterIsMember(Value);
  {$ELSEIF ECHOES}
  result := Char.IsLetter(Value);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
  {$ENDIF}
end;

class method String.CharacterIsNumber(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isDigit(Value);
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.decimalDigitCharacterSet.characterIsMember(Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := Char.IsNumber(Value);
  {$ENDIF}
end;

{$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
class method String.CharacterIsLetterOrNumber(Value: Char): Boolean;
begin
  {$IF COOPER}
  result := java.lang.Character.isLetterOrDigit(Value);
  {$ELSEIF TOFFEE}
  result := Foundation.NSCharacterSet.alphanumericCharacterSet.characterIsMember(Value);
  {$ELSEIF ECHOES}
  result := Char.IsLetter(Value) or Char.IsNumber(Value);
  {$ELSEIF ISLAND}
  {$WARNING Not Implemeted for Island}
  raise new NotImplementedException("Some String APIs are not implemented for Island yet.");
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
  {$ELSEIF TOFFEE}
  exit mapped.compare(Value);
  {$ELSEIF ECHOES}
  exit mapped.Compare(mapped, Value, StringComparison.Ordinal);
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.String.Compare(mapped, Value);
  {$ENDIF}
end;

method String.CompareToIgnoreCase(Value: String): Integer;
begin
  {$IF COOPER}
  exit mapped.compareToIgnoreCase(Value);
  {$ELSEIF TOFFEE}
  exit mapped.caseInsensitiveCompare(Value);
  {$ELSEIF ECHOES}
  exit mapped.Compare(mapped, Value, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  exit mapped.CompareToIgnoreCase(Value);
  {$ENDIF}
end;

method String.Equals(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equals(Value); {$HINT needs to take locale into account!}
  {$ELSEIF TOFFEE}
  exit mapped.compare(Value) = 0;
  {$ELSEIF ECHOES}
  exit mapped.Equals(Value, StringComparison.Ordinal);
  {$ELSEIF ISLAND}
  exit mapped.Equals(Value);
  {$ENDIF}
end;

method String.EqualsIgnoringCase(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equalsIgnoreCase(Value); {$HINT needs to take locale into account!}
  {$ELSEIF TOFFEE}
  exit mapped.caseInsensitiveCompare(Value) = 0;
  {$ELSEIF ECHOES}
  exit mapped.Equals(Value, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  exit mapped.EqualsIgnoreCase(Value);
  {$ENDIF}
end;

method String.EqualsIgnoringCaseInvariant(Value: String): Boolean;
begin
  {$IF COOPER}
  exit mapped.equalsIgnoreCase(Value); // aready invariant, on Java
  {$ELSEIF TOFFEE}
  // RemObjects.Elements.System.length as workaround for issue in 8.3; not needed in 8.4
  exit mapped.compare(Value) options(NSStringCompareOptions.CaseInsensitiveSearch) range(NSMakeRange(0, RemObjects.Elements.System.length(self))) locale(Locale.Invariant) = 0;
  {$ELSEIF ECHOES}
  exit mapped.Equals(Value, StringComparison.InvariantCultureIgnoreCase);
  {$ELSEIF ISLAND}
  exit mapped.EqualsIgnoreCaseInvariant(Value);
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
  if RemObjects.Elements.System.length(Value) = 0 then
    exit true;

  {$IF NOT TOFFEE}
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

method String.IndexOfIgnoringCase(Value: Char): Int32;
begin
  result := IndexOfIgnoringCase(Value, 0);
end;

method String.IndexOfIgnoringCase(Value: String): Int32;
begin
  result := IndexOfIgnoringCase(Value, 0);
end;

method String.IndexOf(Value: Char; StartIndex: Integer): Integer;
begin
  {$IF NOT TOFFEE}
  result := mapped.IndexOf(Value, StartIndex);
  {$ELSEIF TOFFEE}
  result := IndexOf(NSString.stringWithFormat("%c", Value), StartIndex);
  {$ENDIF}
end;

{$IF (ISLAND AND POSIX) OR COOPER}[Warning("Not Implemented for Cooper and Island yet")]{$ENDIF}
method String.IndexOfIgnoringCase(Value: Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER}
  result := self.ToLower().IndexOf(Character.toLowerCase(Value), StartIndex);
  {$ELSEIF TOFFEE}
  result := IndexOf(NSString.stringWithFormat("%c", Value), StartIndex);
  {$ELSEIF ECHOES}
  result := mapped.IndexOf(Value, StartIndex, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  result := mapped.ToLower.IndexOf(Value.ToLOwer(), StartIndex);
  {$ENDIF}
end;

method String.IndexOf(Value: String; StartIndex: Integer): Integer;
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Value.Length = 0 then
    exit 0;

  {$IF NOT TOFFEE}
  result := mapped.IndexOf(Value, StartIndex);
  {$ELSEIF TOFFEE}
  var r := mapped.rangeOfString(Value) options(NSStringCompareOptions.LiteralSearch) range(NSMakeRange(StartIndex, mapped.length - StartIndex));
  result := if r.location = NSNotFound then -1 else Integer(r.location);
  {$ENDIF}
end;

{$IF (ISLAND AND POSIX) OR COOPER}[Warning("Not Implemented for Cooper and Island yet")]{$ENDIF}
method String.IndexOfIgnoringCase(Value: String; StartIndex: Integer): Integer;
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  if Value.Length = 0 then
    exit 0;

  {$IF COOPER}
  result := self.ToLower().IndexOf(Value.ToLower(), StartIndex);
  {$ELSEIF TOFFEE}
  var r := mapped.rangeOfString(Value) options(NSStringCompareOptions.CaseInsensitiveSearch) range(NSMakeRange(StartIndex, mapped.length - StartIndex));
  result := if r.location = NSNotFound then -1 else Integer(r.location);
  {$ELSEIF ECHOES}
  result := mapped.IndexOf(Value, StartIndex, StringComparison.OrdinalIgnoreCase);
  {$ELSEIF ISLAND}
  result := mapped.ToLower().IndexOf(Value.ToLower(), StartIndex);
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

method String.IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER OR (ISLAND AND NOT TOFFEE)}
  for i: Integer := StartIndex to Length - 1 do begin
     for each c: Char in AnyOf do begin
       if Chars[i] = c then
         exit i;
     end;
  end;
  result := -1;
  {$ELSEIF ECHOES}
  result := mapped.IndexOfAny(AnyOf, StartIndex);
  {$ELSEIF TOFFEE}
  var lChars := NSCharacterSet.characterSetWithCharactersInString(new PlatformString withCharacters(AnyOf) length(AnyOf.length));
  var r := mapped.rangeOfCharacterFromSet(lChars) options(NSStringCompareOptions.NSLiteralSearch) range(NSMakeRange(StartIndex, mapped.length - StartIndex));
  result := if r.location = NSNotFound then -1 else Integer(r.location);
  {$ENDIF}
end;

method String.LastIndexOf(Value: Char): Integer;
begin
  {$IF NOT TOFFEE}
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

  {$IF NOT TOFFEE}
  exit mapped.LastIndexOf(Value);
  {$ELSEIF TOFFEE}
  var r := mapped.rangeOfString(Value) options(NSStringCompareOptions.NSBackwardsSearch);
  exit if (r.location = NSNotFound) and (r.length = 0) then -1 else Int32(r.location);
  {$ENDIF}
end;

method String.LastIndexOf(Value: Char; StartIndex: Integer): Integer;
begin
  {$IF COOPER OR ECHOES}
  result := mapped.LastIndexOf(Value, StartIndex);
  {$ELSEIF TOFFEE}
  result := LastIndexOf(NSString.stringWithFormat("%c", Value), StartIndex);
  {$ELSEIF ISLAND}
  result := mapped.LastIndexOf(String(Value), StartIndex);
  {$ENDIF}
end;

method String.LastIndexOf(const Value: String; StartIndex: Integer): Integer;
begin
  {$IF NOT TOFFEE}
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

  {$IF NOT TOFFEE}
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
  {$ELSEIF TOFFEE}
  result := mapped.substringWithRange(Foundation.NSMakeRange(StartIndex, aLength));
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Substring(StartIndex, aLength) as not nullable;
  {$ENDIF}
end;

method String.Split(aSeparator: not nullable String; aRemoveEmptyEntries: Boolean := false): not nullable ImmutableList<String>;
begin
  if IsNullOrEmpty(aSeparator) then
    exit new ImmutableList<String>(self);
  if IsNullOrEmpty(self) then
    exit if aRemoveEmptyEntries then new ImmutableList<String>() else new ImmutableList<String>("");

  {$IF COOPER}
  //exit mapped.split(java.util.regex.Pattern.quote(aSeparator)) as not nullable;
  //Custom implementation because `mapped.split` strips empty oparts at the end, making it incomopatible with the other three platfroms.
  var lResult := new List<String>;
  var i := 0;
  var lSeparatorLength := aSeparator.Length;
  loop begin
    var p := IndexOf(aSeparator, i);
    if p > -1 then begin
      var lPart := self.Substring(i, p-i);
      if (not aRemoveEmptyEntries) or (lPart.length > 0) then
        lResult.Add(lPart);
      i := p+lSeparatorLength;
    end
    else begin
      var lPart := self.Substring(i);
      if (not aRemoveEmptyEntries) or (lPart.length > 0) then
        lResult.Add(lPart);
      break;
    end;
  end;
  result := lResult as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.componentsSeparatedByString(aSeparator) as not nullable;
  if aRemoveEmptyEntries then
    result := result.Where(p -> p:Length > 0).ToList();
  {$ELSEIF ECHOES}
  result := mapped.Split([aSeparator], if aRemoveEmptyEntries then StringSplitOptions.RemoveEmptyEntries else StringSplitOptions.None).ToList() as not nullable;
  {$ELSEIF ISLAND}
  result := mapped.Split(aSeparator, aRemoveEmptyEntries).ToList() as not nullable;
  {$ENDIF}
end;

method String.SplitAtFirstOccurrenceOf(aSeparator: not nullable String): not nullable ImmutableList<String>;
begin
  var p := IndexOf(aSeparator);
  if p > -1 then
    result := new ImmutableList<String>(Substring(0, p), Substring(p+aSeparator.Length))
  else
    result := new ImmutableList<String>(self);
end;

method String.SplitAtLastOccurrenceOf(aSeparator: not nullable String): not nullable ImmutableList<String>;
begin
  var p := LastIndexOf(aSeparator);
  if p > -1 then
    result := new ImmutableList<String>(Substring(0, p), Substring(p+aSeparator.Length))
  else
    result := new ImmutableList<String>(self);
end;

method String.SubstringToFirstOccurrenceOf(aSeparator: not nullable String): not nullable String;
begin
  result := self;
  var p := IndexOf(aSeparator);
  if p > -1 then
    result := result.Substring(0, p);
end;

method String.SubstringFromFirstOccurrenceOf(aSeparator: not nullable String): not nullable String;
begin
  result := self;
  var p := IndexOf(aSeparator);
  if p > -1 then
    result := result.Substring(p+aSeparator.Length);
end;

method String.SubstringToLastOccurrenceOf(aSeparator: not nullable String): not nullable String;
begin
  result := self;
  var p := LastIndexOf(aSeparator);
  if p > -1 then
    result := result.Substring(0, p);
end;

method String.SubstringFromLastOccurrenceOf(aSeparator: not nullable String): not nullable String;
begin
  result := self;
  var p := LastIndexOf(aSeparator);
  if p > -1 then
    result := result.Substring(p+aSeparator.Length);
end;

method String.Replace(OldValue: String; NewValue: String): not nullable String;
begin
  if IsNullOrEmpty(OldValue) then
    raise new ArgumentNullException("OldValue");

  if NewValue = nil then
    NewValue := "";
  {$IF NOT TOFFEE}
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
  {$ELSEIF TOFFEE}
  exit mapped.stringByReplacingCharactersInRange(NSMakeRange(aStartIndex, aLength)) withString(aNewValue);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(aStartIndex, aLength).Insert(aStartIndex, aNewValue) as not nullable;
  {$ENDIF}
end;

method String.Remove(aStartIndex: Int32; aLength: Int32): not nullable String;
begin
  {$IF COOPER}
  exit (mapped.substring(0, aStartIndex)+mapped.substring(aStartIndex+aLength)) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.stringByReplacingCharactersInRange(NSMakeRange(aStartIndex, aLength)) withString("");
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(aStartIndex, aLength) as not nullable;
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
  {$ELSEIF TOFFEE}
  var lTotal: Integer := TotalWidth - mapped.length;
  if lTotal > 0 then begin
    var lChars := NSString.stringWithFormat("%c", PaddingChar);
    lChars := lChars.stringByPaddingToLength(lTotal) withString(PaddingChar) startingAtIndex(0);
    exit lChars + self;
  end;
  result := self;
  {$ELSEIF ECHOES}
  result := mapped.PadLeft(TotalWidth, PaddingChar);
  {$ELSEIF ISLAND}
  result := mapped.PadStart(TotalWidth, PaddingChar);
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
  {$ELSEIF TOFFEE}
  result := mapped;
  if result.Length < TotalWidth then
    result := mapped.stringByPaddingToLength(TotalWidth) withString(PaddingChar) startingAtIndex(0);
  {$ELSEIF ECHOES}
  result := mapped.PadRight(TotalWidth, PaddingChar);
  {$ELSEIF ISLAND}
  result := mapped.PadEnd(TotalWidth, PaddingChar);
  {$ENDIF}
end;

method String.ToLower: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(Locale.Current) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseString;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToLower as not nullable;
  {$ENDIF}
end;

method String.ToLowerInvariant: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(Locale.Invariant) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseStringWithLocale(Locale.Invariant);
  {$ELSEIF ECHOES}
  exit mapped.ToLowerInvariant as not nullable;
  {$ELSEIF ISLAND}
  exit mapped.ToLower(true) as not nullable;
  {$ENDIF}
end;

method String.ToLower(aLocale: Locale): not nullable String;
begin
  {$IF COOPER}
  exit mapped.toLowerCase(aLocale) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.lowercaseStringWithLocale(aLocale);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToLower(aLocale) as not nullable;
  {$ENDIF}
end;

method String.ToUpper: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(Locale.Current) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseString;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToUpper as not nullable;
  {$ENDIF}
end;

method String.ToUpperInvariant: not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(Locale.Invariant) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseStringWithLocale(Locale.Invariant);
  {$ELSEIF ECHOES}
  exit mapped.ToUpperInvariant as not nullable;
  {$ELSEIF ISLAND}
  exit mapped.ToUpper(true) as not nullable;
  {$ENDIF}
end;

method String.ToUpper(aLocale: Locale): not nullable String;
begin
  {$IF COOPER}
  exit mapped.toUpperCase(aLocale) as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.uppercaseStringWithLocale(aLocale);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToUpper(aLocale) as not nullable;
  {$ENDIF}
end;

//
// Trim
//

method String.Trim: not nullable String;
begin
  {$IF COOPER}
  result := Trim(WhiteSpaceCharacters);
  {$ELSEIF TOFFEE}
  result := mapped.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.Trim() as not nullable; // .NET Trim() does include CR/LF and Unicode whitespace
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

method String.Trim(const TrimChars: array of Char): not nullable String;
begin
  {$IF COOPER}
  var lStr := TrimStart(TrimChars);
  result := lStr.TrimEnd(TrimChars);
  {$ELSEIF TOFFEE}
  var lCharset := NSCharacterSet.characterSetWithCharactersInString(new PlatformString withCharacters(TrimChars) length(TrimChars.length));
  result := mapped.stringByTrimmingCharactersInSet(lCharset);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.Trim(TrimChars) as not nullable;
  {$ENDIF}
end;

method String.TrimStart(const TrimChars: array of Char): not nullable String;
begin
  {$IF COOPER OR TOFFEE}
  var len := RemObjects.Elements.System.length(self);
  result := self;
  if len > 0 then begin
    var i: Integer := 0;
    while (i < len) and CharIsAnyOf(self[i], TrimChars) do
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

method String.StartsWith(Value: Char): Boolean;
begin
  result := (Length > 0) and (self[0] = Value);
end;

method String.StartsWith(Value: String): Boolean;
begin
  result := StartsWith(Value, False);
end;

method String.StartsWith(Value: String; IgnoreCase: Boolean): Boolean;
begin
  if RemObjects.Elements.System.length(Value) = 0 then
    exit true;

  {$IF COOPER}
  if IgnoreCase then
    result := mapped.regionMatches(IgnoreCase, 0, Value, 0, Value.length)
  else
    result := mapped.StartsWith(Value);
  {$ELSEIF TOFFEE}
  if Value.Length > mapped.length then begin
    result := false;
  end
  else begin
    if IgnoreCase then
      result := (mapped.compare(Value) options(NSStringCompareOptions.NSCaseInsensitiveSearch) range(NSMakeRange(0, Value.length)) = NSComparisonResult.NSOrderedSame)
    else
      result := mapped.hasPrefix(Value);
  end;
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
  {$ENDIF}
end;

method String.EndsWith(Value: Char): Boolean;
begin
  var len := Length;
  result := (len > 0) and (self[len-1] = Value);
end;

method String.EndsWith(Value: String): Boolean;
begin
  result := EndsWith(Value, False);
end;

method String.EndsWith(Value: String; IgnoreCase: Boolean): Boolean;
begin
  if RemObjects.Elements.System.length(Value) = 0 then
    exit true;

  {$IF COOPER}
  if IgnoreCase then
    result := mapped.toUpperCase.endsWith(PlatformString(Value).toUpperCase)
  else
    result := mapped.endsWith(Value);
  {$ELSEIF TOFFEE}
  if Value.Length > mapped.length then begin
    result := false;
  end
  else begin
    if IgnoreCase then
      result := (mapped.compare(Value) options(NSStringCompareOptions.NSCaseInsensitiveSearch) range(NSMakeRange(mapped.length - Value.length, Value.length)) = NSComparisonResult.NSOrderedSame)
    else
      result := mapped.hasSuffix(Value);
  end;
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
  {$ENDIF}
end;

method String.ToCharArray: not nullable array of Char;
begin
  {$IF COOPER}
  exit mapped.ToCharArray as not nullable;
  {$ELSEIF TOFFEE}
  result := new Char[mapped.length];
  mapped.getCharacters(result) range(NSMakeRange(0, mapped.length));
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToCharArray as not nullable;
  {$ENDIF}
end;

method String.ToByteArray: not nullable array of Byte;
begin
  result := Encoding.UTF8.GetBytes(self) includeBOM(false);
end;

method String.ToByteArray(aEncoding: not nullable Encoding): not nullable array of Byte;
begin
  result := aEncoding.GetBytes(self);
end;

class method String.Join(aSeparator: nullable String; Values: not nullable array of String): not nullable String;
begin
  {$IF COOPER}
  var sb := new StringBuilder;
  for i: Integer := 0 to length(Values)-1 do begin
     if (i ≠ 0) and assigned(aSeparator) then
      sb.append(aSeparator);
    sb.append(Values[i]);
  end;
  result := sb.toString as not nullable;
  {$ELSEIF TOFFEE}
  var lArray := new NSMutableArray withCapacity(Values.length);
  for i: Integer := 0 to Values.length - 1 do
    lArray.addObject(Values[i]);

  result := lArray.componentsJoinedByString(aSeparator);
  {$ELSEIF ECHOES OR ISLAND}
  result := PlatformString.Join(aSeparator, Values) as not nullable;
  {$ENDIF}
end;

class method String.&Join(aSeparator: nullable String; Values: not nullable ImmutableList<String>): not nullable String;
begin
  {$IF COOPER}
  var sb := new StringBuilder;
  for i: Integer := 0 to Values.Count-1 do begin
     if (i ≠ 0) and assigned(aSeparator) then
      sb.append(aSeparator);
    sb.append(Values[i]);
  end;
  result := sb.toString as not nullable;
  {$ELSEIF TOFFEE}
  result := (Values as NSArray).componentsJoinedByString(aSeparator);
  {$ELSEIF ECHOES OR ISLAND}
  result := PlatformString.Join(aSeparator, Values.ToArray) as not nullable;
  {$ENDIF}
end;

{$IF COOPER}
operator String.Implicit(aCharSequence: CharSequence): String;
begin
  result := aCharSequence:toString()
end;

operator String.Implicit(aString: String): CharSequence;
begin
  result := (aString as PlatformString) as CharSequence;
end;
{$ENDIF}

end.