namespace RemObjects.Elements.RTL;

interface

type
  GuidFormat = public enum (&Default, Braces, Parentheses);

  {$IF JAVA}
  PlatformGuid = public java.util.UUID;
  {$ELSEIF TOFFEE}
  PlatformGuid = public Foundation.NSUUID;
  {$ELSEIF ECHOES}
  PlatformGuid = public System.Guid;
  {$ELSEIF ISLAND}
  PlatformGuid = public RemObjects.Elements.System.Guid;
  {$ENDIF}

  Guid = public class {$IF COOPER OR TOFFEE} mapped to PlatformGuid {$ENDIF}
  private
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    fGuid: PlatformGuid;
    {$ENDIF}

    class method CreateEmptyGuid: not nullable Guid;
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    class method Exchange(Value: array of Byte; Index1, Index2: Integer);
    {$ENDIF}
  public
    constructor(aValue: not nullable array of Byte);
    constructor(aValue: not nullable String);
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    constructor (aGuid: PlatformGuid);
    property PlatformGuid: PlatformGuid read fGuid;
    {$ELSE}
    property PlatformGuid: PlatformGuid read self as PlatformGuid;
    {$ENDIF}

    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    operator Implicit(aGuid: PlatformGuid): Guid;
    operator Implicit(aGuid: Guid): PlatformGuid;
    {$ENDIF}

    {$IF NOT (COOPER OR TOFFEE)}
    [&Equals]
    method &Equals(aValue: Object): Boolean; override;
    [Hash]
    method GetHashCode: Integer; override;
    {$ENDIF}

    operator Equal(a, b: Guid): Boolean;
    operator NotEqual(a, b: Guid): Boolean;

    class method NewGuid: Guid;
    //class property EmptyGuid: not nullable Guid := CreateEmptyGuid(); lazy;
    [Obsolete("Use Guid.Empty, instead")]
    class property EmptyGuid: not nullable Guid read &Empty;
    class property &Empty: not nullable Guid read CreateEmptyGuid; //lazy; readonly;

    class method TryParse(aValue: nullable String): nullable Guid;

    method ToByteArray: array of Byte;
    method ToString: String; {$IF ISLAND OR ECHOES}override;{$ENDIF}
    method ToString(Format: GuidFormat): String;

  end;


implementation

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
constructor Guid(aGuid: PlatformGuid);
begin
  fGuid := aGuid;
end;
{$ENDIF}

constructor Guid(aValue: not nullable array of Byte);
begin
  if length(aValue) ≠ 16 then
    raise new ArgumentException("byte array must be exactly 16 bytes.");
  {$IF COOPER}
  var bb := java.nio.ByteBuffer.wrap(aValue);
  result := new java.util.UUID(bb.getLong, bb.getLong);
  {$ELSEIF TOFFEE}
  var lBytes: uuid_t;
  rtl.memcpy(lBytes, aValue, sizeOf(uuid_t));
  result := new NSUUID withUUIDBytes(var lBytes);
  {$ELSEIF ECHOES}
  //reverse byte order to normal (.NET reverse first 4 bytes and next two 2 bytes groups)
  var aFixedValue := new Byte[16];
  &Array.Copy(aValue, aFixedValue, 16);
  Exchange(aFixedValue, 0, 3);
  Exchange(aFixedValue, 1, 2);
  Exchange(aFixedValue, 4, 5);
  Exchange(aFixedValue, 6, 7);
  fGuid := New PlatformGuid(aFixedValue);
  {$ELSEIF ISLAND}
  //reverse byte order to normal (Island reverse first 4 bytes and next two 2 bytes groups, to match .NET)
  var aFixedValue := new Byte[16];
  &Array.Copy(aValue, aFixedValue, 16);
  Exchange(aFixedValue, 0, 3);
  Exchange(aFixedValue, 1, 2);
  Exchange(aFixedValue, 4, 5);
  Exchange(aFixedValue, 6, 7);
  fGuid := New PlatformGuid(aFixedValue);
  {$ENDIF}
end;

constructor Guid(aValue: not nullable String);
begin
  {$IF COOPER}
  result := TryParse(aValue);
  if not assigned(result) then
    raise new FormatException();
  {$ELSEIF TOFFEE}
  result := TryParse(aValue);
  if not assigned(result) then
    raise new FormatException();
  {$ELSEIF ECHOES OR ISLAND}
  fGuid := new PlatformGuid(aValue);
  {$ENDIF}
end;

