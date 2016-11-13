namespace Elements.RTL;

type
  String = public partial class mapped to PlatformString

  public
    
    property FileExists: Boolean read File.Exists(self);
    property FolderExists: Boolean read Folder.Exists(self);
    property FileOrFolderExists: Boolean read Folder.Exists(self) or Folder.Exists(self);
    
    property LastFilePathComponent: String read Path.GetFilename(self);
    property LastFilePathComponentWithoutExtension: String read Path.GetFileNameWithoutExtension(self);
    property PathExitension: String read Path.GetExtension(self);

    property IsWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\\")); // Drive letter or Windows network path

    property IsAbsoluteWindowsPath: Boolean read (Length > 2) and ((self[1] = ':') or StartsWith("\")); // single back-slash is abolute too, even if useless
    property IsAbsoluteUnixPath: Boolean read StartsWith("/");
    property IsAbsolutePath: Boolean read IsAbsoluteUnixPath or IsAbsoluteWindowsPath;

    // Coverts a knonw-to-be Windows or Unix Path to the opposite
    property ToUnixPathFromWindowsPath: String read Replace("\", "/");
    property ToWindowsPathFromUnixPath: String read Replace("/", "\");

    // Converts a local-style path to be Windows or Unix style
    property ToWindowsPath: String read if Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace(Elements.RTL.Path.DirectorySeparatorChar, "\");
    property ToUnixPath: String read if Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace(Elements.RTL.Path.DirectorySeparatorChar, "/");

    // Converts a known-to-be Winows or Unix style path to fit the local platform. and back.
    property ToPlatformPathFromWindowsPath: String read if Elements.RTL.Path.DirectorySeparatorChar ≠ '\' then self.Replace("\", Elements.RTL.Path.DirectorySeparatorChar);
    property ToPlatformPathFromUnixPath: String read if Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then self.Replace("/", Elements.RTL.Path.DirectorySeparatorChar);

    property ToPathWithLocalFolderPrefixIfRelative: String read if not StartsWith(".") and not StartsWith(Path.DirectorySeparatorChar) then "."+Path.DirectorySeparatorChar+self else self;
    property QuotedIfNeeded: String read if IndexOf(" ") > -1 then '"'+self+'"' else self;

  end;

end.
