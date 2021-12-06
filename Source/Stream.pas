namespace RemObjects.Elements.RTL;

interface

type
  Stream = public partial abstract class
  public
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; abstract;
    method Close; abstract;
    method Flush; abstract;
    method &Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; abstract;
    method &Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; abstract;
    method &Read(Buffer: array of Byte; Count: Int32): Int32; inline;
    method &Write(Buffer: array of Byte; Count: Int32): Int32; inline;
    method ReadByte: Int32; virtual;
    method WriteByte(aValue: Byte); virtual;
    method GetLength: Int64; virtual;
    method SetPosition(Value: Int64); virtual;
    method GetPosition: Int64; virtual;

    method CopyTo(Destination: Stream); virtual;

    property Length: Int64 read GetLength; virtual;
    property Position: Int64 read GetPosition write SetPosition; virtual;
    property CanRead: Boolean read; abstract;
    property CanSeek: Boolean read; abstract;
    property CanWrite: Boolean read; abstract;
  end;

  {$IFDEF ECHOES or (ISLAND AND NOT TOFFEE)}
  Stream = public partial class (IDisposable)
  public
    method Dispose;
    begin
      Close;
    end;
  end;
  {$ENDIF}

  {$IFDEF JAVA}
  Stream = public partial class (java.io.Closeable)
  public
  end;
  {$ENDIF}

  {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}

  {$IF ECHOES}
  PlatformStream = public System.IO.Stream;
  {$ELSEIF ISLAND}
  PlatformStream = public RemObjects.Elements.System.Stream;
  {$ENDIF}

  WrappedPlatformStream = public class(Stream)
  protected
    fPlatformStream: PlatformStream;
  public
    method &Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method &Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; override;
    method GetLength: Int64; override;
    method SetLength(Value: Int64);
    method SetPosition(Value: Int64); override;
    method GetPosition: Int64; override;
    method Close; override;
    method Flush; override;

    operator Implicit(aStream: WrappedPlatformStream): PlatformStream;

    property Length: Int64 read GetLength; override;
    property Position: Int64 read GetPosition write SetPosition; override;
    property CanRead: Boolean read fPlatformStream.CanRead; override;
    property CanSeek: Boolean read fPlatformStream.CanSeek; override;
    property CanWrite: Boolean read fPlatformStream.CanWrite; override;

    constructor(aStream: PlatformStream);
    begin
      fPlatformStream := aStream;
    end;
  end;
  {$ENDIF}

  {$IF COOPER}
  PlatformMemoryStream = public java.io.ByteArrayOutputStream;
  {$ELSEIF TOFFEE}
  PlatformMemoryStream = public Foundation.NSMutableData;
  {$ELSEIF ECHOES}
  PlatformMemoryStream = public System.IO.MemoryStream;
  {$ELSEIF ISLAND}
  PlatformMemoryStream = public RemObjects.Elements.System.MemoryStream;
  {$ENDIF}

  MemoryStream = public class({$IF ECHOES OR (ISLAND AND NOT TOFFEE)}WrappedPlatformStream{$ELSE}Stream{$ENDIF})
  private
    fCanWrite: Boolean := true;
    {$IF COOPER OR TOFFEE}
    fPosition: Int64;
    fInternalStream: PlatformMemoryStream;
    method ConvertSeekOffset(Offset: Int64; Origin: SeekOrigin): Int64;
    {$ENDIF}
  protected
    method GetCanRead: Boolean;
    method GetCanSeek: Boolean;
    method GetCanWrite: Boolean;
    method GetBytes: array of Byte; virtual;
  public
    constructor;
    constructor(aCapacity: Integer);
    constructor(aValue: ImmutableBinary);
    constructor(aValue: array of Byte);
    constructor(aValue: array of Byte; aCanWrite: Boolean);
    operator Implicit(aValue: ImmutableBinary): MemoryStream;
    {$IF COOPER OR TOFFEE}
    method &Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method &Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; override;
    method GetLength: Int64; override;
    method SetLength(Value: Int64);
    method SetPosition(Value: Int64); override;
    method GetPosition: Int64; override;

    property Length: Int64 read GetLength; override;
    property Position: Int64 read GetPosition write SetPosition; override;
    {$ENDIF}
    method ToArray: array of Byte;
    method Close; override;
    method Flush; override;
    method Clear;
    method WriteTo(Destination: Stream);

    property Bytes: array of Byte read GetBytes;
    property CanRead: Boolean read GetCanRead; override;
    property CanSeek: Boolean read GetCanSeek; override;
    property CanWrite: Boolean read GetCanWrite; override;
  end;

  {$IF NOT WEBASSEMBLY}

  {$IF COOPER}
  PlatformInternalFileStream = public java.io.RandomAccessFile;
  {$ELSEIF TOFFEE}
  PlatformInternalFileStream = public Foundation.NSFileHandle;
  {$ELSEIF ECHOES}
  PlatformInternalFileStream = public System.IO.FileStream;
  {$ELSEIF ISLAND}
  PlatformInternalFileStream = public RemObjects.Elements.System.FileStream;
  {$ENDIF}

  FileStream = public class({$IF ECHOES OR (ISLAND AND NOT TOFFEE)}WrappedPlatformStream{$ELSE}Stream{$ENDIF})
  {$IF COOPER OR TOFFEE}
  private
    fInternalStream: PlatformInternalFileStream;
  {$ENDIF}
  protected
    method GetCanRead: Boolean;
    method GetCanSeek: Boolean;
    method GetCanWrite: Boolean;

  public
    constructor(FileName: String; Mode: FileOpenMode);
    {$IF COOPER OR TOFFEE}
    method &Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method &Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; override;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; override;
    method GetLength: Int64; override;
    method SetLength(Value: Int64);
    method SetPosition(Value: Int64); override;
    method GetPosition: Int64; override;

    property Length: Int64 read GetLength; override;
    property Position: Int64 read GetPosition write SetPosition; override;
    {$ENDIF}
    method Close; override;
    method Flush; override;
    property CanRead: Boolean read GetCanRead; override;
    property CanSeek: Boolean read GetCanSeek; override;
    property CanWrite: Boolean read GetCanWrite; override;
  end;
  {$ENDIF}

  BinaryStream = public class
  private
    fStream: Stream;
    fEncoding: Encoding := Encoding.UTF8;
    {$IF TOFFEE OR ISLAND}
    fBuffer: array of Byte;
    class const DefBufferSize = 8;
    method ReadRaw(Buffer: ^Void; Count: LongInt);
    method WriteRaw(Buffer: ^Void; Count: LongInt);
    {$ENDIF}
  public
    constructor(aStream: Stream);
    constructor(aStream: Stream; aEncoding: Encoding);

    method ReadByte: Byte;
    method PeekChar: Int32;
    method &Read: Int32;
    method &Read(Count: Integer): array of Byte;
    method ReadSByte: ShortInt;
    method ReadDouble: Double;
    method ReadSingle: Single;
    method ReadInt16: Int16;
    method ReadInt32: Int32;
    method ReadInt64: Int64;
    method ReadString(Count: Int32): String;

    method &Write(aValue: Byte);
    method &Write(aValue: array of Byte; Offset: Int32; Count: Int32);
    method WriteSByte(Value: ShortInt);
    method WriteByte(Value: Byte);
    method WriteDouble(Value: Double);
    method WriteSingle(Value: Single);
    method WriteInt16(Value: Int16);
    method WriteInt32(Value: Int32);
    method WriteInt64(Value: Int64);
    method WriteString(aString: String);

    property BaseStream: Stream read fStream;
  end;