{$IF NOT (COOPER OR TOFFEE)}
method Guid.&Equals(aValue: Object): Boolean;
begin
  if not assigned(aValue) or (aValue is not Guid) then
    exit false;
  {$IF COOPER}
  result := mapped.Equals(aValue);
  {$ELSEIF TOFFEE}
  if not assigned(aValue) or (aValue is not Guid) then
    exit false;
  result := mapped.isEqual(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  result := fGuid.Equals((aValue as Guid).fGuid);
  {$ENDIF}
end;

method Guid.GetHashCode: Integer;
begin
  {$IF COOPER}
  result := mapped.GetHashCode;
  {$ELSEIF TOFFEE}
  result := mapped.hash;
  {$ELSEIF ECHOES OR ISLAND}
  result := fGuid.GetHashCode;
  {$ENDIF}
end;
{$ENDIF}

operator Guid.Equal(a, b: Guid): Boolean;
begin
  if not assigned(a) then exit not assigned(b);
  result := a.Equals(b);
end;

operator Guid.NotEqual(a, b: Guid): Boolean;
begin
  if not assigned(a) then exit assigned(b);
  result := not a.Equals(b);
end;

class method Guid.NewGuid: Guid;
begin
  {$IF COOPER}
  exit mapped.randomUUID;
  {$ELSEIF TOFFEE}
  result := NSUUID.UUID;
  {$ELSEIF ECHOES OR ISLAND}
  exit new Guid(PlatformGuid.NewGuid);
  {$ENDIF}
end;

class method Guid.TryParse(aValue: nullable String): nullable Guid;
begin
  if length(aValue) not in [36, 38] then
    exit nil;

  if aValue.Chars[0] = '{' then begin
    if aValue.Chars[37] <> '}' then
    exit nil;
  end
  else if aValue.Chars[0] = '(' then begin
    if aValue.Chars[37] <> ')' then
      exit nil;
  end;

  {$IF COOPER}
  aValue := java.lang.String(aValue.ToUpper).replaceAll("[{}()]", "");
  exit mapped.fromString(aValue);
  {$ELSEIF TOFFEE}
  if aValue.StartsWith("{") and aValue.EndsWith("}") then
    aValue := aValue.Substring(1,length(aValue)-2);
  result := new NSUUID withUUIDString(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  var lGuid: PlatformGuid;
  if not PlatformGuid.TryParse(aValue, out lGuid) then
    exit nil;
  result := new Guid(lGuid);
  {$ENDIF}
end;

class method Guid.CreateEmptyGuid: not nullable Guid;
begin
  {$IF COOPER}
  exit new java.util.UUID(0, 0);
  {$ELSEIF TOFFEE}
  var lBytes: uuid_t;
  rtl.memset(lBytes, 0, sizeOf(uuid_t));
  exit new NSUUID withUUIDBytes(var lBytes);
  {$ELSEIF ECHOES OR ISLAND}
  exit new Guid(PlatformGuid.Empty);
  {$ENDIF}
end;

method Guid.ToByteArray: array of Byte;
begin
  {$IF COOPER}
  var buffer := java.nio.ByteBuffer.wrap(new SByte[16]);
  buffer.putLong(mapped.MostSignificantBits);
  buffer.putLong(mapped.LeastSignificantBits);
  exit buffer.array;
  {$ELSEIF TOFFEE}
  result := new Byte[sizeOf(uuid_t)];
  var lBytes: uuid_t;
  mapped.getUUIDBytes(var lBytes);
  rtl.memcpy(result, lBytes, sizeOf(uuid_t));
  {$ELSEIF ECHOES}
  var Value := fGuid.ToByteArray;
  //reverse byte order to normal (.NET reverse first 4 bytes and next two 2 bytes groups)
  Exchange(Value, 0, 3);
  Exchange(Value, 1, 2);
  Exchange(Value, 4, 5);
  Exchange(Value, 6, 7);
  exit Value;
  {$ELSEIF ISLAND}
  var Value := fGuid.ToByteArray;
  //reverse byte order to normal (Island reverse first 4 bytes and next two 2 bytes groups, to match .NET)
  Exchange(Value, 0, 3);
  Exchange(Value, 1, 2);
  Exchange(Value, 4, 5);
  Exchange(Value, 6, 7);
  exit Value;
  {$ENDIF}
end;

method Guid.ToString: String;
begin
  result := ToString(GuidFormat.Default);
end;

method Guid.ToString(Format: GuidFormat): String;
begin
  {$IF COOPER}
  case Format of
    Format.Default: result := mapped.toString;
    Format.Braces: result := "{"+mapped.toString+"}";
    Format.Parentheses: result := "("+mapped.toString+")";
    else result := mapped.toString;
  end;
  {$ELSEIF TOFFEE}
  result := mapped.UUIDString;
  case Format of
    Format.Default: ;
    Format.Braces: result := "{"+result+"}";
    Format.Parentheses: result := "("+result+")";
  end;
  {$ELSEIF ECHOES}
  case Format of
    Format.Default: result := fGuid.ToString("D");
    Format.Braces: result := fGuid.ToString("B");
    Format.Parentheses: result := fGuid.ToString("P");
    else result := fGuid.ToString("D");
  end;
  {$ELSEIF ISLAND}
  result := fGuid.ToString;
  case Format of
    Format.Braces: result := "{"+result+"}";
    Format.Parentheses: result := "("+result+")";
  end;
  {$ENDIF}
  result := result.ToUpper();
end;

//method Guid.ToString: String;
//begin
  //result := self.ToString(GuidFormat.Default);
//end;

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
class method Guid.Exchange(Value: array of Byte; Index1: Integer; Index2: Integer);
begin
  var Temp := Value[Index1];
  Value[Index1] := Value[Index2];
  Value[Index2] := Temp;
end;
{$ENDIF}

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
operator Guid.Implicit(aGuid: PlatformGuid): Guid;
begin
  result := new Guid(aGuid);
end;

operator Guid.Implicit(aGuid: Guid): PlatformGuid;
begin
  result := aGuid.fGuid;
end;

{$ENDIF}

end.