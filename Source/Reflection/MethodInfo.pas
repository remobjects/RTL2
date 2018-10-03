namespace RemObjects.Elements.RTL.Reflection;

interface

uses
  RemObjects.Elements.RTL;

type
  {$IF COOPER}
  PlatformMethod = public java.lang.reflect.Method;
  {$ELSEIF ECHOES}
  PlatformMethod = public System.Reflection.MethodInfo;
  {$ELSEIF ISLAND}
  PlatformMethod = public RemObjects.Elements.System.MethodInfo;
  {$ENDIF}

  &Method = public class
  {$IF COOPER OR ECHOES OR ISLAND}
    mapped to PlatformMethod
    {$ENDIF}
  private
    {$IF TOFFEE}
    const MAX_CHAR = 256;
    //var fClass: &Type;
    var fMethod: rtl.Method;
    method getReturnType: &Type;
    method getParameters: array of Parameter;
    {$ENDIF}
    {$IF COOPER}
    method getParameters: array of Parameter;
    {$ENDIF}
  protected
  public
    {$IF ECHOES}
    property Name: String read mapped.Name;
    property ReturnType: &Type read mapped.ReturnType;
    property IsStatic: Boolean read mapped.IsStatic;
    property IsPublic: Boolean read mapped.IsPublic;
    property IsPrivate: Boolean read mapped.IsPrivate;
    property IsFinal: Boolean read mapped.IsFinal;
    property IsAbstract: Boolean read mapped.IsAbstract;
    property Parameters: array of Parameter read mapped.GetParameters();
    {$ENDIF}
    {$IF COOPER}
    property Name: String read mapped.getName();
    property ReturnType: &Type read mapped.getReturnType();
    property IsStatic: Boolean read java.lang.reflect.Modifier.isStatic(mapped.getModifiers);
    property IsPublic: Boolean read java.lang.reflect.Modifier.isPublic(mapped.getModifiers);
    property IsPrivate: Boolean read java.lang.reflect.Modifier.isPrivate(mapped.getModifiers);
    property IsFinal: Boolean read java.lang.reflect.Modifier.isFinal(mapped.getModifiers);
    property IsAbstract: Boolean read java.lang.reflect.Modifier.isAbstract(mapped.getModifiers);
    property Parameters: array of Parameter read getParameters;
    {$ENDIF}
    {$IF TOFFEE}
    constructor withClass(aClass: &Type) &method(aMethod: rtl.Method);
    method Invoke(aInstance: Object; aArgs: array of Object): Object;
    property Name: String read NSStringFromSelector(&Selector);
    property &Selector: SEL read method_getName(fMethod);
    property ReturnType: &Type read getReturnType;
    property IsStatic: Boolean read false; // todo?
    property IsPublic: Boolean read true;
    property IsPrivate: Boolean read false;
    property IsFinal: Boolean read false;
    property IsAbstract: Boolean read false;
    property Parameters: array of Parameter read getParameters;
    {$ENDIF}
  end;

implementation

{$IF TOFFEE}
constructor &Method withClass(aClass: &Type) &method(aMethod: rtl.Method);
begin
  //fClass := aClass;
  fMethod := aMethod;
end;

method &Method.getReturnType: &Type;
begin
  var lDestination: array[0..MAX_CHAR] of AnsiChar;
  method_getReturnType(fMethod, lDestination, MAX_CHAR);
end;

method &Method.getParameters: array of Parameter;
begin
  var lCount := method_getNumberOfArguments(fMethod);
  for i: Int32 := 0 to lCount-1 do begin
    var lDestination: array[0..MAX_CHAR] of AnsiChar;
    method_getArgumentType(fMethod, i, lDestination, MAX_CHAR);
  end;

end;

method &Method.Invoke(aInstance: Object; aArgs: array of Object): Object;
begin
  result := rtl.objc_msgSend(aInstance, Selector, [aArgs]);
end;
{$ENDIF}

{$IF COOPER}
method &Method.getParameters: array of Parameter;
begin
  var parameterTypes := mapped.ParameterTypes;
  var parameterAttributes := mapped.ParameterAnnotations;
  result := new Parameter[parameterTypes.length];
  for i: Integer := 0 to parameterTypes.length - 1 do
  begin
    result[i] := new Parameter(Name := 'Parameter #' + i.toString(), //Java does not support reflection of parameter names in a simple way, debug info is needed.
                                                    ParameterType := parameterTypes[i],
                                                    Position := i,
                                                    CustomAttributes := parameterAttributes[i]);
  end;
end;
{$ENDIF}
end.