namespace RemObjects.Elements.RTL;

interface

{$IF TOFFEE OR (ISLAND AND (LINUX OR ANDROID))}
  {$DEFINE KNOWN_UNIX}
{$ENDIF}
{$IF ISLAND AND WINDOWS}
  {$DEFINE KNOWN_WINDOWS}
{$ENDIF}

type
  Url = public class// {$IF COOPER}mapped to java.net.URL{$ELSEIF ECHOES}mapped to System.Uri{$ELSEIF TOFFEE}mapped to Foundation.NSURL{$ENDIF}
  private
    var fScheme, fHost, fPath, fQueryString, fFragment, fUser: String;
    var fPort: nullable Int32;
    var fCanonicalVersion: Url;
    var fIsCanonical: Boolean;
    var fCachedAbsoluteString: String;
    var fCachedLastPathComponent: String;
    {$IF NOT KNOWN_UNIX}
    var fCachedFilePath: String;
    {$ENDIF}

    method Parse(aUrlString: not nullable String): Boolean;
    method GetHostNameAndPort: nullable String;
    method GetPathAndQueryString: nullable String;
    method CopyWithPath(aPath: not nullable String): not nullable Url;

    method GetFilePath: nullable String;
    method GetWindowsPath: nullable String;
    method GetUnixPath: nullable String;
    method GetCanonicalVersion(): Url;

    method GetPathExtension: String;
    method GetLastPathComponent: String;
    method GetFilePathWithoutLastComponent: String;
    method GetWindowsPathWithoutLastComponent: String;
    method GetUnixPathWithoutLastComponent: String;
    method GetUrlWithoutLastComponent: Url;

    method DoUnixPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3) CaseInsensitive(aCaseInsensitive: Boolean := false): String; //inline; 76882: Echoes: E0 Internal error: GOUNKEX137 with `inline`

    constructor; empty;
    constructor(aScheme: not nullable String; aHost: String; aPath: String);
    constructor(aUrlString: not nullable String);
  public

    class method UrlWithString(aUrlString: nullable String): Url;
    class method UrlWithFilePath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;
    class method UrlWithFilePath(aPath: not nullable String) relativeToUrl(aUrl: not nullable Url) isDirectory(aIsDirectory: Boolean := false): Url;
    class method UrlWithWindowsPath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;
    class method UrlWithUnixPath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;

    property Scheme: String read fScheme;
    property Host: String read fHost;
    property Port: nullable Integer read fPort;
    property Path: String read fPath;
    property QueryString: String read fQueryString;
    property Fragment: String read fFragment;
    property User: String read fUser;

    property HostAndPort: nullable String read GetHostNameAndPort;
    property PathAndQueryString: nullable String read GetPathAndQueryString;

    [ToString]
    method ToString: String; override;
    method ToAbsoluteString: String;

    class method AddPercentEncodingsToPath(aString: String): String;
    class method RemovePercentEncodingsFromPath(aString: String; aAlsoRemovePlusCharacter: Boolean := false): String;
    class method UrlEncodeString(aString: String): String;

    //property PathWithoutLastComponent: String read GetPathWithoutLastComponent; // includes trailing "/" or "\", NOT decoded

    property CanonicalVersion: Url read GetCanonicalVersion;
    property IsFileUrl: Boolean read fScheme = "file";
    property FileExists: Boolean read IsFileUrl and File.Exists(Path);
    property FolderExists: Boolean read IsFileUrl and Folder.Exists(Path);
    property IsAbsoluteWindowsFileURL: Boolean
      read IsFileUrl
        and (((Path:Length ≥ 3) and ((Path[2] = ':') or // absolute drive path, eg `C:`
                                     (Path[1] = '/') and (Path[2] = '/'))) or // network path with `\\`
             (length(fHost) > 0));
    property IsAbsoluteWindowsDriveLetterFileURL: Boolean
      read IsFileUrl and (Path:Length ≥ 3) and (Path[2] = ':');
    property IsAbsoluteWindowsNetworkDriveFileURL: Boolean
      read IsFileUrl and (((Path:Length ≥ 3) and (Path[1] = '/') and (Path[2] = '/')) or (length(fHost) > 0));
    //property IsAbsoluteUnixFileURL: Boolean read IsFileUrl and (Path:StartsWith("/"));

    method IsUnderneath(aPotentialBaseUrl: not nullable Url): Boolean;

    // these are all Url-decoded:
    property FilePath: String read {$IF KNOWN_UNIX}fPath{$ELSE}GetFilePath{$ENDIF};               // converts "/" to "\" on Windows, only
    property WindowsPath: String read GetWindowsPath;                                         // converts "/" to "\", always
    property UnixPath: String read {$IF KNOWN_UNIX}fPath{$ELSE}GetUnixPath{$ENDIF};           // always keeps "/"

    property PathExtension: String read GetPathExtension;     // will include the "."
    property LastPathComponent: String read GetLastPathComponent;
    property LastPathComponentWithoutExtension: String read RemObjects.Elements.RTL.Path.GetFilenameWithoutExtension(GetLastPathComponent);
    property FilePathWithoutLastComponent: String read GetFilePathWithoutLastComponent;               // includes trailing "/" or "\"
    property WindowsPathWithoutLastComponent: String read GetWindowsPathWithoutLastComponent; // includes trailing "\"
    property UnixPathWithoutLastComponent: String read GetUnixPathWithoutLastComponent;       // includes trailing "/"
    property UrlWithoutLastComponent: Url read GetUrlWithoutLastComponent;

    method UrlWithChangedPathExtension(aNewExtension: nullable String): nullable Url; // expects ".", but will add it if needed
    method UrlWithAddedPathExtension(aNewExtension: not nullable String): nullable Url; // expects ".", but will add it if needed

    method UrlWithChangedLastPathComponent(aNewLastPathComponent: not nullable String): nullable Url;

    method GetParentUrl(): Url;

    method SubUrl(params aComponents: array of String): not nullable Url;
    method SubUrl(params aComponents: array of String) isDirectory(aIsDirectory: Boolean): not nullable Url;
    method SubUrlWithFilePath(aSubPath: String): not nullable Url;
    method SubUrlWithFilePath(aSubPath: String) isDirectory(aIsDirectory: Boolean): not nullable Url;

    //method UrlWithRelativeOrAbsoluteSubPath(aSubPath: not nullable String): nullable Url;
    method UrlWithRelativeOrAbsoluteFileSubPath(aSubPath: not nullable String): nullable Url;
    method UrlWithRelativeOrAbsoluteWindowsSubPath(aSubPath: not nullable String): nullable Url;

    method UrlWithFragment(aFragment: nullable String): not nullable Url;
    method UrlWithoutFragment(): not nullable Url; inline;

    method FilePathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String; inline;
    method WindowsPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String; inline;
    method UnixPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String;

    method FilePathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String; //inline; 76830: Toffee: "E0 Internal error: Could not resolve member op_Implicit on RemObjects.Elements.RTL.String" with inline
    method WindowsPathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String; inline;
    method UnixPathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String; inline;

    /* Needed for fire

    * Url.fileURLWithPath(_hintPath) relativeToURL(project.baseURL);

    */

    /*method CrossPlatformPath: String;
    begin
      result := Path;
      if (IsAbsoluteWindowsFileURL) then
        result := result.Substring(1).windowsPathFromUnixPath;
    end;*/

    {$IF COOPER}
    operator Implicit(aUrl: java.net.URL): Url;
    operator Implicit(aUrl: Url): java.net.URL;
    {$ELSEIF ECHOES}
    operator Implicit(aUrl: System.Uri): Url;
    operator Implicit(aUrl: Url): System.Uri;
    {$ELSEIF TOFFEE}
    operator Implicit(aUrl: Foundation.NSURL): Url;
    operator Implicit(aUrl: Url): Foundation.NSURL;
    {$ENDIF}

    class operator Equal(Value1: Url; Value2: Url): Boolean;
    class operator NotEqual(Value1: Url; Value2: Url): Boolean;
    class operator Equal(Value1: Url; Value2: Object): Boolean;
    class operator NotEqual(Value1: Url; Value2: Object): Boolean;
    class operator Equal(Value1: Object; Value2: Url): Boolean;
    class operator NotEqual(Value1: Object; Value2: Url): Boolean;

    {$IF TOFFEE}
    method isEqual(obj: id): Boolean; override;
    method copyWithZone(aZone: ^NSZone): instancetype;
    method hash: NSUInteger; override;
    {$ENDIF}
  end;

