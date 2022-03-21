namespace RemObjects.Elements.RTL;

interface

type
  OperatingSystem = public enum (Unknown, Windows, Linux, macOS, iOS, tvOS, watchOS, Android, Fuchsia, Xbox, Browser);

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
    method GetOSArchitecture: String;
    method GetProcessBitness: Int32;
    method GetProcessArchitecture: String;
    method GetMode: String;
    method GetPlatform: String;
    method GetEnvironmentVariable(aName: String): String;
    method SetEnvironmentVariable(aName: String; aValue: String);
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
    var fOS: nullable OperatingSystem;
    var fOSVersion: nullable String;
    var fProcessArchitecture: String;
    var fOSArchitecture: String;
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
    property Mode: String read GetMode;
    property Platform: String read GetPlatform;

    [Obsolete]
    property Architecture: String read GetOSArchitecture;
    property OSArchitecture: String read GetOSArchitecture;
    property ProcessArchitecture: String read GetProcessArchitecture;

    property ApplicationContext: ApplicationContext read write;

    property IsMono: Boolean read GetIsMono;

    property IsRosetta2: nullable Boolean read begin
      {$IF OSX OR UIKITFORMAC}
      var ret: Integer := 0;
      var size: rtl.size_t := sizeOf(ret);
      if rtl.sysctlbyname("sysctl.proc_translated", @ret, @size, nil, 0) = -1 then begin
        if rtl.errno = rtl.ENOENT then
          exit false;
        exit nil;
      end;
      exit ret = 1;
      {$ENDIF}
    end;

    class property IsWow64Process: Boolean read begin
      if defined("WINDOWS") then begin
        var lIsWow64: rtl.BOOL;
        if rtl.IsWow64Process(rtl.GetCurrentProcess(), @lIsWow64) then
          result := lIsWow64;
      end
      else if defined("ECHOES") and (OS = OperatingSystem.Windows) then begin
        if System.Environment.Is64BitOperatingSystem then
          if ((System.Environment.OSVersion.Version.Major = 5) and (System.Environment.OSVersion.Version.Minor ≥ 1)) or (System.Environment.OSVersion.Version.Major ≥ 6) then
            using lProcess := System.Diagnostics.Process.GetCurrentProcess do
              if IsWow64Process(lProcess.Handle, out var lIsWow64) then
                result := lIsWow64;
      end;
    end;

    {$IF ECHOES}
    [System.Runtime.InteropServices.DllImport('kernel32.dll'/*, true*/)]
    class method IsWow64Process(aProcess: IntPtr; out aIsWow64Process: Boolean): Boolean; external; private;

    [System.Runtime.InteropServices.DllImport('kernel32.dll'/*, true*/)]
    class method IsWow64Process2(aProcess: IntPtr; out aProcessMachine: UInt16; out aNativeMachine: UInt16): Boolean; external; private;

    [System.Runtime.InteropServices.DllImport("kernel32")]
    class method GetSystemInfo(var lpSystemInfo: SYSTEM_INFO); external; private;

    class const PROCESSOR_ARCHITECTURE_AMD64: Integer = 9;
    class const PROCESSOR_ARCHITECTURE_INTEL: Integer = 0;
    class const PROCESSOR_ARCHITECTURE_ARM64: Integer = 12;
    {$ENDIF}

    {$IF COOPER}
    property EnvironmentVariable[aName: String]: String read GetEnvironmentVariable;
    {$ELSE}
    property EnvironmentVariable[aName: String]: String read GetEnvironmentVariable write SetEnvironmentVariable;
    {$ENDIF}

    {$IF WEBASSEMBLY}[Warning("Environment.CurrentDirectory is not available on WebAssebly")]{$ENDIF}
    property CurrentDirectory: String read GetCurrentDirectory;
  end;

  {$IF ECHOES}
  macOS nested in Environment = assembly class
  public
    class property IsHighSierraOrAbove: Boolean read GetIsHighSierraOrAbove;
  private
    class method GetIsHighSierraOrAbove: Boolean;
    begin
      if Environment.OS ≠ OperatingSystem.macOS then exit false;
      var v := Environment.OSVersion.Split(".");
      result := (v.Count > 0) and (Convert.TryToInt32(v[0]) ≥ 17);
    end;
  end;

  [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
  SYSTEM_INFO = unit record
  public
    var wProcessorArchitecture: Int16;
    var wReserved: Int16;
    var dwPageSize: Integer;
    var lpMinimumApplicationAddress: IntPtr;
    var lpMaximumApplicationAddress: IntPtr;
    var dwActiveProcessorMask: IntPtr;
    var dwNumberOfProcessors: Integer;
    var dwProcessorType: Integer;
    var dwAllocationGranularity: Integer;
    var wProcessorLevel: Int16;
    var wProcessorRevision: Int16;
  end;
  {$ENDIF}

implementation

method Environment.GetEnvironmentVariable(aName: String): String;
begin
  {$IF COOPER}
  exit System.getenv(aName);
  {$ELSEIF TOFFEE}
  exit String(Foundation.NSProcessInfo.processInfo:environment[aName]);
  {$ELSEIF ECHOES}
  exit System.Environment.GetEnvironmentVariable(aName);
  {$ELSEIF ISLAND}
  exit RemObjects.Elements.System.Environment.GetEnvironmentVariable(aName);
  {$ENDIF}
end;

{$IF COOPER}[Error("This method is not supported for Java")]{$ENDIF}
method Environment.SetEnvironmentVariable(aName: String; aValue: String);
begin
  {$IF COOPER}
  raise new NotImplementedException("Setting ebvironment variables is not supported on Java.")
  {$ELSEIF TOFFEE}
  setenv(NSString(aName).UTF8String, NSString(aValue):UTF8String, 1);
  {$ELSEIF ECHOES}
  System.Environment.SetEnvironmentVariable(aName, aValue);
  {$ELSEIF ISLAND}
  RemObjects.Elements.System.Environment.SetEnvironmentVariable(aName, aValue);
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
    {$IF OSX OR UIKITFORMAC}
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
    {$IF OSX OR UIKITFORMAC}
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
    {$IF MACOS AND NOT MACCATALYST}
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
    result := Folder(new String(lTmp).TrimEnd([Chr(0)]));
  end
  else
    result := Folder('');
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
    OperatingSystem.macOS: result := Folder(MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kApplicationSupportFolderType));
    OperatingSystem.Windows: result := Folder(System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData));
  end;
  {$ELSEIF TOFFEE}
  result := Folder(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
  {$ELSEIF ISLAND AND WINDOWS}
  result := RemObjects.Elements.System.Environment.GetEnvironmentVariable('appdata');
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
    OperatingSystem.macOS: result := Folder(MacFolders.GetFolder(MacDomains.kLocalDomain, MacFolderTypes.kApplicationSupportFolderType));
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
    result := Folder(MacFolders.GetFolder(MacDomains.kUserDomain, MacFolderTypes.kDomainLibraryFolderType));
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
        result := Folder(Path.Combine(String(GetUserApplicationSupportFolder), "Downloads"));
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
  var lOSName := String(System.getProperty("os.name")):ToLowerInvariant;
  if lOSName.Contains("windows") then exit OperatingSystem.Windows
  else if lOSName.Contains("mac") then exit OperatingSystem.macOS
  else if lOSName.Contains("linux") then begin
    var lRuntime := String(System.Property["java.runtime.name"]):ToLowerInvariant;
    if lRuntime.Contains("android") then
      exit OperatingSystem.Android;
    exit OperatingSystem.Linux;
  end
  else exit OperatingSystem.Unknown;
  {$ELSEIF TOFFEE}
    {$IF OSX OR UIKITFORMAC}
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
  if not assigned(fOS) then begin
    fOS := case System.Environment.OSVersion.Platform of
      PlatformID.WinCE,
      PlatformID.Win32NT,
      PlatformID.Win32S,
      PlatformID.Win32Windows: OperatingSystem.Windows;
      PlatformID.Xbox: OperatingSystem.Xbox;
      PlatformID.MacOSX: OperatingSystem.macOS;
      PlatformID.Unix: case unameWrapper() of
                         "Linux": OperatingSystem.Linux;
                         "Darwin": OperatingSystem.macOS;
                         else OperatingSystem.Unknown;
                       end;
      else OperatingSystem.Unknown;
    end;
  end;
  result := fOS;
  {$ELSEIF ISLAND}
    {$IF LINUX}
    exit OperatingSystem.Linux;
    {$ELSEIF ANDROID}
    exit OperatingSystem.Android;
    {$ELSEIF WINDOWS}
    exit OperatingSystem.Windows;
    {$ELSEIF FUCHSIA}
    exit OperatingSystem.Fuchsia;
    {$ELSEIF WEBASSEMBLY}
    exit OperatingSystem.Browser;
    {$ELSEIF DARWIN}
      {$IF OSX OR UIKITFORMAC}
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
    {$IF OSX OR UIKITFORMAC}
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
  {$ELSEIF TOFFEEV1}
  exit $"{CocoaVersion[0]}.{CocoaVersion[1]}.{CocoaVersion[2]}"
  {$ELSEIF NETFX_CORE}
  exit "6.2";
  {$ELSEIF ECHOES}
  case OS of
    OperatingSystem.macOS: begin
        if not assigned(fOSVersion) then begin
          Process.Run("/usr/bin/sw_vers", ["-productVersion"], out fOSVersion);
          fOSVersion := fOSVersion.Trim;
        end;
        exit fOSVersion;
      end;
    else begin
      exit System.Environment.OSVersion.Version.ToString;
    end;
  end;
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
    {$IF OSX OR UIKITFORMAC}
    result := 64;
    {$ELSEIF IOS}
    result := sizeof(IntPtr)*8;
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

method Environment.GetProcessArchitecture: String;
begin
  {$IF COOPER}
  result := "jvm";
  {$ELSEIF DARWIN}
    {$IF OSX OR UIKITFORMAC}
    result := {$IF __arm64__}"arm64"{$ELSE}"x86_64"{$ENDIF};
    {$ELSEIF IOS}
    result := "arm64";
    {$ELSEIF WATCHOS}
    result := {$IF __arm64_32__}"arm64_32"{$ELSE}"armv7k"{$ENDIF};
    {$ELSEIF TVOS}
    result := "arm64";
    {$ELSE}
      {$ERROR Unsupported Toffee platform}
    {$ENDIF}
  {$ELSEIF ECHOES}
  case Environment.OS of
    OperatingSystem.Windows: try
        var si := new SYSTEM_INFO();
        GetSystemInfo(var si);
        case si.wProcessorArchitecture of
          PROCESSOR_ARCHITECTURE_INTEL: result := "i386";
          PROCESSOR_ARCHITECTURE_AMD64: result := "x86_64";
          PROCESSOR_ARCHITECTURE_ARM64: result := "arm64";
        end;
      except
        result := if Environment.ProcessBitness = 64 then "x86_64" else "i386"; {$HINT Does not cover Windows/ARM yet}
      end;
    OperatingSystem.Linux: begin {$HINT WRONG, returns OS Architecture}
        if not assigned(fProcessArchitecture) then begin
          Process.Run("/bin/uname", ["-m"], out fProcessArchitecture);
          fProcessArchitecture := fProcessArchitecture:Trim;
        end;
        result := fProcessArchitecture;
      end;
    OperatingSystem.macOS: begin // uname returns x86_64 when run from an x86_64 process, even omn arm,. so we're good.
        if not assigned(fProcessArchitecture) then begin
          Process.Run("/usr/bin/uname", ["-m"], out fProcessArchitecture);
          fProcessArchitecture := fProcessArchitecture:Trim;
        end;
        result := fProcessArchitecture;
      end;
    OperatingSystem.iOS: result := "arm64";
    OperatingSystem.tvOS: result := "arm64";
    OperatingSystem.watchOS: result := nil;
    OperatingSystem.Android: result := nil;
  end;
  result := result:Trim();
  {$ELSEIF ISLAND}
  case Environment.OS of
    OperatingSystem.Windows: result := {$IF i386}"i386"{$ELSEIF x86_64}"x86_64"{$ELSE}nil{$ENDIF};
    OperatingSystem.Linux: result := {$IF x86_64}"x86_64"{$ELSEIF aarch64}"aarch64"{$ELSEIF armv7}"armv7"{$ELSE}nil{$ENDIF};
    OperatingSystem.Android: result := {$IF arm64_v8a}"arm64-v8a"{$ELSEIF armeabi}"armeabi"{$ELSEIF armeabi_v7a}"armeabi-v7a"{$ELSEIF x86}"x86"{$ELSEIF x86_64}"x86_64"{$ELSE}nil{$ENDIF}
    OperatingSystem.Browser: result := "wasm32";
  end;
  {$ENDIF}
end;

method Environment.GetOSArchitecture: String;
begin
  {$IF COOPER}
  result := System.getenv("PROCESSOR_ARCHITECTURE");
  {$ELSEIF DARWIN}
    {$IF OSX OR UIKITFORMAC}
      {$IF __ARM64__}
      result := "arm64";
      {$ELSE}
      result := if IsRosetta2 then "arm64" else "x86_64";
      {$ENDIF}
    {$ELSEIF IOS}
    result := "arm64"; // technically imprecise for arm running on VERY old deviced
    {$ELSEIF WATCHOS}
    result := {$IF __arm64_32__}"arm64_32"{$ELSE}"armv7k"{$ENDIF}; // tecnically impreccise
    {$ELSEIF TVOS}
    result := "arm64";
    {$ELSE}
      {$ERROR Unsupported Toffee platform}
    {$ENDIF}
  {$ELSEIF ECHOES}
  case Environment.OS of
    OperatingSystem.Windows: try
        IsWow64Process2(System.Diagnostics.Process.GetCurrentProcess().Handle, out var lProcessMachine, out var lNativeMachine);
        case lNativeMachine of
          $aa64: result := "arm64";
          $14c: result := "i386";
          else result := "x86_64";
        end;
      except
        result := if Environment.OSBitness = 64 then "x86_64" else "i386"; {$HINT Does not cover WIndows/ARM yet}
      end;
    OperatingSystem.Linux: begin
        if not assigned(fOSArchitecture) then begin
          Process.Run("/bin/uname", ["-m"], out fOSArchitecture);
          fOSArchitecture := fOSArchitecture:Trim;
        end;
        result := fOSArchitecture;
      end;
    OperatingSystem.macOS: begin
        if not assigned(fOSArchitecture) then begin
          RemObjects.Elements.RTL.Process.Run("/usr/bin/arch", ["-arm64e", "/usr/bin/uname", "-m"], out var lTryArm, out var e1);
          lTryArm := lTryArm.Trim;
          if lTryArm.Trim = "arm64" then
            fOSArchitecture := "arm64"
          else begin
            Process.Run("/usr/bin/uname", ["-m"], out fOSArchitecture);
            fOSArchitecture := fOSArchitecture:Trim;
          end;
        end;
        result := fOSArchitecture;
      end;
    OperatingSystem.iOS: result := "arm64";
    OperatingSystem.tvOS: result := "arm64";
    OperatingSystem.watchOS: result := nil;
    OperatingSystem.Android: result := nil;
  end;
  result := result:Trim();
  {$ELSEIF ISLAND}
  case Environment.OS of
    OperatingSystem.Windows: result := if Environment.ProcessBitness = 64 then "x86_64" else "i386"; {$HINT Does not cover WIndows/ARM yet}
    OperatingSystem.Linux: result := nil;//Process.Run("/bin/uname", ["-m"], out result);
    OperatingSystem.Android: result := nil;
    OperatingSystem.Browser: result := "wasm32";
  end;
  result := result:Trim();
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

method Environment.GetMode: String;
begin
  {$IF COOPER}
  result := "Echoes";
  {$ELSEIF ISLAND}
  result := "Island";
  {$ELSEIF ECHOES}
  result := "Echoes";
  {$ELSEIF TOFFEE}
  result := "Toffee";
  {$ENDIF}
end;

method Environment.GetPlatform: String;
begin
  {$IF COOPER}
  result := "Java";
  {$ELSEIF TOFFEEV2}
  result := "Island/Cocoa";
  {$ELSEIF ISLAND}
  result := "Island";
  {$ELSEIF ECHOES}
  result := ".NET";
  {$ELSEIF TOFFEE}
  result := "Cocoa";
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
  {$IF WEBASSEMBLY}
  raise new NotImplementedException("Environment.CurrentDirectory is not available on WebAssebly")
  {$ELSE}
  exit RemObjects.Elements.System.Environment.CurrentDirectory;
  {$ENDIF}
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