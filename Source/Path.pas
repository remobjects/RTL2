namespace Elements.RTL;

interface

type
  Path = public static class
  public
    method ChangeExtension(aFileName: not nullable String; NewExtension: nullable String): not nullable String;
    method Combine(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
    method GetParentDirectory(aFileName: not nullable String): nullable String;
    method GetExtension(aFileName: not nullable String): not nullable String;
    method GetFileName(aFileName: not nullable String): not nullable String;
    method GetFileNameWithoutExtension(aFileName: not nullable String): not nullable String;
    method GetPathWithoutExtension(aFileName: not nullable String): not nullable String;
    method GetFullPath(RelativePath: not nullable String): not nullable String;
    
    {$IF TOFFEE}
    method ExpandTildeInPath(aPath: not nullable String): not nullable String;
    {$ENDIF}
    
    property DirectorySeparatorChar: Char read Folder.Separator;
  end;

implementation

method Path.ChangeExtension(aFileName: not nullable String; NewExtension: nullable String): not nullable String;
begin
  if length(NewExtension) = 0 then
    exit GetFileNameWithoutExtension(aFileName);

  var lIndex := aFileName.LastIndexOf(".");

  if lIndex <> -1 then
    aFileName := aFileName.Substring(0, lIndex);

  if NewExtension[0] = '.' then
    result := aFileName + NewExtension
  else
    result := aFileName + "." + NewExtension as not nullable;
end;

method Path.Combine(aBasePath: not nullable String; params aPaths: array of String): not nullable String;
begin
  result := aBasePath;
  if result.EndsWith(DirectorySeparatorChar) and (length(aPaths) > 0) then
    result := result.Substring(0, result.Length-1);
  for each p in aPaths do
    if length(p) > 0 then
      result := result+DirectorySeparatorChar+p;
end;

method Path.GetParentDirectory(aFileName: not nullable String): nullable String;
begin
  if length(aFileName) = 0 then
    raise new ArgumentException("Invalid arguments");
    
  var LastChar := aFileName[aFileName.Length - 1];

  if LastChar = Folder.Separator then
    aFileName := aFileName.Substring(0, aFileName.Length - 1);

  if (aFileName = Folder.Separator) or ((length(aFileName) = 2) and (aFileName[1] = ':')) then
    exit nil; // root folder has no parent

  var lIndex := aFileName.LastIndexOf(Folder.Separator);

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
  result := aFileName.GetLastPathComponentWithSeparatorChar(DirectorySeparatorChar);
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
  var lIndex2 := aFileName.LastIndexOf(DirectorySeparatorChar);
  
  if (lIndex > lIndex2) then
    exit aFileName.Substring(0, lIndex);

  exit aFileName;
end;

method Path.GetFullPath(RelativePath: not nullable String): not nullable String;
begin
  {$IF COOPER}
  exit new java.io.File(RelativePath).AbsolutePath as not nullable;  
  {$ELSEIF NETFX_CORE}
  exit RelativePath; //api has no such function
  {$ELSEIF WINDOWS_PHONE}
  exit System.IO.Path.GetFullPath(RelativePath)  as not nullable;
  {$ELSEIF ECHOES}
  exit System.IO.Path.GetFullPath(RelativePath) as not nullable;
  {$ELSEIF TOFFEE}
  exit (RelativePath as NSString).stringByStandardizingPath;
  {$ENDIF}
end;

{$IF TOFFEE}
method Path.ExpandTildeInPath(aPath: not nullable String): not nullable String;
begin
  result := (aPath as PlatformString).stringByExpandingTildeInPath;
end;
{$ENDIF}

end.
