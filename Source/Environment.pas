namespace RemObjects.Elements.RTL;

interface

type
  OperatingSystem = public enum(Unknown, Windows, Linux, macOS, iOS, tvOS, watchOS, Android, WindowsPhone, Xbox);

  ApplicationContext = public Object;

  Environment = public static class
  private
    method GetNewLine: String;
    method GetUserName: String;
    method GetFullUserName: String;
    method GetMachineName: String;
    method GetOS: OperatingSystem;
    method GetOSName: String;
    method GetOSVersion: String;
    method GetOSBitness: Int32;
    method GetProcessBitness: Int32;
    method GetEnvironmentVariable(Name: String): String;
    method GetCurrentDirectory: String;

    method GetIsMono: Boolean;

    method GetUserHomeFolder: Folder;
    method GetDesktopFolder: Folder;
    method GetTempFolder: Folder;
    method GetApplicationSupportFolder: Folder;

    {$IF ECHOES}
    [System.Runtime.InteropServices.DllImport("libc")]
    method uname(buf: IntPtr): Integer; external;
    method unameWrapper: String;
    class var unameResult: String;
    {$ENDIF}
  public
    property LineBreak: String read GetNewLine;

    property UserName: String read GetUserName;
    property FullUserName: String read GetFullUserName;
    property MachineName: String read GetMachineName;

    property UserHomeFolder: nullable Folder read GetUserHomeFolder;
    property DesktopFolder: nullable Folder read GetDesktopFolder;
    property TempFolder: nullable Folder read GetTempFolder;
    property UserApplicationSupportFolder: nullable Folder read GetApplicationSupportFolder; // Mac only

    property OS: OperatingSystem read GetOS;
    property OSName: String read GetOSName;
    property OSVersion: String read GetOSVersion;
    property OSBitness: Int32 read GetOSBitness;
    property ProcessBitness: Int32 read GetProcessBitness;

    property ApplicationContext: ApplicationContext read write;

    property IsMono: Boolean read GetIsMono;

    property EnvironmentVariable[Name: String]: String read GetEnvironmentVariable;
    property CurrentDirectory: String read GetCurrentDirectory;
  end;

  macOS nested in Environment = public class
  public
    class property IsHighSierraOrAbove: Boolean read GetIsHighSierraOrAbove;
  private
    class method GetIsHighSierraOrAbove: Boolean;
    begin
      if Environment.OS ≠ OperatingSystem.macOS then exit false;
      {$IF ECHOES}
      var v := Environment.OSVersion.Split(".");
      result := (v.Count > 0) and (Convert.TryToInt32(v[0]) ≥ 17);
      {$ENDIF}
      {$IF TOFFEE AND MACOS}
      result := rint(AppKit.NSAppKitVersionNumber) >  1504;//AppKit.NSAppKitVersionNumber10_12;
      {$ENDIF}
    end;
  end;

implementation

method Environment.GetEnvironmentVariable(Name: String): String;
begin
  {$IF COOPER}
  exit System.getenv(Name);
  {$ELSEIF NETSTANDARD}
  raise new NotSupportedException("GetEnvironmentVariable not supported on this platfrom");
  {$ELSEIF ECHOES}
  exit System.Environment.GetEnvironmentVariable(Name);
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.GetEnvironmentVariable(Name);
  {$ELSEIF TOFFEE}
  exit Foundation.NSProcessInfo.processInfo:environment:objectForKey(Name);
  {$ENDIF}
end;

