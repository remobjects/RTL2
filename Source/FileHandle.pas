namespace RemObjects.Elements.RTL;


interface

type
  FileOpenMode = public (&ReadOnly, &Create, ReadWrite);
  SeekOrigin = public (&Begin, Current, &End);

  {$IF ECHOES}
  PlatformSeekOrigin = public System.IO.SeekOrigin;
  {$ENDIF}
  {$IF ISLAND}
  PlatformSeekOrigin = public RemObjects.Elements.System.SeekOrigin;
  {$ENDIF}

  {$IF NOT WEBASSEMBLY}

  {$IF ECHOES}
  PlatformFileMode = System.IO.FileMode;
  PlatformFileAccess = System.IO.FileAccess;
  PlatformFileShare = System.IO.FileShare;
  PlatformFileStream = System.IO.FileStream;
  {$ENDIF}
  {$IF ISLAND}
  PlatformFileMode = RemObjects.Elements.System.FileMode;
  PlatformFileAccess = RemObjects.Elements.System.FileAccess;
  PlatformFileShare = RemObjects.Elements.System.FileShare;
  PlatformFileStream = RemObjects.Elements.System.FileStream;
  {$ENDIF}

  FileHandle = public class mapped to {$IF COOPER}java.io.RandomAccessFile{$ELSEIF ECHOES OR ISLAND}PlatformFileStream{$ELSEIF TOFFEE}NSFileHandle{$ENDIF}
  private
    method GetLength: Int64;
    method SetLength(value: Int64);
    method GetPosition: Int64;
    method SetPosition(value: Int64);
    method ValidateBuffer(Buffer: array of Byte; Offset: Integer; Count: Integer);
  public
    constructor(FileName: String; Mode: FileOpenMode);

    class method FromFile(aFile: File; Mode: FileOpenMode): FileHandle;

    method Close;
    method Flush;
    method &Read(Buffer: array of Byte; Offset: Integer; Count: Integer): Integer;
    method &Read(Buffer: array of Byte; Count: Integer): Integer;
    method &Read(Count: Integer): ImmutableBinary;
    method &Write(Buffer: array of Byte; Offset: Integer; Count: Integer);
    method &Write(Buffer: array of Byte; Count: Integer);
    method &Write(Buffer: array of Byte);
    method &Write(Data: ImmutableBinary);
    method Seek(Offset: Int64; Origin: SeekOrigin);

    property Length: Int64 read GetLength write SetLength;
    property Position: Int64 read GetPosition write SetPosition;
  end;

  {$ENDIF}

implementation

{$IF NOT WEBASSEMBLY}

constructor FileHandle(FileName: String; Mode: FileOpenMode);
begin
  {$IF COOPER}
  var lMode: String := if Mode = FileOpenMode.ReadOnly then "r" else "rw";
  exit new java.io.RandomAccessFile(FileName, lMode);
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
  exit new PlatformFileStream(FileName, lMode, lAccess, PlatformFileShare.Read);
  {$ELSEIF TOFFEE}
  case Mode of
    FileOpenMode.ReadOnly: result := NSFileHandle.fileHandleForReadingAtPath(FileName);
    FileOpenMode.ReadWrite: result :=  NSFileHandle.fileHandleForUpdatingAtPath(FileName);
    FileOpenMode.Create: begin
        result :=  NSFileHandle.fileHandleForWritingAtPath(FileName);
        if not assigned(result) then begin
          NSFileManager.defaultManager.createFileAtPath(FileName) contents(nil) attributes(nil);
          result :=  NSFileHandle.fileHandleForWritingAtPath(FileName);
        end;
      end;
    else raise new NotImplementedException;
  end;
  if not assigned(result) then
    raise new Exception('Could not obtain file handle for file '+FileName);
  {$ENDIF}
end;

class method FileHandle.FromFile(aFile: File; Mode: FileOpenMode): FileHandle;
begin
  {$IF COOPER}
  var lMode: String := if Mode = FileOpenMode.ReadOnly then "r" else "rw";
  exit new java.io.RandomAccessFile(aFile, lMode);
  {$ELSEIF ECHOES OR ISLAND}
  var lMode: PlatformFileAccess := if Mode = FileOpenMode.ReadOnly then PlatformFileAccess.Read else PlatformFileAccess.ReadWrite;
  exit new PlatformFileStream(PlatformString(aFile), PlatformFileMode.Open, lMode);
  {$ELSEIF TOFFEE}
  case Mode of
    FileOpenMode.ReadOnly: exit NSFileHandle.fileHandleForReadingAtPath(aFile);
    FileOpenMode.ReadWrite: exit NSFileHandle.fileHandleForUpdatingAtPath(aFile);
  end;
  {$ENDIF}
end;

method FileHandle.Close;
begin
  {$IF COOPER}
  mapped.close;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Close;
  {$ELSEIF TOFFEE}
  mapped.closeFile;
  {$ENDIF}
