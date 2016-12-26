namespace RemObjects.Elements.RTL;

interface

type
  GuidFormat = public enum (&Default, Braces, Parentheses);
  
  {$IF JAVA}
  PlatformGuid = java.util.UUID;
  {$ELSEIF ECHOES}
  PlatformGuid = System.Guid;
  {$ELSEIF ISLAND}
  PlatformGuid = RemObjects.Elements.System.Guid;
  {$ELSEIF TOFFEE}
  PlatformGuid = Foundation.NSUUID;
  {$ENDIF}

  Guid = public class {$IF COOPER OR TOFFEE}mapped to PlatformGuid{$ENDIF}
  private
    {$IF ECHOES OR ISLAND}
    fGuid: PlatformGuid;
    {$ENDIF}

    class method CreateEmptyGuid: not nullable Guid;
    {$IF ECHOES}
    class method Exchange(Value: array of Byte; Index1, Index2: Integer);
    {$ENDIF}
  public
    constructor(aValue: not nullable array of Byte);
    constructor(aValue: not nullable String);
    {$IF ECHOES OR ISLAND}
    constructor (aGuid: PlatformGuid);
    {$ENDIF}

    method &Equals(aValue: Guid): Boolean;

    class method NewGuid: Guid;
    //class property EmptyGuid: not nullable Guid := CreateEmptyGuid(); lazy;
    class property EmptyGuid: not nullable Guid read CreateEmptyGuid;

    class method TryParse(aValue: String): nullable Guid;

    method ToByteArray: array of Byte;
    method ToString(Format: GuidFormat): String;

    {$IF COOPER OR ECHOES OR ISLAND}
    method ToString: PlatformString; override;
    {$ELSEIF TOFFEE}
    method description: PlatformString;
    {$ENDIF}    
  end;


implementation

{$IF ECHOES OR ISLAND}
constructor Guid(aGuid: PlatformGuid);
begin
  fGuid := aGuid;
end;
{$ENDIF}

constructor Guid(aValue: not nullable array of Byte);
begin
  {$IF COOPER}
  var bb := java.nio.ByteBuffer.wrap(aValue);
  result := new java.util.UUID(bb.getLong, bb.getLong);
  {$ELSEIF ECHOES}
  //reverse byte order to normal (.NET reverse first 4 bytes and next two 2 bytes groups)
  Exchange(aValue, 0, 3);
  Exchange(aValue, 1, 2);
  Exchange(aValue, 4, 5);
  Exchange(aValue, 6, 7);
  fGuid := New PlatformGuid(aValue);
  {$ELSEIF TOFFEE}
  //result := new NSUUID withUUIDBytes(uuid_t(aValue));
  raise new RTLException("not implemented yet");
  {$ENDIF}
end;

constructor Guid(aValue: not nullable String);
begin
  {$IF COOPER}
  result := TryParse(aValue);
  if not assigned(result) then
    raise new FormatException();
  {$ELSEIF ECHOES}
  fGuid := new PlatformGuid(aValue);
  {$ELSEIF TOFFEE}
  result := TryParse(aValue);
  if not assigned(result) then
    raise new FormatException();
  {$ENDIF}
end;

method Guid.Equals(aValue: Guid): Boolean;
begin
  {$IF COOPER}
  result := mapped.Equals(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  result := fGuid.Equals(aValue);
  {$ELSEIF TOFFEE}
  result := mapped.isEqual(aValue);
  {$ENDIF}
end;

class method Guid.NewGuid: Guid;
begin
  {$IF COOPER}
  exit mapped.randomUUID;
  {$ELSEIF ECHOES OR ISLAND}
  exit new Guid(PlatformGuid.NewGuid);
  {$ELSEIF TOFFEE}
  result := NSUUID.UUID;
  {$ENDIF}
end;

class method Guid.TryParse(aValue: String): Guid;
begin
  if (aValue.Length <> 38) and (aValue.Length <> 36) then
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
  {$ELSEIF ECHOES}// OR ISLAND}
  var lGuid: PlatformGuid;
  if not PlatformGuid.TryParse(aValue, out lGuid) then
    exit nil;
  result := new Guid(lGuid);
  {$ELSEIF TOFFEE}
  if aValue.StartsWith("{") and aValue.EndsWith("}") then
    aValue := aValue.Substring(1,length(aValue)-2);
  result := new NSUUID withUUIDString(aValue);
  {$ENDIF}
end;

class method Guid.CreateEmptyGuid: not nullable Guid;
begin
  {$IF COOPER}
  exit new java.util.UUID(0, 0);
  {$ELSEIF ECHOES OR ISLAND}
  exit new Guid(PlatformGuid.Empty);
  {$ELSEIF TOFFEE}
  var lBytes := new byte[16];
  memset(lBytes, 0, 16);
  //exit new NSUUID withUUIDBytes(@lBytes);
  raise new RTLException("not implemented yet");
  {$ENDIF}
end;

method Guid.ToByteArray: array of Byte;
begin
  {$IF COOPER}
  var buffer := java.nio.ByteBuffer.wrap(new SByte[16]);
  buffer.putLong(mapped.MostSignificantBits);
  buffer.putLong(mapped.LeastSignificantBits);
  exit buffer.array;
  {$ELSEIF ECHOES}
  var Value := fGuid.ToByteArray;
  //reverse byte order to normal (.NET reverse first 4 bytes and next two 2 bytes groups)
  Exchange(Value, 0, 3);
  Exchange(Value, 1, 2);
  Exchange(Value, 4, 5);
  Exchange(Value, 6, 7);
  exit Value;
  {$ELSEIF TOFFEE}
  result := new Byte[16];
  //mapped.getUUIDBytes(@result)
  {$ENDIF}
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
  {$ELSEIF ECHOES}
  case Format of
    Format.Default: result := fGuid.ToString("D");
    Format.Braces: result := fGuid.ToString("B");
    Format.Parentheses: result := fGuid.ToString("P");
    else result := fGuid.ToString("D");
  end;
  {$ELSEIF TOFFEE}
  result := mapped.UUIDString;
  case Format of
    Format.Default: ;
    Format.Braces: result := "{"+result+"}";
    Format.Parentheses: result := "("+result+")";
  end;
  {$ENDIF}
  result := result.ToUpper();
end;

{$IF COOPER OR ECHOES OR ISLAND}
method Guid.ToString: PlatformString;
{$ELSEIF TOFFEE}
method Guid.description: NSString;
{$ENDIF}
begin
  result := self.ToString(GuidFormat.Default);
end;

{$IF ECHOES}
class method Guid.Exchange(Value: array of Byte; Index1: Integer; Index2: Integer);
begin
  var Temp := Value[Index1];
  Value[Index1] := Value[Index2];
  Value[Index2] := Temp;
end;
{$ENDIF}

end.
