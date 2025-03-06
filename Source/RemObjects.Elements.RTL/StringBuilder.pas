namespace RemObjects.Elements.RTL;

interface

type
  {$IF COOPER}
  PlatformStringBuilder = public java.lang.StringBuilder;
  {$ELSEIF TOFFEE}
  PlatformStringBuilder = public Foundation.NSMutableString;
  {$ELSEIF ECHOES}
  PlatformStringBuilder = public System.Text.StringBuilder;
  {$ELSEIF ISLAND}
  PlatformStringBuilder = public RemObjects.Elements.System.StringBuilder;
  {$ENDIF}

  StringBuilder = public class mapped to PlatformStringBuilder
  private
    method get_Chars(&Index : Integer): Char;
    method set_Chars(&Index : Integer; Value: Char);
    method set_Length(Value: Integer);
  public
    constructor; mapped to constructor();
    constructor(Capacity: Integer); mapped to {$IF NOT TOFFEE}constructor(Capacity){$ELSE}stringWithCapacity(Capacity){$ENDIF};
    constructor(Data: String); mapped to {$IF NOT TOFFEE}constructor(Data){$ELSE}stringWithString(Data){$ENDIF};

    method Append(Value: nullable String): StringBuilder; inline;
    method Append(Value: nullable String; StartIndex, Count: Integer): StringBuilder; inline;
    method Append(Value: Char; RepeatCount: Integer): StringBuilder; inline;
    method Append(Value: Char): StringBuilder; inline;
    method AppendLine: StringBuilder;  inline;
    method AppendLine(Value: nullable String): StringBuilder; inline;
    method AppendLine(aFormat: nullable String; params aParams: array of Object): StringBuilder; inline;
    method AppendFormat(aFormat: String; params aParams: array of Object): StringBuilder; inline;

    method Clear; inline;
    method Delete(StartIndex, Count: Integer): StringBuilder; inline;
    method Replace(StartIndex, Count: Integer; Value: String): StringBuilder; inline;
    method Substring(StartIndex: Integer): String; inline;
    method Substring(StartIndex, Count: Integer): String; inline;
    method Insert(Offset: Integer; Value: String): StringBuilder; inline;

    property Length: Integer read mapped.length write set_Length;
    property Chars[&Index: Integer]: Char read get_Chars write set_Chars; default;
  end;

implementation

method StringBuilder.Append(Value: Char; RepeatCount: Integer): StringBuilder;
begin
  if RepeatCount < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Number of repeats");

  {$IF COOPER}
  for i: Int32 := 1 to RepeatCount do
    mapped.append(Value);

  result := mapped;
  {$ELSEIF TOFFEE}
  mapped.appendString(new String(Value, RepeatCount));
  result := mapped;
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.Append(Value, RepeatCount);
  {$ENDIF}
end;

method StringBuilder.Append(Value: Char): StringBuilder;
begin
  {$IF COOPER}
  mapped.append(Value);
  result := mapped;
  {$ELSEIF TOFFEE}
  mapped.appendString(NSString.stringWithCharacters(@Value) length(1));
  result := mapped;
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.Append(Value);
  {$ENDIF}
end;

method StringBuilder.Append(Value: nullable String): StringBuilder;
begin
  if Value = nil then
    exit;

  {$IF NOT TOFFEE}
  exit mapped.Append(Value);
  {$ELSEIF TOFFEE}
  mapped.appendString(Value);
  exit mapped;
  {$ENDIF}
end;

