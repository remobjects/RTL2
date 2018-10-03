namespace RemObjects.Elements.RTL.Reflection;

interface

uses
  RemObjects.Elements.RTL;

type
  {$IF ECHOES}
  PlatformProperty = public System.Reflection.PropertyInfo;
  {$ELSEIF ISLAND}
  PlatformProperty = public RemObjects.Elements.System.PropertyInfo;
  {$ENDIF}

  &Property = public class
  {$IF ECHOES OR ISLAND}
    mapped to PlatformProperty
  {$ENDIF}
  private
  {$IF TOFFEE}
    fProperty: ^Void;
  {$ENDIF}
  public
  {$IF TOFFEE}
    constructor withClass(aClass: &Type) &property(aProperty: ^Void);
    method GetValue(aInst: Object; aArgs: array of Object): Object;
    method SetValue(aInst: Object; aArgs: array of Object; aValue: Object);
    property Name: String read NSString.stringWithUTF8String(rtl.property_getName(fProperty));
  {$ENDIF}
  end;

implementation

{$IF TOFFEE}
constructor &Property withClass(aClass: &Type) &property(aProperty: ^Void);
begin
  fProperty := aProperty;
end;

method &Property.GetValue(aInst: Object; aArgs: array of Object): Object;
begin
  result := aInst.valueForKey(Name);
end;

method &Property.SetValue(aInst: Object; aArgs: array of Object; aValue: Object);
begin
  aInst.setValue(aValue) forKey(Name);
end;
{$ENDIF}

end.