implementation

method Stream.&Read(Buffer: array of Byte; Count: Int32): Int32;
begin
  result := &Read(Buffer, 0, Count);
end;

method Stream.&Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  result := &Write(Buffer, 0, Count);
end;

method Stream.ReadByte: Int32;
begin
  var lArray := new Byte[1];
  if &Read(lArray, 0, sizeOf(Byte)) = sizeOf(Byte) then
    result := lArray[0]
  else
    result := -1;
end;

method Stream.WriteByte(aValue: Byte);
begin
  var lArray := new Byte[1];
  lArray[0] := aValue;
  &Write(lArray, 0, sizeOf(Byte));
end;

method Stream.CopyTo(Destination: Stream);
const
  bufSize = 4 * 1024;
begin
  if Destination = nil then raise new Exception('Destination is null');
  if not self.CanRead then raise new NotSupportedException("Stream.CopyTo is only supported if the source CanRead.");
  if not Destination.CanWrite then raise new NotSupportedException("Stream.CopyTo is only supported if the target CanWrite.");
  var lBuf := new Byte[bufSize];
  while true do begin
    var lRest := &Read(lBuf, bufSize);
    if lRest > 0 then lRest := Destination.Write(lBuf, lRest);
    if lRest <> bufSize then break;
  end;
end;

