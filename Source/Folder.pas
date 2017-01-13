namespace RemObjects.Elements.RTL;

interface

{$IF COOPER}
uses com.remobjects.elements.linq;
{$ENDIF}

type
  Folder = public class mapped to {$IF WINDOWS_PHONE OR NETFX_CORE}Windows.Storage.StorageFolder{$ELSE}PlatformString{$ENDIF}
  private
    class method GetSeparator: Char;
    {$IF COOPER}
    property JavaFile: java.io.File read new java.io.File(mapped);
    {$ELSEIF ISLAND}
    property IslandFolder: RemObjects.Elements.System.Folder read new RemObjects.Elements.System.Folder(mapped);
    {$ELSEIF TOFFEE}
    method Combine(BasePath: String; SubPath: String): String;
    {$ENDIF}

    method DoGetFiles(aFolder: Folder; aList: List<File>);
  public
    constructor(aPath: not nullable String);

    method Exists: Boolean; // Workaround for 74547: Mapped types: static methods can be called with class type as parameter
    method Create(FailIfExists: Boolean := false);
    method CreateFile(FileName: String; FailIfExists: Boolean := false): File;
    method CreateSubfolder(SubfolderName: String; FailIfExists: Boolean := false): Folder;

    method Delete;
    method Rename(NewName: String): Folder;

    method GetFile(FileName: String): File;
    method GetFiles: not nullable List<File>;
    method GetFiles(aRecursive: Boolean): not nullable List<File>;
    method GetSubfolders: not nullable List<Folder>;

    class method Create(FolderName: Folder; FailIfExists: Boolean := false): Folder;
    class method Delete(FolderName: Folder);
    class method Exists(aFolderName: nullable Folder): Boolean;
    class method GetFiles(FolderName: Folder; aRecursive: Boolean := false): not nullable List<File>;
    class method GetSubfolders(FolderName: Folder): not nullable List<Folder>;

    class property Separator: Char read GetSeparator;

    {$IF WINDOWS_PHONE OR NETFX_CORE}
    property FullPath: not nullable String read mapped.Path;
    property Name: not nullable String read mapped.Name;
    {$ELSE}
    property FullPath: not nullable String read mapped;
    property Name: not nullable String read Path.GetFileName(mapped);
    {$ENDIF}
    property &Extension: not nullable String read Path.GetExtension(FullPath);
  end;

  {$IF WINDOWS_PHONE OR NETFX_CORE}
  extension method Windows.Foundation.IAsyncOperation<TResult>.Await<TResult>: TResult;
  {$ENDIF}

implementation

{$IF COOPER OR TOFFEE}
type
  FolderHelper = static class
  public
    {$IF COOPER}method DeleteFolder(Value: java.io.File);{$ENDIF}
    {$IF TOFFEE}method IsDirectory(Value: String): Boolean;{$ENDIF}
  end;
{$ELSEIF WINDOWS_PHONE OR NETFX_CORE}
type
  FolderHelper = static class
  public
    method GetFile(Folder: Windows.Storage.StorageFolder; FileName: String): Windows.Storage.StorageFile;
    method GetFolder(Folder: Windows.Storage.StorageFolder; FolderName: String): Windows.Storage.StorageFolder;
  end;
{$ENDIF}

constructor Folder(aPath: not nullable String);
begin
  {$IF WINDOWS_PHONE OR NETFX_CORE}
  exit Windows.Storage.StorageFolder.GetFolderFromPathAsync(aPath).Await;
  {$ELSE}
  exit Folder(aPath);
  {$ENDIF}
end;

class method Folder.Exists(aFolderName: nullable Folder): Boolean;
begin
  result := (length(aFolderName) > 0) and aFolderName.Exists;
end;

class method Folder.GetFiles(FolderName: Folder; aRecursive: Boolean := false): not nullable List<File>;
begin
  result := if aRecursive then FolderName.GetFiles(true) else FolderName.GetFiles(); // latter is optimized
end;

class method Folder.GetSubfolders(FolderName: Folder): not nullable List<Folder>;
begin
  result := FolderName.GetSubfolders();
end;

method Folder.CreateSubfolder(SubfolderName: String; FailIfExists: Boolean := false): Folder;
begin
  result := new Folder(Path.Combine(self.FullPath, SubfolderName));
  result.Create(FailIfExists);
end;

class method Folder.Create(FolderName: Folder; FailIfExists: Boolean := false): Folder;
begin
  result := Folder(FolderName);
  result.Create(FailIfExists);
