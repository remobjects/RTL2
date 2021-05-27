namespace RemObjects.Elements.RTL;

{$IF ECHOES OR WINDOWS}

type
  RegistryHive = public {$IF ECHOES}Microsoft.Win32.RegistryHive{$ELSE}String{$ENDIF};

  Registry = public static class
  private
  protected
  public

    property CurrentUser: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.CurrentUser{$ELSE}"HKEY_CURRENT_USER"{$ENDIF};
    property LocalMachine: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.LocalMachine{$ELSE}"HKEY_LOCAL_MACHINE"{$ENDIF};
    property ClassesRoot: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.ClassesRoot{$ELSE}"HKEY_CLASSES_ROOT"{$ENDIF};
    property Users: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.Users{$ELSE}"HKEY_USERS"{$ENDIF};
    property PerformanceData: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.PerformanceData{$ELSE}"HKEY_PERFORMANCE_DATA"{$ENDIF};
    property CurrentConfig: RegistryHive read {$IF ECHOES}Microsoft.Win32.RegistryHive.CurrentConfig{$ELSE}"HKEY_CURRENT_CONFIG"{$ENDIF};

    method GetSubKeyNames(aRootKey: not nullable RegistryHive; aKeyName: not nullable String): nullable ImmutableList<String>;
    begin
      {$IF ECHOES}
      using lBaseKey := Microsoft.Win32.RegistryKey.OpenBaseKey(aRootKey, Microsoft.Win32.RegistryView.Default) do
        using lKey := lBaseKey.OpenSubKey(aKeyName) do
          result := lKey:GetSubKeyNames().ToList;
      {$ELSEIF ISLAND}
      result := RemObjects.Elements.System.Registry.GetSubKeyNames(aRootKey+"\"+aKeyName);
      {$ENDIF}
    end;

    method GetValue(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable Object;
    begin
      {$IF ECHOES}
      using lBaseKey := Microsoft.Win32.RegistryKey.OpenBaseKey(aRootKey, Microsoft.Win32.RegistryView.Default) do
        using lKey := lBaseKey.OpenSubKey(aKeyName) do
          result := coalesce(lKey:GetValue(aValueName), aDefaultValue);
      {$ELSEIF ISLAND}
      result := RemObjects.Elements.System.Registry.GetValue(aRootKey+"\"+aKeyName, aValueName, aDefaultValue);
      {$ENDIF}
    end;

    method GetValue32(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable Object;
    begin
      {$IF ECHOES}
      using lBaseKey := Microsoft.Win32.RegistryKey.OpenBaseKey(aRootKey, Microsoft.Win32.RegistryView.Registry32) do
        using lKey := lBaseKey.OpenSubKey(aKeyName) do
          result := coalesce(lKey:GetValue(aValueName), aDefaultValue);
      {$ELSEIF ISLAND}
      result := RemObjects.Elements.System.Registry.GetValue32(aRootKey+'\'+aKeyName, aValueName, aDefaultValue);
      {$ENDIF}
    end;

    method GetValue64(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable Object;
    begin
      {$IF ECHOES}
      using lBaseKey := Microsoft.Win32.RegistryKey.OpenBaseKey(aRootKey, Microsoft.Win32.RegistryView.Registry64) do
        using lKey := lBaseKey.OpenSubKey(aKeyName) do
          result := coalesce(lKey:GetValue(aValueName), aDefaultValue);
      {$ELSEIF ISLAND}
      result := RemObjects.Elements.System.Registry.GetValue64(aRootKey+'\'+aKeyName, aValueName, aDefaultValue);
      {$ENDIF}
    end;

    method GetStringValue(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable String;
    begin
      result := String(GetValue(aRootKey, aKeyName, aValueName, aDefaultValue));
    end;

    method GetStringValue32(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable String;
    begin
      result := String(GetValue32(aRootKey, aKeyName, aValueName, aDefaultValue));
    end;

    method GetStringValue64(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable String;
    begin
      result := String(GetValue64(aRootKey, aKeyName, aValueName, aDefaultValue));
    end;

    method SetValue(aRootKey: not nullable RegistryHive; aKeyName: not nullable String; aValueName: not nullable String; aValue: Object);
    begin
      {$IF ECHOES}
      using lBaseKey := Microsoft.Win32.RegistryKey.OpenBaseKey(aRootKey, Microsoft.Win32.RegistryView.Default) do begin
        var lKey := lBaseKey.OpenSubKey(aKeyName, true);
        if not assigned(lKey) then
          lKey := lBaseKey.CreateSubKey(aKeyName);
        if assigned(aValue) then
          lKey.SetValue(aValueName, aValue)
        else
          lKey.DeleteValue(aValueName);
        lKey:Dispose();
      end;
      {$ELSEIF ISLAND}
      RemObjects.Elements.System.Registry.SetValue(aRootKey+"\"+aKeyName, aValueName, aValue);
      {$ENDIF}
    end;

  end;

{$ENDIF}

end.