namespace RemObjects.Elements.RTL;

interface

type
  Encoding = public class {$IF COOPER}mapped to java.nio.charset.Charset{$ELSEIF ECHOES}mapped to System.Text.Encoding{$ELSEIF TOFFEE}mapped to Foundation.NSNumber{$ENDIF}
  private
    {$IF ISLAND}
    var fName: not nullable String;
    constructor (aName: not nullable String);
    {$ENDIF}
    method GetName: not nullable String;
    method GetIsUTF8: Boolean;
  public
    method GetBytes(aValue: String): not nullable array of Byte; inline;
    method GetBytes(aValue: String) includeBOM(aBOM: Boolean): not nullable array of Byte;

    method GetString(aValue: not nullable array of Byte): String;
    method GetString(aValue: not nullable array of Byte; aOffset: Integer; aCount: Integer): String;

    class method GetEncoding(aName: not nullable String): nullable Encoding;
    property Name: not nullable String read GetName;
    property isUTF8: Boolean read GetIsUTF8;

    class property ASCII: not nullable Encoding read GetEncoding("US-ASCII") as not nullable;
    class property UTF8: not nullable Encoding read GetEncoding("UTF-8") as not nullable;
    class property UTF16LE: not nullable Encoding read GetEncoding("UTF-16LE") as not nullable;
    class property UTF16BE: not nullable Encoding read GetEncoding("UTF-16BE") as not nullable;

    class property &Default: not nullable Encoding read UTF8;

    {$IF TOFFEE}
    method AsNSStringEncoding: NSStringEncoding;
    class method FromNSStringEncoding(aEncoding: NSStringEncoding): Encoding;
    {$ENDIF}
  end;

implementation

method Encoding.GetBytes(aValue: String): not nullable array of Byte;
begin
  result := GetBytes(aValue) includeBOM(false);
end;

method Encoding.GetBytes(aValue: String) includeBOM(aBOM: Boolean): not nullable array of Byte;
begin
  {$WARNING Still needs to handle BOM option for non-Toffee and non-UTF-8}
  ArgumentNullException.RaiseIfNil(aValue, "aValue");
  {$IF COOPER}
  var Buffer := java.nio.charset.Charset(self).encode(aValue);
  result := new Byte[Buffer.remaining];
  Buffer.get(result);
  {$ELSEIF ECHOES}
  exit mapped.GetBytes(aValue) as not nullable;
  {$ELSEIF ISLAND}
  result := case fName.ToUpper.Replace("-", "") of
              "UTF8": TextConvert.StringToUTF8(aValue);
              "UTF16": TextConvert.StringToUTF16(aValue);
              "UTF16BE": TextConvert.StringToUTF16BE(aValue);
              "UTF16LE": TextConvert.StringToUTF16LE(aValue);
              "UTF32": TextConvert.StringToUTF32(aValue);
              "UTF32BE": TextConvert.StringToUTF32BE(aValue);
              "UTF32LE": TextConvert.StringToUTF32LE(aValue);
              //"ASCII","USASCII","UTFASCII": TextConvert.StringToASCII(aValue);
            end;
  {$ELSEIF TOFFEE}
  var lResult := ((aValue as NSString).dataUsingEncoding(self.AsNSStringEncoding) allowLossyConversion(true) as Binary);
  if not assigned(lResult) then
    raise new FormatException("Unable to convert data");
  if isUTF8 and aBOM then begin
    var lBOM: array of Byte := [$EF, $BB, $BF];
    var lResult2 := new Binary();
    lResult2.Write(lBOM);
    lResult2.Write(lResult);
    lResult := lResult2;
  end;
  result := lResult.ToArray();
  {$ENDIF}
end;

method Encoding.GetString(aValue: not nullable array of Byte; aOffset: Integer; aCount: Integer): String;
begin
  if aValue = nil then
    raise new ArgumentNullException("aValue");
  if aCount = 0 then
    exit "";

  RangeHelper.Validate(new Range(aOffset, aCount), aValue.Length);
  {$IF COOPER}
  var Buffer := java.nio.charset.Charset(self).newDecoder.
    onMalformedInput(java.nio.charset.CodingErrorAction.REPLACE).
    onUnmappableCharacter(java.nio.charset.CodingErrorAction.REPLACE).
    replaceWith("?").
    decode(java.nio.ByteBuffer.wrap(aValue, aOffset, aCount));
  result := Buffer.toString;
  {$ELSEIF ECHOES}
  if isUTF8 and (length(aValue) >= aOffset+3) and (aValue[aOffset] = $EF) and (aValue[aOffset+1] = $BB) and (aValue[aOffset+2] = $BF) then begin
    inc(aOffset, 3);
    dec(aCount, 3);
  end;
  result := mapped.GetString(aValue, aOffset, aCount);
  {$ELSEIF ISLAND}
  result := case fName.ToUpper.Replace("-","") of
              "UTF8": TextConvert.UTF8ToString(aValue /*, aOffset, aCunt*/);
              "UTF16": TextConvert.UTF16ToString(aValue /*, aOffset, aCunt*/);
              "UTF16BE": TextConvert.UTF16BEToString(aValue /*, aOffset, aCunt*/);
              "UTF16LE": TextConvert.UTF16LEToString(aValue /*, aOffset, aCunt*/);
              "UTF32": TextConvert.UTF32ToString(aValue /*, aOffset, aCunt*/);
              "UTF32BE": TextConvert.UTF32BEToString(aValue /*, aOffset, aCunt*/);
              "UTF32LE": TextConvert.UTF32LEToString(aValue /*, aOffset, aCunt*/);
              //"ASCII","USASCII","UTFASCII": TextConvert.ASCIIToString(aValue /*, aOffset, aCunt*/);
            end;
  {$ELSEIF TOFFEE}
  result := new NSString withBytes(@aValue[aOffset]) length(aCount) encoding(self.AsNSStringEncoding);
  if not assigned(result) then
    raise new FormatException("Unable to convert input data");
  {$ENDIF}