method StringBuilder.Append(Value: nullable String; StartIndex: Integer; Count: Integer): StringBuilder;
begin
  if (StartIndex = 0) and (Count = 0) then
    exit mapped;

  if Value = nil then
    exit;

  if (StartIndex < 0) or (Count < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Start index and count");

  {$IF COOPER}
  exit mapped.append(Value, startIndex, startIndex + count);
  {$ELSEIF TOFFEE}
  mapped.appendString(Value.Substring(StartIndex, Count));
  exit mapped;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Append(Value, StartIndex, Count);
  {$ENDIF}
end;

method StringBuilder.AppendLine(Value: nullable String): StringBuilder;
begin
  {$IF COOPER}
  if assigned(Value) then
    mapped.append(Value);
  mapped.append(Environment.LineBreak);
  exit mapped;
  {$ELSEIF TOFFEE}
  if assigned(Value) then
    mapped.appendString(Value);
  mapped.appendString(Environment.LineBreak);
  exit mapped;
  {$ELSEIF ECHOES OR ISLAND}
  if assigned(Value) then
    mapped.AppendLine(Value)
  else
    mapped.AppendLine();
  exit mapped
  {$ENDIF}
end;

method StringBuilder.AppendLine(aFormat: nullable String; params aParams: array of Object): StringBuilder;
begin
  result := AppendLine(String.Format(aFormat, aParams));
end;

method StringBuilder.AppendFormat(aFormat: String; params aParams: array of Object): StringBuilder;
begin
  result := Append(String.Format(aFormat, aParams));
end;

method StringBuilder.AppendLine: StringBuilder;
begin
  {$IF COOPER}
  mapped.append(Environment.LineBreak);
  exit mapped;
  {$ELSEIF TOFFEE}
  mapped.appendString(Environment.LineBreak);
  exit mapped;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.AppendLine;
  {$ENDIF}
end;

method StringBuilder.Clear;
begin
  {$IF COOPER}
  mapped.SetLength(0);
  {$ELSEIF TOFFEE}
  mapped.SetString("");
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Length := 0;
  {$ENDIF}
end;

method StringBuilder.Delete(StartIndex: Integer; Count: Integer): StringBuilder;
begin
  if Count > self.Length then
    raise new ArgumentOutOfRangeException("Count is greater than length of buffer");

  {$IF COOPER}
  exit mapped.delete(StartIndex, StartIndex + Count);
  {$ELSEIF TOFFEE}
  mapped.deleteCharactersInRange(NSMakeRange(StartIndex, Count));
  exit mapped;
  {$ELSEIF ECHOES OR ISLAND}
   exit mapped.Remove(StartIndex, Count);
  {$ENDIF}
end;

method StringBuilder.get_Chars(&Index: Integer): Char;
begin
  if &Index  < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Index");

  {$IF COOPER}
  exit mapped.charAt(&Index);
  {$ELSEIF TOFFEE}
  result := mapped.characterAtIndex(&Index);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Chars[&Index];
  {$ENDIF}
end;

method StringBuilder.Insert(Offset: Integer; Value: String): StringBuilder;
begin
  if Value = nil then
    raise new ArgumentNullException("Value");

  {$IF NOT TOFFEE}
  exit mapped.Insert(Offset, Value);
  {$ELSEIF TOFFEE}
  mapped.insertString(Value) atIndex(Offset);
  exit mapped;
  {$ENDIF}
end;

method StringBuilder.Replace(StartIndex: Integer; Count: Integer; Value: String): StringBuilder;
begin
  if Count > self.Length then
    raise new ArgumentOutOfRangeException("Count is greater than length of buffer");

  if Value = nil then
    raise new ArgumentNullException("Value");

  {$IF COOPER}
  exit  mapped.replace(StartIndex, StartIndex + Count, Value);
  {$ELSEIF TOFFEE}
  mapped.replaceCharactersInRange(NSMakeRange(StartIndex, Count)) withString(Value);
  exit mapped;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Remove(StartIndex, Count);
  exit mapped.Insert(StartIndex, Value);
  {$ENDIF}
end;

method StringBuilder.set_Chars(&Index: Integer; Value: Char);
begin
  if &Index  < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Index");

  {$IF COOPER}
  mapped.setCharAt(&Index,Value);
  {$ELSEIF TOFFEE}
  mapped.replaceCharactersInRange(NSMakeRange(&Index, 1)) withString(Value);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Chars[&Index] := Value;
  {$ENDIF}
end;

method StringBuilder.set_Length(Value: Integer);
begin
  {$IF COOPER}
  mapped.setLength(Value);
  {$ELSEIF TOFFEE}
  if Value > mapped.length then
    Append(#0, Value - mapped.length)
  else
    mapped.deleteCharactersInRange(NSMakeRange(Value, mapped.length - Value));
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Length := Value;
  {$ENDIF}
end;

method StringBuilder.Substring(StartIndex: Integer): String;
begin
  {$IF COOPER}
  exit mapped.substring(StartIndex);
  {$ELSEIF TOFFEE}
  exit mapped.substringFromIndex(StartIndex);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToString(StartIndex, Length - StartIndex);
  {$ENDIF}
end;

method StringBuilder.Substring(StartIndex: Integer; Count: Integer): String;
begin
  if (StartIndex < 0) or (Count < 0) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Start index and count");

  {$IF COOPER}
  exit mapped.substring(StartIndex, StartIndex + Count);
  {$ELSEIF TOFFEE}
  exit mapped.substringWithRange(NSMakeRange(StartIndex, Count));
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToString(StartIndex, Count);
  {$ENDIF}
end;

end.