namespace RemObjects.Elements.RTL;

{$IF MACOS OR ECHOES}

{$IF DARWIN}
uses
  Foundation,
  CoreFoundation,
  Security;
{$ENDIF}
{$IF ECHOES}
type
  SecKeychainItemRef = ^Void;
  SecKeychainRef = IntPtr;
  OSStatus = Int32;
{$ENDIF}

{$HIDE CPW8} // CPW8 Unsafe types and operations are not supported on Java

type
  KeychainHelper = public static class
  public

    method LoadPasswordForAccount(aAccountName: String) AppName(aAppName: String): String; unsafe;
    begin
      var account := Encoding.UTF8.GetBytes(aAccountName);
      var appName := Encoding.UTF8.GetBytes(aAppName);
      var len: UInt32 := 0;
      var data: ^Void := nil;
      var s := SecKeychainFindGenericPassword(nil, length(appName), ^AnsiChar(@appName[0]), length(account), ^AnsiChar(@account[0]), @len, @data, nil);
      if s ≠ 0 then begin
        {$IF DARWIN}
        //var error: CFStringRef := SecCopyErrorMessageString(s, nil);
        //NSLog("Error '%@' (%ld) obtaining password for %@ from keychain.", bridge<NSString>(error), Int64(s), aAccountName);
        //CFRelease(error);
        {$ENDIF}
        exit nil;
      end
      else begin
        {$IF ECHOES}
        var dataArray := new Byte[len];
        System.Runtime.InteropServices.Marshal.Copy(IntPtr(data), dataArray, 0, len);
        result := Encoding.UTF8.GetString(dataArray, 0, len);
        {$ELSEIF DARWIN}
        result := new NSString withBytes(data) length(len) encoding(NSStringEncoding.UTF8StringEncoding);
        {$ENDIF}
        SecKeychainItemFreeContent(nil, data);
      end;
    end;

    method SavePassword(aPassword: String) ForAccount(aAccountName: String) AppName(aAppName: String); unsafe;
    begin
      var account := Encoding.UTF8.GetBytes(aAccountName);
      var appName := Encoding.UTF8.GetBytes(aAppName);
      //  Need to check if item exists and, if yes, delete first. Else the save below will fail
      var len: UInt32 := 0;
      var data: ^Void := nil;
      var item: SecKeychainItemRef := nil;
      var s := SecKeychainFindGenericPassword(nil, length(appName), ^AnsiChar(@appName[0]), length(account), ^AnsiChar(@account[0]), @len, @data, @item);
      if (s = 0) then
        if assigned(item) then
          SecKeychainItemDelete(item);
      if assigned(aPassword) then begin
        var pw := Encoding.UTF8.GetBytes(aPassword);
        var s2 := SecKeychainAddGenericPassword(nil, length(appName), ^AnsiChar(@appName[0]), length(account), ^AnsiChar(@account[0]), length(pw), ^AnsiChar(@pw[0]), @item);
        if s2 ≠ 0 then begin
          {$IF DARWIN}
          //var error: CFStringRef := SecCopyErrorMessageString(s, nil);
          //NSLog("Error '%@' (%ld) storing new password for %@ in keychain.", bridge<NSString>(error), Int64(s2), aAccountName);
          //CFRelease(error);
          {$ENDIF}
        end;
      end;
    end;

    method DeletePasswordForAccount(aAccountName: String) AppName(aAppName: String);
    begin
      SavePassword(nil) ForAccount(aAccountName) AppName(aAppName);
    end;

  private

    {$IF ECHOES}
    const SecurityFramework = "/System/Library/Frameworks/Security.framework/Versions/A/Security";

    [System.Runtime.InteropServices.DllImport(SecurityFramework, EntryPoint = "SecKeychainFindGenericPassword")]
    class method SecKeychainFindGenericPassword(keychainOrArray: SecKeychainRef; serviceNameLength: UInt32; serviceName: ^AnsiChar; accountNameLength: UInt32; accountName: ^AnsiChar; passwordLength: ^UInt32; passwordData: ^^Void; itemRef: ^SecKeychainItemRef): OSStatus; external; unsafe;

    [System.Runtime.InteropServices.DllImport(SecurityFramework, EntryPoint = "SecKeychainAddGenericPassword")]
    class method SecKeychainAddGenericPassword(keychain: SecKeychainRef; serviceNameLength: UInt32; serviceName: ^AnsiChar; accountNameLength: UInt32; accountName: ^AnsiChar; passwordLength: UInt32; passwordData: ^Void; itemRef: ^SecKeychainItemRef): OSStatus; external; unsafe;

    [System.Runtime.InteropServices.DllImport(SecurityFramework, EntryPoint = "SecKeychainItemFreeContent")]
    class method SecKeychainItemFreeContent(attrList: IntPtr; data: ^Void): OSStatus; external; unsafe;

    [System.Runtime.InteropServices.DllImport(SecurityFramework, EntryPoint = "SecKeychainItemDelete")]
    class method SecKeychainItemDelete(aItem: SecKeychainItemRef): OSStatus; external;
    {$ENDIF}

  end;

{$ENDIF}

end.