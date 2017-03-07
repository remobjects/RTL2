namespace RemObjects.Elements.RTL;

interface

type
  Stream = public abstract class
  protected
    method DoGetLength: Int64; virtual;
    method DoSetPosition(Value: Int64); virtual;
    method DoGetPosition: Int64; virtual;
    method DoGetCanRead: Boolean; abstract;
    method DoGetCanSeek: Boolean; abstract;
    method DoGetCanWrite: Boolean; abstract;
    method DoSetLength(Value: Int64); abstract;
    
    method GetLength: Int64; 
    method SetPosition(Value: Int64); 
    method GetPosition: Int64; 
    method GetCanRead: Boolean; 
    method GetCanSeek: Boolean; 
    method GetCanWrite: Boolean; 
    method SetLength(Value: Int64); 
  public
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; abstract;
    method Close; abstract;
    method Flush; abstract;
    method &Read(Buffer: array of Byte; Count: Int32): Int32; abstract;
    method &Write(Buffer: array of Byte; Count: Int32): Int32; abstract;

    method ReadString(out Value: String): Int32; virtual;
    method WriteString(Value: String): Int32; virtual;
    method ReadInteger(out Value: Int32): Int32; virtual;
    method WriteInteger(Value: Int32): Int32; virtual;

    method CopyTo(Destination: Stream); virtual;

    property Length: Int64 read GetLength write SetLength;
    property Position: Int64 read GetPosition write SetPosition;
    property CanRead: Boolean read GetCanRead; 
    property CanSeek: Boolean read GetCanSeek; 
    property CanWrite: Boolean read GetCanWrite; 
  end;

  PlatformInternalMemoryStream = {$IF ECHOES}System.IO.MemoryStream{$ELSEIF COOPER}java.nio.ByteBuffer{$ELSEIF TOFFEE}NSMutableData{$ELSEIF ISLAND}RemObjects.Elements.System.MemoryStream{$ENDIF};

  PlatformMemoryStream = public class
  private
    fInternalStream: PlatformInternalMemoryStream;
    {$IF TOFFEE}
    fPosition: Int64;
    {$ENDIF}
    {$IF TOFFEE OR COOPER}
    method ConvertSeekOffset(Offset: Int64; Origin: SeekOrigin): Int64;
    {$ENDIF}
  public
    constructor;
    constructor(aCapacity: Integer);
    method GetLength: Int64; 
    method SetLength(Value: Int64);
    method SetPosition(aValue: Int64); 
    method GetPosition: Int64;
    method GetBuffer: array of Byte;
    
    method &Read(Buffer: array of Byte; Count: Int32): Int32;
    method &Write(Buffer: array of Byte; Count: Int32): Int32;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64;
  end;

  MemoryStream = public class(Stream)
  private
    fInternalStream: PlatformMemoryStream;
  protected
    method DoGetCanRead: Boolean; override;
    method DoGetCanSeek: Boolean; override;
    method DoGetCanWrite: Boolean; override;
    method DoGetLength: Int64; override;
    method DoSetLength(Value: Int64); override;
    method DoSetPosition(Value: Int64); override;
    method DoGetPosition: Int64; override;
    method GetBytes: array of Byte; virtual;

  public
    constructor;
    constructor(aCapacity: Integer);
    method &Read(Buffer: array of Byte; Count: Int32): Int32; override;
    method &Write(Buffer: array of Byte; Count: Int32): Int32; override;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; override;
    method Close; override;
    method Flush; override;
    property Bytes: array of Byte read GetBytes;
  end;
  
  PlatformInternalFileStream = {$IF ECHOES}System.IO.FileStream{$ELSEIF COOPER}java.io.RandomAccessFile{$ELSEIF TOFFEE}NSFileHandle{$ELSEIF ISLAND}RemObjects.Elements.System.FileStream{$ENDIF};
  
  PlatformIntFileStream = public class
  private
    fInternalStream: PlatformInternalFileStream;
  public
    constructor(FileName: String; Mode: FileOpenMode);
    method GetLength: Int64;
    method SetLength(Value: Int64);
    method SetPosition(Value: Int64);
    method GetPosition: Int64;

    method &Read(Buffer: array of Byte; Count: Int32): Int32;
    method &Write(Buffer: array of Byte; Count: Int32): Int32;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64;
    method Close;
    method Flush;
  end;

  FileStream = public class(Stream)
  private
    fInternalStream: PlatformIntFileStream;
  protected
    method DoGetCanRead: Boolean; override;
    method DoGetCanSeek: Boolean; override;
    method DoGetCanWrite: Boolean; override;
    method DoGetLength: Int64; override;
    method DoSetLength(Value: Int64); override;
    method DoSetPosition(Value: Int64); override;
    method DoGetPosition: Int64; override;

  public
    constructor(FileName: String; Mode: FileOpenMode);
    method &Read(Buffer: array of Byte; Count: Int32): Int32; override;
    method &Write(Buffer: array of Byte; Count: Int32): Int32; override;
    method Seek(Offset: Int64; Origin: SeekOrigin): Int64; override;
    method Close; override;
    method Flush; override;
  end;

