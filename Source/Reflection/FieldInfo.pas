namespace RemObjects.Elements.RTL.Reflection;

interface

uses
  RemObjects.Elements.RTL;

type
  {$IF COOPER}
  PlatformField = public java.lang.reflect.Field;
  {$ELSEIF ECHOES}
  PlatformField = public System.Reflection.FieldInfo;
  {$ELSEIF ISLAND}
  PlatformField = public RemObjects.Elements.System.FieldInfo;
  {$ENDIF}

  Field = public class {$IF COOPER OR ECHOES OR (ISLAND AND NOT TOFFEEV1)} mapped to PlatformField {$ENDIF}
  private
    {$IF TOFFEE AND NOT ISLAND}
    fField: ^Void;
    //fType: &Type;
    fClass: &Type;
    method get_Type: &Type;
    {$ENDIF}
  public
    {$IF TOFFEE AND NOT ISLAND}
    constructor withClass(aClass: &Type) field(aField: ^Void);
    method GetValue(aInstance: Object): Object;
    method SetValue(aInstance: Object; aValue: Object);
    property Name: String read raise new NotImplementedException("Reflection for Fields is not implemented yet for Cocoa");//NSString.stringWithUTF8String(rtl.property_getName(fField));
    property &Type: &Type read get_Type;
    property DeclaringType: &Type read fClass;
    property FieldClass: ^Void read fField;
    {$ELSEIF COOPER}
    property Name: String read mapped.Name;
    property &Type: &Type read mapped.GetType;
    property IsStatic: Boolean read java.lang.reflect.Modifier.isStatic(mapped.Modifiers);
    property Visibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeCooperVisibiliy(mapped.Modifiers);
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringClass);
    method GetValue(aInstance: Object; aArgs: array of Object): Object; mapped to get(aInstance);
    method SetValue(aInstance: Object; aArgs: array of Object; aValue: Object); mapped to &set(aInstance, aValue);
    {$ELSEIF ECHOES}
    property Name: String read mapped.Name;
    property &Type: &Type read mapped.FieldType;
    property IsStatic: Boolean read mapped.IsStatic;
    property IsReadOnly: Boolean read mapped.IsInitOnly; // closest match?
    property Visibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeEchoesVisibiliy(mapped);
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    method GetValue(aInstance: Object): Object; mapped to GetValue(aInstance);
    method SetValue(aInstance: Object; aValue: Object); mapped to SetValue(aInstance, aValue);
    property Attributes: ImmutableList<RemObjects.Elements.RTL.Reflection.Attribute> read sequence of RemObjects.Elements.RTL.Reflection.Attribute(mapped.Attributes).ToList();
    {$ELSEIF ISLAND}
    property Name: String read mapped.Name;
    property &Type: &Type read mapped.Type;
    property IsStatic: Boolean read mapped.IsStatic;
    property IsReadOnly: Boolean read mapped.Flags and FieldFlags.ReadOnly ≠ 0;
    property Visibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeIslandVisibiliy(mapped.Access);
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    method GetValue(aInstance: Object): Object; mapped to GetValue(aInstance);
    method SetValue(aInstance: Object; aValue: Object); mapped to SetValue(aInstance, aValue);
    property Attributes: ImmutableList<RemObjects.Elements.RTL.Reflection.Attribute> read sequence of RemObjects.Elements.RTL.Reflection.Attribute(mapped.Attributes).ToList();
    {$ENDIF}
  end;

implementation

{$IF TOFFEE AND NOT ISLAND}
constructor Field withClass(aClass: &Type) &field(aField: ^Void);
begin
  fClass := aClass;
  fField := aField;
end;

method Field.GetValue(aInstance: Object): Object;
begin
  result := aInstance.valueForKey(Name);
end;

method Field.SetValue(aInstance: Object; aValue: Object);
begin
  aInstance.setValue(aValue) forKey(Name);
end;

method Field.get_Type: &Type;
begin
  raise new NotImplementedException("Reflection for Fields is not implemented yet for Cocoa")
  //if fType = nil then begin
    //var lStringType: String := NSString.stringWithUTF8String(property_getAttributes(fField));
    //lStringType := lStringType.Substring(1);
    //var lPos := lStringType.IndexOf(',');
    //if lPos ≥ 0 then
      //lStringType := lStringType.Substring(0, lPos);
    //if (lStringType ≠ '^?') and (lStringType.length > 1) then begin
      //var lClass := NSClassFromString(lStringType);
      //fType := new &Type withClass(lClass);
    //end
    //else
      //fType := new &Type withSimpleType(lStringType);
  //end;
  //result := fType;
end;
{$ENDIF}

end.