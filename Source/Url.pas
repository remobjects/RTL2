namespace Elements.RTL;

interface

type
  Url = public class mapped to {$IF COOPER}java.net.URL{$ELSEIF ECHOES}System.Uri{$ELSEIF TOFFEE}Foundation.NSURL{$ENDIF}

  private
    {$IF ECHOES}
    method GetPort: Integer;
    method GetFragment: String;
    method GetUserInfo: String;
    method GetQueryString: String;
    {$ENDIF}
    {$IF TOFFEE}
    method GetUserInfo: String;
    method GetPort: Integer;
    {$ENDIF}
    
  public
    constructor(UriString: String);
    
    class method UrlWithFilePath(aPath: String; aIsDirectory: Boolean := false): Url;
    begin
      {$IF TOFFEE}
      exit NSURL.fileURLWithPath(aPath) isDirectory(aIsDirectory);
      {$ENDIF}
    end;

    property Scheme: String read {$IF COOPER}mapped.Protocol{$ELSEIF ECHOES}mapped.Scheme;{$ELSEIF TOFFEE}mapped.scheme{$ENDIF};
    property Host: String read mapped.Host;
    property Port: Int32 read {$IF COOPER}mapped.Port{$ELSEIF ECHOES}GetPort(){$ELSEIF TOFFEE}GetPort(){$ENDIF};
    property Path: String read {$IF COOPER}mapped.Path{$ELSEIF ECHOES}mapped.AbsolutePath{$ELSEIF TOFFEE}mapped.path{$ENDIF};
    property QueryString: String read {$IF COOPER}mapped.Query{$ELSEIF ECHOES}GetQueryString(){$ELSEIF TOFFEE}mapped.query{$ENDIF};
    property Fragment: String read {$IF COOPER}mapped.toURI.Fragment{$ELSEIF ECHOES}GetFragment(){$ELSEIF TOFFEE}mapped.fragment{$ENDIF};
    property UserInfo: String read {$IF COOPER}mapped.UserInfo{$ELSE}GetUserInfo{$ENDIF};

    {$IF NOUGAT}
    /*[ToString] // ASPE ToString method cannot have any parameters
                 // E178 Cannot find a suitable method in the base class to override with signature "class method ToString(&self: Url): NSString"
    method ToString: NSString; override;
    begin
      exit mapped.absoluteString;
    end;*/
    {$ENDIF}

    class method UrlEncodeString(aString: String): String;

    method GetParentUrl(): Url;
    method GetSubUrl(aName: String): Url;
    
    property IsFileUrl: Boolean read Scheme = "file";
    property FileExists: Boolean read IsFileUrl and File.Exists(Path);
    property FolderExists: Boolean read IsFileUrl and Folder.Exists(Path);
    property IsAbsoluteWindowsFileURL: Boolean read IsFileUrl and (Path:Length ≥ 3) and (Path[2] = ':');
    property IsAbsoluteUnixFileURL: Boolean read IsFileUrl and (Path:StartsWith("/"));
    
    method CrossPlatformPath: String;
    begin
      result := Path;
      if (IsAbsoluteWindowsFileURL) then
        result := result.Substring(1).windowsPathFromUnixPath;
    end;
    
  end;
    
implementation

{$IF TOFFEE}
method Url.GetUserInfo: String;
begin
  if mapped.user = nil then
    exit nil;

  if mapped.password <> nil then
    exit mapped.user + ":" + mapped.password
  else
    exit mapped.user;
end;

method Url.GetPort: Integer;
begin
  exit if mapped.port = nil then -1 else mapped.port.intValue;
end;
{$ENDIF}

{$IF ECHOES}
method Url.GetPort: Integer;
begin
  if mapped.IsDefaultPort then
    exit -1;

  exit mapped.Port;
end;

method Url.GetFragment: String;
begin
  if mapped.Fragment.Length = 0 then
    exit nil;

  if mapped.Fragment.StartsWith("#") then
    exit mapped.Fragment.Substring(1);

  exit mapped.Fragment;
end;

method Url.GetQueryString: String;
begin
  if mapped.Query.Length = 0 then
    exit nil;

  if mapped.Query.StartsWith("?") then
    exit mapped.Query.Substring(1);

  exit mapped.Query;
end;

method Url.GetUserInfo: String;
begin
  if mapped.UserInfo.Length = 0 then
    exit nil;

  exit mapped.UserInfo;
end;
{$ENDIF}

constructor Url(UriString: String);
begin
  if String.IsNullOrEmpty(UriString) then
    raise new ArgumentNullException("UriString");

  {$IF COOPER}
  exit new java.net.URI(UriString).toURL; //URI performs validation
  {$ELSEIF ECHOES}
  exit new System.Uri(UriString);
  {$ELSEIF TOFFEE}
  var Value := Foundation.NSURL.URLWithString(UriString);
  if Value = nil then
    raise new ArgumentException("Url was not in correct format");

  var Req := Foundation.NSURLRequest.requestWithURL(Value);
  if not Foundation.NSURLConnection.canHandleRequest(Req) then
    raise new ArgumentException("Url was not in correct format");

  exit Value as not nullable;
  {$ENDIF}
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
  {$ELSEIF TOFFEE}
  result := NSString(aString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet);
  {$ENDIF}
end;

method Url.GetParentUrl(): nullable Url;
begin
  if Path = '/' then
    result := nil
  {$IF COOPER}
  else if Path.EndsWith('/') then
    result := mapped.toURI.resolve('..').toURL
  else
    result := mapped.toURI.resolve('.').toURL;
  {$ELSEIF ECHOES}
  else if Path.EndsWith('/') then
    result := new Uri(mapped, '..')
  else
    result := new Uri(mapped, '.');
  {$ELSEIF TOFFEE}
  else
    result := mapped.URLByDeletingLastPathComponent;
  {$ENDIF}
end;

method Url.GetSubUrl(aName: String): Url;
begin
  {$IF COOPER}
  result := mapped.toURI.resolve(aName).toURL
  {$ELSEIF ECHOES}
  result := new Uri(mapped, aName);
  {$ELSEIF TOFFEE}
  result := mapped.URLByAppendingPathComponent(aName);
  {$ENDIF}
end;

end.
