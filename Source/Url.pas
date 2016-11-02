namespace Elements.RTL;

interface

type
  Url = public class// {$IF COOPER}mapped to java.net.URL{$ELSEIF ECHOES}mapped to System.Uri{$ELSEIF TOFFEE}mapped to Foundation.NSURL{$ENDIF}
  private
    var fScheme, fHost, fPath, fQueryString, fFragment, fUser: String;
    var fPort: nullable Int32;

    method Parse(aUrlString: not nullable String);
    method GetHostNameAndPort: nullable String;
    method GetPathAndQueryString: nullable String;
    method CopyWithPath(aPath: not nullable String): not nullable Url;

    method GetFilePath: nullable String;
    method GetWindowsFilePath: nullable String;
    method GetUnixFilePath: nullable String;
    method GetCanonicalVersion(): Url;

    constructor; empty;
    constructor(aScheme: not nullable String; aHost: String; aPath: String);
    constructor(aUrlString: not nullable String);
  public
    
    class method UrlWithString(aUrlString: not nullable String): Url;
    class method UrlWithFilePath(aPath: not nullable String; aIsDirectory: Boolean := false): Url;

    property Scheme: String read fScheme;
    property Host: String read fHost;
    property Port: nullable Integer read fPort;
    property Path: String read fPath;
    property QueryString: String read fQueryString;
    property Fragment: String read fFragment;
    property User: String read fUser;

    property FilePath: String read GetFilePath;
    property WindowsFilePath: String read GetWindowsFilePath;
    property UnixFilePath: String read GetUnixFilePath;

    [ToString]
    method ToString: String; override;
    method ToAbsoluteString: String;

    class method UrlEncodePath(aString: String): String;
    class method UrlDecodePath(aString: String): String;
    class method UrlEncodeString(aString: String): String;

    method GetParentUrl(): Url;
    method GetSubUrl(aName: String): Url;
    
    property CanonicalVersion: Url read GetCanonicalVersion;
    property IsFileUrl: Boolean read Scheme = "file";
    property FileExists: Boolean read IsFileUrl and File.Exists(Path);
    property FolderExists: Boolean read IsFileUrl and Folder.Exists(Path);
    property IsAbsoluteWindowsFileURL: Boolean read IsFileUrl and (Path:Length ≥ 3) and (Path[1] = ':');
    property IsAbsoluteUnixFileURL: Boolean read IsFileUrl and (Path:StartsWith("/"));
    
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
    
  end;
  
implementation

constructor Url(aUrlString: not nullable String);
begin
  Parse(aUrlString);
end;

constructor Url(aScheme: not nullable String; aHost: String; aPath: String);
begin
  fScheme := aScheme;
  fHost := aHost;
  fPath := aPath;
end;

class method Url.UrlWithString(aUrlString: not nullable String): Url;
begin
  result := new Url(aUrlString);
end;