end;

method Encoding.GetString(aValue: not nullable array of Byte): String;
begin
  if aValue = nil then
    raise new ArgumentNullException("aValue");
  exit GetString(aValue, 0, aValue.length);
end;

class method Encoding.GetEncoding(aName: not nullable String): nullable Encoding;
begin
  try
    {$IF COOPER}
    exit java.nio.charset.Charset.forName(aName);
    {$ELSEIF WINDOWS_PHONE}
    result := CustomEncoding.ForName(aName);

    if result = nil then
      result := System.Text.Encoding.GetEncoding(aName);
    {$ELSEIF ECHOES}
    result := System.Text.Encoding.GetEncoding(aName);
    {$ELSEIF ISLAND}
    if aName.ToUpper() not in ['US-ASCII', 'ASCII','UTF-ASCII','UTF8','UTF-8','UTF16','UTF-16','UTF32','UTF-32','UTF16LE','UTF-16LE','UTF32LE','UTF-32LE','UTF16BE','UTF-16BE','UTF32BE','UTF-32BE'] then
      raise new Exception(String.Format('Unknown Encoding "{0}"', aName));
    result := new Encoding(aName.ToUpper);
    {$ELSEIF TOFFEE}
    var lEncoding := NSStringEncoding.UTF8StringEncoding;
    case aName of
      'UTF8','UTF-8': lEncoding := NSStringEncoding.UTF8StringEncoding;
      'UTF16','UTF-16': lEncoding := NSStringEncoding.UTF16StringEncoding;
      'UTF32','UTF-32': lEncoding := NSStringEncoding.UTF32StringEncoding;
      'UTF16LE','UTF-16LE': lEncoding := NSStringEncoding.UTF16LittleEndianStringEncoding;
      'UTF16BE','UTF-16BE': lEncoding := NSStringEncoding.UTF16BigEndianStringEncoding;
      'UTF32LE','UTF-32LE': lEncoding := NSStringEncoding.UTF32LittleEndianStringEncoding;
      'UTF32BE','UTF-32BE': lEncoding := NSStringEncoding.UTF32BigEndianStringEncoding;
      'US-ASCII', 'ASCII','UTF-ASCII': lEncoding := NSStringEncoding.ASCIIStringEncoding;
      else begin
        var lH := CFStringConvertIANACharSetNameToEncoding(bridge<CFStringRef>(aName));
        if lH = kCFStringEncodingInvalidId then
          raise new ArgumentException();
        lEncoding := CFStringConvertEncodingToNSStringEncoding(lH) as NSStringEncoding;
      end;
    end;
    result := NSNumber.numberWithUnsignedInt(lEncoding);
    {$ENDIF}
  except
    result := nil;
  end;
end;

method Encoding.GetName: not nullable String;
begin
  {$IF COOPER}
  exit mapped.name as not nullable;
  {$ELSEIF ECHOES}
  exit mapped.WebName as not nullable;
  {$ELSEIF ISLAND}
  exit fName as not nullable;
  {$ELSEIF TOFFEE}
  var lName := CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(mapped.unsignedIntValue));
  if not assigned(lName) then
    raise new Exception("Invalid encoding.");
  result := bridge<NSString>(lName, BridgeMode.Transfer) as not nullable;
  {$ENDIF}
end;

method Encoding.GetIsUTF8: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-8";
  {$ELSEIF ISLAND}
  result := fName.ToUpper.Replace("-", "") = "UTF8";
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF8StringEncoding;
  {$ENDIF}
end;

{$IF TOFFEE}
method Encoding.AsNSStringEncoding: NSStringEncoding;
begin
  result := (self as NSNumber).unsignedIntegerValue as NSStringEncoding;
end;

class method Encoding.FromNSStringEncoding(aEncoding: NSStringEncoding): Encoding;
begin
  result := NSNumber.numberWithUnsignedInteger(aEncoding);
end;

{$ENDIF}

{$IF ISLAND}
constructor Encoding(aName: not nullable String);
begin
  fName := aName;
end;
{$ENDIF}

end.