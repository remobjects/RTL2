﻿namespace RemObjects.Elements.RTL;

interface

type
  String = public partial class mapped to PlatformString
  private
    method GetLastUnixPathComponent: String;
    method GetLastWindowsPathComponent: String;

  assembly
    method GetLastPathComponentWithSeparatorChar(aSeparator: Char): not nullable String;
    
  public
    
    property FileExists: Boolean read File.Exists(self);
    property FolderExists: Boolean read Folder.Exists(self);
    property FileOrFolderExists: Boolean read Folder.Exists(self) or Folder.Exists(self);
    
    property LastPathComponent: String read Path.GetFilename(self);             // uses the platform-specific folder separator
    property LastUnixPathComponent: String read GetLastUnixPathComponent;       // always uses `/`
    property LastWindowsPathComponent: String read GetLastWindowsPathComponent; // always uses `\`

    property PathWithoutExtension: String read Path.GetPathWithoutExtension(self);
    property PathExtension: String read Path.GetExtension(self);

    property IsWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\\")); // Drive letter or Windows network path

    property IsAbsoluteWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\")); // single back-slash is abolute too, even if useless
    property IsAbsoluteUnixPath: Boolean read StartsWith("/");
    property IsAbsolutePath: Boolean read IsAbsoluteUnixPath or IsAbsoluteWindowsPath;

    // Coverts a knonw-to-be Windows or Unix Path to the opposite
    property ToUnixPathFromWindowsPath: String read Replace("\", "/");
    property ToWindowsPathFromUnixPath: String read Replace("/", "\");

    // Converts a local-style path to be Windows or Unix style
    property ToWindowsPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "\");
    property ToUnixPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "/");

    // Converts a known-to-be Winows or Unix style path to fit the local platform. and back.
    property ToPlatformPathFromWindowsPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace("\", RemObjects.Elements.RTL.Path.DirectorySeparatorChar);
    property ToPlatformPathFromUnixPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace("/", RemObjects.Elements.RTL.Path.DirectorySeparatorChar);

    property ToPathWithLocalFolderPrefixIfRelative: String read if not StartsWith(".") and not StartsWith(Path.DirectorySeparatorChar) then "."+Path.DirectorySeparatorChar+self else self;
    property QuotedIfNeeded: String read if IndexOf(" ") > -1 then '"'+self+'"' else self;

  end;
  
implementation

method String.GetLastPathComponentWithSeparatorChar(aSeparator: Char): not nullable String;
begin
  if RemObjects.Elements.System.length(self) = 0 then
    exit "";

  result := self;
  var LastChar: Char := result[result.Length-1];
  if LastChar = aSeparator then
    result := result.Substring(0, result.Length-1);

  var lIndex := result.LastIndexOf(aSeparator);
  
  if (lIndex > -1) and (lIndex < result.Length-1) then
    exit result.Substring(lIndex+1);
  
  exit result;
end;

method String.GetLastUnixPathComponent: String;
begin
  result := GetLastPathComponentWithSeparatorChar('/');
end;

method String.GetLastWindowsPathComponent: String;
begin
  result := GetLastPathComponentWithSeparatorChar('\');
end;

end.