method Environment.GetNewLine: String;
begin
  {$IF COOPER}
  exit System.getProperty("line.separator");
  {$ELSEIF ECHOES}
  exit System.Environment.NewLine;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.NewLine;
  {$ELSEIF TOFFEE}
  exit String(#10);
  {$ENDIF}
end;

method Environment.GetUserName: String;
begin
  {$IF COOPER AND ANDROID}
  {$HINT need to do this w/o depending on android.jar somehow}
  AppContextMissingException.RaiseIfMissing();

  var Manager := android.accounts.AccountManager.get(ApplicationContext);
  var Accounts := Manager.Accounts;

  if Accounts.length = 0 then
    exit "";

  result := Accounts[0].name;
  {$ELSEIF COOPER}
  result := System.getProperty("user.name");
  {$ELSEIF NETSTANDARD}
  result := Windows.Networking.Proximity.PeerFinder.DisplayName;
  {$ELSEIF NETFX_CORE}
  result := Windows.System.UserProfile.UserInformation.GetDisplayNameAsync.Await;
  {$ELSEIF ECHOES}
  result := System.Environment.UserName;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.Environment.UserName;
  {$ELSEIF TOFFEE}
    {$IF OSX}
    result := Foundation.NSUserName;
    {$ELSEIF IOS}
    exit "iOS User";
    {$ELSEIF WATCHOS}
    exit "Apple Watch User";
    {$ELSEIF TVOS}
    exit "Apple TV User";
    {$ENDIF}
  {$ENDIF}
end;

method Environment.GetFullUserName: String;
begin
  {$HINT Implement for other platforms}
  {$IF TOFFEE}
    {$IF OSX}
    result := Foundation.NSFullUserName;
    {$ELSE}
    result := GetUserName();
    {$ENDIF}
  {$ELSE}
  result := GetUserName();
  {$ENDIF}
end;

method Environment.GetMachineName: String;
begin
  {$IF COOPER}
  try
    result := java.net.InetAddress.getLocalHost().getHostName();
  except
    result := getUserName();
  end;
  {$ELSEIF ECHOES}
  result := System.Environment.MachineName;
  {$ELSEIF ISLAND AND WINDOWS}
  var lSize: rtl.DWORD := rtl.MAX_COMPUTERNAME_LENGTH + 1;
  var lName := new Char[lSize];
  if rtl.GetComputerName(@lName[0], @lSize) then begin
    result := new String(lName, 0, lSize);
  end
  else
    result := GetUserName();
  {$ELSEIF ISLAND AND (ANDROID OR LINUX)}
  var lSize := 255;
  var lName := new AnsiChar[lSize];
  if rtl.gethostname(@lName[0], lSize - 1) = 0 then
    result := RemObjects.Elements.System.String.FromPAnsiChars(@lName[0])
  else
    result := GetUserName();
  {$ELSEIF TOFFEE}
    {$IF OSX}
    result := NSHost.currentHost.localizedName;
    if result.EndsWith(".local") then
      result := result.Substring(0, length(result)-6);
    {$ELSEIF IOS OR TVOS}
    result := UIKit.UIDevice.currentDevice.name;
    {$ELSE}
    result := WatchKit.WKInterfaceDevice.currentDevice.name;
    {$ENDIF}
  {$ENDIF}
end;

method Environment.GetUserHomeFolder: Folder;
begin
  {$IF COOPER}
  {$IF ANDROID}
  AppContextMissingException.RaiseIfMissing;
  exit Environment.ApplicationContext.FilesDir.AbsolutePath;
  {$ELSE}
  exit System.getProperty("user.home");
  {$ENDIF}
  {$ELSEIF ECHOES}
  exit Folder(System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile));
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.Environment.UserHomeFolder.FullName;
  {$ELSEIF TOFFEE}
  result := NSFileManager.defaultManager.homeDirectoryForCurrentUser.path;
  {$ENDIF}
end;

{$IF (ISLAND AND POSIX) OR COOPER}[Warning("Not Implemented for Cooper, Linux and Android")]{$ENDIF}
method Environment.GetDesktopFolder: Folder;
begin
  {$IF COOPER}
  {$IF ANDROID}
  result := nil;
  {$ELSE}
  result := nil;
  {$ENDIF}
  {$ELSEIF ECHOES}
  exit Folder(System.Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory));
  {$ELSEIF ISLAND AND WINDOWS}
  var lAllocator: rtl.IMalloc;
  var lMalloc: ^rtl.IMalloc := @lAllocator;
  var lDir: rtl.LPCITEMIDLIST;
  var lTmp := new Char[rtl.MAX_PATH + 1];
  if rtl.SHGetMalloc(@lMalloc) = rtl.NOERROR then begin
    rtl.SHGetSpecialFolderLocation(nil, rtl.CSIDL_DESKTOPDIRECTORY, @lDir);
    rtl.SHGetPathFromIDList(lDir, @lTmp[0]);
    lMalloc^.lpVtbl^.Free(lMalloc, lDir);
    result := new String(lTmp).TrimEnd([Chr(0)]);
  end
  else
    result := '';
  {$ELSEIF ISLAND AND POSIX
  {$WARNING Not Implemented for Island yet}
  {$ELSEIF TOFFEE}
  result := NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0);
  {$ENDIF}
