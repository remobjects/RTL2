namespace RemObjects.Elements.RTL;

interface

type
  {$IF ECHOES}
  ImmutablePlatformBinary = System.IO.MemoryStream;
  PlatformBinary = System.IO.MemoryStream;
  {$ELSEIF ISLAND}
  ImmutablePlatformBinary = RemObjects.Elements.System.MemoryStream;
  PlatformBinary = RemObjects.Elements.System.MemoryStream;
  {$ELSEIF TOFFEE}
  ImmutablePlatformBinary = Foundation.NSData;
  PlatformBinary = Foundation.NSMutableData;
  {$ENDIF}


  ImmutableBinary = public class {$IF ECHOES OR ISLAND OR TOFFEE}mapped to ImmutablePlatformBinary{$ENDIF}
  {$IF COOPER}
  protected
    fData: java.io.ByteArrayOutputStream := new java.io.ByteArrayOutputStream();
  {$ENDIF}
  public
    constructor; {$IF TOFFEE OR ECHOES}mapped to constructor();{$ELSE}empty;{$ENDIF}
    constructor(anArray: array of Byte);
    constructor(Bin: Binary);

    method &Read(Range: Range): array of Byte;
    method &Read(aStartIndex: Integer; aCount: Integer): array of Byte;
    method &Read(Count: Integer): array of Byte;

    method Subdata(Range: Range): Binary;
    method Subdata(aStartIndex: Integer; aCount: Integer): Binary;

    method ToArray: not nullable array of Byte;
    property Length: Integer read {$IF COOPER}fData.size{$ELSEIF ECHOES OR ISLAND}mapped.Length{$ELSEIF TOFFEE}mapped.length{$ENDIF};
  end;

  Binary = public class(ImmutableBinary) {$IF ECHOES OR ISLAND OR TOFFEE}mapped to PlatformBinary{$ENDIF}
  public
    constructor;
    constructor(anArray: array of Byte);
    constructor(Bin: Binary);

    method Assign(Bin: Binary);
    method Clear;


    method &Write(Buffer: array of Byte; Offset: Integer; Count: Integer);
    method &Write(Buffer: array of Byte; Count: Integer);
    method &Write(Buffer: array of Byte);
    method &Write(Bin: Binary);

    {$IF TOFFEE}
    operator Implicit(aData: NSData): Binary;
    {$ENDIF}
  end;

implementation

{ Binary }

constructor ImmutableBinary(anArray: array of Byte);
begin
  if anArray = nil then
    raise new ArgumentNullException("Array");

  {$IF COOPER}
  fData.Write(anArray, 0, anArray.Length);
  {$ELSEIF ECHOES}
  var ms := new ImmutablePlatformBinary();
  ms.Write(anArray, 0, anArray.Length);
  exit ms;
  {$ELSEIF ISLAND}
  var ms := new ImmutablePlatformBinary();
  ms.Write(anArray, anArray.Length);
  exit ms;
  {$ELSEIF TOFFEE}
  exit NSData.dataWithBytes(anArray) length(length(anArray));
  {$ENDIF}
end;

constructor ImmutableBinary(Bin: Binary);
begin
  ArgumentNullException.RaiseIfNil(Bin, "Bin");
  {$IF COOPER}
  if Bin <> nil then
    fData.Write(Bin.ToArray, 0, Bin.Length);
  {$ELSEIF ECHOES OR ISLAND}
  var ms := new ImmutablePlatformBinary();
  ImmutablePlatformBinary(Bin).WriteTo(ms);
  exit ms;
  {$ELSEIF TOFFEE}
  exit NSData.dataWithData(Bin);
  {$ENDIF}
end;

constructor Binary;
begin
  {$IF COOPER}
  {$ELSEIF ECHOES OR ISLAND}
  result := new ImmutablePlatformBinary();
  {$ELSEIF TOFFEE}
  result :=  NSData.data;
  {$ENDIF}
end;

constructor Binary(anArray: array of Byte);
begin
  if anArray = nil then
    raise new ArgumentNullException("Array");

  {$IF COOPER}
  inherited constructor(anArray);
  {$ELSEIF ECHOES}
  var ms := new PlatformBinary();
  ms.Write(anArray, 0, anArray.Length);
  exit ms;
  {$ELSEIF ISLAND}
  var ms := new PlatformBinary();
  if length(anArray) > 0 then
    ms.Write(anArray, 0, length(anArray));
  exit ms;
  {$ELSEIF TOFFEE}
  exit NSMutableData.dataWithBytes(anArray) length(length(anArray));
  {$ENDIF}
