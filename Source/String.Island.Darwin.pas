namespace RemObjects.Elements.RTL;

{$IF ISLAND AND DARWIN}

uses
  Foundation;

type
  String = public partial class
  private
  public

    //
    // Casts
    //

    class operator Implicit(aValue: nullable String): nullable Foundation.NSString;
    begin
      result := aValue as PlatformString as NSString;
    end;

    class operator Implicit(aValue: nullable Foundation.NSString): nullable String;
    begin
      result := aValue as PlatformString /*as String*/;
    end;

    class operator Implicit(aValue: nullable id): nullable String;
    begin
      result := aValue as NSString as PlatformString /*as String*/;
    end;

    class operator Explicit(aValue: nullable String): nullable NSString;
    begin
      result := aValue;
    end;

    class operator Explicit(aValue: nullable NSString): nullable String;
    begin
      result := aValue;
    end;

    class operator Explicit(aValue: nullable id): nullable String;
    begin
      result := aValue;
    end;

    //
    // Equality
    //

    class operator Equal(aValue1: String; aValue2: NSString): Boolean;
    begin
      result := PlatformString(aValue1) = aValue2;
    end;

    class operator Equal(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 = PlatformString(aValue1);
    end;

    //
    // Inequality
    //

    class operator NotEqual(aValue1: String; aValue2: NSString): Boolean;
    begin
      result := PlatformString(aValue1) ≠ aValue2;
    end;

    class operator NotEqual(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 ≠ PlatformString(aValue1);
    end;

    //
    // Comparisons
    //

    class operator Greater(aValue1: String; aValue2: NSString): Boolean;
    begin
      result := PlatformString(aValue1) > String(aValue2);
    end;

    class operator Greater(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 > PlatformString(aValue1);
    end;

    class operator Less(aValue1: String; aValue2: NSString): Boolean;
    begin
        result := PlatformString(aValue1) < aValue2;
    end;

    class operator Less(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 < PlatformString(aValue1);
    end;

    class operator GreaterOrEqual(aValue1: String; aValue2: NSString): Boolean;
    begin
      result := PlatformString(aValue1) ≥ aValue2;
    end;

    class operator GreaterOrEqual(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 ≥ PlatformString(aValue1);
    end;

    class operator LessOrEqual(aValue1: String; aValue2: NSString): Boolean;
    begin
      result := PlatformString(aValue1) ≤ aValue2;
    end;

    class operator LessOrEqual(aValue1: NSString; aValue2: String): Boolean;
    begin
      result := aValue2 ≤ PlatformString(aValue1);
    end;

  end;

{$ENDIF}

end.