namespace RemObjects.Elements.RTL;

interface

uses
  {$IF COOPER}
  remobjects.elements.linq,
  {$ENDIF}
  RemObjects.Elements;

type
  Folder = public class mapped to PlatformString
  private
    class method GetSeparator: Char;
    {$IF COOPER}
    property JavaFile: java.io.File read new java.io.File(mapped);
    {$ENDIF}
    {$IF ISLAND AND NOT WEBASSEMBLY}
    property IslandFolder: RemObjects.Elements.System.Folder read new RemObjects.Elements.System.Folder(mapped);
    {$ENDIF}
    {$IF TOFFEE}
    method Combine(BasePath: String; SubPath: String): String;
    {$ENDIF}

    {$IF NOT WEBASSEMBLY}
    method DoGetFiles(aFolder: Folder; aList: List<File>);

    method getDateCreated: DateTime;
    method getDateModified: DateTime;
    method setDateModified(aDateTime: DateTime);
    {$ENDIF}
  public
    constructor(aPath: not nullable String);

    class property Separator: Char read GetSeparator;

    {$IF NOT WEBASSEMBLY}
    method Exists: Boolean; // Workaround for 74547: Mapped types: static methods can be called with class type as parameter
    method Create(FailIfExists: Boolean := false);
    method CreateFile(FileName: String; FailIfExists: Boolean := false): File;
    method CreateSubfolder(SubfolderName: String; FailIfExists: Boolean := false): Folder;

    method Delete;
    method Rename(NewName: String): Folder;

    method CopyContentsTo(aNewFolder: Folder; aRecursive: Boolean := true);

    method GetFile(FileName: String): File;
    method GetFiles: not nullable ImmutableList<String>;
    method GetFiles(aRecursive: Boolean): not nullable ImmutableList<String>;
    method GetSubfolders: not nullable List<String>;

    method FirstMatchingSubfolder(aFolder: String; aSubFolderOptions: sequence of String): nullable String;
    begin
      result := Path.FirstMatchingSubfolder(aFolder, aSubFolderOptions);
    end;

    method FirstMatchingSubfolder(aFolder: String; aSubFolderOptions: sequence of String; aBuildPath: block(aFolder, aSubFolder: String): String): nullable String;
    begin
      result := Path.FirstMatchingSubfolder(aFolder, aSubFolderOptions, aBuildPath);
    end;

    class method Create(aFolderName: Folder; FailIfExists: Boolean := false): Folder;
    class method Delete(aFolderName: Folder);
    class method Exists(aFolderName: nullable Folder): Boolean;
    class method GetFiles(aFolderName: Folder; aRecursive: Boolean := false): not nullable ImmutableList<String>;
    class method GetFilesAndFolders(aFolderName: Folder): not nullable ImmutableList<String>;
    class method GetSubfolders(aFolderName: Folder): not nullable List<String>;

    property DateCreated: DateTime read getDateCreated;
    property DateModified: DateTime read getDateModified write setDateModified;
    {$ENDIF}

    property FullPath: not nullable String read mapped;
    property Name: not nullable String read Path.GetFileName(mapped);

    property &Extension: not nullable String read Path.GetExtension(FullPath);
  end;

implementation

{$IF COOPER}
type
  FolderHelper = static class
  public
    method DeleteFolder(Value: java.io.File);
  end;
{$ENDIF}
{$IF TOFFEE}
type
  FolderHelper = static class
  public
    method IsDirectory(Value: String): Boolean;
  end;
{$ENDIF}

constructor Folder(aPath: not nullable String);
begin
  exit Folder(aPath);
end;

class method Folder.GetSeparator: Char;
begin
  {$IF COOPER}
  exit java.io.File.separatorChar;
  {$ELSEIF TOFFEE}
  exit '/';
  {$ELSEIF ECHOES}
  exit System.IO.Path.DirectorySeparatorChar;
  {$ELSEIF ISLAND}
  {$IF WEBASSEMBLY}exit '/';{$ELSE}exit RemObjects.Elements.System.Path.DirectorySeparatorChar;{$ENDIF}
  //exit if defined("WEBASSEMBLY") then '/' else RemObjects.Elements.System.Path.DirectorySeparatorChar;
  {$ENDIF}
end;

{$IF NOT WEBASSEMBLY}
class method Folder.Exists(aFolderName: nullable Folder): Boolean;
begin
  result := (length(aFolderName) > 0) and aFolderName.Exists;
end;

class method Folder.GetFiles(aFolderName: Folder; aRecursive: Boolean := false): not nullable ImmutableList<String>;
begin
  result := if aRecursive then aFolderName.GetFiles(true) else aFolderName.GetFiles(); // latter is optimized
end;

class method Folder.GetFilesAndFolders(aFolderName: Folder): not nullable ImmutableList<String>;
begin
  var lList := new List<String> as not nullable;
  lList.Add(aFolderName.GetFiles);
  for each el in aFolderName.GetSubfolders do 
    lList.Add(el);
  result := lList;