end;

class method Folder.Delete(FolderName: Folder);
begin
  FolderName.Delete();
end;

method Folder.DoGetFiles(aFolder: Folder; aList: List<File>);
begin
  aList.Add(aFolder.GetFiles);
  for each f in aFolder.GetSubFolders() do
    DoGetFiles(f, aList);
end;

method Folder.GetFiles(aRecursive: Boolean): not nullable List<File>;
begin
  if not aRecursive then exit GetFiles();
  result := new List<File>();
  DoGetFiles(self, result)
end;

{$IF WINDOWS_PHONE OR NETFX_CORE}
class method FolderHelper.GetFile(Folder: Windows.Storage.StorageFolder; FileName: String): Windows.Storage.StorageFile;
begin
  ArgumentNullException.RaiseIfNil(Folder, "Folder");
  ArgumentNullException.RaiseIfNil(FileName, "FileName");
  try
    exit Folder.GetFileAsync(FileName).Await;
  except
    exit nil;
  end;
end;

class method FolderHelper.GetFolder(Folder: Windows.Storage.StorageFolder; FolderName: String): Windows.Storage.StorageFolder;
begin
  ArgumentNullException.RaiseIfNil(Folder, "Folder");
  ArgumentNullException.RaiseIfNil(FolderName, "FolderName");
  try
    exit Folder.GetFolderAsync(FolderName).Await;
  except
    exit nil;
  end;
end;

class method Folder.GetSeparator: Char;
begin
  exit '\';
end;

class method Folder.UserHomeFolder: Folder;
begin
  exit Windows.Storage.ApplicationData.Current.LocalFolder;
end;

method Folder.CreateFile(FileName: String; FailIfExists: Boolean := false): File;
begin
  exit mapped.CreateFileAsync(FileName, iif(FailIfExists, Windows.Storage.CreationCollisionOption.FailIfExists, Windows.Storage.CreationCollisionOption.OpenIfExists)).Await;
end;

method Folder.Exists(): Boolean;
begin
  // WP8 API - best API
  try
    var item := Windows.Storage.ApplicationData.Current.LocalFolder.GetItemAsync(mapped.Name).Await();
    exit assigned(item);
  except
    exit false;
  end;
end;

method Folder.Create(FailIfExists: Boolean := false);
begin
  mapped.CreateFolderAsync(self.FullPath, iif(FailIfExists, Windows.Storage.CreationCollisionOption.FailIfExists, Windows.Storage.CreationCollisionOption.OpenIfExists)).Await();
end;

method Folder.Delete;
begin
  mapped.DeleteAsync.AsTask.Wait;
end;

method Folder.GetFile(FileName: String): File;
begin
  exit FolderHelper.GetFile(mapped, FileName);
end;

method Folder.GetFiles: not nullable List<File>;
begin
  var files := mapped.GetFilesAsync.Await;
  result := new List<File>();
  for i: Integer := 0 to files.Count-1 do
    result.Add(File(files.Item[i]));
end;

method Folder.GetSubfolders: not nullable List<Folder>;
begin
  var folders := mapped.GetFoldersAsync.Await;
  result := new List<Folder>();
  for i: Integer := 0 to folders.Count-1 do
    result.Add(Folder(folders.Item[i]));
end;

method Folder.Rename(NewName: String): Folder;
begin
  mapped.RenameAsync(NewName, Windows.Storage.NameCollisionOption.FailIfExists).AsTask().Wait();
end;

extension method Windows.Foundation.IAsyncOperation<TResult>.&Await<TResult>: TResult;
begin
  exit self.AsTask.Result;
end;
{$ELSE}
class method Folder.GetSeparator: Char;
begin
  {$IF COOPER}
  exit java.io.File.separatorChar;
  {$ELSEIF ECHOES}
  exit System.IO.Path.DirectorySeparatorChar;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Path.DirectorySeparatorChar;
  {$ELSEIF TOFFEE}
  exit '/';
  {$ENDIF}
end;