end;

method Environment.GetTempFolder: Folder;
begin
  {$IF COOPER}
  result := System.getProperty('java.io.tmpdir');
  {$ELSEIF ECHOES}
  result := System.IO.Path.GetTempPath;
  {$ELSEIF ISLAND}
  {$IF WINDOWS}
  var lMax := rtl.MAX_PATH;
  var lBuf := new Char[lMax + 1];
  var lLen := rtl.GetTempPath(lMax, @lBuf[0]);
  result := if lLen <> 0 then new String(lBuf, 0, lLen) else '';
  {$ELSEIF POSIX}
  var lString := 'TMPDIR';
  var lTmp := rtl.getenv(lString.ToAnsiChars);
  var lDir: String := '';
  if lTmp <> nil then
    lDir := RemObjects.Elements.System.String.FromPAnsiChars(lTmp);
  result := if lDir <> '' then lDir else rtl.P_tmpdir;
  {$ENDIF}
  {$ELSEIF TOFFEE}
  var lTemp := NSTemporaryDirectory();
  result := if lTemp = nil then '/tmp' else lTemp;
  {$ENDIF}
end;

method Environment.GetApplicationSupportFolder: Folder;
begin
  {$IF ECHOES}
  if OS = OperatingSystem.macOS then
    result := MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kApplicationSupportFolderType);
  {$ELSEIF TOFFEE}
  result := NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0);
  {$ENDIF}
  if (length(result) > 0) and not Folder.Exists(result) then
    Folder.Create(result);
end;