implementation

constructor Url(aUrlString: not nullable String);
begin
  if not Parse(aUrlString) then
    raise new FormatException("Invalid URL format '{0}'", aUrlString)
end;

constructor Url(aScheme: not nullable String; aHost: String; aPath: String);
begin
  fScheme := aScheme;
  fHost := aHost;
  fPath := aPath;
end;

class method Url.UrlWithString(aUrlString: nullable String): Url;
begin
  try
    if length(aUrlString) > 0 then
      result := new Url(aUrlString);
  except
    on FormatException do;
  end;
end;

class method Url.UrlWithFilePath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;
begin
  {$IF NOT KNOWN_UNIX}
  if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then
    exit UrlWithWindowsPath(aPath) isDirectory(aIsDirectory);
  {$ENDIF}
  if aPath.IsAbsoluteWindowsPath then
    aPath := "/"+aPath; // Windows paths always get an extra "/"
  result := UrlWithUnixPath(aPath) isDirectory(aIsDirectory);
end;

class method Url.UrlWithFilePath(aPath: not nullable String) relativeToUrl(aUrl: not nullable Url) isDirectory(aIsDirectory: Boolean := false): Url;
begin
  if aPath.IsAbsolutePath then
    result := UrlWithFilePath(aPath) isDirectory(aIsDirectory)
  else
    result := UrlWithFilePath(Path.Combine(aUrl.FilePath, aPath)) isDirectory(aIsDirectory).CanonicalVersion;