method Folder.CreateFile(FileName: String; FailIfExists: Boolean := false): File;
begin
  {$IF COOPER}
  var lNewFile := new java.io.File(mapped, FileName);
  if lNewFile.exists then begin
    if FailIfExists then
      raise new IOException(RTLErrorMessages.FILE_EXISTS, FileName);

    exit lNewFile.path;
  end
  else begin
    lNewFile.createNewFile;
  end;
  result := lNewFile.path;
  {$ELSEIF ECHOES}
  var NewFileName := System.IO.Path.Combine(mapped, FileName);

  if System.IO.File.Exists(NewFileName) then begin
    if FailIfExists then
      raise new IOException(RTLErrorMessages.FILE_EXISTS, FileName);

    exit NewFileName;
  end;

  var fs := System.IO.File.Create(NewFileName);
  fs.Close;
  exit NewFileName;
  {$ELSEIF ISLAND}
  result := IslandFolder.CreateFile(FileName).FullName;
  {$ELSEIF TOFFEE}
  var NewFileName := Combine(mapped, FileName);
  var Manager := NSFileManager.defaultManager;
  if Manager.fileExistsAtPath(NewFileName) then begin
    if FailIfExists then
      raise new IOException(RTLErrorMessages.FILE_EXISTS, FileName);

    exit File(NewFileName);
  end;

  Manager.createFileAtPath(NewFileName) contents(nil) attributes(nil);
  exit File(NewFileName);
  {$ENDIF}
end;

method Folder.Exists: Boolean;
begin
  {$IF COOPER}
  result := JavaFile.exists;
  {$ELSEIF ECHOES}
  result := System.IO.Directory.Exists(mapped);
  {$ELSEIF ISLAND}
  result := IslandFolder.Exists();
  {$ELSEIF TOFFEE}
  var isDirectory := false;
  result := NSFileManager.defaultManager.fileExistsAtPath(self) isDirectory(var isDirectory) and isDirectory;
  {$ENDIF}
end;

method Folder.Create(FailIfExists: Boolean := false);
begin
  {$IF COOPER}
  var lFile := JavaFile;
  if lFile.exists then begin
    if FailIfExists then
      raise new IOException(RTLErrorMessages.FOLDER_EXISTS, mapped);
    exit;
  end
  else begin
    if not lFile.mkdir then
      raise new IOException(RTLErrorMessages.FOLDER_CREATE_ERROR, mapped);
  end;
  {$ELSEIF ECHOES}
  if System.IO.Directory.Exists(mapped) then begin
    if FailIfExists then
      raise new IOException(RTLErrorMessages.FOLDER_EXISTS, mapped);
  end
  else begin
    System.IO.Directory.CreateDirectory(mapped);
  end;
  {$ELSEIF ISLAND}
  RemObjects.Elements.System.Folder.CreateFolder(mapped, FailIfExists);
  {$ELSEIF TOFFEE}
  var isDirectory := false;
  if NSFileManager.defaultManager.fileExistsAtPath(mapped) isDirectory(var isDirectory) then begin
    if isDirectory and FailIfExists then
      raise new IOException(RTLErrorMessages.FOLDER_EXISTS, mapped);
    if not isDirectory then
      raise new IOException(RTLErrorMessages.FILE_EXISTS, mapped);
  end
  else begin
    var lError: NSError := nil;
    if not NSFileManager.defaultManager.createDirectoryAtPath(mapped) withIntermediateDirectories(true) attributes(nil) error(var lError) then
      raise new NSErrorException(lError);
  end;
  {$ENDIF}
end;

method Folder.Delete;
begin
  {$IF COOPER}
  var lFile := JavaFile;
  if not lFile.exists then
    raise new IOException(RTLErrorMessages.FOLDER_NOTFOUND, mapped);

  FolderHelper.DeleteFolder(lFile);
  {$ELSEIF ECHOES}
  System.IO.Directory.Delete(mapped, true);
  {$ELSEIF ISLAND}
  IslandFolder.Delete();
  {$ELSEIF TOFFEE}
  var lError: NSError := nil;
  if not NSFileManager.defaultManager.removeItemAtPath(mapped) error(var lError) then
    raise new NSErrorException(lError);
  {$ENDIF}
end;

method Folder.GetFile(FileName: String): File;
begin
  {$IF COOPER}
  var ExistingFile := new java.io.File(mapped, FileName);
  if not ExistingFile.exists then
    exit nil;

  exit ExistingFile.path;
  {$ELSEIF ECHOES}
  var ExistingFileName := System.IO.Path.Combine(mapped, FileName);
  if System.IO.File.Exists(ExistingFileName) then
    exit ExistingFileName;

  exit nil;
  {$ELSEIF ISLAND}
  IslandFolder.GetFile(FileName);
  {$ELSEIF TOFFEE}
  ArgumentNullException.RaiseIfNil(FileName, "FileName");
  var ExistingFileName := Combine(mapped, FileName);
  if not NSFileManager.defaultManager.fileExistsAtPath(ExistingFileName) then
    exit nil;

  exit File(ExistingFileName);
  {$ENDIF}
