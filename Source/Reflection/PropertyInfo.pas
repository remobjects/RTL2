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

  &Property = public class {$IF ECHOES OR (ISLAND AND NOT TOFFEE)} mapped to PlatformProperty {$ENDIF}
  private
  {$IF TOFFEE AND NOT ISLAND}
    fProperty: ^Void;
    fType: &Type;
    method get_Type: &Type;
  {$ENDIF}
  public
  {$IF TOFFEE AND NOT ISLAND}
    constructor withClass(aClass: &Type) &property(aProperty: ^Void);
    method GetValue(aInst: Object; aArgs: array of Object): Object;
    method SetValue(aInst: Object; aArgs: array of Object; aValue: Object);
    property Name: String read NSString.stringWithUTF8String(rtl.property_getName(fProperty));
    property PropertyClass: ^Void read fProperty;
    property &Type: &Type read get_Type;
  {$ENDIF}
  end;

implementation

{$IF TOFFEE AND NOT ISLAND}
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

method &Property.get_Type: &Type;
begin
  if fType = nil then begin
    var lStringType: String := NSString.stringWithUTF8String(property_getAttributes(fProperty));
    lStringType := lStringType.Substring(1);
    var lPos := lStringType.IndexOf(',');
    if lPos ≥ 0 then
      lStringType := lStringType.SubString(0, lPos);
    if (lStringType ≠ '^?') and (lStringType.length > 1) then begin
      var lClass := NSClassFromString(lStringType);
      fType := new &Type withClass(lClass);
    end
    else
      fType := new &Type withSimpleType(lStringType);
  end;
  result := fType;
end;
{$ENDIF}

end.