end;

class method Url.UrlWithWindowsPath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;
begin
  if aPath.IsAbsoluteWindowsPath then begin
    if (length(aPath) ≥ 2) and (aPath[0] = '\') and (aPath[1] = '\') then begin
      aPath := aPath.Substring(2);
      var p := aPath.IndexOf("\");
      if p > 0 then begin
        var lHost := aPath.Substring(0, p);
        aPath := aPath.Substring(p);
        aPath := aPath.Replace("\", "/");
        result := UrlWithUnixPath(aPath) isDirectory(aIsDirectory);
        result.fHost := lHost;
        exit;
      end;
    end
    else begin
      aPath := "/"+aPath; // Windows paths always get an extra "/"
    end;
  end;
  aPath := aPath.Replace("\", "/");
  result := UrlWithUnixPath(aPath) isDirectory(aIsDirectory);
end;

class method Url.UrlWithUnixPath(aPath: not nullable String) isDirectory(aIsDirectory: Boolean := false): Url;
begin
  if aIsDirectory and not aPath.EndsWith("/") then
    aPath := aPath+"/";
  result := new Url("file", nil, aPath);
end;

//
// Parse & Print
//

method Url.Parse(aUrlString: not nullable String): Boolean;
begin
  var lProtocolPosition := aUrlString.IndexOf('://');
  if lProtocolPosition ≥ 0 then begin
    fScheme := aUrlString.Substring(0, lProtocolPosition);
    aUrlString := aUrlString.Substring(lProtocolPosition + 3); /* skip over :// */
  end;

  if (fScheme = "file") and aUrlString.StartsWith("///") then
    aUrlString := aUrlString.Substring(3); // compensate for old fake/wrong Windows network path URLs

  var lHostAndPort: String;
  lProtocolPosition := aUrlString.IndexOf('/');
  if lProtocolPosition = -1 then begin
    lProtocolPosition := aUrlString.IndexOf('?');
  end;
  if lProtocolPosition ≥ 0 then begin
    lHostAndPort := aUrlString.Substring(0, lProtocolPosition);
    aUrlString := aUrlString.Substring(lProtocolPosition);
  end
  else begin
    lHostAndPort := aUrlString;
    aUrlString := '';
  end;

  if lHostAndPort.StartsWith('[') then begin
    lProtocolPosition := lHostAndPort.IndexOf(']');
    if lProtocolPosition > 0 then begin
      fHost := lHostAndPort.Substring(1, lProtocolPosition - 1);
      var lRest: String := lHostAndPort.Substring(lProtocolPosition + 1).Trim();
      if lRest.StartsWith(':') then begin
        var lPort: String := lRest.Substring(1);
        fPort := Convert.TryToInt32(lPort);
        if not assigned(fPort) then
          exit false;
      end;
    end
    else begin
      exit false;
    end;
  end
  else begin
    lProtocolPosition := lHostAndPort.IndexOf(':');
    if lProtocolPosition ≥ 0 then begin
      fHost := lHostAndPort.Substring(0, lProtocolPosition);
      var lPort: String := lHostAndPort.Substring(lProtocolPosition + 1);
      fPort := Convert.TryToInt32(lPort);
      if not assigned(fPort) then
        exit false;
    end
    else begin
      fHost := lHostAndPort;
      fPort := nil;
    end;
  end;
  lProtocolPosition := aUrlString.IndexOf(#63);
  if lProtocolPosition ≥ 0 then begin
    fPath := RemovePercentEncodingsFromPath(aUrlString.Substring(0, lProtocolPosition), true);
    fQueryString := aUrlString.Substring(lProtocolPosition + 1);
  end
  else begin
    if aUrlString.Length = 0 then begin
      aUrlString := '/';
    end;
    fPath := RemovePercentEncodingsFromPath(aUrlString, true);
    fQueryString := nil;
  end;
  result := true;
end;

method Url.ToString: String;
begin
  result := ToAbsoluteString;
end;

method Url.ToAbsoluteString: String;
begin
  if not assigned(fCachedAbsoluteString) then begin
    var lResult := new StringBuilder();
    lResult.Append(fScheme);
    lResult.Append("://");
    if length(fUser) > 0 then
      lResult.Append(fUser+"@");
    lResult.Append(GetHostNameAndPort());
    lResult.Append(GetPathAndQueryString());
    fCachedAbsoluteString := lResult.ToString();
  end;
  result := fCachedAbsoluteString;
end;

method Url.GetHostNameAndPort: nullable String;
begin
  if length(fHost) > 0 then
    result := if fHost.Contains(':') then '['+fHost+']' else fHost;
  if assigned(fPort) then
    result := result+':'+fPort.ToString();
end;

method Url.GetPathAndQueryString: nullable String;
begin
  if length(fPath) > 0 then
    result := AddPercentEncodingsToPath(fPath);
  if length(fQueryString) > 0 then
    result := result+'?'+fQueryString;
  if length(fFragment) > 0 then
    result := result+'#'+fFragment;
end;

//
// Working with Paths
//

method Url.GetFilePath: nullable String;
begin
  if IsFileUrl and assigned(fPath) then begin
    {$IF NOT KNOWN_UNIX}
    if not assigned(fCachedFilePath) then begin
      if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then
        fCachedFilePath := GetWindowsPath()
      else
        fCachedFilePath := fPath;
    end;
    result := fCachedFilePath;
    {$ENDIF}
  end;
end;

method Url.GetWindowsPath: nullable String;
begin
  if IsFileUrl and assigned(fPath) then begin
    result := fPath.Replace('/', '\');
    if length(fHost) > 0 then
      result := "\\"+fHost+result
    else if IsAbsoluteWindowsFileURL then
      result := result.SubString(1);
  end;
end;

method Url.GetUnixPath: nullable String;
begin
  if IsFileUrl then
    result := fPath;
end;

method Url.FilePathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String;
begin
  result := UnixPathRelativeToUrl(aUrl) Threshold(aThreshold);
  {$IF NOT KNOWN_UNIX}
  if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then
    result := result:Replace('/', RemObjects.Elements.RTL.Path.DirectorySeparatorChar);
  {$ENDIF}
end;

method Url.WindowsPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String;
begin
  result := UnixPathRelativeToUrl(aUrl) Threshold(aThreshold);
  result := result:Replace('/', '\');
end;

method Url.UnixPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3): String;
begin
  var SelfIsAbsoluteWindowsUrl := IsAbsoluteWindowsFileURL;
  var BaseIsAbsoluteWindowsUrl := aUrl.IsAbsoluteWindowsFileURL;
  if SelfIsAbsoluteWindowsUrl ≠ BaseIsAbsoluteWindowsUrl then begin
    exit nil; // can never be relative;
  end
  else if SelfIsAbsoluteWindowsUrl and BaseIsAbsoluteWindowsUrl then begin
    var SelfIsDriveletter := IsAbsoluteWindowsDriveLetterFileURL;
    var BaseIsDriveletter := aUrl.IsAbsoluteWindowsDriveLetterFileURL;
    if SelfIsDriveletter ≠ BaseIsDriveletter then begin
      exit nil; // can never be relative;
    end
    else if SelfIsDriveletter and BaseIsDriveletter then begin
      if LowerChar(Path[1]) ≠ LowerChar(aUrl.Path[1]) then exit nil; // different drive, can never be relative;
      result := DoUnixPathRelativeToUrl(aUrl) Threshold(aThreshold) CaseInsensitive(true);
    end
    else begin// both network urls
      result := DoUnixPathRelativeToUrl(aUrl) Threshold(aThreshold) CaseInsensitive(true);
    end;
  end
  else begin
    result := DoUnixPathRelativeToUrl(aUrl) Threshold(aThreshold) CaseInsensitive(false);
  end;
end;

method Url.DoUnixPathRelativeToUrl(aUrl: not nullable Url) Threshold(aThreshold: Integer := 3) CaseInsensitive(aCaseInsensitive: Boolean := false): String;
begin
  if (Scheme = aUrl.Scheme) and (Host:ToLowerInvariant() = aUrl.Host:ToLowerInvariant()) and (Port = aUrl.Port) then begin
    if IsFileUrl and assigned(fPath) then begin

      var baseUrl := aUrl.CanonicalVersion.Path;
      var local := CanonicalVersion.fPath;
      if not baseUrl.EndsWith("/") then
        baseUrl := baseUrl+"/";

      if local.StartsWith(baseUrl) then
        exit local.Substring(length(baseUrl));
      if aThreshold <= 0 then
        exit local;

      var baseComponents := baseUrl.Split("/");
      var localComponents := local.Split("/");
      var len := Math.Min(baseComponents.Count, localComponents.Count);
      var i := 0;
      if aCaseInsensitive then
        while (i < len) and (baseComponents[i].ToLowerInvariant() = localComponents[i].ToLowerInvariant()) do inc(i)
      else
        while (i < len) and (baseComponents[i] = localComponents[i]) do inc(i);

      baseComponents := baseComponents.SubList(i);
      localComponents := localComponents.SubList(i);

      if baseComponents.count-1 >= aThreshold then
        exit local;

      baseUrl := baseComponents.JoinedString("/");
      local := localComponents.JoinedString("/");

      var relative := "";
      for j: Integer := baseComponents.count-1 downto 1 do
        relative := "../"+relative;

      result := RemObjects.Elements.RTL.Path.CombineUnixPath(relative, local);
    end;
  end;
end;

method Url.FilePathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String;
begin
  result := FilePathRelativeToUrl(aUrl) Threshold(if aAlways then Consts.MaxInt32 else 3);
end;

method Url.WindowsPathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String;
begin
  result := WindowsPathRelativeToUrl(aUrl) Threshold(if aAlways then Consts.MaxInt32 else 3);
end;

method Url.UnixPathRelativeToUrl(aUrl: not nullable Url) Always(aAlways: Boolean): String;
begin
  result := UnixPathRelativeToUrl(aUrl) Threshold(if aAlways then Consts.MaxInt32 else 3);
end;

method Url.IsUnderneath(aPotentialBaseUrl: not nullable Url): Boolean;
begin
  if (Scheme = aPotentialBaseUrl.Scheme) and (Host = aPotentialBaseUrl.Host) and (Port = aPotentialBaseUrl.Port) then begin
    var baseUrl := aPotentialBaseUrl.CanonicalVersion.UnixPath;
    var local := CanonicalVersion.UnixPath;
    if not baseUrl.EndsWith("/") then
      baseUrl := baseUrl+"/";
    result := local.StartsWith(baseUrl);
  end;
end;

method Url.GetPathExtension: nullable String;
begin
  var lName := GetLastPathComponent;
  if length(lName) > 0 then begin
    var p := lName.LastIndexOf(".");
    if p > -1 then
      result := lName.Substring(p); // include the "."
  end;
end;

method Url.GetLastPathComponent: nullable String;
begin
  if not assigned(fCachedLastPathComponent) then begin
    var lPath := fPath;
    if lPath.EndsWith("/") then
      lPath := lPath.Substring(0, length(lPath)-1);
    if length(lPath) > 0 then begin
      var p := lPath.LastIndexOf("/");
      if (p > -1) and (p < length(lPath)-1) then
        fCachedLastPathComponent := lPath.Substring(p+1) // exclude the "/"
      else
        fCachedLastPathComponent := lPath;
    end;
  end;
  result := fCachedLastPathComponent;
end;

method Url.GetFilePathWithoutLastComponent: String;
begin
  result := GetUnixPathWithoutLastComponent;
  if assigned(result) then begin
    {$IF NOT KNOWN_UNIX}
    if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then begin
      result := result.Replace('/', RemObjects.Elements.RTL.Path.DirectorySeparatorChar);
      if IsAbsoluteWindowsFileURL then
        result := result.SubString(1);
    end;
    {$ENDIF}
  end;
end;

method Url.GetWindowsPathWithoutLastComponent: String;
begin
  result := GetUnixPathWithoutLastComponent;
  result := result:Replace('/', '\');
  if IsAbsoluteWindowsFileURL then
    result := result.SubString(1);
end;

method Url.GetUnixPathWithoutLastComponent: String;
begin
  if length(fPath) > 0 then begin
    var p := fPath.LastIndexOf("/");
    if (p > 0) then // yes, 0, not -1
      result := fPath.Substring(0, p+1); // include the "/"
  end;
end;

method Url.GetUrlWithoutLastComponent: nullable Url;
begin
  var lPath := GetUnixPathWithoutLastComponent();
  if length(lPath) > 0 then
    result := CopyWithPath(lPath);
end;

method Url.UrlWithChangedPathExtension(aNewExtension: nullable String): nullable Url;
begin
  var lName := GetLastPathComponent;
  if length(lName) > 0 then begin
    var p := lName.LastIndexOf(".");
    if p > -1 then
      lName := lName.Substring(0, p); // exclude the "."
    if length(aNewExtension) > 0 then begin
      if not aNewExtension.StartsWith(".") then
        aNewExtension := "."+aNewExtension; // force a "." into the neww extension
      lName := lName+aNewExtension;
    end;
    result := CopyWithPath(GetUnixPathWithoutLastComponent+lName);
  end;
end;

method Url.UrlWithAddedPathExtension(aNewExtension: not nullable String): nullable Url;
begin
  var lPath := fPath;
  if length(lPath) > 0 then begin
    if lPath.EndsWith("/") then
      lPath := lPath.SubString(0, length(lPath)-1);
    if not aNewExtension.StartsWith(".") then
      aNewExtension := "."+aNewExtension; // force a "." into the neww extension
    lPath := lPath+aNewExtension;
    if fPath.EndsWith("/") then
      lPath := lPath+"/";
    result := CopyWithPath(lPath);
  end;
end;

method Url.UrlWithChangedLastPathComponent(aNewLastPathComponent: not nullable String): nullable Url;
begin
  result := CopyWithPath(GetUnixPathWithoutLastComponent+aNewLastPathComponent);
end;

method Url.UrlWithFragment(aFragment: nullable String): not nullable Url;
begin
  if fFragment = aFragment then
    exit self;
  result := new Url();
  result.fScheme := fScheme;
  result.fHost := fHost;
  result.fPath := fPath;
  result.fQueryString := fQueryString;
  result.fFragment := aFragment;
  result.fUser := fUser;
  result.fPort := fPort;
end;

method Url.UrlWithoutFragment(): not nullable Url;
begin
  if Fragment = nil then
    exit self;
  result := UrlWithFragment(nil);
end;

//
// Modifications
//

method Url.CopyWithPath(aPath: not nullable String): not nullable Url;
begin
  result := new Url();
  result.fScheme := fScheme;
  result.fHost := fHost;
  result.fPath := aPath;
  result.fQueryString := fQueryString;
  result.fFragment := fFragment;
  result.fUser := fUser;
  result.fPort := fPort;
end;

method Url.GetParentUrl(): nullable Url;
begin
  if fPath = '/' then
    exit nil;
  if (length(fPath) = 3) and (fPath[2] = ':') then
    exit nil;
  if (length(fPath) = 4) and (fPath[2] = ':') and (fPath[3] = '/') then
    exit nil;

  var lNewPath := fPath;
  if Path.EndsWith('/') then
    lNewPath := lNewPath.Substring(0, length(lNewPath)-1);
  var p := lNewPath.LastIndexOf('/');
  if p > -1 then begin
    lNewPath := lNewPath.Substring(0,p+1); // include the trailing "/"
    if lNewPath = "///" then // don't strip off a Windows Network Share name
      exit nil;
    {$HINT check and compensate for any more weirdness with windows file paths?}
    exit CopyWithPath(lNewPath);
  end;
  result := CopyWithPath('/')
end;

method Url.SubUrl(params aComponents: array of String): not nullable Url;
begin
  result := SubUrl(aComponents) isDirectory(false);
end;

method Url.SubUrl(params aComponents: array of String) isDirectory(aIsDirectory: Boolean): not nullable Url;
begin
  var lNewPath := fPath;

  for each c in aComponents do begin
    if not lNewPath.EndsWith('/') then
      lNewPath := lNewPath+'/';
    lNewPath := lNewPath+c;
  end;
  if aIsDirectory and not lNewPath.EndsWith('/') then
    lNewPath := lNewPath+'/';

  result := CopyWithPath(lNewPath);
end;

method Url.SubUrlWithFilePath(aSubPath: String): not nullable Url;
begin
  result := SubUrlWithFilePath(aSubPath) isDirectory(false);
  {$HINT handle "wrong" stuff. like, what if aName starts with `/`? do we fail? do we use the absolute path}
end;

method Url.SubUrlWithFilePath(aSubPath: String) isDirectory(aIsDirectory: Boolean): not nullable Url;
begin
  {$IF NOT KNOWN_UNIX}
  if RemObjects.Elements.RTL.Path.DirectorySeparatorChar ≠ '/' then
    aSubPath := aSubPath.Replace(RemObjects.Elements.RTL.Path.DirectorySeparatorChar, '/');
  {$ENDIF}
  result := SubUrl(aSubPath);
end;


method Url.UrlWithRelativeOrAbsoluteFileSubPath(aSubPath: not nullable String): nullable Url;
begin
  if aSubPath.IsAbsolutePath then
    exit Url.UrlWithFilePath(aSubPath);
  result := SubUrlWithFilePath(aSubPath);;
end;

method Url.UrlWithRelativeOrAbsoluteWindowsSubPath(aSubPath: not nullable String): nullable Url;
begin
  if aSubPath.IsAbsolutePath then
    exit Url.UrlWithWindowsPath(aSubPath);
  aSubPath := aSubPath.Replace('\', '/');
  result := SubUrl(aSubPath);;
end;

/*method Url.UrlWithRelativeOrAbsoluteSubPath(aSubPath: not nullable String): nullable Url;
begin
  if aSubPath.IsAbsolutePath then
    exit Url.UrlWithFilePath(aSubPath);
  result := SubUrl(aSubPath);
end;*/

method Url.GetCanonicalVersion(): Url;
begin
  if fIsCanonical then
    exit self;

  if assigned(fCanonicalVersion) then
    exit fCanonicalVersion;

  var lParts := fPath.Split("/").UniqueMutableCopy();
  var i := 0;
  while i < lParts.Count do begin
    case lParts[i] of
      "..": if (i > 0) and (lParts[i-1] ≠ "..") and (lParts[i-1] ≠ "") then begin
              lParts.RemoveRange(i-1, 2);
              dec(i);
              continue;
            end;
      ".": begin
             lParts.RemoveAt(i);
             continue;
           end;
    end;
    inc(i);
  end;

  {$HINT needs to fix case to match disk case, if present? }

  var lNewPath := lParts.JoinedString("/");
  if lNewPath ≠ fPath then begin
    fCanonicalVersion := CopyWithPath(lNewPath);
    result := fCanonicalVersion;
  end
  else begin
    fIsCanonical := true;
    result := self;
  end;
end;

//
// Helper APIs
//

class method Url.AddPercentEncodingsToPath(aString: String): String;
begin
  var lResult := new StringBuilder();
  for i: Int32 := 0 to length(aString)-1 do begin
    var ch := aString[i];
    var c: UInt16 := ord(ch);
    if (c < 46) or (58 < c < 65) or (90 < c < 95) or (c = 96) or (122 < c) then begin
      var lBytes := Convert.ToUtf8Bytes(ch);
      for each b in lBytes do
        lResult.Append("%"+Convert.ToHexString(ord(b), 2));
    end
    else
      lResult.Append(ch);
  end;
  result := lResult.ToString()
end;

class method Url.RemovePercentEncodingsFromPath(aString: String; aAlsoRemovePlusCharacter: Boolean := false): String;
begin
  var lResultBytes := new Byte[length(aString)];
  var i := 0;
  var j := 0;
  while i < length(aString) do begin
    var ch := aString[i];
    if ord(ch) > 256 then
      raise new UrlParserException("Invalid character in Url-Encoded path");
    if ch = '%' then begin
      if (i < length(aString)-1) and (aString[i+1] = '%') then begin
        lResultBytes[j] := Byte(ch);
        inc(i);
      end
      else if (i < length(aString)-2) and (aString[i+1] in ['0'..'9','A'..'F','a'..'f']) and (aString[i+2] in ['0'..'9','A'..'F','a'..'f']) then begin
        var c := Convert.HexStringToInt32(aString[i+1]+aString[i+2]);
        lResultBytes[j] := Byte(c);
        inc(i, 2);
      end;
    end
    else if (ch = '+') and aAlsoRemovePlusCharacter then begin
      lResultBytes[j] := 32; // space
    end
    else begin
      lResultBytes[j] := Byte(ch);
    end;
    inc(i);
    inc(j);
  end;
  try
    result := Convert.Utf8BytesToString(lResultBytes, j);
  except
    result := Encoding.ASCII.GetString(lResultBytes, 0, j);
  end;
end;

class method Url.UrlEncodeString(aString: String): String;
begin
  {$IF COOPER}
  exit java.net.URLEncoder.Encode(aString, 'utf-8');
  {$ELSEIF ECHOES}
    {$IF NETSTANDARD}
    result := System.Net.HttpUtility.UrlEncode(aString);
    {$ELSEIF NETFX_CORE}
    result := System.Net.WebUtility.UrlEncode(aString);
    {$ELSE}
    result := System.Web.HttpUtility.UrlEncode(aString);
    {$ENDIF}
  {$ELSEIF ISLAND}
  {$WARNING Not Implemented}
  {$ELSEIF TOFFEE}
  result := PlatformString(aString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet);
  {$ENDIF}
end;

//
// Casts
//

{$IF COOPER}
operator Url.Implicit(aUrl: java.net.URL): Url;
begin
  if assigned(aUrl) then
    result := Url.UrlWithString(aUrl.toString());
end;

operator Url.Implicit(aUrl: Url): java.net.URL;
begin
  if assigned(aUrl) then
    result := new java.net.URI(aUrl.ToAbsoluteString).toURL;
end;
{$ELSEIF ECHOES}
operator Url.Implicit(aUrl: System.Uri): Url;
begin
  if assigned(aUrl) then
    result := Url.UrlWithString(aUrl.AbsoluteUri);
end;

operator Url.Implicit(aUrl: Url): System.Uri;
begin
  if assigned(aUrl) then
    result := new System.Uri(aUrl.ToAbsoluteString);
end;
{$ELSEIF TOFFEE}
operator Url.Implicit(aUrl: Foundation.NSURL): Url;
begin
  if assigned(aUrl) then
    result := Url.UrlWithString(aUrl.absoluteString);
end;

operator Url.Implicit(aUrl: Url): Foundation.NSURL;
begin
  if assigned(aUrl) then
    result := Foundation.NSURL.URLWithString(aUrl.ToAbsoluteString);
end;
{$ENDIF}

class operator Url.Equal(Value1: Url; Value2: Url): Boolean;
begin
  if not assigned(Value1) then exit not assigned(Value2);
  result := Value1.ToAbsoluteString() = Value2:ToAbsoluteString();
end;

class operator Url.NotEqual(Value1: Url; Value2: Url): Boolean;
begin
  if not assigned(Value1) then exit assigned(Value2);
  result := Value1.ToAbsoluteString() ≠ Value2:ToAbsoluteString();
end;

class operator Url.Equal(Value1: Url; Value2: Object): Boolean;
begin
  if not assigned(Value1) then exit not assigned(Value2);
  result := Value1.ToAbsoluteString() = Url(Value2):ToAbsoluteString();
end;

class operator Url.NotEqual(Value1: Url; Value2: Object): Boolean;
begin
  if not assigned(Value1) then exit assigned(Value2);
  result := Value1.ToAbsoluteString() ≠ Url(Value2):ToAbsoluteString();
end;

class operator Url.Equal(Value1: Object; Value2: Url): Boolean;
begin
  if not assigned(Value1) then exit not assigned(Value2);
  result := Url(Value1):ToAbsoluteString() = Value2.ToAbsoluteString();
end;

class operator Url.NotEqual(Value1: Object; Value2: Url): Boolean;
begin
  if not assigned(Value1) then exit assigned(Value2);
  result := Url(Value1):ToAbsoluteString() ≠ Value2.ToAbsoluteString();
end;

{$IF TOFFEE}
method Url.isEqual(obj: id): Boolean;
begin
  if obj = self then
    exit true;
  if obj is Url then
    exit CanonicalVersion.ToAbsoluteString() = (obj as Url).CanonicalVersion.ToAbsoluteString();
  if obj is NSURL then
    exit CanonicalVersion.ToAbsoluteString() = (obj as NSURL).standardizedURL.absoluteString();
end;

method Url.copyWithZone(aZone: ^NSZone): instancetype;
begin
  result := Url.UrlWithString(self.ToString);
end;

method Url.hash: NSUInteger;
begin
  result := (ToAbsoluteString as PlatformString).hash;
end;
{$ENDIF}

end.