end;

method Folder.GetFiles: not nullable List<File>;
begin
  {$IF COOPER}
  result := JavaFile.listFiles((f,n)->new java.io.File(f, n).isFile).Select(f->f.path).ToList() as not nullable;
  {$ELSEIF ECHOES}
  result := new List<File>(System.IO.Directory.GetFiles(mapped));
  {$ELSEIF ISLAND}
  result := IslandFolder.GetFiles().Select(f -> f.FullName).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := new List<File>;
  var Items := NSFileManager.defaultManager.contentsOfDirectoryAtPath(mapped) error(nil);
  if Items = nil then
    exit;

  for i: Integer := 0 to Items.count - 1 do begin
    var item := Combine(mapped, Items.objectAtIndex(i));
    if not FolderHelper.IsDirectory(item) then
      result.Add(File(item));
  end;
  {$ENDIF}
end;

method Folder.GetSubfolders: not nullable List<Folder>;
begin
  {$IF COOPER}
  result := JavaFile.listFiles( (f,n) -> new java.io.File(f, n).isDirectory).Select(f -> f.Path).ToList() as not nullable;
  {$ELSEIF ECHOES}
  result := new List<Folder>(System.IO.Directory.GetDirectories(mapped));
  {$ELSEIF ISLAND}
  result := IslandFolder.GetSubFolders().Select(f -> f.FullName).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := new List<Folder>();
  var Items := NSFileManager.defaultManager.contentsOfDirectoryAtPath(mapped) error(nil);
  if Items = nil then
    exit;

  for i: Integer := 0 to Items.count - 1 do begin
    var item := Combine(mapped, Items.objectAtIndex(i));
    if FolderHelper.IsDirectory(item) then
      result.Add(Folder(item));
  end;
  {$ENDIF}
end;

method Folder.Rename(NewName: String): Folder;
begin
  {$IF COOPER}
  var lFile := JavaFile;
  var NewFolder := new java.io.File(lFile.ParentFile, NewName);
  if NewFolder.exists then
    raise new IOException(RTLErrorMessages.FOLDER_EXISTS, NewName);

  if not lFile.renameTo(NewFolder) then
    raise new IOException(RTLErrorMessages.IO_RENAME_ERROR, mapped, NewName);

  result := NewName;
  {$ELSEIF ECHOES}
  var TopLevel := System.IO.Path.GetDirectoryName(mapped);
  var FolderName := System.IO.Path.Combine(TopLevel, NewName);
  if System.IO.Directory.Exists(FolderName) then
    raise new IOException(RTLErrorMessages.FOLDER_EXISTS, NewName);

  System.IO.Directory.Move(mapped, FolderName);
  result := FolderName;
  {$ELSEIF ISLAND}
  IslandFolder.Rename(NewName);
  {$ELSEIF TOFFEE}
  var RootFolder := mapped.stringByDeletingLastPathComponent;
  var NewFolderName := Combine(RootFolder, NewName);
  var Manager := NSFileManager.defaultManager;

  if Manager.fileExistsAtPath(NewFolderName) then
    raise new IOException(RTLErrorMessages.FOLDER_EXISTS, NewName);

  var lError: NSError := nil;
  if not Manager.moveItemAtPath(mapped) toPath(NewFolderName) error(var lError) then
    raise new NSErrorException(lError);

  result := NewFolderName;
  {$ENDIF}
end;
{$ENDIF}

{$IF COOPER}
class method FolderHelper.DeleteFolder(Value: java.io.File);
begin
  if Value.isDirectory then begin
    var Items := Value.list;
    for Item in Items do
      DeleteFolder(new java.io.File(Value, Item));

    if not Value.delete then
      raise new IOException(RTLErrorMessages.FOLDER_DELETE_ERROR, Value.Name);
  end
  else
    if not Value.delete then
      raise new IOException(RTLErrorMessages.FOLDER_DELETE_ERROR, Value.Name);
end;
{$ENDIF}

{$IF TOFFEE}
class method FolderHelper.IsDirectory(Value: String): Boolean;
begin
  Foundation.NSFileManager.defaultManager.fileExistsAtPath(Value) isDirectory(@Result);
end;

method Folder.Combine(BasePath: String; SubPath: String): String;
begin
  result := NSString(BasePath):stringByAppendingPathComponent(SubPath);
end;
{$ENDIF}

end.