class method Url.UrlWithFilePath(aPath: not nullable String; aIsDirectory: Boolean := false): Url;
begin
  if aPath.IsWindowsPath then begin
    aPath := aPath.Replace("\", "/")
  end;
  
  if aIsDirectory and not aPath.EndsWith("/") then
    aPath := aPath+"/";
  result := new Url("file", nil, UrlEncodePath(aPath));
end;

//
// Parse & Print
//

method Url.Parse(aUrlString: not nullable String);
begin
  var lProtocolPosition := aUrlString.IndexOf('://');
  if lProtocolPosition ≥ 0 then begin
    fScheme := aUrlString.Substring(0, lProtocolPosition);
    aUrlString := aUrlString.Substring(lProtocolPosition + 3); /* skip over :// */
  end;
  
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
          raise new UrlParserException(String.Format("Invalid Port specification '{0}'", lPort));
      end;
    end
    else begin
      raise new UrlParserException(String.Format("Invalid IPv6 host name specification '{0}'", lHostAndPort));
    end;
  end
  else begin
    lProtocolPosition := lHostAndPort.IndexOf(':');
    if lProtocolPosition ≥ 0 then begin
      fHost := lHostAndPort.Substring(0, lProtocolPosition);
      var lPort: String := lHostAndPort.Substring(lProtocolPosition + 1);
      fPort := Convert.TryToInt32(lPort);
      if not assigned(fPort) then
        raise new UrlParserException(String.Format("Invalid Port specification '{0}'", lPort));
    end
    else begin
      fHost := lHostAndPort;
      fPort := nil;
    end;
  end;
  lProtocolPosition := aUrlString.IndexOf(#63);
  if lProtocolPosition ≥ 0 then begin
    fPath := aUrlString.Substring(0, lProtocolPosition);
    fQueryString := aUrlString.Substring(lProtocolPosition + 1);
  end
  else begin
    if aUrlString.Length = 0 then begin
      aUrlString := '/';
    end;
    fPath := aUrlString;
    fQueryString := nil;
  end;
end;

method Url.ToString: String;
begin
  result := ToAbsoluteString;
end;

method Url.ToAbsoluteString: String;
begin
  result := fScheme;
  result := result+"://";
  if length(fUser) > 0 then
    result := result+fUser+"@";
  result := result+GetHostNameAndPort();
  result := result+GetPathAndQueryString();
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
    result := fPath;
  if length(fQueryString) > 0 then
    result := result+'?'+fQueryString;
  if length(fFragment) > 0 then
    result := result+'#'+fFragment;
end;

method Url.GetFilePath: nullable String;
begin
  if IsFileUrl and assigned(fPath) then
    result := UrlDecodePath(fPath).Replace('/', Elements.RTL.Path.DirectorySeparatorChar);
end;

method Url.GetWindowsFilePath: nullable String;
begin
  if IsFileUrl and assigned(fPath) then
    result := UrlDecodePath(fPath).Replace('/', '\');
end;

method Url.GetUnixFilePath: nullable String;
begin
  if IsFileUrl then
    result := fPath;
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
  if (length(fPath) = 2) and (fPath[1] = ':') then
    exit nil;
  if (length(fPath) = 3) and (fPath[1] = ':') and (fPath[2] = '/') then
    exit nil;
    
  var lNewPath := fPath;
  if Path.EndsWith('/') then
    lNewPath := lNewPath.Substring(0, length(lNewPath)-1);
  var p := lNewPath.LastIndexOf('/');
  if p > -1 then begin
    {$HINT check and compensate for for weirdness with windows file paths?}
    exit CopyWithPath(lNewPath.Substring(0,p+1)); // include the trailing "/"
  end;
  result := CopyWithPath('/')
end;

method Url.GetSubUrl(aName: String): Url;
begin
  var lNewPath := fPath;
  if length(lNewPath) = 0 then
    lNewPath := '/';
  if not lNewPath.EndsWith('/') then
    lNewPath := lNewPath+'/';
  result := CopyWithPath(lNewPath+aName);
  {$HINT handle "wrong" stuff. like, what if aName starts with `/`? do we fail? do we use the absolute path}
end;

method Url.GetCanonicalVersion(): Url;
begin
  var lNewPath := fPath;
  {$HINT implement}
  if lNewPath ≠ fPath then
    result := CopyWithPath(lNewPath)
  else
    result := self;
end;

//
// Helper APIs
//

class method Url.UrlEncodePath(aString: String): String;
begin
  var lResult := new StringBuilder();
  for i: Int32 := 0 to length(aString)-1 do begin
    var ch := aString[i];
    var c: UInt16 := ord(ch);
    if (c < 46) or (58 < c < 65) or (90 < c < 95) or (95 < c < 97) or (123 < c) then begin
      var lBytes := Convert.ToUtf8Bytes(ch);
      for each b in lBytes do 
        lResult.Append("%"+Convert.ToHexString(ord(b), 2));
    end
    else
      lResult.Append(ch);
  end;
  result := lResult.ToString()
end;

class method Url.UrlDecodePath(aString: String): String;
begin
  var lResult := new StringBuilder();
  var i := 0;
  while i < length(aString) do begin
    var ch := aString[i];
    if ch = '%' then begin
      if (i < length(aString)-1) and (aString[i+1] = '%') then begin
        lResult.Append(ch);
        inc(i);
      end
      else if (i < length(aString)-2) and (aString[i+1] in ['0'..'9']) and (aString[i+2] in ['0'..'9']) then begin
        var c := Convert.HexStringToInt32(aString[i+1]+aString[i+2]);
        {$HINT handle UTF-8 pairs}
        lResult.Append(chr(c));
        inc(i, 2);
      end;
    end
    else if ch = '+' then begin
      lResult.Append(' ');
    end
    else begin
      lResult.Append(ch);
    end;
    inc(i);
  end;
  result := lResult.ToString()
end;

class method Url.UrlEncodeString(aString: String): String;
begin
  {$IF COOPER}
  exit java.net.URLEncoder.Encode(aString, 'utf-8');
  {$ELSEIF ECHOES}
    {$IF WINDOWS_PHONE}
    result := System.Net.HttpUtility.UrlEncode(aString);
    {$ELSEIF NETFX_CORE}
    result := System.Net.WebUtility.UrlEncode(aString);
    {$ELSE}
    result := System.Web.HttpUtility.UrlEncode(aString);
    {$ENDIF}
  {$ELSEIF ISLAND}
  {$WARNING Not Implemented}
  {$ELSEIF TOFFEE}
  result := NSString(aString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet);
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


end.
