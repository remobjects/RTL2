namespace Elements.RTL;

interface

type
  Locale = public class {$IF ECHOES}mapped to System.Globalization.CultureInfo{$ELSEIF COOPER}mapped to java.util.Locale{$ELSEIF TOFFEE}mapped to Foundation.NSLocale{$ENDIF}
  public
  
    {$IF COOPER}
    class property Invariant: Locale read java.util.Locale.US;
    class property Current: Locale read java.util.Locale.Default;
    {$ELSEIF ECHOES}
    class property Invariant: Locale read System.Globalization.CultureInfo.InvariantCulture;
    class property Current: Locale read System.Globalization.CultureInfo.CurrentCulture;
    {$ELSEIF ISLAND}
    class property Invariant: Locale read nil; {$WARNING Not Implemented}
    class property Current: Locale read nil; {$WARNING Not Implemented}
    {$ELSEIF TOFFEE}
    class property Invariant: Locale read NSLocale.systemLocale;
    class property Current: Locale read NSLocale.currentLocale;
    {$ENDIF}

    {$IF COOPER}
    property Identifier: String read mapped.toString;
    {$ELSEIF ECHOES}
    property Identifier: String read mapped.Name;
    {$ELSEIF TOFFEE}
    property Identifier: String read mapped.localeIdentifier;
    {$ENDIF}
  end;

implementation

end.