end;

method FileHandle.Flush;
begin
  {$IF COOPER}
  mapped.Channel.force(false);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Flush;
  {$ELSEIF TOFFEE}
  mapped.synchronizeFile;
  {$ENDIF}
end;

method FileHandle.ValidateBuffer(Buffer: array of Byte; Offset: Integer; Count: Integer);
begin
  if Buffer = nil then
    raise new ArgumentNullException("Buffer");

  if Offset < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Offset");

  if Count < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Count");

  if Count = 0 then
    exit;

  var BufferLength := RemObjects.Oxygene.System.length(Buffer);

  if Offset >= BufferLength then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "Offset");

  if Count > BufferLength then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "Count");

  if Offset + Count > BufferLength then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.OUT_OF_RANGE_ERROR, Offset, Count, BufferLength);
end;

method FileHandle.Read(Buffer: array of Byte; Offset: Integer; Count: Integer): Integer;
begin
  ValidateBuffer(Buffer, Offset, Count);

  if Count = 0 then
    exit 0;

  {$IF COOPER}
  exit mapped.read(Buffer, Offset, Count);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Read(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  var Bin := mapped.readDataOfLength(Count);
  Bin.getBytes(@Buffer[Offset]) length(Bin.length);

  exit Bin.length;
  {$ENDIF}
end;

method FileHandle.&Read(Buffer: array of Byte; Count: Integer): Integer;
begin
  exit &Read(Buffer, 0, Count);
end;

method FileHandle.&Read(Count: Integer): ImmutableBinary;
begin
  var Buffer := new Byte[Count];
  var lCount := &Read(Buffer, 0, Count);
  var lResult := new Binary;
  lResult.Write(Buffer, lCount);
  result := lResult;
end;

method FileHandle.Write(Buffer: array of Byte; Offset: Integer; Count: Integer);
begin
  ValidateBuffer(Buffer, Offset, Count);

  if Count = 0 then
    exit;

  {$IF COOPER}
  mapped.write(Buffer, Offset, Count);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Write(Buffer, Offset, Count);
  {$ELSEIF TOFFEE}
  var Bin := new NSData withBytes(@Buffer[Offset]) length(Count);
  mapped.writeData(Bin);
  {$ENDIF}
end;

method FileHandle.&Write(Buffer: array of Byte; Count: Integer);
begin
  &Write(Buffer, 0, Count);
end;

method FileHandle.&Write(Buffer: array of Byte);
begin
  &Write(Buffer, 0, RemObjects.Oxygene.System.length(Buffer));
end;

method FileHandle.&Write(Data: ImmutableBinary);
begin
  ArgumentNullException.RaiseIfNil(Data, "Data");
  &Write(Data.ToArray, 0, Data.Length);
end;

method FileHandle.Seek(Offset: Int64; Origin: SeekOrigin);
begin
  {$IF COOPER}
  case Origin of
    SeekOrigin.Begin: mapped.seek(Offset);
    SeekOrigin.Current: mapped.seek(Position + Offset);
    SeekOrigin.End: mapped.seek(Length + Offset);
  end;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Seek(Offset, PlatformSeekOrigin(Origin));
  {$ELSEIF TOFFEE}
  case Origin of
    SeekOrigin.Begin: mapped.seekToFileOffset(Offset);
    SeekOrigin.Current: mapped.seekToFileOffset(Position + Offset);
    SeekOrigin.End: mapped.seekToFileOffset(Length + Offset);
  end;
  {$ENDIF}
end;

method FileHandle.GetLength: Int64;
begin
  {$IF COOPER}
  exit mapped.length;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Length;
  {$ELSEIF TOFFEE}
  var Origin := mapped.offsetInFile;
  result := mapped.seekToEndOfFile;
  mapped.seekToFileOffset(Origin);
  {$ENDIF}
end;

method FileHandle.SetLength(value: Int64);
begin
  {$IF COOPER}
  mapped.setLength(Value);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.SetLength(value);
  {$ELSEIF TOFFEE}
  var Origin := mapped.offsetInFile;
  mapped.truncateFileAtOffset(value);
  if Origin > value then
    Seek(0, SeekOrigin.Begin)
  else
    Seek(Origin, SeekOrigin.Begin);
  {$ENDIF}
end;

method FileHandle.GetPosition: Int64;
begin
  {$IF COOPER}
  exit mapped.FilePointer;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Position;
  {$ELSEIF TOFFEE}
  exit mapped.offsetInFile;
  {$ENDIF}
end;

method FileHandle.SetPosition(value: Int64);
begin
  {$IF COOPER}
  Seek(value, SeekOrigin.Begin);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Position := value;
  {$ELSEIF TOFFEE}
  Seek(value, SeekOrigin.Begin);
  {$ENDIF}
end;

{$ENDIF}

end.