end;

class method Folder.GetSubfolders(aFolderName: Folder): not nullable List<String>;
begin
  result := aFolderName.GetSubfolders();
end;

method Folder.CreateSubfolder(SubfolderName: String; FailIfExists: Boolean := false): Folder;
begin
  result := new Folder(Path.Combine(self.FullPath, SubfolderName));
  result.Create(FailIfExists);
end;

class method Folder.Create(aFolderName: Folder; FailIfExists: Boolean := false): Folder;
begin
  result := Folder(aFolderName);
  result.Create(FailIfExists);
end;

class method Folder.Delete(aFolderName: Folder);
begin
  aFolderName.Delete();
end;

method Folder.DoGetFiles(aFolder: Folder; aList: List<File>);
begin
  aList.Add(aFolder.GetFiles as ImmutableList<File>);
  for each f in aFolder.GetSubFolders() do
    DoGetFiles(Folder(f), aList);
end;

method Folder.GetFiles(aRecursive: Boolean): not nullable ImmutableList<String>;
begin
  if not aRecursive then exit GetFiles();
  var lResult := new List<File>() as not nullable;
  DoGetFiles(self, lResult);
  result := List<String>(lResult);
end;

method Folder.CopyContentsTo(aNewFolder: Folder; aRecursive: Boolean := true);
begin
  aNewFolder.Create();
  for each f in GetFiles() do
    File(f).CopyTo(File(Path.Combine(String(aNewFolder), Path.GetFileName(f))));
  if aRecursive then
    for each f in GetSubfolders() do
      Folder(f).CopyContentsTo(Folder(Path.Combine(String(aNewFolder), Path.getFileName(f))));
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
  {$ENDIF}
end;

method Folder.Exists: Boolean;
begin
  {$IF COOPER}
  result := JavaFile.exists;
  {$ELSEIF TOFFEE}
  var isDirectory := false;
  result := NSFileManager.defaultManager.fileExistsAtPath(self) isDirectory(var isDirectory) and isDirectory;
  {$ELSEIF ECHOES}
  if mapped.Contains("*") or mapped.Contains("?") then
    exit false;
  result := System.IO.Directory.Exists(mapped);
  {$ELSEIF ISLAND}
  result := IslandFolder.Exists();
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
  {$ENDIF}
end;

method Folder.Delete;
begin
  {$IF COOPER}
  var lFile := JavaFile;
  if not lFile.exists then
    raise new IOException(RTLErrorMessages.FOLDER_NOTFOUND, mapped);

  FolderHelper.DeleteFolder(lFile);
  {$ELSEIF TOFFEE}
  var lError: NSError := nil;
  if not NSFileManager.defaultManager.removeItemAtPath(mapped) error(var lError) then
    raise new NSErrorException(lError);
  {$ELSEIF ECHOES}
  System.IO.Directory.Delete(mapped, true);
  {$ELSEIF ISLAND}
  IslandFolder.Delete();
  {$ENDIF}
end;

method Folder.GetFile(FileName: String): File;
begin
  {$IF COOPER}
  var ExistingFile := new java.io.File(mapped, FileName);
  if not ExistingFile.exists then
    exit nil;

  exit ExistingFile.path;
  {$ELSEIF TOFFEE}
  ArgumentNullException.RaiseIfNil(FileName, "FileName");
  var ExistingFileName := Combine(mapped, FileName);
  if not NSFileManager.defaultManager.fileExistsAtPath(ExistingFileName) then
    exit nil;

  exit File(ExistingFileName);
  {$ELSEIF ECHOES}
  var ExistingFileName := System.IO.Path.Combine(mapped, FileName);
  if System.IO.File.Exists(ExistingFileName) then
    exit ExistingFileName;

  exit nil;
  {$ELSEIF ISLAND}
  IslandFolder.GetFile(FileName);
  {$ENDIF}
end;

method Folder.GetFiles: not nullable ImmutableList<String>;
begin
  {$IF COOPER}
  result := JavaFile.listFiles((f,n)->new java.io.File(f, n).isFile).Select(f->f.path).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  var lResult := new List<String> as not nullable;
  var Items := NSFileManager.defaultManager.contentsOfDirectoryAtPath(mapped) error(nil);
  if Items = nil then
    exit lResult;

  for i: Integer := 0 to Items.count - 1 do begin
    var item := Combine(mapped, String(Items.objectAtIndex(i)));
    if not FolderHelper.IsDirectory(item) then
      lResult.Add(String(item));
  end;
  result := lResult;
  {$ELSEIF ECHOES}
  result := new ImmutableList<String>(System.IO.Directory.GetFiles(mapped));
  {$ELSEIF ISLAND}
  result := IslandFolder.GetFiles().Select(f -> f.FullName).ToList() as not nullable;
  {$ENDIF}