method Stream.GetLength: Int64;
begin
  if not CanSeek then raise new NotSupportedException("Stream.Length is only supported if the CanSeek is true.");
  var lPos := Seek(0, SeekOrigin.Current);
  var lTemp := Seek(0, SeekOrigin.End);
  Seek(lPos, SeekOrigin.Begin);
  result := lTemp;
end;

method Stream.GetPosition: Int64;
begin
  result := Seek(0, SeekOrigin.Current);
end;

method Stream.SetPosition(Value: Int64);
begin
  Seek(Value, SeekOrigin.Begin);
end;

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
method WrappedPlatformStream.GetLength: Int64;
begin
  result := fPlatformStream.Length;
end;

method WrappedPlatformStream.SetLength(Value: Int64);
begin
  fPlatformStream.SetLength(Value);
end;

method WrappedPlatformStream.SetPosition(Value: Int64);
begin
  fPlatformStream.Position := Value;
end;

method WrappedPlatformStream.GetPosition: Int64;
begin
  result := fPlatformStream.Position;
end;

method WrappedPlatformStream.Close;
begin
  fPlatformStream.Close;
end;

method WrappedPlatformStream.Flush;
begin
  fPlatformStream.Flush;
end;

method WrappedPlatformStream.Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  {$IF ECHOES}
  result := fPlatformStream.Read(Buffer, Offset, Count);
  {$ELSEIF ISLAND}
  result := fPlatformStream.Read(Buffer, Offset, Count);
  {$ENDIF}
end;

method WrappedPlatformStream.Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  if not CanWrite then
    raise new Exception('Stream is read only');

  {$IF ECHOES}
  fPlatformStream.Write(Buffer, Offset, Count);
  result := Count;
  {$ELSEIF ISLAND}
  result := fPlatformStream.Write(Buffer, Offset, Count);
  {$ENDIF}
end;

method WrappedPlatformStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  {$IF ECHOES}
  result := fPlatformStream.Seek(Offset, System.IO.SeekOrigin(Origin));
  {$ELSEIF ISLAND}
  result := fPlatformStream.Seek(Offset, RemObjects.Elements.System.SeekOrigin(Origin));
  {$ENDIF}
end;

operator WrappedPlatformStream.Implicit(aStream: WrappedPlatformStream): PlatformStream;
begin
  result := aStream:fPlatformStream;
end;

{$ENDIF}

method MemoryStream.GetBytes: array of Byte;
begin
  {$IF COOPER}
  result := fInternalStream.toByteArray;
  {$ELSEIF TOFFEE}
  result := new Byte[GetLength];
  fInternalStream.getBytes(result) range(NSMakeRange(0, result.length));
  {$ELSEIF ECHOES}
  result := System.IO.MemoryStream(fPlatformStream).ToArray;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.MemoryStream(fPlatformStream).ToArray;
  {$ENDIF}
end;

method MemoryStream.GetCanRead: Boolean;
begin
  result := true;
end;

method MemoryStream.GetCanSeek: Boolean;
begin
  result := true;
end;

method MemoryStream.GetCanWrite: Boolean;
begin
  result := fCanWrite;
end;

