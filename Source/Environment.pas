namespace RemObjects.Elements.RTL;

interface

type
  OperatingSystem = public enum(Unknown, Windows, Linux, macOS, iOS, tvOS, watchOS, Android, WindowsPhone, Xbox, Browser);

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
    method GetUserApplicationSupportFolder: Folder;
    method GetUserLibraryFolder: Folder;
    method GetUserDownloadsFolder: nullable Folder;
    method GetSystemApplicationSupportFolder: Folder;

    {$IF ECHOES}
    [System.Runtime.InteropServices.DllImport("libc")]
    method uname(buf: IntPtr): Integer; external;
    method unameWrapper: String;
    class var unameResult: String;
    [System.Runtime.InteropServices.DllImport("shell32.dll")]
    class method SHGetKnownFolderPath([System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPStruct)] rfid: System.Guid; dwFlags: Cardinal; hToken: IntPtr; var pszPath: IntPtr): Integer; external;
    {$ENDIF}
  public
    property LineBreak: String read GetNewLine;

    property UserName: String read GetUserName;
    property FullUserName: String read GetFullUserName;
    property MachineName: String read GetMachineName;

    property UserHomeFolder: nullable Folder read GetUserHomeFolder;
    property DesktopFolder: nullable Folder read GetDesktopFolder;
    property TempFolder: nullable Folder read GetTempFolder;
    property UserApplicationSupportFolder: nullable Folder read GetUserApplicationSupportFolder; // Mac only
    property UserLibraryFolder: nullable Folder read GetUserLibraryFolder; // Mac only
    property UserDownloadsFolder: nullable Folder read GetUserDownloadsFolder;
    property SystemApplicationSupportFolder: nullable Folder read GetSystemApplicationSupportFolder; // Mac only

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
  {$ELSEIF TOFFEE}
  exit string(Foundation.NSProcessInfo.processInfo:environment:objectForKey(Name));
  {$ELSEIF ECHOES}
  exit System.Environment.GetEnvironmentVariable(Name);
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.GetEnvironmentVariable(Name);
  {$ENDIF}
end;

method Environment.GetNewLine: String;
begin
  {$IF COOPER}
  exit System.getProperty("line.separator");
  {$ELSEIF TOFFEE}
  exit String(#10);
  {$ELSEIF ECHOES}
  exit System.Environment.NewLine;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.NewLine;
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
  {$ELSEIF NETFX_CORE}
  result := Windows.System.UserProfile.UserInformation.GetDisplayNameAsync.Await;
  {$ELSEIF ECHOES}
  result := System.Environment.UserName;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.Environment.UserName;
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
  {$ELSEIF TOFFEE}
    {$IF MACOS}
    result := NSHost.currentHost.localizedName;
    if result.EndsWith(".local") then
      result := result.Substring(0, length(result)-6);
    {$ELSEIF IOS OR TVOS}
    result := UIKit.UIDevice.currentDevice.name;
    {$ELSE}
    result := WatchKit.WKInterfaceDevice.currentDevice.name;
    {$ENDIF}
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
  {$ELSEIF TOFFEE}
  result := NSFileManager.defaultManager.homeDirectoryForCurrentUser.path;
  {$ELSEIF ECHOES}
  exit Folder(System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile));
  {$ELSEIF ISLAND}
    {$IFNDEF WEBASSEMBLY}
    result := RemObjects.Elements.System.Environment.UserHomeFolder.FullName;
    {$ENDIF}
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
  {$ELSEIF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
  {$ELSEIF ECHOES}
  exit Folder(System.Environment.GetFolderPath(System.Environment.SpecialFolder.DesktopDirectory));
  {$ELSEIF ISLAND AND WINDOWS}
  var lAllocator: rtl.IMalloc;
  var lDir: rtl.LPCITEMIDLIST;
  var lTmp := new Char[rtl.MAX_PATH + 1];
  if rtl.SHGetMalloc(@lAllocator) = rtl.NOERROR then begin
    rtl.SHGetSpecialFolderLocation(nil, rtl.CSIDL_DESKTOPDIRECTORY, @lDir);
    rtl.SHGetPathFromIDList(lDir, @lTmp[0]);
    lAllocator.Free(lDir);
    result := new String(lTmp).TrimEnd([Chr(0)]);
  end
  else
    result := '';
  {$ELSEIF ISLAND AND POSIX}
  {$WARNING Not Implemented for Island yet}
  {$ENDIF}
end;

method Environment.GetTempFolder: Folder;
begin
  {$IF COOPER}
  result := System.getProperty('java.io.tmpdir');
  {$ELSEIF TOFFEE}
  var lTemp := NSTemporaryDirectory();
  result := if lTemp = nil then '/tmp' else lTemp;
  {$ELSEIF ECHOES}
  result := System.IO.Path.GetTempPath;
  {$ELSEIF ISLAND}
  {$IFNDEF WEBASSEMBLY}
  result := RemObjects.Elements.System.Environment.TempFolder.FullName;
  {$ENDIF}
  {$ENDIF}
end;

method Environment.GetUserApplicationSupportFolder: Folder;
begin
  {$IF ECHOES}
  case OS of
    OperatingSystem.macOS: result := MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kApplicationSupportFolderType);
    OperatingSystem.Windows: result := System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData);
  end;
  {$ELSEIF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
  {$ENDIF}
  {$IF NOT WEBASSEMBLY}
  if (length(result) > 0) and not Folder.Exists(result) then
    Folder.Create(result);
  {$ENDIF}
end;

method Environment.GetSystemApplicationSupportFolder: Folder;
begin
  {$IF ECHOES}
  case OS of
    OperatingSystem.macOS: result := MacFolders.GetFolder(MacDomains.kLocalDomain, MacFolderTypes.kApplicationSupportFolderType);
    //OperatingSystem.Windows: result := System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData);
  end;
  {$ELSEIF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true).objectAtIndex(0));
  {$ENDIF}
  {$IF NOT WEBASSEMBLY}
  if (length(result) > 0) and not Folder.Exists(result) then
    Folder.Create(result);
  {$ENDIF}
