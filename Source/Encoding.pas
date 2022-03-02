namespace RemObjects.Elements.RTL;

interface

type
  {$IF COOPER}
  PlatformEncoding = public java.nio.charset.Charset;
  {$ELSEIF TOFFEE}
  PlatformEncoding = public Foundation.NSNumber;
  {$ELSEIF ECHOES}
  PlatformEncoding = public System.Text.Encoding;
  {$ELSEIF ISLAND}
  PlatformEncoding = public RemObjects.Elements.System.Encoding;
  {$ENDIF}

  Encoding = public class mapped to PlatformEncoding
  private
    method GetName: not nullable String;
    method GetIsUTF8: Boolean;
    method GetIsUTF16BE: Boolean;
    method GetIsUTF16LE: Boolean;
    method GetIsUTF32BE: Boolean;
    method GetIsUTF32LE: Boolean;
    method SkipBOM(aValue: not nullable array of Byte; var aOffset: Integer; var aCount: Integer): Boolean;

  public
    method GetBytes(aValue: String): not nullable array of Byte; inline;
    method GetBytes(aValue: String) includeBOM(aIncludeBOM: Boolean): not nullable array of Byte;

    method GetString(aValue: not nullable array of Byte): String;
    method GetString(aValue: not nullable array of Byte; aOffset: Integer; aCount: Integer): String;

    method GetString(aValue: not nullable ImmutableBinary): String;
    {$IF ISLAND AND DARWIN AND NOT TOFFEE}
    method GetString(aValue: not nullable Foundation.NSData): String;
    {$ENDIF}

    class method GetEncoding(aName: not nullable String): nullable Encoding;
    property Name: not nullable String read GetName;
    property isUTF8: Boolean read GetIsUTF8;
    property isUTF16BE: Boolean read GetIsUTF16BE;
    property isUTF16LE: Boolean read GetIsUTF16LE;
    property isUTF32BE: Boolean read GetIsUTF32BE;
    property isUTF32LE: Boolean read GetIsUTF32LE;

    class property ASCII: not nullable Encoding read GetEncoding("US-ASCII") as not nullable;
    class property UTF8: not nullable Encoding read GetEncoding("UTF-8") as not nullable;
    class property UTF16LE: not nullable Encoding read GetEncoding("UTF-16LE") as not nullable;
    class property UTF16BE: not nullable Encoding read GetEncoding("UTF-16BE") as not nullable;
    class property UTF32LE: not nullable Encoding read GetEncoding("UTF-32LE") as not nullable;
    class property UTF32BE: not nullable Encoding read GetEncoding("UTF-32BE") as not nullable;

    class property &Default: not nullable Encoding read UTF8;

    class method DetectFromBytes(aBytes: array of Byte): nullable Encoding; inline;
    begin
      DetectFromBytes(aBytes, out var nil);
    end;

    class method DetectFromBytes(aBytes: array of Byte; out aSkipBytes: Integer): nullable Encoding;
    begin
      var len := length(aBytes);
      if len < 2 then
        exit nil;

      if (aBytes[0] = $EF) and (aBytes[1] = $BB) and (len ≥ 3) and (aBytes[2] = $BF) then begin
        aSkipBytes := 3;
        exit UTF8;
      end;
      if (aBytes[0] = $FE) and (aBytes[1] = $FF)  then begin
        aSkipBytes := 2;
        exit UTF16BE;
      end;
      if (aBytes[0] = $FF) and (aBytes[1] = $FE)  then begin
        if (len ≥ 4) and (aBytes[2] = $00) and (aBytes[3] = $00) then begin
          aSkipBytes := 4;
          exit UTF32BE;
        end;
        aSkipBytes := 2;
        exit UTF16LE;
      end;
      if (aBytes[0] = $00) and (aBytes[1] = $00) and (len ≥ 4) and (aBytes[2] = $FE) and (aBytes[3] = $FF) then begin
        aSkipBytes := 4;
        exit UTF32BE;
      end;
    end;

    {$IF DARWIN}
    method AsNSStringEncoding: NSStringEncoding;
    class method FromNSStringEncoding(aEncoding: NSStringEncoding): Encoding;
    {$ENDIF}
  end;

implementation

method Encoding.GetBytes(aValue: String): not nullable array of Byte;
begin
  result := GetBytes(aValue) includeBOM(false);
end;

