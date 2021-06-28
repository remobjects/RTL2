namespace RemObjects.Elements.RTL;

{$IF ISLAND AND DARWIN}

uses
  Foundation;

type
  {$IF TOFFEE}
  {$IFDEF ISLAND}
  OtherString = unit RemObjects.Elements.System.String;
  {$ELSE}
  OtherString = unit PlatformString;
  {$ENDIF}
  {$ELSE}
  OtherString = unit Foundation.NSString;
  {$ENDIF}

type
  String = public partial class
  private
  public

    //
    // Casts
    //

    class operator Implicit(aValue: nullable String): nullable OtherString;
    begin
      result := aValue as PlatformString as OtherString;
    end;

    class operator Implicit(aValue: nullable OtherString): nullable String;
    begin
      result := aValue as PlatformString /*as String*/;
    end;

    class operator Implicit(aValue: nullable id): nullable String;
    begin
      result := aValue as OtherString as PlatformString /*as String*/;
    end;

    {$IF ISLAND AND NOT TOFFEEV2}
    class operator Implicit(aValue: nullable String): nullable id;
    begin
      result := aValue as PlatformString as NSString;
    end;
    {$ENDIF}

    //
    // Equality
    //

    class operator Equal(aValue1: String; aValue2: OtherString): Boolean;
    begin
      result := PlatformString(aValue1) = aValue2;
    end;

    class operator Equal(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 = PlatformString(aValue2);
    end;

    //
    // Inequality
    //

    class operator NotEqual(aValue1: String; aValue2: OtherString): Boolean;
    begin
      result := PlatformString(aValue1) ≠ aValue2;
    end;

    class operator NotEqual(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 ≠ PlatformString(aValue2);
    end;

    //
    // Comparisons
    //

    class operator Greater(aValue1: String; aValue2: OtherString): Boolean;
    begin
      result := PlatformString(aValue1) > (aValue2);
    end;

    class operator Greater(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 > PlatformString(aValue2);
    end;

    class operator Less(aValue1: String; aValue2: OtherString): Boolean;
    begin
        result := PlatformString(aValue1) < aValue2;
    end;

    class operator Less(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 < PlatformString(aValue2);
    end;

    class operator GreaterOrEqual(aValue1: String; aValue2: OtherString): Boolean;
    begin
      result := PlatformString(aValue1) ≥ aValue2;
    end;

    class operator GreaterOrEqual(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 ≥ PlatformString(aValue2);
    end;

    class operator LessOrEqual(aValue1: String; aValue2: OtherString): Boolean;
    begin
      result := PlatformString(aValue1) ≤ aValue2;
    end;

    class operator LessOrEqual(aValue1: OtherString; aValue2: String): Boolean;
    begin
      result := aValue1 ≤ PlatformString(aValue2);
    end;

  end;

{$ENDIF}

end.