end;

method Environment.GetUserLibraryFolder: Folder;
begin
  {$IF ECHOES}
  if OS = OperatingSystem.macOS then
    result := MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kDomainLibraryFolderType);
  {$ELSEIF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
  {$ENDIF}
  {$IF NOT WEBASSEMBLY}
  if (length(result) > 0) and not Folder.Exists(result) then
    Folder.Create(result);
  {$ENDIF}
end;

method Environment.GetUserDownloadsFolder: nullable Folder;
begin
  {$IF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DownloadsDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
  {$ELSEIF ECHOES}
  case OS of
    OperatingSystem.macOS: begin
        //result := MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kDomainLibraryFolderType);
        result := Path.Combine(GetUserApplicationSupportFolder, "Downloads");
      end;
    OperatingSystem.Windows: begin
        var lFolder: IntPtr;
        if SHGetKnownFolderPath(new System.Guid("374DE290-123F-4565-9164-39C4925E467B"), $00004000, nil, var lFolder) >= 0 then
          result:= System.Runtime.InteropServices.Marshal.PtrToStringUni(lFolder);
      end;
  end;
  {$ELSEIF ISLAND}
    {$IF WINDOWS}
    var lGuidString := RemObjects.Elements.System.String("{374DE290-123F-4565-9164-39C4925E467B}").ToCharArray(true);
    var lGuid: rtl.GUID;
    if rtl.IIDFromString(@lGuidString[0], @lGuid) >= 0 then begin
      var lFolder: rtl.PWSTR;
      if rtl.SHGetKnownFolderPath(@lGuid, rtl.DWORD(rtl.KNOWN_FOLDER_FLAG.KF_FLAG_DONT_VERIFY), nil, @lFolder) >= 0 then
        result := RemObjects.Elements.System.String.FromPChar(lFolder);
    end;
    {$ENDIF}
  {$ENDIF}
  {$IF NOT WEBASSEMBLY}
  if (length(result) > 0) and not Folder.Exists(result) then
    Folder.Create(result);
  {$ENDIF}
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
      {$ERROR Unsupported Cocoa platform}
    {$ENDIF}
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
    {$ELSEIF WEBASSEMBLY}
    exit OperatingSystem.Browser;
    {$ELSEIF DARWIN}
    exit OperatingSystem.macOS; // for now
    {$ELSE}
    exit OperatingSystem.Windows;
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
      {$ERROR Unsupported Cocoa platform}
    {$ENDIF}
  {$ELSEIF NETFX_CORE}
  exit "Microsoft Windows NT 6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Platform.ToString();
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.OSName;
  {$ENDIF}
end;

method Environment.GetOSVersion: String;
begin
  {$IF COOPER}
  exit System.getProperty("os.version");
  {$ELSEIF TOFFEE}
  exit NSProcessInfo.processInfo.operatingSystemVersionString;
  {$ELSEIF NETFX_CORE}
  exit "6.2";
  {$ELSEIF ECHOES}
  exit System.Environment.OSVersion.Version.ToString;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.OSVersion;
  {$ENDIF}
end;

method Environment.GetOSBitness: Int32;
begin
  if GetProcessBitness = 64 then exit 64;
  {$IF COOPER}
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
  {$ELSEIF ECHOES}
  result := if System.Environment.Is64BitOperatingSystem then 64 else 32;
  {$ELSEIF ISLAND}
  result := 0;
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
  {$ELSEIF TOFFEE}
  exit Foundation.NSFileManager.defaultManager().currentDirectoryPath;
  {$ELSEIF ECHOES}
  exit System.Environment.CurrentDirectory;
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.CurrentDirectory;
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