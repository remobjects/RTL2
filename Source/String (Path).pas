namespace Elements.RTL;

type
  String = public partial class mapped to PlatformString

  public
    
    property FileExists: Boolean read File.Exists(self);
    property FolderExists: Boolean read Folder.Exists(self);

    property IsWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\\"));

    property PathIsAbsolute: Boolean read StartsWith("/") or IsWindowsPath;
    property CrossPlatformPathIsAbsolute: Boolean read StartsWith("/") or StartsWith("\") or IsWindowsPath;

    property UnixPathFromWindowsPath: String read Replace("\", "/");
    property WindowsPathFromUnixPath: String read Replace("/", "\");

    property PathWithLocalFolderPrefixIfRelative: String read if not StartsWith(".") and not StartsWith("/") then "."+Path.DirectorySeparatorChar+self else self;
    property QuotedIfNeeded: String read if IndexOf(" ") > -1 then '"'+self+'"' else self;

  end;

end.