implementation

method Stream.ReadString(out Value: String): Int32;
begin

end;

method Stream.WriteString(Value: String): Int32;
begin

end;

method Stream.ReadInteger(out Value: Int32): Int32;
begin

end;

method Stream.WriteInteger(Value: Int32): Int32;
begin

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

method Stream.DoGetLength: Int64;
begin
  if not CanSeek then raise new NotSupportedException();
  var lPos := Seek(0, SeekOrigin.Current);
  var lTemp := Seek(0, SeekOrigin.End);
  Seek(lPos, SeekOrigin.Begin);
  result := lTemp;
end;

method Stream.DoSetPosition(Value: Int64);
begin
  Seek(Value, SeekOrigin.Begin);
end;

method Stream.DoGetPosition: Int64;
begin
  result := Seek(0, SeekOrigin.Current);
end;

method Stream.GetLength: Int64;
begin
  result := DoGetLength;
end;

method Stream.GetPosition: Int64;
begin
  result := DoGetPosition;
end;

method Stream.SetPosition(Value: Int64);
begin
  DoSetPosition(Value);
end;

method Stream.GetCanRead: Boolean; 
begin
  result := DoGetCanRead;
end;

method Stream.GetCanSeek: Boolean; 
begin
  result := DoGetCanSeek;
end;

method Stream.GetCanWrite: Boolean; 
begin
  result := DoGetCanWrite;
end;

method Stream.SetLength(Value: Int64); 
begin
  DoSetLength(Value);
end;

constructor PlatformMemoryStream;
begin
  // TODO refactor, constructor(aCapacity)
  {$IF COOPER}
  fInternalStream := java.nio.ByteBuffer.allocateDirect(0);
  {$ELSEIF ECHOES}
  fInternalStream := new System.IO.MemoryStream();
  {$ELSEIF ISLAND}
  fInternalStream := new RemObjects.Elements.System.MemoryStream();
  {$ELSEIF TOFFEE}
  fInternalStream := new NSMutableData();
  fPosition := 0;
  {$ENDIF}
end;

constructor PlatformMemoryStream(aCapacity: Integer);
begin
  {$IF COOPER}
  fInternalStream := java.nio.ByteBuffer.allocateDirect(aCapacity);
  {$ELSEIF ECHOES}
  fInternalStream := new System.IO.MemoryStream(aCapacity);
  {$ELSEIF ISLAND}
  fInternalStream := new RemObjects.Elements.System.MemoryStream(aCapacity);
  {$ELSEIF TOFFEE}
  fInternalStream := NSMutableData.dataWithCapacity(aCapacity);
  fPosition := 0;
  {$ENDIF}
end;

method PlatformMemoryStream.GetLength: Int64; 
begin
  {$IF COOPER}
  result := fInternalStream.capacity;
  {$ELSEIF ECHOES OR ISLAND}
  result := fInternalStream.Length;
  {$ELSEIF TOFFEE}
  result := fInternalStream.length;
  {$ENDIF}
end;

method PlatformMemoryStream.SetLength(Value: Int64);
begin
  {$IF COOPER}
  var lOldPos := fInternalStream.position;
  var lNewStream := java.nio.ByteBuffer.allocate(Value);
  var lTemp := new Byte[fInternalStream.capacity];
  fInternalStream.position(0);
  fInternalStream.get(lTemp, 0, lTemp.length);
  lNewStream.put(lTemp, 0, lTemp.length);
  lNewStream.position(lOldPos);
  fInternalStream := lNewStream;
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.SetLength(Value);
  {$ELSEIF TOFFEE}
  fInternalStream.length := Value;
  {$ENDIF}
end;

method PlatformMemoryStream.SetPosition(aValue: Int64); 
begin
  {$IF COOPER}
  fInternalStream.position(aValue);
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.Position := aValue;
  {$ELSEIF TOFFEE}
  fPosition := aValue;
  {$ENDIF}
end;

method PlatformMemoryStream.GetPosition: Int64; 
begin
  {$IF COOPER}
  result := fInternalStream.position;
  {$ELSEIF ECHOES OR ISLAND}
  result := fInternalStream.Position;
  {$ELSEIF TOFFEE}
  result := fPosition;
  {$ENDIF}
end;

method PlatformMemoryStream.GetBuffer: array of Byte;
begin
  {$IF COOPER}
  result := fInternalStream.array;
  {$ELSEIF ECHOES}
  result := fInternalStream.GetBuffer;
  {$ELSEIF ISLAND}
  result := fInternalStream.ToArray;
  {$ELSEIF TOFFEE}
  result := new Byte[GetLength];
  fInternalStream.getBytes(result) range(NSMakeRange(0, result.length));
  {$ENDIF}