end;

method Folder.GetSubfolders: not nullable List<String>;
begin
  {$IF COOPER}
  result := JavaFile.listFiles( (f,n) -> new java.io.File(f, n).isDirectory).Select(f -> f.Path).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := new List<String>();
  var Items := NSFileManager.defaultManager.contentsOfDirectoryAtPath(mapped) error(nil);
  if Items = nil then
    exit;

  for i: Integer := 0 to Items.count - 1 do begin
    var item := Combine(mapped, String(Items.objectAtIndex(i)));
    if FolderHelper.IsDirectory(item) then
      result.Add(String(item));
  end;
  {$ELSEIF ECHOES}
  result := new List<String>(System.IO.Directory.GetDirectories(mapped));
  {$ELSEIF ISLAND}
  result := IslandFolder.GetSubFolders().Select(f -> f.FullName).ToList() as not nullable;
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

  result := Folder(NewName);
  {$ELSEIF TOFFEE}
  var RootFolder := mapped.stringByDeletingLastPathComponent;
  var NewFolderName := Combine(RootFolder, NewName);
  var Manager := NSFileManager.defaultManager;

  if Manager.fileExistsAtPath(NewFolderName) then
    raise new IOException(RTLErrorMessages.FOLDER_EXISTS, NewName);

  var lError: NSError := nil;
  if not Manager.moveItemAtPath(mapped) toPath(NewFolderName) error(var lError) then
    raise new NSErrorException(lError);

  result := Folder(NewFolderName);
  {$ELSEIF ECHOES}
  var TopLevel := System.IO.Path.GetDirectoryName(mapped);
  var FolderName := System.IO.Path.Combine(TopLevel, NewName);
  if System.IO.Directory.Exists(FolderName) then
    raise new IOException(RTLErrorMessages.FOLDER_EXISTS, NewName);

  System.IO.Directory.Move(mapped, FolderName);
  result := FolderName;
  {$ELSEIF ISLAND}
  IslandFolder.Rename(NewName);
  {$ENDIF}
end;

method Folder.getDateCreated: DateTime;
begin
  if not Exists then
    raise new FileNotFoundException(FullPath);
  {$IF COOPER}
  result := new DateTime(new java.util.Date(JavaFile.lastModified())); // Java doesn't seem to have access to the creation date separately?
  {$ELSEIF TOFFEE}
  result := NSFileManager.defaultManager.attributesOfItemAtPath(self.FullPath) error(nil):valueForKey(NSFileCreationDate)
  {$ELSEIF ECHOES}
  result := new DateTime(System.IO.File.GetCreationTimeUtc(mapped));
  {$ELSEIF ISLAND}
  result := new DateTime(IslandFolder.DateCreated);
  {$ENDIF}
end;

method Folder.getDateModified: DateTime;
begin
  if not Exists then
    raise new FileNotFoundException(FullPath);
  {$IF COOPER}
  result := new DateTime(new java.util.Date(JavaFile.lastModified()));
  {$ELSEIF TOFFEE}
  result := NSFileManager.defaultManager.attributesOfItemAtPath(self.FullPath) error(nil):valueForKey(NSFileModificationDate);
  {$ELSEIF ECHOES}
  result := new DateTime(System.IO.File.GetLastWriteTimeUtc(mapped));
  {$ELSEIF ISLAND}
  result := new DateTime(IslandFolder.DateModified);
  {$ENDIF}
end;

{$IF COOPER OR ISLAND}[Warning("Not Implemented for all platforms")]{$ENDIF}
method Folder.setDateModified(aDateTime: DateTime);
begin
  if not Exists then
    raise new FileNotFoundException(FullPath);
  {$IF COOPER}
  {$WARNING Not implemented}
  //JavaFile.setLastModified(...)
  //result := new DateTime(new java.util.Date(JavaFile.lastModified()));
  {$ELSEIF TOFFEE}
  var lError: NSError := nil;
  if not NSFileManager.defaultManager.setAttributes(NSDictionary.dictionaryWithObject(aDateTime) forKey(NSFileModificationDate)) ofItemAtPath(self.FullPath) error(var lError) then
    raise new NSErrorException withError(lError);
  {$ELSEIF ECHOES}
  System.IO.Directory.SetLastWriteTimeUtc(mapped, aDateTime);
  {$ELSEIF ISLAND}
  {$WARNING Not implemented}
  //IslandFolder.DateModified := aDateTime;
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
  {$HIDE CPW8}
  Foundation.NSFileManager.defaultManager.fileExistsAtPath(Value) isDirectory(@Result);
  {$SHOW CPW8}
end;

method Folder.Combine(BasePath: String; SubPath: String): String;
begin
  result := NSString(BasePath):stringByAppendingPathComponent(SubPath);
end;
{$ENDIF}

end.