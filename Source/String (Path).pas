namespace RemObjects.Elements.RTL;

{$IF TOFFEE OR (ISLAND AND (LINUX OR ANDROID))}
  {$DEFINE KNOWN_UNIX}
{$ENDIF}
{$IF ISLAND AND WINDOWS}
  {$DEFINE KNOWN_WINDOWS}
{$ENDIF}

interface

type
  String = public partial class mapped to PlatformString
  private
    method GetLastUnixPathComponent: String;
    method GetLastWindowsPathComponent: String;

  assembly
    method GetLastPathComponentWithSeparatorChar(aSeparator: String): not nullable String;

  public

    {$IF NOT WEBASSEMBLY}
    property FileExists: Boolean read File.Exists(self);
    property FolderExists: Boolean read Folder.Exists(self);
    property FileOrFolderExists: Boolean read File.Exists(self) or Folder.Exists(self);
    {$ENDIF}

    property LastPathComponent: String read Path.GetFilename(self);                                 // uses the platform-specific folder separator
    property LastPathComponentWithoutExtension: String read Path.GetFilenameWithoutExtension(self); // uses the platform-specific folder separator
    property LastUnixPathComponent: String read GetLastUnixPathComponent;                           // always uses `/`
    property LastWindowsPathComponent: String read GetLastWindowsPathComponent;                     // always uses `\`

    property PathWithoutExtension: String read Path.GetPathWithoutExtension(self); inline;
    property PathExtension: String read Path.GetExtension(self); inline;
    property NetworkServerName: nullable String read Path.GetNetworkServerName(self); inline;

    property IsWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\\")); // Drive letter or Windows network path

    property IsAbsoluteWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\")); // single back-slash is abolute too, even if useless
    property IsAbsoluteUnixPath: Boolean read StartsWith("/");
    property IsAbsolutePath: Boolean read IsAbsoluteUnixPath or IsAbsoluteWindowsPath;

    // Coverts a knonw-to-be Windows or Unix Path to the opposite
    property ToUnixPathFromWindowsPath: String read Replace("\", "/");
    property ToWindowsPathFromUnixPath: String read Replace("/", "\");

    {$IF KNOWN_UNIX}
    // Converts a local-style path to be Windows or Unix style
    property ToWindowsPath: String read self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "\");
    property ToUnixPath: String read self;
    // Converts a known-to-be Winows or Unix style path to fit the local platform. and back.
    property ToPlatformPathFromWindowsPath: String read self.Replace("\", RemObjects.Elements.RTL.Path.DirectorySeparatorChar);
    property ToPlatformPathFromUnixPath: String read self;
    {$ELSEIF KNOWN_WINDOWS}
    // Converts a local-style path to be Windows or Unix style
    property ToWindowsPath: String read self;
    property ToUnixPath: String read self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "/");
    // Converts a known-to-be Winows or Unix style path to fit the local platform. and back.
    property ToPlatformPathFromWindowsPath: String read self;
    property ToPlatformPathFromUnixPath: String read self.Replace("/", RemObjects.Elements.RTL.Path.DirectorySeparatorChar);
    {$ELSE}
    // Converts a local-style path to be Windows or Unix style
    property ToWindowsPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "\") else self;
    property ToUnixPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, "/") else self;
    // Converts a known-to-be Winows or Unix style path to fit the local platform. and back.
    property ToPlatformPathFromWindowsPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace("\", RemObjects.Elements.RTL.Path.DirectorySeparatorChar) else self;
    property ToPlatformPathFromUnixPath: String read if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace("/", RemObjects.Elements.RTL.Path.DirectorySeparatorChar) else self;
    {$ENDIF}

    property ToPathWithLocalFolderPrefixIfRelative: String read if not StartsWith(".") and not StartsWith(Path.DirectorySeparatorChar) then "."+Path.DirectorySeparatorChar+self else self;
    property QuotedIfNeeded: String read if IndexOf(" ") > -1 then '"'+self+'"' else self;

  end;

implementation

method String.GetLastPathComponentWithSeparatorChar(aSeparator: String): not nullable String;
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