end;

method PlatformMemoryStream.Read(Buffer: array of Byte; Count: Int32): Int32;
begin
  {$IF COOPER}
  if fInternalStream.remaining < Count then
    result := fInternalStream.remaining
  else
    result := Count;
  fInternalStream.get(Buffer, 0, result);
  {$ELSEIF ECHOES}
  result := fInternalStream.Read(Buffer, 0, Count);
  {$ELSEIF ISLAND}
  result := fInternalStream.Read(Buffer, Count);
  {$ELSEIF TOFFEE}
  fInternalStream.getBytes(Buffer) range(NSMakeRange(fPosition, Count));
  inc(fPosition, Count);
  {$ENDIF}
end;

method PlatformMemoryStream.Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  {$IF COOPER}
  if fInternalStream.remaining < Count then
    result := fInternalStream.remaining
  else
    result := Count;
  fInternalStream.put(Buffer, 0, result);
  {$ELSEIF ECHOES}
  result := fInternalStream.Read(Buffer, 0, Count);
  {$ELSEIF ISLAND}
  result := fInternalStream.Read(Buffer, Count);
  {$ELSEIF TOFFEE}
  fInternalStream.replaceBytesInRange(NSMakeRange(fPosition, Count)) withBytes(Buffer);
  inc(fPosition, Count);
  {$ENDIF}
end;

{$IF TOFFEE OR COOPER}
method PlatformMemoryStream.ConvertSeekOffset(Offset: Int64; Origin: SeekOrigin): Int64;
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
{$ENDIF}

method PlatformMemoryStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  {$IF COOPER}
  result := ConvertSeekOffset(Offset, Origin);
  fInternalStream.position(result);
  {$ELSEIF ECHOES}
  result := fInternalStream.Seek(Offset, System.IO.SeekOrigin(Origin));
  {$ELSEIF ISLAND}
  result := fInternalStream.Seek(Offset, RemObjects.Elements.System.SeekOrigin(Origin));
  {$ELSEIF TOFFEE}
  result := ConvertSeekOffset(Offset, Origin);
  fPosition := result;
  {$ENDIF}
end;

method MemoryStream.GetBytes: array of Byte;
begin
  result := fInternalStream.GetBuffer;
end;

method MemoryStream.DoGetCanRead: Boolean;
begin
  result := true;
end;

method MemoryStream.DoGetCanSeek: Boolean;
begin
  result := true;
end;

method MemoryStream.DoGetCanWrite: Boolean;
begin
  result := true;
end;

method MemoryStream.DoGetLength: Int64;
begin
  result := fInternalStream.GetLength;
end;

method MemoryStream.DoSetLength(Value: Int64);
begin
  fInternalStream.SetLength(Value);
end;

method MemoryStream.DoSetPosition(Value: Int64);
begin
  fInternalStream.SetPosition(Value);
end;

method MemoryStream.DoGetPosition: Int64;
begin
  result := fInternalStream.GetPosition;
end;

constructor MemoryStream;
begin
  fInternalStream := new PlatformMemoryStream;
end;

constructor MemoryStream(aCapacity: Integer);
begin
  fInternalStream := new PlatformMemoryStream(aCapacity);
end;

method MemoryStream.Read(Buffer: array of Byte; Count: Int32): Int32;
begin
  result := fInternalStream.Read(Buffer, Count);
end;

method MemoryStream.Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  result := fInternalStream.Write(Buffer, Count);
end;

method MemoryStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  result := fInternalStream.Seek(Offset, Origin);
end;

method MemoryStream.Close;
begin
  // No OP
end;

method MemoryStream.Flush;
begin
  // No OP
end;

constructor PlatformIntFileStream(FileName: String; Mode: FileOpenMode);
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
  fInternalStream := new PlatformFileStream(FileName, lMode, lAccess, PlatformFileShare.Read);
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

method PlatformIntFileStream.GetLength: Int64;
begin
  {$IF COOPER}
  result := fInternalStream.length;
  {$ELSEIF ECHOES OR ISLAND}
  result := fInternalStream.Length;
  {$ELSEIF TOFFEE}
  var lOrigin := fInternalStream.offsetInFile;
  result := fInternalStream.seekToEndOfFile;
  fInternalStream.seekToFileOffset(lOrigin);
  {$ENDIF}
end;

method PlatformIntFileStream.SetLength(Value: Int64);
begin
  {$IF COOPER}
  fInternalStream.setLength(Value);
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.SetLength(value);
  {$ELSEIF TOFFEE}
  var lOrigin := fInternalStream.offsetInFile;
  fInternalStream.truncateFileAtOffset(Value);
  if lOrigin > Value then
    Seek(0, SeekOrigin.Begin)
  else
    Seek(lOrigin, SeekOrigin.Begin);
  {$ENDIF}
