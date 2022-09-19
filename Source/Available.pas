namespace RemObjects.Elements.RTL;

method __ElementsPlatformAndVersionAtLeast(aPlatformName: String; aMaj, aMin: Integer; aRev: Integer := 0): Boolean; public;
begin
  case caseInsensitive(aPlatformName) of
    "tvos": begin
        if defined("TARGET_OS_TV") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        // We only support tvOS on native
      end;
    "watchos": begin
        if defined("TARGET_OS_WATCH") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        // We only support watchOS on native
      end;
    "ios", "iphoneos", "ipados": begin
        if defined("TARGET_OS_UIKITFORMAC") then
          exit __ElementsUIKitForMacVersionAtLeast(aMaj, aMin, aRev);
        if defined("TARGET_OS_IPHONE") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        // We only support iOS on native
      end;
    "macos", "mac os x", "os x", "mac os": begin
        if defined("TARGET_OS_MAC") or defined("TARGET_OS_UIKITFORMAC") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        if (defined("ECHOES") or defined("COOPER")) and (Environment.OS = OperatingSystem.macOS) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
    "uikitformac", "uikit for mac", "catalyst", "maccatalyst", "mac catalyst": begin
        if defined("TARGET_OS_UIKITFORMAC") then
          exit __ElementsUIKitForMacVersionAtLeast(aMaj, aMin, aRev);
        // We only support Catalyst on native
      end;

    "windows": begin
        if defined("WINDOWS") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        if (defined("ECHOES") or defined("COOPER")) and (Environment.OS = OperatingSystem.Windows) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
    "linux": begin
        if defined("LINUX") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        if (defined("ECHOES") or defined("COOPER")) and (Environment.OS = OperatingSystem.Linux) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
    "fuchsia": begin
        if defined("FUCHSIA") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        if (defined("ECHOES") or defined("COOPER")) and (Environment.OS = OperatingSystem.Windows) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;

    "android": begin
        if defined("ANDROID") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
        if defined("COOPER") and (Environment.OS = OperatingSystem.Android) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
    "androidndk", "android ndk": begin
        if defined("DARWIN") and defined("ANDROID") then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
    "androidsdk", "android sdk": begin
        if defined("COOPER") and (Environment.OS = OperatingSystem.Android) then
          exit __ElementsPlatformVersionAtLeast(aMaj, aMin, aRev);
      end;
  end;
end;

method __ElementsPlatformVersionString: String; public;
begin
  __ElementsLoadPlatformVersion;
  result := $"{__ElementsPlatformVersion[1]}.{__ElementsPlatformVersion[2]},{__ElementsPlatformVersion[3]}";
end;


var __ElementsPlatformVersion: array[0..3] of Integer;
{$IFDEF TARGET_OS_UIKITFORMAC}
var __ElementsUIKitForMacVersion: array[0..3] of Integer;
{$ENDIF}