{$IF COOPER OR TOFFEE}
method MemoryStream.GetLength: Int64;
begin
  {$IF COOPER}
  result := fInternalStream.size;
  {$ELSEIF TOFFEE}
  result := fInternalStream.length;
  {$ENDIF}
end;

method MemoryStream.SetLength(Value: Int64);
begin
  {$IF COOPER}
  // NO OP
  {$ELSEIF TOFFEE}
  fInternalStream.length := Value;
  {$ENDIF}
end;

method MemoryStream.SetPosition(Value: Int64);
begin
  {$IF COOPER}
  fPosition := Value;
  {$ELSEIF TOFFEE}
  fPosition := Value;
  {$ENDIF}
end;

method MemoryStream.GetPosition: Int64;
begin
  {$IF COOPER}
  result := fPosition;
  {$ELSEIF TOFFEE}
  result := fPosition;
  {$ENDIF}
end;
{$ENDIF}

constructor MemoryStream;
begin
  {$IF COOPER}
  fInternalStream := new java.io.ByteArrayOutputStream();
  {$ELSEIF TOFFEE}
  fInternalStream := new NSMutableData();
  fPosition := 0;
  {$ELSEIF ECHOES}
  inherited constructor(new System.IO.MemoryStream());
  {$ELSEIF ISLAND}
  inherited constructor(new RemObjects.Elements.System.MemoryStream());
  {$ENDIF}
end;

constructor MemoryStream(aCapacity: Integer);
begin
  {$IF COOPER}
  fInternalStream := new java.io.ByteArrayOutputStream(aCapacity);
  {$ELSEIF TOFFEE}
  fInternalStream := NSMutableData.dataWithCapacity(aCapacity);
  fPosition := 0;
  {$ELSEIF ECHOES}
  inherited constructor(new System.IO.MemoryStream(aCapacity));
  {$ELSEIF ISLAND}
  inherited constructor(new RemObjects.Elements.System.MemoryStream(aCapacity));
  {$ENDIF}
end;

constructor MemoryStream(aValue: ImmutableBinary);
begin
  {$IF COOPER}
  fInternalStream := aValue.ToPlatformBinary;
  {$ELSEIF TOFFEE}
  fInternalStream := aValue.UniqueMutableCopy;
  {$ELSEIF ECHOES OR ISLAND}
  fPlatformStream := aValue;
  {$ENDIF}
end;

constructor MemoryStream(aValue: array of Byte);
begin
  constructor(aValue, true);
end;

constructor MemoryStream(aValue: array of Byte; aCanWrite: Boolean);
begin
  constructor;
  &write(aValue, 0, aValue.Length);
  Position := 0;
  fCanWrite := aCanWrite;
end;

operator MemoryStream.Implicit(aValue: ImmutableBinary): MemoryStream;
begin
  result := new MemoryStream(aValue);
end;

