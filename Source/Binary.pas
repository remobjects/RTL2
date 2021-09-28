namespace RemObjects.Elements.RTL;

interface

type
  {$IF COOPER}
  ImmutablePlatformBinary = public java.io.ByteArrayOutputStream;
  PlatformBinary = public java.io.ByteArrayOutputStream;
  {$ELSEIF TOFFEE}
  ImmutablePlatformBinary = public Foundation.NSData;
  PlatformBinary = public Foundation.NSMutableData;
  {$ELSEIF ECHOES}
  ImmutablePlatformBinary = public System.IO.MemoryStream;
  PlatformBinary = public System.IO.MemoryStream;
  {$ELSEIF ISLAND}
  ImmutablePlatformBinary = public RemObjects.Elements.System.MemoryStream;
  PlatformBinary = public RemObjects.Elements.System.MemoryStream;
  {$ENDIF}

  ImmutableBinary = public class {$IF ECHOES OR ISLAND OR TOFFEE}mapped to ImmutablePlatformBinary{$ENDIF}
  {$IF COOPER}
  protected
    fData: java.io.ByteArrayOutputStream := new java.io.ByteArrayOutputStream();
  {$ENDIF}
  public
    {$IF TOFFEE OR ECHOES}constructor; mapped to constructor();{$ENDIF}
    {$IF NOT (TOFFEE OR ECHOES)}constructor; empty;{$ENDIF}
    constructor(anArray: not nullable array of Byte);
    constructor(Bin: not nullable ImmutableBinary);

    method &Read(Range: Range): array of Byte;
    method &Read(aStartIndex: Integer; aCount: Integer): array of Byte;
    method &Read(Count: Integer): array of Byte;

    method Subdata(Range: Range): Binary;
    method Subdata(aStartIndex: Integer; aCount: Integer): Binary;

    method IndexOf(aBytes: array of Byte): Integer;

    method UniqueCopy: not nullable ImmutableBinary;
    method UniqueMutableCopy: not nullable Binary;
    method MutableVersion: not nullable Binary;

    method ToArray: not nullable array of Byte;
    {$IF COOPER}
    method ToPlatformBinary: ImmutablePlatformBinary;
    {$ENDIF}
    {$IF ISLAND AND DARWIN AND NOT TOFFEE}
    method ToNSData: Foundation.NSData;
    method ToNSMutableData: Foundation.NSMutableData;
    constructor(aData: not nullable NSData);
    {$ENDIF}
    property Length: Integer read {$IF COOPER}fData.size{$ELSEIF ECHOES OR ISLAND}mapped.Length{$ELSEIF TOFFEE}mapped.length{$ENDIF};
  end;

  Binary = public class(ImmutableBinary) {$IF ECHOES OR ISLAND OR TOFFEE}mapped to PlatformBinary{$ENDIF}
  public
    constructor;
    constructor(anArray: array of Byte);
    constructor(Bin: ImmutableBinary);

    method Assign(Bin: ImmutableBinary);
    method Clear;

    method &Write(Buffer: array of Byte; Offset: Integer; Count: Integer);
    method &Write(Buffer: array of Byte; Count: Integer);
    method &Write(Buffer: array of Byte);
    method &Write(Bin: Binary);

    {$IF TOFFEE}
    operator Implicit(aData: NSData): Binary;
    {$ENDIF}
  end;

  ByteArrayExtensions = public extension record(array of Byte)
  public

    method IndexOf(aBytes: array of Byte): Integer;
    begin
      result := -1;
      var len := RemObjects.Elements.System.length(aBytes);
      if len = 0 then
        exit;
      if len ≤ RemObjects.Elements.System.length(self) then begin
        lOuterLoop:
          for i: Integer := 0 to Length-len do begin
            if aBytes[0] = self[i] then begin
              for j: Integer := 1 to len-1 do
                if aBytes[j] ≠ self[i+j] then
                  continue lOuterLoop;
              exit i;
            end;
          end;
      end;
    end;

    method IndexOf(aByte: Byte): Integer;
    begin
      result := -1;
      for i: Integer := 0 to RemObjects.Elements.System.length(self)-1 do
        if aByte = self[i] then
          exit i;
    end;

    method &Reverse(aArray: array of Byte);
    begin
      var len := Length;
      for i: Integer := 0 to (len-1) div 2 do begin
        var lSave := self[i];
        self[i] := self[len-1-i];
        self[len-1-i] := lSave;
      end;
    end;

  end;


implementation

{ Binary }

constructor ImmutableBinary(anArray: not nullable array of Byte);
begin
  {$IF COOPER}
  fData.Write(anArray, 0, anArray.Length);
  {$ELSEIF TOFFEE}
  exit NSData.dataWithBytes(anArray) length(RemObjects.Oxygene.System.length(anArray));
  {$ELSEIF ECHOES}
  var ms := new ImmutablePlatformBinary();
  ms.Write(anArray, 0, anArray.Length);
  ms.Position := 0;
  exit ms;
  {$ELSEIF ISLAND}
  var ms := new ImmutablePlatformBinary();
  ms.Write(anArray, anArray.Length);
  exit ms;
  {$ENDIF}
end;

constructor ImmutableBinary(Bin: not nullable ImmutableBinary);
begin
  {$IF COOPER}
  if Bin <> nil then
    fData.Write(Bin.ToArray, 0, Bin.Length);
  {$ELSEIF TOFFEE}
  exit NSData.dataWithData(Bin);
  {$ELSEIF ECHOES OR ISLAND}
  var ms := new ImmutablePlatformBinary();
  ImmutablePlatformBinary(Bin).WriteTo(ms);
  ms.Position := 0;
  exit ms;
  {$ENDIF}
