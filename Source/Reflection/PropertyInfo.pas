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

  &Property = public class {$IF ECHOES OR (ISLAND AND NOT TOFFEEV1)} mapped to PlatformProperty {$ENDIF}
  private
    {$IF TOFFEE AND NOT ISLAND}
    fProperty: ^Void;
    fType: &Type;
    fClass: &Type;
    method get_Type: &Type;
    {$ENDIF}
  public
    {$IF TOFFEE AND NOT ISLAND}
    constructor withClass(aClass: &Type) &property(aProperty: ^Void);
    method GetValue(aInstance: Object; aArgs: array of Object): Object;
    method SetValue(aInstance: Object; aArgs: array of Object; aValue: Object);
    property Name: String read NSString.stringWithUTF8String(rtl.property_getName(fProperty));
    property &Type: &Type read get_Type;
    property DeclaringType: &Type read fClass;
    property PropertyClass: ^Void read fProperty;
    {$ELSEIF ECHOES}
    property Name: String read mapped.Name;
    property &Type: &Type read mapped.PropertyType;
    //property IsStatic: Boolean read mapped.IsStatic;
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    property GetterVisibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeEchoesVisibiliy(mapped.GetGetMethod(true));
    property SetterVisibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeEchoesVisibiliy(mapped.GetSetMethod(true));
    method GetValue(aInstance: Object; aArgs: array of Object): Object; mapped to GetValue(aInstance, aArgs);
    method SetValue(aInstance: Object; aArgs: array of Object; aValue: Object); mapped to SetValue(aInstance, aValue, aArgs);
    property Attributes: ImmutableList<RemObjects.Elements.RTL.Reflection.Attribute> read sequence of RemObjects.Elements.RTL.Reflection.Attribute(mapped.Attributes).ToList();
    {$ELSEIF ISLAND}
    property Name: String read mapped.Name;
    property &Type: &Type read mapped.Type;
    property IsStatic: Boolean read mapped.IsStatic;
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    property GetterVisibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeIslandVisibiliy(mapped.Read:Access);
    property SetterVisibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeIslandVisibiliy(mapped.Write:Access);
    method GetValue(aInstance: Object; aArgs: array of System.Object): Object; mapped to GetValue(aInstance, aArgs);
    method SetValue(aInstance: Object; aArgs: array of System.Object; aValue: Object); mapped to SetValue(aInstance, aArgs, aValue);
    property Attributes: ImmutableList<RemObjects.Elements.RTL.Reflection.Attribute> read sequence of RemObjects.Elements.RTL.Reflection.Attribute(mapped.Attributes).ToList();
    {$ENDIF}
  end;

implementation

{$IF TOFFEE AND NOT ISLAND}
constructor &Property withClass(aClass: &Type) &property(aProperty: ^Void);
begin
  fClass := aClass;
  fProperty := aProperty;
end;

method &Property.GetValue(aInstance: Object; aArgs: array of Object): Object;
begin
  result := aInstance.valueForKey(Name);
end;

method &Property.SetValue(aInstance: Object; aArgs: array of Object; aValue: Object);
begin
  aInstance.setValue(aValue) forKey(Name);
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