method Environment.GetOS: OperatingSystem;
begin
  {$IF COOPER}
  {$HINT how to detect android? i don't wanna build RTL separately}
  var lOSName := String(System.getProperty("os.name")):ToLowerInvariant;
  if lOSName.Contains("windows") then exit OperatingSystem.Windows
  else if lOSName.Contains("linux") then exit OperatingSystem.Linux
  else if lOSName.Contains("mac") then exit OperatingSystem.macOS
  else exit OperatingSystem.Unknown;
  {$ELSEIF NETSTANDARD}
  exit OperatingSystem.WindowsPhone;
  {$ELSEIF NETFX_CORE}
  exit OperatingSystem.Windows
  {$ELSEIF ECHOES}
  case System.Environment.OSVersion.Platform of
    PlatformID.WinCE,
    PlatformID.Win32NT,
    PlatformID.Win32S,
    PlatformID.Win32Windows: exit OperatingSystem.Windows;
    PlatformID.Xbox: exit OperatingSystem.Xbox;
    PlatformID.MacOSX: exit OperatingSystem.macOS;
    PlatformID.Unix: case unameWrapper() of
                       "Linux": exit OperatingSystem.Linux;
                       "Darwin": exit OperatingSystem.macOS;
                       else exit OperatingSystem.Unknown;
                     end;
    else exit OperatingSystem.Unknown;
  end;
  {$ELSEIF ISLAND}
    {$IF LINUX}
    exit OperatingSystem.Linux;
    {$ELSEIF ANDROID}
    exit OperatingSystem.Android;
    {$ELSEIF WINDOWS}
    exit OperatingSystem.Windows;
    {$ELSE}
      {$ERROR Unsupported Island platform}
    {$ENDIF}
  {$ELSEIF TOFFEE}
    {$IF OSX}
    exit OperatingSystem.macOS;
    {$ELSEIF IOS}
    exit OperatingSystem.iOS;
    {$ELSEIF WATCHOS}
    exit OperatingSystem.watchOS;
    {$ELSEIF TVOS}
    exit OperatingSystem.tvOS;
    {$ELSE}
      {$ERROR Unsupported Island platform}
    {$ENDIF}
  {$ENDIF}
end;

{$IF ECHOES}
method Environment.unameWrapper: String;
begin
  if not assigned(unameResult) then begin
    var lBuffer := IntPtr.Zero;
    try
      lBuffer := System.Runtime.InteropServices.Marshal.AllocHGlobal(8192);
      if uname(lBuffer) = 0 then
        unameResult := System.Runtime.InteropServices.Marshal.PtrToStringAnsi(lBuffer);
    except
    finally
      if lBuffer ≠ IntPtr.Zero then
        System.Runtime.InteropServices.Marshal.FreeHGlobal(lBuffer);
    end;
  end;
  result := unameResult;
end;
{$ENDIF}

method Environment.GetOSName: String;
begin
  {$IF COOPER}
  exit System.getProperty("os.name");
  {$ELSEIF NETSTANDARD}
  exit System.Environment.OSVersion.Platform.ToString();
  {$ELSEIF NETFX_CORE}
  exit "Microsoft Windows NT 6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Platform.ToString();
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.OSName;
  {$ELSEIF TOFFEE}
    {$IF OSX}
    exit "macOS";
    {$ELSEIF IOS}
    exit "iOS";
    {$ELSEIF WATCHOS}
    exit "watchOS";
    {$ELSEIF TVOS}
    exit "tvOS";
    {$ELSE}
      {$ERROR Unsupported Toffee platform}
    {$ENDIF}
  {$ENDIF}
end;

method Environment.GetOSVersion: String;
begin
  {$IF COOPER}
  System.getProperty("os.version");
  {$ELSEIF NETSTANDARD}
  exit System.Environment.OSVersion.Version.ToString;
  {$ELSEIF NETFX_CORE}
  exit "6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Version.ToString;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.OSVersion;
  {$ELSEIF TOFFEE}
  exit NSProcessInfo.processInfo.operatingSystemVersionString;
  {$ENDIF}
end;

method Environment.GetOSBitness: Int32;
begin
  if GetProcessBitness = 64 then exit 64;
  {$IF COOPER}
  result := 0;
  {$ELSEIF NETSTANDARD}
  result := 0;
  {$ELSEIF ECHOES}
  result := if System.Environment.Is64BitOperatingSystem then 64 else 32;
  {$ELSEIF ISLAND}
  result := 0;
  {$ELSEIF TOFFEE}
    {$IF OSX}
    result := 64;
    {$ELSEIF IOS}
    result := 0;
    {$ELSEIF WATCHOS}
    result := 32;
    {$ELSEIF TVOS}
    result := 64;
    {$ELSE}
      {$ERROR Unsupported Toffee platform}
    {$ENDIF}
  {$ENDIF}
end;

method Environment.GetProcessBitness: Int32;
begin
  {$IF COOPER}
  result := Convert.TryToInt32(System.getProperty("sun.arch.data.model"));
  {$ELSE}
  result := sizeOf(IntPtr)*8;
  {$ENDIF}
end;

method Environment.GetCurrentDirectory(): String;
begin
  {$IF COOPER}
  exit System.getProperty("user.dir");
  {$ELSEIF NETFX_CORE}
  exit Windows.Storage.ApplicationData.Current.LocalFolder.Path;
  {$ELSEIF NETSTANDARD}
  exit System.Environment.CurrentDirectory;
  {$ELSEIF ECHOES}
  exit System.Environment.CurrentDirectory;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.CurrentDirectory;
  {$ELSEIF TOFFEE}
  exit Foundation.NSFileManager.defaultManager().currentDirectoryPath;
  {$ENDIF}
end;

method Environment.GetIsMono: Boolean;
begin
  {$IF ECHOES}
  result := assigned(System.Type.GetType("Mono.Runtime"));
  {$ELSE}
  result := false;
  {$ENDIF}
end;

end.