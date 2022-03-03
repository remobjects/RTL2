namespace RemObjects.Elements.RTL;

interface

type
  Path = public static class
  private
    method GetLastPathComponentWithSeparatorChar(aPath:String; aSeparator: Char): not nullable String;
    method GetLastPathComponentWithSeparatorChars(aPath:String; aSeparators: array of Char): not nullable String;

  public
    method ChangeExtension(aFileName: not nullable String; aNewExtension: nullable String): not nullable String;

    method Combine(aBasePath: nullable String; params aPaths: array of String): nullable String;
    method CombineUnixPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
    method CombineWindowsPath(aBasePath: not nullable String; params aPaths: array of String): not nullable String;

    {$IF NOT WEBASSEMBLY}
    method FirstMatchingSubfolder(aFolder: String; aSubFolderOptions: sequence of String): nullable String;
    begin
      for each f in aSubFolderOptions do
        if Path.Combine(aFolder, f).FolderExists then
          exit Path.Combine(aFolder, f);
    end;

    method FirstMatchingSubfolder(aFolder: String; aSubFolderOptions: sequence of String; aBuildPath: block(aFolder, aSubFolder: String): String): nullable String;
    begin
      for each f in aSubFolderOptions do begin
        var p := aBuildPath(aFolder, f);
        if p:FolderExists then
          exit p;
      end;
    end;
    {$ENDIF}

    method GetParentDirectory(aFileName: not nullable String) FolderSeparator(aFolderSeparator: Char): nullable String;
    method GetParentDirectory(aFileName: not nullable String) FolderSeparators(aFolderSeparators: array of Char): nullable String; private;

    method GetParentDirectory(aFileName: not nullable String): nullable String;
    method GetUnixParentDirectory(aFileName: not nullable String): nullable String;
    method GetWindowsParentDirectory(aFileName: not nullable String): nullable String;

    method GetExtension(aFileName: not nullable String): not nullable String;

    method GetFileName(aFileName: not nullable String): not nullable String;
    method GetUnixFileName(aFileName: not nullable String): not nullable String;
    method GetWindowsFileName(aFileName: not nullable String): not nullable String;

    method GetFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
    method GetUnixFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
    method GetWindowsFileNameWithoutExtension(aFileName: not nullable String): not nullable String;

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

method Path.ChangeExtension(aFileName: not nullable String; aNewExtension: nullable String): not nullable String;
begin
  if (length(aNewExtension) > 0) and (aNewExtension[0] ≠ '.') then
    aNewExtension := "."+aNewExtension
  else if aNewExtension = "." then
    aNewExtension := nil;

  var lIndex := aFileName.LastIndexOf(".");
  var lFolderIndex := aFileName.LastIndexOfAny(['/','\']);

  if (lIndex > -1) and (lFolderIndex ≤ lIndex) then
    aFileName := aFileName.Substring(0, lIndex);

  if length(aNewExtension) > 0 then
    result := aFileName+aNewExtension as not nullable
  else
    result := aFileName;
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
  if defined("WINDOWS") or (defined("ECHOES") and (Environment.OS = OperatingSystem.Windows)) then
    result := GetParentDirectory(aFileName) FolderSeparators(['/','\'])
  else
    result := GetParentDirectory(aFileName) FolderSeparator(Folder.Separator);
end;

method Path.GetUnixParentDirectory(aFileName: not nullable String): nullable String;
begin
  result := GetParentDirectory(aFileName) FolderSeparator('/');
end;

method Path.GetWindowsParentDirectory(aFileName: not nullable String): nullable String;
begin
  result := GetParentDirectory(aFileName)  FolderSeparator('\');
end;

method Path.GetParentDirectory(aFileName: not nullable String) FolderSeparator(aFolderSeparator: Char): nullable String;
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

method Path.GetParentDirectory(aFileName: not nullable String) FolderSeparators(aFolderSeparators: array of Char): nullable String;
begin
  if length(aFileName) = 0 then
    raise new ArgumentException("Invalid arguments");

  var LastChar := aFileName[aFileName.Length - 1];

  if aFolderSeparators.ContainsChar(LastChar) then
    aFileName := aFileName.Substring(0, aFileName.Length - 1);

  if ((length(aFileName) = 1) and aFolderSeparators.ContainsChar(aFileName[0])) or ((length(aFileName) = 2) and (aFileName[1] = ':')) then
    exit nil; // root folder has no parent

  var lIndex := aFileName.LastIndexOfAny(aFolderSeparators);

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
  if defined("WINDOWS") or (defined("ECHOES") and (Environment.OS = OperatingSystem.Windows)) then
    result := GetLastPathComponentWithSeparatorChars(aFileName, ['/','\'])
  else
    result := GetLastPathComponentWithSeparatorChar(aFileName, Folder.Separator);
end;

method Path.GetUnixFileName(aFileName: not nullable String): not nullable String;
begin
  result := GetLastPathComponentWithSeparatorChar(aFileName, '/');
end;

method Path.GetWindowsFileName(aFileName: not nullable String): not nullable String;
begin
  result := GetLastPathComponentWithSeparatorChar(aFileName, '\');
end;

method Path.GetFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
begin
  aFileName := GetFileName(aFileName);
  var lIndex := aFileName.LastIndexOf(".");

  if lIndex <> -1 then
    exit aFileName.Substring(0, lIndex);

  exit aFileName;
end;

method Path.GetUnixFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
begin
  aFileName := GetUnixFileName(aFileName);
  var lIndex := aFileName.LastIndexOf(".");

  if lIndex <> -1 then
    exit aFileName.Substring(0, lIndex);

  exit aFileName;
end;

method Path.GetWindowsFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
begin
  aFileName := GetWindowsFileName(aFileName);
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

method Path.GetLastPathComponentWithSeparatorChar(aPath:String; aSeparator: Char): not nullable String;
begin
  if RemObjects.Elements.System.length(aPath) = 0 then
    exit "";

  result := aPath as not nullable;
  var LastChar: Char := result[result.Length-1];
  if LastChar = aSeparator then
    result := result.Substring(0, result.Length-1);

  var lIndex := result.LastIndexOf(aSeparator);

  if (lIndex > -1) and (lIndex < result.Length-1) then
    exit result.Substring(lIndex+1);

  exit result;
end;

method Path.GetLastPathComponentWithSeparatorChars(aPath:String; aSeparators: array of Char): not nullable String;
begin
  if RemObjects.Elements.System.length(aPath) = 0 then
    exit "";

  result := aPath as not nullable;
  var LastChar: Char := result[result.Length-1];
  if aSeparators.ContainsChar(LastChar) then
    result := result.Substring(0, result.Length-1);

  var lIndex := result.LastIndexOfAny(aSeparators);

  if (lIndex > -1) and (lIndex < result.Length-1) then
    exit result.Substring(lIndex+1);

  exit result;
end;

end.