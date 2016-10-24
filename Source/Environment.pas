namespace Elements.RTL;

interface

type
  OperatingSystem = public enum(Unknown, Windows, Linux, macOS, iOS, tvOS, watchOS, Android, WindowsPhone, Xbox);

  ApplicationContext = public Object;

  Environment = public static class
  private
    class method GetNewLine: String;
    class method GetUserName: String;
    class method GetOS: OperatingSystem;
    class method GetOSName: String;
    class method GetOSVersion: String;
    
    {$IF ECHOES}
    [System.Runtime.InteropServices.DllImport("libc")]
    class method uname(buf: IntPtr): Integer; external;
    class method unameWrapper: String;
    class var unameResult: String;
    {$ENDIF}
  public
    property NewLine: String read GetNewLine;
    property UserName: String read GetUserName;
    property OS: OperatingSystem read GetOS;
    property OSName: String read GetOSName;
    property OSVersion: String read GetOSVersion;
    property ApplicationContext: ApplicationContext read write;

    method GetEnvironmentVariable(Name: String): String;
    method CurrentDirectory: String;
  end;

implementation

class method Environment.GetEnvironmentVariable(Name: String): String;
begin
  {$IF COOPER}
  exit System.getenv(Name); 
  {$ELSEIF WINDOWS_PHONE OR NETFX_CORE}
  raise new NotSupportedException("GetEnvironmentVariable not supported on this platfrom");
  {$ELSEIF ECHOES}
  exit System.Environment.GetEnvironmentVariable(Name);
  {$ELSEIF TOFFEE}
  exit Foundation.NSProcessInfo.processInfo:environment:objectForKey(Name);
  {$ENDIF}
end;

class method Environment.GetNewLine: String;
begin
  {$IF COOPER}
  exit System.getProperty("line.separator");
  {$ELSEIF ECHOES}
  exit System.Environment.NewLine;
  {$ELSEIF TOFFEE}
  exit String(#10);
  {$ENDIF}
end;

class method Environment.GetUserName: String;
begin
  {$IF ANDROID}
  {$HINT need to do this w/o depending on android.jar somehow}
  AppContextMissingException.RaiseIfMissing();

  var Manager := android.accounts.AccountManager.get(ApplicationContext);
  var Accounts := Manager.Accounts;

  if Accounts.length = 0 then
    exit "";

  exit Accounts[0].name;
  {$ELSEIF COOPER}
  exit System.getProperty("user.name");
  {$ELSEIF WINDOWS_PHONE}
  exit Windows.Networking.Proximity.PeerFinder.DisplayName;
  {$ELSEIF NETFX_CORE}
  exit Windows.System.UserProfile.UserInformation.GetDisplayNameAsync.Await;
  {$ELSEIF ECHOES}
  exit System.Environment.UserName;
  {$ELSEIF OSX}
  exit Foundation.NSUserName;
  {$ELSEIF IOS}
  exit UIKit.UIDevice.currentDevice.name;
  {$ELSEIF WATCHOS}
  exit "Apple Watch";
  {$ELSEIF tvOS}
  exit "Apple TV";
  {$ENDIF}
end;

class method Environment.GetOS: OperatingSystem;
begin
  {$IF COOPER}
  {$HINT how to detect android? i dont wanan build RTL separately}
  var lOSName := String(System.getProperty("os.name")):ToLowerInvariant;
  if lOSName.Contains("windows") then exit OperatingSystem.Windows
  else if lOSName.Contains("linux") then exit OperatingSystem.Linux
  else if lOSName.Contains("mac") then exit OperatingSystem.macOS
  else exit OperatingSystem.Unknown;
  {$ELSEIF WINDOWS_PHONE}
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
    PlatformID.Unix: case unameWrapper() of
                       "Linux": exit OperatingSystem.Linux;
                       "Darwin": exit OperatingSystem.macOS;
                       else exit OperatingSystem.Unknown;
                     end;
    else exit OperatingSystem.Unknown;
  end;
  {$ELSEIF TOFFEE}
    {$IF OSX}
    exit OperatingSystem.macOS;
    {$ELSEIF IOS}
    exit OperatingSystem.iOS;
    {$ELSEIF WATCHOS}
    exit OperatingSystem.watchOS;
    {$ELSEIF TVOS}
    exit OperatingSystem.tvOS;
    {$ENDIF}
  {$ELSEIF ISLAND}
    {$IF WINDOWS}
    exit OperatingSystem.Windows;
    {$ELSEIF IOS}
    exit OperatingSystem.Linux;
    {$ENDIF}
  {$ENDIF}
end;

{$IF ECHOES}
class method Environment.unameWrapper: String;
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

class method Environment.GetOSName: String;
begin
  {$IF COOPER}
  exit System.getProperty("os.name");
  {$ELSEIF WINDOWS_PHONE}
  exit System.Environment.OSVersion.Platform.ToString();
  {$ELSEIF NETFX_CORE}
  exit "Microsoft Windows NT 6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Platform.ToString();
  {$ELSEIF TOFFEE}
    {$IF OSX}
    exit "macOS";
    {$ELSEIF IOS}
    exit "iOS";
    {$ELSEIF WATCHOS}
    exit "watchOS";
    {$ELSEIF TVOS}
    exit "tvOS";
    {$ENDIF}
  {$ELSEIF ISLAND}
    {$IF WINDOWS}
    exit "Windows";
    {$ELSEIF IOS}
    exit "Linux";
    {$ENDIF}
  {$ENDIF}
end;

class method Environment.GetOSVersion: String;
begin
  {$IF COOPER}  
  System.getProperty("os.version");
  {$ELSEIF WINDOWS_PHONE}
  exit System.Environment.OSVersion.Version.ToString;
  {$ELSEIF NETFX_CORE}
  exit "6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Version.ToString;
  {$ELSEIF TOFFEE}
  exit NSProcessInfo.processInfo.operatingSystemVersionString;
  {$ENDIF}
end;

class method Environment.CurrentDirectory(): String;
begin
  {$IF COOPER}
  exit System.getProperty("user.dir");
  {$ELSEIF NETFX_CORE}
  exit Windows.Storage.ApplicationData.Current.LocalFolder.Path;
  {$ELSEIF WINDOWS_PHONE OR NETFX_CORE}
  exit System.Environment.CurrentDirectory; 
  {$ELSEIF ECHOES}
  exit System.Environment.CurrentDirectory;
  {$ELSEIF TOFFEE}
  exit Foundation.NSFileManager.defaultManager().currentDirectoryPath;
  {$ENDIF}
end;

end.