method Encoding.GetBytes(aValue: String) includeBOM(aIncludeBOM: Boolean): not nullable array of Byte;
begin
  {$WARNING Still needs to handle BOM option for non-Toffee and non-UTF-8}
  ArgumentNullException.RaiseIfNil(aValue, "aValue");
  {$IF COOPER}
  var Buffer := java.nio.charset.Charset(self).encode(aValue);
  result := new Byte[Buffer.remaining];
  Buffer.get(result);
  {$ELSEIF TOFFEE}
  var lResult := ((aValue as NSString).dataUsingEncoding(self.AsNSStringEncoding) allowLossyConversion(true) as ImmutableBinary);
  if not assigned(lResult) then
    raise new FormatException("Unable to convert data");
  if isUTF8 and aIncludeBOM then begin
    var lBOM: array of Byte := [$EF, $BB, $BF];
    var lResult2 := new Binary();
    lResult2.Write(lBOM);
    lResult2.Write(lResult);
    lResult := lResult2;
  end;
  result := lResult.ToArray();
  {$ELSEIF ECHOES}
  result := mapped.GetBytes(aValue) as not nullable;
  if isUTF8 and aIncludeBOM then begin
    var lPreamble := new Binary(mapped.GetPreamble());
    lPreamble.Write(result);
    result := lPreamble.ToArray();
  end;
  {$ELSEIF ISLAND}
  result := mapped.GetBytes(aValue, aIncludeBOM);
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
  {$ELSEIF TOFFEE}
  result := new NSString withBytes(@aValue[aOffset]) length(aCount) encoding(self.AsNSStringEncoding);
  if not assigned(result) then
    raise new FormatException("Unable to convert input data");
  {$ELSEIF ECHOES}
  SkipBOM(aValue, var aOffset, var aCount);
  result := mapped.GetString(aValue, aOffset, aCount);
  {$ELSEIF ISLAND}
  result := mapped.GetString(aValue, aOffset, aCount);
  {$ENDIF}
end;

method Encoding.SkipBOM(aValue: not nullable array of Byte; var aOffset: Integer; var aCount: Integer): Boolean;
begin
  if isUTF8 and (length(aValue) >= aOffset+3) and (aValue[aOffset] = $EF) and (aValue[aOffset+1] = $BB) and (aValue[aOffset+2] = $BF) then begin
    inc(aOffset, 3);
    dec(aCount, 3);
    result := true;
  end
  else if isUTF16BE and (length(aValue) >= aOffset+2) and (aValue[aOffset] = $FE) and (aValue[aOffset+1] = $FF) then begin
    inc(aOffset, 2);
    dec(aCount, 2);
    result := true;
  end
  else if isUTF16LE and (length(aValue) >= aOffset+2) and (aValue[aOffset] = $FF) and (aValue[aOffset+1] = $FE) then begin
    inc(aOffset, 2);
    dec(aCount, 2);
    result := true;
  end
  else if isUTF16BE and (length(aValue) >= aOffset+4) and (aValue[aOffset] = $00) and (aValue[aOffset+1] = $00) and (aValue[aOffset+2] = $FE) and (aValue[aOffset+3] = $FF) then begin
    inc(aOffset, 4);
    dec(aCount, 4);
    result := true;
  end
  else if isUTF16LE and (length(aValue) >= aOffset+4) and (aValue[aOffset] = $FF) and (aValue[aOffset+1] = $FE) and (aValue[aOffset+2] = $00) and (aValue[aOffset+3] = $00) then begin
    inc(aOffset, 4);
    dec(aCount, 4);
    result := true;
  end
end;

method Encoding.GetString(aValue: not nullable ImmutableBinary): String;
begin
  {$IF NOT TOFFEE}
  result := GetString(aValue.ToArray());
  {$ELSE}
  result := new NSString withData(aValue) encoding(self.AsNSStringEncoding);
  if not assigned(result) then
    raise new FormatException("Unable to convert input data");
  {$ENDIF}
end;

{$IF ISLAND AND DARWIN AND NOT TOFFEE}
method Encoding.GetString(aValue: not nullable Foundation.NSData): String;
begin
  var lArray := new byte[aValue.length];
  aValue.getBytes(@lArray[0]);
  result := GetString(lArray);
end;
{$ENDIF}

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
    result := NSNumber.numberWithUnsignedInt(lEncoding as UInt32);
    {$ELSEIF ECHOES}
    result := System.Text.Encoding.GetEncoding(aName);
    {$ELSEIF ISLAND}
    case aName of
      'UTF8','UTF-8': result := PlatformEncoding.UTF8;
      'UTF16','UTF-16': result := PlatformEncoding.UTF16LE; //?
      'UTF32','UTF-32': result := PlatformEncoding.UTF32LE; //?
      'UTF16LE','UTF-16LE': result := PlatformEncoding.UTF16LE;
      'UTF16BE','UTF-16BE': result := PlatformEncoding.UTF16BE;
      'UTF32LE','UTF-32LE': result := PlatformEncoding.UTF32LE;
      'UTF32BE','UTF-32BE': result := PlatformEncoding.UTF32BE;
      'US-ASCII', 'ASCII','UTF-ASCII': result := PlatformEncoding.ASCII;
      else raise new Exception(String.Format('Unknown Encoding "{0}"', aName));
    end;
    {$ENDIF}
  except
    result := nil;
  end;
