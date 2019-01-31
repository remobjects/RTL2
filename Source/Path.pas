namespace RemObjects.Elements.RTL;

interface

type
  Path = public static class
  private
    method DoGetParentDirectory(aFileName: not nullable String; aFolderSeparator: Char): nullable String;

  public
    method ChangeExtension(aFileName: not nullable String; NewExtension: nullable String): not nullable String;

    method Combine(aBasePath: nullable String; params aPaths: array of String): nullable String;
    method CombineUnixPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
    method CombineWindowsPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;

    method GetParentDirectory(aFileName: not nullable String): nullable String;
    method GetUnixParentDirectory(aFileName: not nullable String): nullable String;
    method GetWindowsParentDirectory(aFileName: not nullable String): nullable String;

    method GetExtension(aFileName: not nullable String): not nullable String;
    method GetFileName(aFileName: not nullable String): not nullable String;
    method GetUnixFileName(aFileName: not nullable String): not nullable String;
    method GetWindowsFileName(aFileName: not nullable String): not nullable String;
    method GetFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
    method GetPathWithoutExtension(aFileName: not nullable String): not nullable String;
    {$IF NOT WEBASSEMBLY}
    method GetFullPath(RelativePath: not nullable String): not nullable String;
    {$ENDIF}
    method GetPath(aFullPath: not nullable String) RelativeToPath(aBasePath: not nullable String): nullable String;

    method GetNetworkServerName(aFileName: not nullable String): nullable String;

    {$IF TOFFEE OR (ISLAND AND DARWIN)}
    method ExpandTildeInPath(aPath: not nullable String): not nullable String;
    {$ENDIF}

    property DirectorySeparatorChar: Char read Folder.Separator;
    property PathListSeparatorChar: Char read if Environment.OS = OperatingSystem.Windows then ';' else ':';
  end;

implementation

method Path.ChangeExtension(aFileName: not nullable String; NewExtension: nullable String): not nullable String;
begin
  var lIndex := aFileName.LastIndexOf(".");

  if lIndex <> -1 then
    aFileName := aFileName.Substring(0, lIndex);

  if length(NewExtension) = 0 then
    exit aFileName;

  if NewExtension[0] = '.' then
    result := aFileName + NewExtension
  else
    result := aFileName + "." + NewExtension as not nullable;
end;

method Path.Combine(aBasePath: nullable String; params aPaths: array of String): nullable String;
begin
  if not assigned(aBasePath) then
    exit nil;

  result := aBasePath;
  if result.EndsWith(Folder.Separator) and (length(aPaths) > 0) then
    result := result.Substring(0, result.Length-1);
  for each p in aPaths do
    if length(p) > 0 then
      result := result+Folder.Separator+p;
end;

method Path.CombineUnixPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
begin
  result := aBasePath;
  if result.EndsWith("/") and (length(aPaths) > 0) then
    result := result.Substring(0, result.Length-1);
  for each p in aPaths do
    if length(p) > 0 then
      result := result+"/"+p;
end;

method Path.CombineWindowsPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
begin
  result := aBasePath;
  if result.EndsWith("\") and (length(aPaths) > 0) then
    result := result.Substring(0, result.Length-1);
  for each p in aPaths do
    if length(p) > 0 then
      result := result+"\"+p;
end;

method Path.GetParentDirectory(aFileName: not nullable String): nullable String;
begin
  result := DoGetParentDirectory(aFileName, Folder.Separator);
end;

method Path.GetUnixParentDirectory(aFileName: not nullable String): nullable String;
begin
  result := DoGetParentDirectory(aFileName, '/');
end;

method Path.GetWindowsParentDirectory(aFileName: not nullable String): nullable String;
begin
  result := DoGetParentDirectory(aFileName, '\');
end;

method Path.DoGetParentDirectory(aFileName: not nullable String; aFolderSeparator: Char): nullable String;
begin
  if length(aFileName) = 0 then
    raise new ArgumentException("Invalid arguments");

  var LastChar := aFileName[aFileName.Length - 1];

  if LastChar = aFolderSeparator then
    aFileName := aFileName.Substring(0, aFileName.Length - 1);

  if (aFileName = aFolderSeparator) or ((length(aFileName) = 2) and (aFileName[1] = ':')) then
    exit nil; // root folder has no parent

  var lIndex := aFileName.LastIndexOf(aFolderSeparator);

  if aFileName.StartsWith('\\') then begin

    if lIndex > 1 then
      result := aFileName.Substring(0, lIndex)
    else
      result := nil; // network share has no parent folder

  end
  else begin

    if lIndex > -1 then
      result := aFileName.Substring(0, lIndex)
    else
      result := ""

  end;
end;

method Path.GetExtension(aFileName: not nullable String): not nullable String;
begin
  aFileName := GetFileName(aFileName);
  var lIndex := aFileName.LastIndexOf(".");

  if (lIndex <> -1) and (lIndex < aFileName.Length - 1) then
    exit aFileName.Substring(lIndex);

  exit "";
end;

method Path.GetFileName(aFileName: not nullable String): not nullable String;
begin
  result := aFileName.GetLastPathComponentWithSeparatorChar(Folder.Separator);
end;

method Path.GetUnixFileName(aFileName: not nullable String): not nullable String;
begin
  result := aFileName.GetLastPathComponentWithSeparatorChar('/');
end;

method Path.GetWindowsFileName(aFileName: not nullable String): not nullable String;
begin
  result := aFileName.GetLastPathComponentWithSeparatorChar('\');
end;

method Path.GetFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
begin
  aFileName := GetFileName(aFileName);
  var lIndex := aFileName.LastIndexOf(".");

  if lIndex <> -1 then
    exit aFileName.Substring(0, lIndex);

  exit aFileName;
end;

method Path.GetPathWithoutExtension(aFileName: not nullable String): not nullable String;
begin
  var lIndex := aFileName.LastIndexOf(".");
  var lIndex2 := aFileName.LastIndexOf(Folder.Separator);

  if (lIndex > lIndex2) then
    exit aFileName.Substring(0, lIndex);

  exit aFileName;
end;

{$IF NOT WEBASSEMBLY}
method Path.GetFullPath(RelativePath: not nullable String): not nullable String;
begin
  {$IF COOPER}
  exit new java.io.File(RelativePath).AbsolutePath as not nullable;
  {$ELSEIF NETFX_CORE}
  exit RelativePath; //api has no such function
  {$ELSEIF ECHOES}
  exit System.IO.Path.GetFullPath(RelativePath) as not nullable;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Path.GetFullPath(RelativePath) as String as not nullable;
  {$ELSEIF TOFFEE}
  exit (RelativePath as NSString).stringByStandardizingPath;
  {$ENDIF}
end;
{$ENDIF}

method Path.GetPath(aFullPath: not nullable String) RelativeToPath(aBasePath: not nullable String): nullable String;
begin
  result := Url.UrlWithFilePath(aFullPath).FilePathRelativeToUrl(Url.UrlWithFilePath(aBasePath)) Always(true);
end;

method Path.GetNetworkServerName(aFileName: not nullable String): nullable String;
begin
  if not aFileName.StartsWith("\\") then exit nil;
  aFileName := aFileName.Substring(2);
  var p := aFileName.IndexOf("\");
  if p ≤ -1 then exit nil;
  result := aFileName.Substring(0, p);
end;


{$IF TOFFEE OR (ISLAND AND DARWIN)}
method Path.ExpandTildeInPath(aPath: not nullable String): not nullable String;
begin
  result := (aPath as Foundation.NSString).stringByExpandingTildeInPath as not nullable String;
end;
{$ENDIF}

end.