end;

constructor Binary(Bin: Binary);
begin
  ArgumentNullException.RaiseIfNil(Bin, "Bin");
  {$IF COOPER}
  Assign(Bin);
  {$ELSEIF ECHOES OR ISLAND}
  var ms := new PlatformBinary();
  PlatformBinary(Bin).WriteTo(ms);
  exit ms;
  {$ELSEIF TOFFEE}
  exit NSMutableData.dataWithData(Bin);
  {$ENDIF}
end;

method Binary.Assign(Bin: Binary);
begin
  {$IF COOPER}
  Clear;
  if Bin <> nil then
    fData.Write(Bin.ToArray, 0, Bin.Length);
  {$ELSEIF ECHOES OR ISLAND}
  Clear;
  if assigned(Bin) then
    PlatformBinary(Bin).WriteTo(mapped);
  {$ELSEIF TOFFEE}
  mapped.setData(Bin);
  {$ENDIF}
end;

method ImmutableBinary.Read(Range: Range): array of Byte;
begin
  if Range.Length = 0 then
    exit [];

  RangeHelper.Validate(Range, self.Length);

  result := new Byte[Range.Length];
  {$IF COOPER}
  System.arraycopy(fData.toByteArray, Range.Location, result, 0, Range.Length);
  {$ELSEIF ECHOES}
  mapped.Position := Range.Location;
  mapped.Read(result, 0, Range.Length);
  {$ELSEIF TOFFEE}
  mapped.getBytes(result) range(Range);
  {$ENDIF}
end;

method ImmutableBinary.Read(aStartIndex: Integer; aCount: Integer): array of Byte;
begin
  if aCount = 0 then
    exit [];
  result := &Read(new Range(aStartIndex, aCount));
end;

method ImmutableBinary.Read(Count: Integer): array of Byte;
begin
  result := &Read(new Range(0, Math.Min(Count, self.Length)));
end;

method ImmutableBinary.Subdata(Range: Range): Binary;
begin
  result := new Binary(&Read(Range));
end;

method ImmutableBinary.Subdata(aStartIndex: Integer; aCount: Integer): Binary;
begin
  result := new Binary(&Read(aStartIndex, aCount));
end;

method Binary.&Write(Buffer: array of Byte; Offset: Integer; Count: Integer);
begin
  if not assigned(Buffer) then
    raise new ArgumentNullException("Buffer");

  if Count = 0 then
    exit;

  RangeHelper.Validate(new Range(Offset, Count), Buffer.Length);
  {$IF COOPER}
  fData.write(Buffer, Offset, Count);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Seek(0, PlatformSeekOrigin.End);
  mapped.Write(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  mapped.appendBytes(@Buffer[Offset]) length(Count);
  {$ENDIF}
end;

method Binary.Write(Buffer: array of Byte; Count: Integer);
begin
  &Write(Buffer, 0, Count);
end;

method Binary.&Write(Buffer: array of Byte);
begin
  &Write(Buffer, RemObjects.Oxygene.System.length(Buffer));
end;

method Binary.Write(Bin: Binary);
begin
  ArgumentNullException.RaiseIfNil(Bin, "Bin");
  {$IF COOPER OR ECHOES OR ISLAND}
  &Write(Bin.ToArray, Bin.Length);
  {$ELSEIF TOFFEE}
  mapped.appendData(Bin);
  {$ENDIF}
end;

method ImmutableBinary.ToArray: not nullable array of Byte;
begin
  {$IF COOPER}
  result := fData.toByteArray as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.ToArray as not nullable;
  {$ELSEIF TOFFEE}
  result := new Byte[mapped.length];
  mapped.getBytes(result) length(mapped.length);
  {$ENDIF}
end;

method Binary.Clear;
begin
  {$IF COOPER}
  fData.reset;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.SetLength(0);
  mapped.Position := 0;
  {$ELSEIF TOFFEE}
  mapped.setLength(0);
  {$ENDIF}
end;

{$IF TOFFEE}
operator Binary.Implicit(aData: NSData): Binary;
begin
  if aData is NSMutableData then
    result := aData as NSMutableData
  else
    result := aData:mutableCopy;
end;
{$ENDIF}

end.