end;

constructor Binary;
begin
  {$IF COOPER}
  {$ELSEIF TOFFEE}
  result :=  NSData.data;
  {$ELSEIF ECHOES OR ISLAND}
  result := new ImmutablePlatformBinary();
  {$ENDIF}
end;

constructor Binary(anArray: array of Byte);
begin
  if anArray = nil then
    raise new ArgumentNullException("Array");

  {$IF COOPER}
  inherited constructor(anArray);
  {$ELSEIF TOFFEE}
  exit NSMutableData.dataWithBytes(anArray) length(RemObjects.Oxygene.System.length(anArray));
  {$ELSEIF ECHOES}
  var ms := new PlatformBinary();
  ms.Write(anArray, 0, anArray.Length);
  ms.Position := 0;
  exit ms;
  {$ELSEIF ISLAND}
  var ms := new PlatformBinary();
  if RemObjects.Oxygene.System.length(anArray) > 0 then
    ms.Write(anArray, 0, RemObjects.Oxygene.System.length(anArray));
  exit ms;
  {$ENDIF}
end;

constructor Binary(Bin: ImmutableBinary);
begin
  ArgumentNullException.RaiseIfNil(Bin, "Bin");
  {$IF COOPER}
  Assign(Bin);
  {$ELSEIF TOFFEE}
  exit NSMutableData.dataWithData(Bin);
  {$ELSEIF ECHOES OR ISLAND}
  var ms := new PlatformBinary();
  PlatformBinary(Bin).WriteTo(ms);
  ms.Position := 0;
  exit ms;
  {$ENDIF}
end;

method Binary.Assign(Bin: ImmutableBinary);
begin
  {$IF COOPER}
  Clear;
  if Bin <> nil then
    fData.Write(Bin.ToArray, 0, Bin.Length);
  {$ELSEIF TOFFEE}
  mapped.setData(Bin);
  {$ELSEIF ECHOES OR ISLAND}
  Clear;
  if assigned(Bin) then
    PlatformBinary(Bin).WriteTo(mapped);
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
  {$ELSEIF TOFFEE}
  mapped.getBytes(result) range(Range);
  {$ELSEIF ECHOES}
  mapped.Position := Range.Location;
  mapped.Read(result, 0, Range.Length);
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
  {$ELSEIF TOFFEE}
  mapped.appendBytes(@Buffer[Offset]) length(Count);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Seek(0, PlatformSeekOrigin.End);
  mapped.Write(Buffer, Offset, Count);
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
  {$IF NOT TOFFEE}
  &Write(Bin.ToArray, Bin.Length);
  {$ELSEIF TOFFEE}
  mapped.appendData(Bin);
  {$ENDIF}
end;

method ImmutableBinary.IndexOf(aBytes: array of Byte): Integer;
begin
  result := ToArray.IndexOf(aBytes);
end;

method ImmutableBinary.UniqueCopy: not nullable ImmutableBinary;
begin
  {$IF NOT TOFFEE}
  result := new ImmutableBinary(self);
  {$ELSEIF TOFFEE}
  result := mapped.copy as not nullable;
  {$ENDIF}
end;

method ImmutableBinary.UniqueMutableCopy: not nullable Binary;
begin
  {$IF NOT TOFFEE}
  result := new Binary(self);
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

method ImmutableBinary.MutableVersion: not nullable Binary;
begin
  {$IF COOPER}
  result := new Binary(self);
  {$ELSEIF ECHOES OR ISLAND}
  result := Binary(self);
  {$ELSEIF TOFFEE}
  if self is NSMutableData then
    result := self as NSMutableData
  else
    result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

method ImmutableBinary.ToArray: not nullable array of Byte;
begin
  {$IF COOPER}
  result := fData.toByteArray as not nullable;
  {$ELSEIF TOFFEE}
  result := new Byte[mapped.length];
  mapped.getBytes(result) length(mapped.length);
  {$ELSEIF ECHOES OR ISLAND}
  result := mapped.ToArray as not nullable;
  {$ENDIF}
end;

{$IF COOPER}
method ImmutableBinary.ToPlatformBinary: ImmutablePlatformBinary;
begin
  result := fData;
end;
{$ENDIF}

{$IF ISLAND AND DARWIN AND NOT TOFFEE}
method ImmutableBinary.ToNSData: Foundation.NSData;
begin
  var lArray := mapped.ToArray();
  result := new Foundation.NSData withBytes(@lArray[0]) length(RemObjects.Elements.System.length(lArray));
end;

method ImmutableBinary.ToNSMutableData: Foundation.NSMutableData;
begin
  var lArray := mapped.ToArray();
  result := new Foundation.NSMutableData withBytes(@lArray[0]) length(RemObjects.Elements.System.length(lArray));
end;

constructor ImmutableBinary(aData: not nullable NSData);
begin
  {$HINT implement more efficiently with a custom MemoryStream oveerload?}
  var ms := new ImmutablePlatformBinary();
  ms.Write(aData.bytes, aData.length);
  exit ms;
end;
{$ENDIF}

method Binary.Clear;
begin
  {$IF COOPER}
  fData.reset;
  {$ELSEIF TOFFEE}
  mapped.setLength(0);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.SetLength(0);
  mapped.Position := 0;
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