method __ElementsLoadPlatformVersion;
begin
  if __ElementsPlatformVersion[0] = 1 then
    exit;

  __ElementsPlatformVersion[0] := 1;
  {$IF DARWIN}
    {$HIDE CPW6}
    if NSProcessInfo.processInfo.respondsToSelector(selector(operatingSystemVersion)) then begin
      // operatingSystemVersion is new in macOS 10.10 and iOS 8, but we don"t support older versions in Island.
      var version := Foundation.NSProcessInfo.processInfo.operatingSystemVersion;
      __ElementsPlatformVersion[1] := version.majorVersion;
      __ElementsPlatformVersion[2] := version.minorVersion;
      __ElementsPlatformVersion[3] := version.patchVersion;

      // hack for macOS 11.0 reporting 10.16. Hopefully we can revert before RTM
      if defined("TARGET_OS_MAC") or defined("TARGET_OS_UIKITFORMAC") then begin
        if (__ElementsPlatformVersion[1] = 10) and (__ElementsPlatformVersion[2] = 16) then begin
          __ElementsPlatformVersion[1] := 11;
          __ElementsPlatformVersion[2] := 0;
        end;
      end;

      if defined("TARGET_OS_UIKITFORMAC") and __ElementsPlatformVersionAtLeast(10, 15) then begin
        if __ElementsPlatformVersion[1] = 10 then begin
          if (__ElementsPlatformVersion[2] in [15, 16]) then begin // Special handling for 10.15 and (temp) 10.16
            __ElementsUIKitForMacVersion[1] := __ElementsPlatformVersion[2]-2; // 15 -> 13, 16 -> 14
            __ElementsUIKitForMacVersion[2] := __ElementsPlatformVersion[3];
            __ElementsUIKitForMacVersion[3] := 0;
          end;
        end
        else begin // macOS 11.0 and above
          __ElementsUIKitForMacVersion[1] := __ElementsPlatformVersion[1]+3; // 11 -> 14
          __ElementsUIKitForMacVersion[2] := case __ElementsPlatformVersion[1] of
            11: __ElementsPlatformVersion[2]+2; // 11.0 -> 14.2, 11.1 -> 14.3
            12: if __ElementsPlatformVersion[2] < 2 then 0 else if __ElementsPlatformVersion[2] < 2 then __ElementsPlatformVersion[2]-1 else __ElementsPlatformVersion[2]-2;
            13: if __ElementsPlatformVersion[2] < 2 then 0 else __ElementsPlatformVersion[2]-1; // 13.0/13.1 -> 16.0, 13.2 -> 16.1?
            else __ElementsPlatformVersion[2]; // (guesswork, until we know where macOS 14 goes
          end;
          __ElementsUIKitForMacVersion[3] := 0;
        end;
      end;
    end
    else begin
      //
      // fallback, operatingSystemVersion is new in macOS 10.10, iOS 8,
      //
      {$IFDEF TARGET_OS_IPHONE}
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_8_0 then __ElementsPlatformVersion := [1, 8, 0, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_7_1 then __ElementsPlatformVersion := [1, 7, 1, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_7_0 then __ElementsPlatformVersion := [1, 7, 0, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_6_1 then __ElementsPlatformVersion := [1, 6, 1, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_6_0 then __ElementsPlatformVersion := [1, 6, 0, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_5_1 then __ElementsPlatformVersion := [1, 5, 1, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_5_0 then __ElementsPlatformVersion := [1, 5, 0, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_3 then __ElementsPlatformVersion := [1, 4, 3, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_2 then __ElementsPlatformVersion := [1, 4, 2, 0] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber_iOS_4_1 then __ElementsPlatformVersion := [1, 4, 1, 0] else
      __ElementsPlatformVersion := [1, 4, 0, 0];
      {$ELSEIF TARGET_OS_MAC and not TARGET_OS_IPHONE}
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_10_1 then __ElementsPlatformVersion := [1, 10, 10, 1] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_9_2 then __ElementsPlatformVersion := [1, 10, 9, 2] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_9_1 then __ElementsPlatformVersion := [1, 10, 9, 1] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_4 then __ElementsPlatformVersion := [1, 10, 8, 4] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_3 then __ElementsPlatformVersion := [1, 10, 8, 3] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_2 then __ElementsPlatformVersion := [1, 10, 8, 2] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_8_1 then __ElementsPlatformVersion := [1, 10, 8, 1] else

      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_4 then __ElementsPlatformVersion := [1, 10, 7, 4] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_3 then __ElementsPlatformVersion := [1, 10, 7, 3] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_2 then __ElementsPlatformVersion := [1, 10, 7, 2] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_7_1 then __ElementsPlatformVersion := [1, 10, 7, 1] else

      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_8 then __ElementsPlatformVersion := [1, 10, 6, 8] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_6 then __ElementsPlatformVersion := [1, 10, 6, 6] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_5 then __ElementsPlatformVersion := [1, 10, 6, 5] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_4 then __ElementsPlatformVersion := [1, 10, 6, 4] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_3 then __ElementsPlatformVersion := [1, 10, 6, 3] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_2 then __ElementsPlatformVersion := [1, 10, 6, 2] else
      if NSFoundationVersionNumber >=  NSFoundationVersionNumber10_6_1 then __ElementsPlatformVersion := [1, 10, 6, 1] else
      __ElementsPlatformVersion := [1, 10, 5, 0];
      {$ELSE}
      // fuck it ;)
      {$ENDIF}
    end;

  {$ELSE}

    var lVersion: ImmutableList<String>;
    {$IF ISLAND}
    lVersion := String(RemObjects.Elements.System.Environment.OSVersion).Split(".");
    {$ELSEIF ECHOES}
    if Environment.OS = OperatingSystem.macOS then begin
      Process.Run("/usr/bin/sw_vers", ["-productVersion"], out var fOSVersion);
      lVersion := fOSVersion:Trim.Split("."); // on macOS, System.Environment.OSVersion returns the Darwin kernel version :(.
    end
    else begin
      lVersion := String(System.Environment.OSVersion.Version.ToString).Split(".");
    end;
    {$ELSEIF COOPER}
    lVersion := Environment.JavaSystemProperty["os.name"]:Split(".");
    {$ELSE}
    {$ERROR Not Implemented}
    {$ENDIF}

    if length(lVersion) ≥ 1 then
      __ElementsPlatformVersion[1] := Convert.TryToInt32(lVersion[0]);
    if length(lVersion) ≥ 2 then
      __ElementsPlatformVersion[2] := Convert.TryToInt32(lVersion[1]);
    if length(lVersion) ≥ 3 then
      __ElementsPlatformVersion[3] := Convert.TryToInt32(lVersion[02]);

  {$ENDIF}
end;

method __ElementsPlatformVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  __ElementsLoadPlatformVersion;
  if (aMaj > __ElementsPlatformVersion[1]) then exit false;
  if (aMaj = __ElementsPlatformVersion[1]) then begin
    if (aMin > __ElementsPlatformVersion[2]) then exit false;
    if (aMin = __ElementsPlatformVersion[2]) then begin
      if (aRev > __ElementsPlatformVersion[3]) then exit false;
    end;
  end;
  exit true;
end;

{$IF DARWIN AND TARGET_OS_UIKITFORMAC}
method __ElementsUIKitForMacVersionAtLeast(aMaj, aMin: Integer; aRev: Integer := 0): Boolean;
begin
  __ElementsLoadPlatformVersion;
  if (aMaj > __ElementsUIKitForMacVersion[1]) then exit false;
  if (aMaj = __ElementsUIKitForMacVersion[1]) then begin
    if (aMin > __ElementsUIKitForMacVersion[2]) then exit false;
    if (aMin = __ElementsUIKitForMacVersion[2]) then begin
      if (aRev > __ElementsUIKitForMacVersion[3]) then exit false;
    end;
  end;
  exit true;
end;
{$ENDIF}

end.