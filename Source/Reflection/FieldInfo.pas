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

  Field = public class {$IF COOPER OR ECHOES OR (ISLAND AND NOT TOFFEE)} mapped to PlatformField {$ENDIF}
  private
  {$IF TOFFEE AND NOT ISLAND}
    fField: ^Void;
    fType: &Type;
    method get_Type: &Type;
  {$ENDIF}
  public
  {$IF TOFFEE AND NOT ISLAND}
    constructor withClass(aClass: &Type) field(aField: ^Void);
    method GetValue(aInst: Object; aArgs: array of Object): Object;
    method SetValue(aInst: Object; aArgs: array of Object; aValue: Object);
    property Name: String read NSString.stringWithUTF8String(rtl.property_getName(fField));
    property PropertyClass: ^Void read fField;
    property &Type: &Type read get_Type;
  {$ENDIF}
  end;

implementation

{$IF TOFFEE AND NOT ISLAND}
constructor Field withClass(aClass: &Type) &field(aField: ^Void);
begin
  fField := aField;
end;

method Field.GetValue(aInst: Object; aArgs: array of Object): Object;
begin
  result := aInst.valueForKey(Name);
end;

method Field.SetValue(aInst: Object; aArgs: array of Object; aValue: Object);
begin
  aInst.setValue(aValue) forKey(Name);
end;

method Field.get_Type: &Type;
begin
  if fType = nil then begin
    var lStringType: String := NSString.stringWithUTF8String(property_getAttributes(fField));
    lStringType := lStringType.Substring(1);
    var lPos := lStringType.IndexOf(',');
    if lPos ≥ 0 then
      lStringType := lStringType.Substring(0, lPos);
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