{$IF COOPER OR TOFFEE}
method MemoryStream.ConvertSeekOffset(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  case Origin of
    SeekOrigin.Begin:
      result := Offset;

    SeekOrigin.Current:
      result := GetPosition + Offset;

    SeekOrigin.End:
      result := GetLength + Offset;
  end;
end;

method MemoryStream.Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  if (fPosition + Count) >= self.Length then
    result := self.Length - fPosition
  else
    result := Count;
  {$IF COOPER}
  System.arraycopy(fInternalStream.toByteArray, fPosition, Buffer, Offset, result);
  {$ELSEIF TOFFEE}
  fInternalStream.getBytes(@Buffer[Offset]) range(NSMakeRange(fPosition, result));
  {$ENDIF}
  inc(fPosition, result);
end;

method MemoryStream.Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  if not CanWrite then
    raise new Exception('Stream is read only');

  {$IF COOPER}
  fInternalStream.write(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  fInternalStream.replaceBytesInRange(NSMakeRange(fPosition, Count)) withBytes(@Buffer[Offset]);
  {$ENDIF}
  inc(fPosition, Count);
  result := Count;
end;

method MemoryStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  result := ConvertSeekOffset(Offset, Origin);
  fPosition := result;
end;
{$ENDIF}

method MemoryStream.ToArray: array of Byte;
begin
  result := GetBytes;
end;

method MemoryStream.Close;
begin
  // No OP
end;

method MemoryStream.Flush;
begin
  // No OP
end;

method MemoryStream.Clear;
begin
  {$IF COOPER}
  fInternalStream.reset;
  {$ELSEIF TOFFEE}
  fInternalStream.setLength(0);
  {$ELSEIF ECHOES OR ISLAND}
  fPlatformStream.SetLength(0);
  fPlatformStream.Position := 0;
  {$ENDIF}
end;

method MemoryStream.WriteTo(Destination: Stream);
begin
  var lOldPos := Position;
  try
    CopyTo(Destination);

  finally
    Position := lOldPos;
  end;
end;

{$IF NOT WEBASSEMBLY}
method FileStream.GetCanRead: Boolean;
begin
  result := true;
end;

method FileStream.GetCanSeek: Boolean;
begin
  result := true;
end;

method FileStream.GetCanWrite: Boolean;
begin
  result := true;
end;

{$IF COOPER OR TOFFEE}
method FileStream.GetLength: Int64;
begin
  {$IF COOPER}
  result := fInternalStream.length;
  {$ELSEIF TOFFEE}
  var lOrigin := fInternalStream.offsetInFile;
  result := fInternalStream.seekToEndOfFile;
  fInternalStream.seekToFileOffset(lOrigin);
  {$ENDIF}
end;

method FileStream.SetLength(Value: Int64);
begin
  {$IF COOPER}
  fInternalStream.setLength(Value);
  {$ELSEIF TOFFEE}
  var lOrigin := fInternalStream.offsetInFile;
  fInternalStream.truncateFileAtOffset(Value);
  if lOrigin > Value then
    Seek(0, SeekOrigin.Begin)
  else
    Seek(lOrigin, SeekOrigin.Begin);
  {$ENDIF}
end;

method FileStream.SetPosition(Value: Int64);
begin
  {$IF COOPER}
  Seek(Value, SeekOrigin.Begin);
  {$ELSEIF TOFFEE}
  Seek(Value, SeekOrigin.Begin);
  {$ENDIF}
end;

method FileStream.GetPosition: Int64;
begin
  {$IF COOPER}
  result := fInternalStream.FilePointer;
  {$ELSEIF TOFFEE}
  result := fInternalStream.offsetInFile;
  {$ENDIF}
end;
{$ENDIF}

constructor FileStream(FileName: String; Mode: FileOpenMode);
begin
  {$IF COOPER}
  var lMode: String := if Mode = FileOpenMode.ReadOnly then "r" else "rw";
  fInternalStream := new java.io.RandomAccessFile(FileName, lMode);
  {$ELSEIF TOFFEE}
  case Mode of
    FileOpenMode.ReadOnly: fInternalStream := NSFileHandle.fileHandleForReadingAtPath(FileName);
    FileOpenMode.ReadWrite: fInternalStream := NSFileHandle.fileHandleForUpdatingAtPath(FileName);
    FileOpenMode.Create: begin
        fInternalStream := NSFileHandle.fileHandleForWritingAtPath(FileName);
        if not assigned(fInternalStream) then begin
          NSFileManager.defaultManager.createFileAtPath(FileName) contents(nil) attributes(nil);
          fInternalStream := NSFileHandle.fileHandleForWritingAtPath(FileName);
        end;
    end;
    else raise new NotImplementedException;
  end;
  if fInternalStream = nil then
    raise new Exception('Could not obtain file handle for file ' + FileName);
  {$ELSEIF ECHOES OR ISLAND}
  var lAccess: PlatformFileAccess := case Mode of
                                         FileOpenMode.ReadOnly: PlatformFileAccess.Read;
                                         FileOpenMode.Create: PlatformFileAccess.Write;
                                         else PlatformFileAccess.ReadWrite;
                                       end;
  var lMode: PlatformFileMode := case Mode of
                                         FileOpenMode.ReadOnly: PlatformFileMode.Open;
                                         FileOpenMode.Create: PlatformFileMode.Create;
                                         else PlatformFileMode.OpenOrCreate;
                                       end;
  inherited constructor(new PlatformFileStream(FileName, lMode, lAccess, PlatformFileShare.Read));
  {$ENDIF}
end;

{$IF COOPER OR TOFFEE}
method FileStream.Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  if Count = 0 then
    exit 0;

  {$IF COOPER}
  result := fInternalStream.read(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  var lBin := fInternalStream.readDataOfLength(Count);
  lBin.getBytes(@Buffer[Offset]) length(lBin.length);

  result := lBin.length;
  {$ENDIF}
end;

method FileStream.Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32;
begin
  if Count = 0 then
    exit;

  result := Count;
  {$IF COOPER}
  fInternalStream.write(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  var lBin := new NSData withBytes(@Buffer[Offset]) length(Count);
  fInternalStream.writeData(lBin);
  {$ENDIF}
end;

method FileStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  {$IF COOPER}
  case Origin of
    SeekOrigin.Begin: fInternalStream.seek(Offset);
    SeekOrigin.Current: fInternalStream.seek(GetPosition + Offset);
    SeekOrigin.End: fInternalStream.seek(GetLength + Offset);
  end;
  {$ELSEIF TOFFEE}
  case Origin of
    SeekOrigin.Begin: fInternalStream.seekToFileOffset(Offset);
    SeekOrigin.Current: fInternalStream.seekToFileOffset(GetPosition + Offset);
    SeekOrigin.End: fInternalStream.seekToFileOffset(GetLength + Offset);
  end;
  {$ENDIF}
end;
{$ENDIF}

method FileStream.Close;
begin
  {$IF COOPER}
  fInternalStream.close;
  {$ELSEIF TOFFEE}
  fInternalStream.closeFile;
  {$ELSEIF ECHOES OR ISLAND}
  PlatformInternalFileStream(fPlatformStream).Close;
  {$ENDIF}
end;

method FileStream.Flush;
begin
  {$IF COOPER}
  fInternalStream.Channel.force(false);
  {$ELSEIF TOFFEE}
  fInternalStream.synchronizeFile;
  {$ELSEIF ECHOES OR ISLAND}
  PlatformInternalFileStream(fPlatformStream).Flush;
  {$ENDIF}
end;
{$ENDIF}

constructor BinaryStream(aStream: Stream);
begin
  {$IF TOFFEE OR ISLAND}
  fBuffer := new Byte[DefBufferSize];
  {$ENDIF}
  fStream := aStream;
end;

constructor BinaryStream(aStream: Stream; aEncoding: Encoding);
begin
  fEncoding := aEncoding;
  constructor(aStream);
end;

{$IF TOFFEE OR ISLAND}
method BinaryStream.ReadRaw(Buffer: ^void; Count: LongInt);
begin
  fStream.&Read(fBuffer, 0, Count);
  {$IF TOFFEE}
  rtl.memcpy(Buffer, @fBuffer[0], Count);
  {$ELSEIF ISLAND}
  {$IFDEF WINDOWS}ExternalCalls.memcpy(Buffer, @fBuffer[0], Count){$ELSEIF POSIX}rtl.memcpy(Buffer, @fBuffer[0], Count){$ENDIF};
  {$ENDIF}
end;

method BinaryStream.WriteRaw(Buffer: ^void; Count: LongInt);
begin
  {$IF TOFFEE}
  rtl.memcpy(@fBuffer[0], Buffer, Count);
  {$ELSEIF ISLAND}
  {$IFDEF WINDOWS}ExternalCalls.memcpy(@fBuffer[0], Buffer, Count){$ELSEIF POSIX}rtl.memcpy(@fBuffer[0], Buffer, Count){$ENDIF};
  {$ENDIF}
  &Write(fBuffer, 0, Count);
end;
{$ENDIF}

method BinaryStream.ReadByte: Byte;
begin
  result := fStream.ReadByte;
end;

method BinaryStream.PeekChar: Int32;
begin
  if not fStream.CanSeek then
    exit -1;

  var lOldPos := fStream.Position;
  result := &Read;
  fStream.Position := lOldPos;
end;

method BinaryStream.Read: Int32;
begin
  var lRead := new Byte[128];
  var lOldPos: Int64;
  var lConverted: String := '';

  if fStream.CanSeek then
    lOldPos := fStream.Position;

  var lBytes: Int32;
  var lTotal := 0;
  while lTotal = 0 do begin
    lBytes := if (fEncoding = Encoding.UTF16BE) or (fEncoding = Encoding.UTF16LE) then 2 else 1;
    var lOneByte := fStream.ReadByte;
    lRead[0] := lOneByte;
    if lOneByte = -1 then
      lBytes := 0;
      if lBytes > 1 then begin
        lOneByte := fStream.ReadByte;
        lRead[1] := lOneByte;
        if lOneByte = -1 then
          lBytes := 1;
      end;

      if lBytes = 0 then
        exit -1;

      try
        lConverted := fEncoding.GetString(lRead, 0, lBytes);
        lTotal := lConverted.Length;
      except
       if fStream.CanSeek then
         fStream.Position := lOldPos;
       raise;
      end;
  end;
  if lConverted.Length = 0 then
    result := -1
  else
    result := Ord(lConverted[0]);
end;

method BinaryStream.Read(Count: Integer): array of Byte;
begin
  var lTotal := Math.Min(Count, fStream.Length);
  result := new Byte[lTotal];
  fStream.Read(result, lTotal);
end;

method BinaryStream.ReadSByte: ShortInt;
begin
  var lByte := ReadByte;
  result := ShortInt(lByte);
end;

method BinaryStream.ReadDouble: Double;
begin
  {$IF COOPER}
  var lTemp := java.nio.ByteBuffer.wrap(Read(sizeOf(result)));
  result := lTemp.getDouble;
  {$ELSEIF ECHOES}
  result := BitConverter.ToDouble(&Read(sizeOf(result)), 0);
  {$ELSEIF ISLAND OR TOFFEE}
  ReadRaw(@result, sizeOf(result));
  {$ENDIF}
end;

method BinaryStream.ReadSingle: Single;
begin
  {$IF COOPER}
  var lTemp := java.nio.ByteBuffer.wrap(Read(sizeOf(result)));
  result := lTemp.getFloat;
  {$ELSEIF ECHOES}
  result := BitConverter.ToSingle(&Read(sizeOf(result)), 0);
  {$ELSEIF ISLAND OR TOFFEE}
  ReadRaw(@result, sizeOf(result));
  {$ENDIF}
end;

method BinaryStream.ReadInt16: Int16;
begin
  {$IF COOPER}
  var lTemp := java.nio.ByteBuffer.wrap(Read(sizeOf(result)));
  result := lTemp.getShort;
  {$ELSEIF ECHOES}
  result := BitConverter.ToInt16(&Read(sizeOf(result)), 0);
  {$ELSEIF ISLAND OR TOFFEE}
  ReadRaw(@result, sizeOf(result));
  {$ENDIF}
end;

method BinaryStream.ReadInt32: Int32;
begin
  {$IF COOPER}
  var lTemp := java.nio.ByteBuffer.wrap(Read(sizeOf(result)));
  result := lTemp.getInt;
  {$ELSEIF ECHOES}
  result := BitConverter.ToInt32(Read(sizeOf(result)), 0);
  {$ELSEIF ISLAND OR TOFFEE}
  ReadRaw(@result, sizeOf(result));
  {$ENDIF}
end;

method BinaryStream.ReadInt64: Int64;
begin
  {$IF COOPER}
  var lTemp := java.nio.ByteBuffer.wrap(Read(sizeOf(result)));
  result := lTemp.getLong;
  {$ELSEIF ECHOES}
  result := BitConverter.ToInt64(&Read(sizeOf(result)), 0);
  {$ELSEIF ISLAND OR TOFFEE}
  ReadRaw(@result, sizeOf(result));
  {$ENDIF}
end;

method BinaryStream.ReadString(Count: Int32): String;
begin
  var lTotal := if Count > fStream.Length - fStream.Position then fStream.Length - fStream.Position else Count;
  var lBytes := new Byte[lTotal];
  fStream.Read(lBytes, lTotal);
  result := fEncoding.GetString(lBytes);
end;

method BinaryStream.Write(aValue: Byte);
begin
  fStream.WriteByte(aValue);
end;

method BinaryStream.Write(aValue: array of Byte; Offset: Int32; Count: Int32);
begin
    fStream.Write(aValue, Offset, Count);
end;

method BinaryStream.WriteSByte(Value: ShortInt);
begin
  fStream.WriteByte(Value);
end;

method BinaryStream.WriteByte(Value: Byte);
begin
  fStream.WriteByte(Value);
end;

method BinaryStream.WriteDouble(Value: Double);
begin
  {$IF COOPER}
  var lSize := sizeOf(Value);
  var lTmp := java.nio.ByteBuffer.allocate(lSize);
  lTmp.putDouble(Value);
  var lArray := lTmp.array;
  &Write(lArray, 0, lSize);
  {$ELSEIF ECHOES}
  var lBuf := BitConverter.GetBytes(Value);
  &Write(lBuf, 0, lBuf.Length);
  {$ELSEIF ISLAND OR TOFFEE}
  &WriteRaw(@Value, sizeOf(Value));
  {$ENDIF}
end;

method BinaryStream.WriteSingle(Value: Single);
begin
  {$IF COOPER}
  var lSize := sizeOf(Value);
  var lTmp := java.nio.ByteBuffer.allocate(lSize);
  lTmp.putFloat(Value);
  var lArray := lTmp.array;
  &Write(lArray, 0, lSize);
  {$ELSEIF ECHOES}
  var lBuf := BitConverter.GetBytes(Value);
  &Write(lBuf, 0, lBuf.Length);
  {$ELSEIF ISLAND OR TOFFEE}
  &WriteRaw(@Value, sizeOf(Value));
  {$ENDIF}
end;

method BinaryStream.WriteInt16(Value: Int16);
begin
  {$IF COOPER}
  var lSize := sizeOf(Value);
  var lTmp := java.nio.ByteBuffer.allocate(lSize);
  lTmp.putShort(Value);
  var lArray := lTmp.array;
  &Write(lArray, 0, lSize);
  {$ELSEIF ECHOES}
  var lBuf := BitConverter.GetBytes(Value);
  &Write(lBuf, 0, lBuf.Length);
  {$ELSEIF ISLAND OR TOFFEE}
  &WriteRaw(@Value, sizeOf(Value));
  {$ENDIF}
end;

method BinaryStream.WriteInt32(Value: Int32);
begin
  {$IF COOPER}
  var lSize := sizeOf(Value);
  var lTmp := java.nio.ByteBuffer.allocate(lSize);
  lTmp.putInt(Value);
  var lArray := lTmp.array;
  &Write(lArray, 0, lSize);
  {$ELSEIF ECHOES}
  var lBuf := BitConverter.GetBytes(Value);
  &Write(lBuf, 0, lBuf.Length);
  {$ELSEIF ISLAND OR TOFFEE}
  &WriteRaw(@Value, sizeOf(Value));
  {$ENDIF}
end;

method BinaryStream.WriteInt64(Value: Int64);
begin
  {$IF COOPER}
  var lSize := sizeOf(Value);
  var lTmp := java.nio.ByteBuffer.allocate(lSize);
  lTmp.putLong(Value);
  var lArray := lTmp.array;
  &Write(lArray, 0, lSize);
  {$ELSEIF ECHOES}
  var lBuf := BitConverter.GetBytes(Value);
  &Write(lBuf, 0, lBuf.Length);
  {$ELSEIF ISLAND OR TOFFEE}
  &WriteRaw(@Value, sizeOf(Value));
  {$ENDIF}
end;

method BinaryStream.WriteString(aString: String);
begin
  var lBytes := fEncoding.GetBytes(aString);
  fStream.Write(lBytes, 0, length(lBytes));
end;

end.