end;

method PlatformIntFileStream.SetPosition(Value: Int64);
begin
  {$IF COOPER}
  Seek(Value, SeekOrigin.Begin);
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.Position := value;
  {$ELSEIF TOFFEE}
  Seek(Value, SeekOrigin.Begin);
  {$ENDIF}
end;

method PlatformIntFileStream.GetPosition: Int64;
begin
  {$IF COOPER}
  result := fInternalStream.FilePointer;
  {$ELSEIF ECHOES OR ISLAND}
  result := fInternalStream.Position;
  {$ELSEIF TOFFEE}
  result := fInternalStream.offsetInFile;
  {$ENDIF}
end;

method PlatformIntFileStream.Read(Buffer: array of Byte; Count: Int32): Int32;
begin
  if Count = 0 then
    exit 0;

  {$IF COOPER}
  result := fInternalStream.read(Buffer, 0, Count);
  {$ELSEIF ECHOES}
  result := fInternalStream.Read(Buffer, 0, Count);
  {$ELSEIF ISLAND}
  result := fInternalStream.Read(Buffer, 0, Count);
  {$ELSEIF TOFFEE}
  var lBin := fInternalStream.readDataOfLength(Count);
  lBin.getBytes(Buffer) length(lBin.length);

  result := lBin.length;
  {$ENDIF}
end;

method PlatformIntFileStream.Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  if Count = 0 then
    exit;

  {$IF COOPER}
  fInternalStream.write(Buffer, 0, Count);
  {$ELSEIF ECHOES}
  fInternalStream.Write(Buffer, 0, Count);
  {$ELSEIF ISLAND}
  fInternalStream.Write(Buffer, Count);
  {$ELSEIF TOFFEE}
  var lBin := new NSData withBytes(Buffer) length(Count);
  fInternalStream.writeData(lBin);
  {$ENDIF}
end;

method PlatformIntFileStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  {$IF COOPER}
  case Origin of
    SeekOrigin.Begin: fInternalStream.seek(Offset);
    SeekOrigin.Current: fInternalStream.seek(GetPosition + Offset);
    SeekOrigin.End: fInternalStream.seek(GetLength + Offset);
  end;
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.Seek(Offset, PlatformSeekOrigin(Origin));
  {$ELSEIF TOFFEE}
  case Origin of
    SeekOrigin.Begin: fInternalStream.seekToFileOffset(Offset);
    SeekOrigin.Current: fInternalStream.seekToFileOffset(GetPosition + Offset);
    SeekOrigin.End: fInternalStream.seekToFileOffset(GetLength + Offset);
  end;
  {$ENDIF}
end;

method PlatformIntFileStream.Close;
begin
  {$IF COOPER}
  fInternalStream.close;
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.Close;
  {$ELSEIF TOFFEE}
  fInternalStream.closeFile;
  {$ENDIF}
end;

method PlatformIntFileStream.Flush;
begin
  {$IF COOPER}
  fInternalStream.Channel.force(false);
  {$ELSEIF ECHOES OR ISLAND}
  fInternalStream.Flush;
  {$ELSEIF TOFFEE}
  fInternalStream.synchronizeFile;
  {$ENDIF}
end;

method FileStream.DoGetCanRead: Boolean;
begin
  result := true;
end;

method FileStream.DoGetCanSeek: Boolean;
begin
  result := true;
end;

method FileStream.DoGetCanWrite: Boolean;
begin
  result := true;
end;

method FileStream.DoGetLength: Int64;
begin
  fInternalStream.GetLength;
end;

method FileStream.DoSetLength(Value: Int64);
begin
  fInternalStream.SetLength(Value);
end;

method FileStream.DoSetPosition(Value: Int64);
begin
  fInternalStream.SetPosition(Value);
end;

method FileStream.DoGetPosition: Int64;
begin
  fInternalStream.GetPosition;
end;

constructor FileStream(FileName: String; Mode: FileOpenMode);
begin
  fInternalStream := new PlatformIntFileStream(FileName, Mode);
end;

method FileStream.Read(Buffer: array of Byte; Count: Int32): Int32;
begin
  fInternalStream.Read(Buffer, Count);
end;

method FileStream.Write(Buffer: array of Byte; Count: Int32): Int32;
begin
  fInternalStream.Write(Buffer, Count);
end;

method FileStream.Seek(Offset: Int64; Origin: SeekOrigin): Int64;
begin
  fInternalStream.Seek(Offset, Origin);
end;

method FileStream.Close;
begin
  fInternalStream.Close;
end;

method FileStream.Flush;
begin
  fInternalStream.Flush;
end;


end.
