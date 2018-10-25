namespace RemObjects.Elements.RTL;

{$IF (ECHOES AND NOT NETSTANDARD) OR WINDOWS}

type
  RegistryKey = public {$IF ECHOES}Microsoft.Win32.RegistryKey{$ELSE}String{$ENDIF};

  Registry = public static class
  private
  protected
  public

    property CurrentUser := {$IF ECHOES}Microsoft.Win32.Registry.CurrentUser{$ELSE}"HKEY_CURRENT_USER"{$ENDIF};
    property LocalMachine := {$IF ECHOES}Microsoft.Win32.Registry.LocalMachine{$ELSE}"HKEY_LOCAL_MACHINE"{$ENDIF};
    property ClassesRoot := {$IF ECHOES}Microsoft.Win32.Registry.ClassesRoot{$ELSE}"HKEY_CLASSES_ROOT"{$ENDIF};
    property Users := {$IF ECHOES}Microsoft.Win32.Registry.Users{$ELSE}"HKEY_USERS"{$ENDIF};
    property PerformanceData := {$IF ECHOES}Microsoft.Win32.Registry.PerformanceData{$ELSE}"HKEY_PERFORMANCE_DATA"{$ENDIF};
    property CurrentConfig := {$IF ECHOES}Microsoft.Win32.Registry.CurrentConfig{$ELSE}"HKEY_CURRENT_CONFIG"{$ENDIF};

    method GetSubKeyNames(aRootKey: not nullable RegistryKey; aKeyName: not nullable String): nullable ImmutableList<String>;
    begin
      {$IF ECHOES}
      using lKey := aRootKey.OpenSubKey(aKeyName) do
        result := lKey:GetSubKeyNames().ToList;
      {$ELSEIF ISLAND}
      raise new NotImplementedException("Registry GetValue64 is not implemented for Island.");
      {$ENDIF}
    end;

    method GetValue(aRootKey: not nullable RegistryKey; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable Object;
    begin
      {$IF ECHOES}
      var lKey := aRootKey.OpenSubKey(aKeyName);
      result := coalesce(lKey.GetValue(aValueName), aDefaultValue);
      {$ELSEIF ISLAND}
      result := RemObjects.Elements.System.Registry.GetValue(aRootKey+"\"+aKeyName, aValueName, aDefaultValue);
      {$ENDIF}
    end;

    method GetValue64(aRootKey: not nullable RegistryKey; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable Object;
    begin
      {$IF ECHOES}
      var lKey := Microsoft.Win32.RegistryKey(typeOf(Microsoft.Win32.RegistryKey).GetMethod('OpenBaseKey'):Invoke(nil, [aRootKey, 256]));
      result := coalesce(lKey.GetValue(aValueName), aDefaultValue);
      {$ELSEIF ISLAND}
      raise new NotImplementedException("Registry GetValue64 is not implemented for Island.");
      {$ENDIF}
    end;

    method GetStringValue(aRootKey: not nullable RegistryKey; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable String;
    begin
      result := String(GetValue(aRootKey, aKeyName, aValueName, aDefaultValue));
    end;

    method GetStringValue64(aRootKey: not nullable RegistryKey; aKeyName: not nullable String; aValueName: not nullable String; aDefaultValue: nullable Object := nil): nullable String;
    begin
      result := String(GetValue64(aRootKey, aKeyName, aValueName, aDefaultValue));
    end;

    method SetValue(aRootKey: not nullable RegistryKey; aKeyName: not nullable String; aValueName: not nullable String; aValue: Object);
    begin
      {$IF ECHOES}
      var lKey := aRootKey.OpenSubKey(aKeyName);
      if not assigned(lKey) then
        lKey := aRootKey.CreateSubKey(aKeyName);//, true);
      if assigned(aValue) then
        lKey.SetValue(aValueName, aValue)
      else
        lKey.DeleteValue(aValueName);
      {$ELSEIF ISLAND}
      RemObjects.Elements.System.Registry.SetValue(aRootKey+"\"+aKeyName, aValueName, aValue);
      {$ENDIF}
    end;

  end;

{$ENDIF}

end.