end;

method Encoding.GetName: not nullable String;
begin
  {$IF COOPER}
  exit mapped.name as not nullable;
  {$ELSEIF TOFFEE}
  var lName := CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(mapped.unsignedIntValue));
  if not assigned(lName) then
    raise new Exception("Invalid encoding.");
  result := bridge<NSString>(lName, BridgeMode.Transfer) as not nullable;
  {$ELSEIF ECHOES}
  exit mapped.WebName as not nullable;
  {$ELSEIF ISLAND}
  exit mapped.Name;
  {$ENDIF}
end;

method Encoding.GetIsUTF8: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF8StringEncoding;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-8";
  {$ELSEIF ISLAND}
  result := mapped.Name.ToUpper.Replace("-", "") = "UTF8";
  {$ENDIF}
end;

method Encoding.GetIsUTF16BE: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF16BigEndianStringEncoding;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-16be";
  {$ELSEIF ISLAND}
  result := mapped.Name.ToUpper.Replace("-", "") = "UTF16BE";
  {$ENDIF}
end;

method Encoding.GetIsUTF16LE: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF16LittleEndianStringEncoding;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-16le";
  {$ELSEIF ISLAND}
  result := mapped.Name.ToUpper.Replace("-", "") = "UTF16LE";
  {$ENDIF}
end;

method Encoding.GetIsUTF32BE: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF32BigEndianStringEncoding;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-32be";
  {$ELSEIF ISLAND}
  result := mapped.Name.ToUpper.Replace("-", "") = "UTF32BE";
  {$ENDIF}
end;

method Encoding.GetIsUTF32LE: Boolean;
begin
  {$IF COOPER}
  //exit mapped.name;
  {$ELSEIF TOFFEE}
  result := AsNSStringEncoding = NSStringEncoding.UTF32LittleEndianStringEncoding;
  {$ELSEIF ECHOES}
  result := mapped.WebName.ToLower = "utf-32le";
  {$ELSEIF ISLAND}
  result := mapped.Name.ToUpper.Replace("-", "") = "UTF32LE";
  {$ENDIF}
end;

{$IF DARWIN}
method Encoding.AsNSStringEncoding: NSStringEncoding;
begin
  {$IF TOFFEE}
  result := (self as NSNumber).unsignedIntegerValue as NSStringEncoding;
  {$ELSE}
  case Name of
    'UTF8','UTF-8': result := NSStringEncoding.UTF8StringEncoding;
    'UTF16','UTF-16': result := NSStringEncoding.UTF16StringEncoding; //?
    'UTF32','UTF-32': result := NSStringEncoding.UTF32StringEncoding; //?
    'UTF16LE','UTF-16LE': result := NSStringEncoding.UTF16LittleEndianStringEncoding;
    'UTF16BE','UTF-16BE': result := NSStringEncoding.UTF16BigEndianStringEncoding;
    'UTF32LE','UTF-32LE': result := NSStringEncoding.UTF32LittleEndianStringEncoding;
    'UTF32BE','UTF-32BE': result := NSStringEncoding.UTF32BigEndianStringEncoding;
    'US-ASCII', 'ASCII','UTF-ASCII': result := NSStringEncoding.ASCIIStringEncoding;
    else raise new Exception(String.Format('Unknown Encoding "{0}"', Name));
  end;
  {$ENDIF}
end;

class method Encoding.FromNSStringEncoding(aEncoding: NSStringEncoding): Encoding;
begin
  {$IF TOFFEE}
  result := NSNumber.numberWithUnsignedInteger(aEncoding);
  {$ELSE}
  case aEncoding of
    NSStringEncoding.UTF8StringEncoding: result := Encoding.UTF8;
    //NSStringEncoding.UTF16StringEncoding: result := Encoding.UTF16BE;
    //NSStringEncoding.UTF32StringEncoding: result := Encoding.UTF32;
    NSStringEncoding.UTF16LittleEndianStringEncoding: result := Encoding.UTF16LE;
    NSStringEncoding.UTF16BigEndianStringEncoding: result := Encoding.UTF16BE;
    NSStringEncoding.UTF32LittleEndianStringEncoding: result := Encoding.UTF32LE;
    NSStringEncoding.UTF32BigEndianStringEncoding: result := Encoding.UTF32BE;
    NSStringEncoding.ASCIIStringEncoding: result := Encoding.ASCII;
    else raise new Exception(String.Format("Unsupported Encoding #{0}", aEncoding as Integer));
  end;
  {$ENDIF}
end;

{$ENDIF}

end.