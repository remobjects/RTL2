namespace RemObjects.Elements.RTL;

{$IF TOFFEE OR (ISLAND AND (LINUX OR ANDROID))}
  {$DEFINE KNOWN_UNIX}
{$ENDIF}
{$IF ISLAND AND WINDOWS}
  {$DEFINE KNOWN_WINDOWS}
{$ENDIF}

type
  String = public partial class mapped to PlatformString

  public

    {$IF NOT WEBASSEMBLY}
    property FileExists: Boolean read File.Exists(File(self)); inline;
    property FolderExists: Boolean read Folder.Exists(Folder(self)); inline;
    property FileOrFolderExists: Boolean read File.Exists(File(self)) or Folder.Exists(Folder(self)); inline;
    {$ENDIF}

    property LastPathComponent: String read Path.GetFileName(self); inline;                                 // uses the platform-specific folder separator
    property LastUnixPathComponent: String read Path.GetUnixFileName(self); inline;
    property LastWindowsPathComponent: String read Path.GetWindowsFileName(self); inline;

    property LastPathComponentWithoutExtension: String read Path.GetFileNameWithoutExtension(self); inline; // uses the platform-specific folder separator
    property LastUnixPathComponentWithoutExtension: String read Path.GetFileNameWithoutExtension(LastUnixPathComponent); inline;
    property LastWindowsPathComponentWithoutExtension: String read Path.GetFileNameWithoutExtension(LastWindowsPathComponent); inline;

    property PathWithoutExtension: String read Path.GetPathWithoutExtension(self); inline;
    property PathExtension: String read Path.GetExtension(self); inline;
    property NetworkServerName: nullable String read Path.GetNetworkServerName(self); inline;

    property ParentDirectory: nullable String read Path.GetParentDirectory(self);
    property WindowsParentDirectory: nullable String read Path.GetWindowsParentDirectory(self);
    property UnixParentDirectory: nullable String read Path.GetUnixParentDirectory(self);

    method AppendPath(params aPaths: array of String): nullable String;
    begin
      result := Path.Combine(self, aPaths);
    end;

    method AppendWindowsPath(params aPaths: array of String): nullable String;
    begin
      result := Path.CombineWindowsPath(self, aPaths);
    end;

    method AppendUnixPath(params aPaths: array of String): nullable String;
    begin
      result := Path.CombineUnixPath(self, aPaths);
    end;

    property IsWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\\")); // Drive letter or Windows network path

    property IsAbsoluteWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\")); // single back-slash is abolute too, even if useless
    property IsAbsoluteUnixPath: Boolean read StartsWith("/");
    property IsAbsolutePath: Boolean read IsAbsoluteUnixPath or IsAbsoluteWindowsPath;

    method ToPathRelativeToFolder(aBasePath: not nullable String): nullable String;
    begin
      result := Url.UrlWithFilePath(self).FilePathRelativeToUrl(Url.UrlWithFilePath(aBasePath)) Always(true);
    end;

    method ToPathRelativeToFolder(aBasePath: not nullable String) Threshold(aThreshold: Integer): nullable String;
    begin
      result := Url.UrlWithFilePath(self).FilePathRelativeToUrl(Url.UrlWithFilePath(aBasePath)) Threshold(aThreshold);
    end;

    method ToPathRelativeToFolder(aBasePath: not nullable String) Always(aAlways: Boolean): nullable String;
    begin
      result := Url.UrlWithFilePath(self).FilePathRelativeToUrl(Url.UrlWithFilePath(aBasePath)) Always(aAlways);
    end;

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
    property QuotedIfNeeded: String read if IndexOf(" ") > -1 then String('"'+self+'"') else self;
    {$IFDEF STRICTMAPPED}
    class operator Implicit(aVal: String): Folder; inline; begin exit PlatformString(aVal); end;
    class operator Implicit(aVal: String): File; inline; begin exit PlatformString(aVal); end;
    class operator Implicit(aVal: Folder): String; inline; begin exit PlatformString(aVal); end;
    class operator Implicit(aVal: File): String; inline; begin exit PlatformString(aVal); end;
    {$ENDIF}
  end;

end.