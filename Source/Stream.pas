namespace RemObjects.Elements.RTL;

interface

type
  Stream = public abstract class
  public
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; abstract;
    method Close; abstract;
    method Flush; abstract;
    method &Read(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; abstract;
    method &Write(Buffer: array of Byte; Offset: Int32; Count: Int32): Int32; abstract;
    method &Read(Buffer: array of Byte; Count: Int32): Int32; inline;
    method &Write(Buffer: array of Byte; Count: Int32): Int32; inline;
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

  {$IF ECHOES OR ISLAND}
  PlatformStream = {$IF ECHOES}System.IO.Stream{$ELSEIF ISLAND}RemObjects.Elements.System.Stream{$ENDIF};
  WrappedPlatformStream = public abstract class(Stream)
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

    property Length: Int64 read GetLength; override;
    property Position: Int64 read GetPosition write SetPosition; override;
  end;
  {$ENDIF}

  PlatformMemoryStream = {$IF ECHOES}System.IO.MemoryStream{$ELSEIF COOPER}java.io.ByteArrayOutputStream{$ELSEIF TOFFEE}NSMutableData{$ELSEIF ISLAND}RemObjects.Elements.System.MemoryStream{$ENDIF};  
  
  MemoryStream = public class({$IF ECHOES OR ISLAND}WrappedPlatformStream{$ELSE}Stream{$ENDIF})
  private
    {$IF COOPER OR TOFFEE}
    fPosition: Int64;
    {$ENDIF}
    {$IF TOFFEE OR COOPER}
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
    {$IF TOFFEE OR COOPER}
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

    property Bytes: array of Byte read GetBytes;
    property CanRead: Boolean read GetCanRead; override;
    property CanSeek: Boolean read GetCanSeek; override;
    property CanWrite: Boolean read GetCanWrite; override;
  end;
  
  PlatformInternalFileStream = {$IF ECHOES}System.IO.FileStream{$ELSEIF COOPER}java.io.RandomAccessFile{$ELSEIF TOFFEE}NSFileHandle{$ELSEIF ISLAND}RemObjects.Elements.System.FileStream{$ENDIF};
  
  FileStream = public class({$IF ECHOES OR ISLAND}WrappedPlatformStream{$ELSE}Stream{$ENDIF})
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

implementation

method Stream.&Read(Buffer: array of Byte; Count: Int32): Int32; 
begin
  result := &Read(Buffer, 0, Count);
end;

method Stream.&Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  result := &Write(Buffer, 0, Count);
end;

method Stream.CopyTo(Destination: Stream);
const
  bufSize = 4 * 1024; 
begin
  if Destination = nil then raise new Exception('Destination is null');
  if not self.CanRead then raise new NotSupportedException;
  if not Destination.CanWrite then raise new NotSupportedException;
  var lBuf := new Byte[bufSize];
  while true do begin
    var lRest := &Read(lBuf, bufSize);
    if lRest > 0 then lRest := Destination.Write(lBuf, lRest);
    if lRest <> bufSize then break;
  end;
end;

method Stream.GetLength: Int64;
begin
  if not CanSeek then raise new NotSupportedException();
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

{$IF ECHOES OR ISLAND}
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
{$ENDIF}

method MemoryStream.GetBytes: array of Byte;
begin
  {$IF COOPER}
  result := fInternalStream.toByteArray;
  {$ELSEIF ECHOES}
  result := System.IO.MemoryStream(fPlatformStream).GetBuffer;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.MemoryStream(fPlatformStream).ToArray;
  {$ELSEIF TOFFEE}
  result := new Byte[GetLength];
  fInternalStream.getBytes(result) range(NSMakeRange(0, result.length));
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
  result := true;
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
  {$ELSEIF ECHOES}
  fPlatformStream := new System.IO.MemoryStream()
  {$ELSEIF ISLAND}
  fPlatformStream := new RemObjects.Elements.System.MemoryStream();
  {$ELSEIF TOFFEE}
  fInternalStream := new NSMutableData();
  fPosition := 0;
  {$ENDIF}
end;

constructor MemoryStream(aCapacity: Integer);
begin
  {$IF COOPER}
  fInternalStream := new java.io.ByteArrayOutputStream(aCapacity);
  {$ELSEIF ECHOES}
  fPlatformStream := new System.IO.MemoryStream(aCapacity)
  {$ELSEIF ISLAND}
  fPlatformStream := new RemObjects.Elements.System.MemoryStream(aCapacity);
  {$ELSEIF TOFFEE}
  fInternalStream := NSMutableData.dataWithCapacity(aCapacity);
  fPosition := 0;
  {$ENDIF}
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

method MemoryStream.Close;
begin
  // No OP
end;

method MemoryStream.Flush;
begin
  // No OP
end;

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
  fPlatformStream := new PlatformFileStream(FileName, lMode, lAccess, PlatformFileShare.Read);
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
  {$ELSEIF ECHOES OR ISLAND}
  PlatformInternalFileStream(fPlatformStream).Close;
  {$ELSEIF TOFFEE}
  fInternalStream.closeFile;
  {$ENDIF}
end;

method FileStream.Flush;
begin
  {$IF COOPER}
  fInternalStream.Channel.force(false);
  {$ELSEIF ECHOES OR ISLAND}
  PlatformInternalFileStream(fPlatformStream).Flush;
  {$ELSEIF TOFFEE}
  fInternalStream.synchronizeFile;
  {$ENDIF}
end;

end.
