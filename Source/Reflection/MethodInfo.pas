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

  &Method = public class {$IF COOPER OR ECHOES OR ISLAND} mapped to PlatformMethod {$ENDIF}
  private
    {$IF TOFFEE AND NOT ISLAND}
    const MAX_CHAR = 256;
    //var fClass: &Type;
    var fMethod: rtl.Method;
    var fClass: &Type;
    method getReturnType: &Type;
    method getParameters: array of Parameter;
    {$ELSEIF COOPER}
    method getParameters: array of Parameter;
    {$ENDIF}
  protected
  public
    {$IF TOFFEE AND NOT ISLAND}
    constructor withClass(aClass: &Type) &method(aMethod: rtl.Method);
    method Invoke(aInstance: Object; params aArgs: array of Object): Object;
    property Name: String read NSStringFromSelector(&Selector);
    property Pointer: rtl.Method read fMethod;
    property &Selector: SEL read method_getName(fMethod);
    property ReturnType: &Type read getReturnType;
    property IsStatic: Boolean read false; // todo?
    property IsFinal: Boolean read false;
    property IsAbstract: Boolean read false;
    property Parameters: array of Parameter read getParameters;
    property DeclaringType: &Type read fClass;
    [Obsolete("Use Visibility")] property IsPublic: Boolean read true;
    [Obsolete("Use Visibility")] property IsPrivate: Boolean read false;
    {$ELSEIF COOPER}
    method Invoke(aInstance: Object; params aArgs: array of Object): Object;
    property Name: String read mapped.getName();
    property ReturnType: &Type read mapped.getReturnType();
    property IsStatic: Boolean read java.lang.reflect.Modifier.isStatic(mapped.getModifiers);
    property IsFinal: Boolean read java.lang.reflect.Modifier.isFinal(mapped.getModifiers);
    property IsAbstract: Boolean read java.lang.reflect.Modifier.isAbstract(mapped.getModifiers);
    property Parameters: array of Parameter read getParameters;
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringClass);
    [Obsolete("Use Visibility")] property IsPublic: Boolean read java.lang.reflect.Modifier.isPublic(mapped.getModifiers);
    [Obsolete("Use Visibility")] property IsPrivate: Boolean read java.lang.reflect.Modifier.isPrivate(mapped.getModifiers);
    {$ELSEIF ECHOES}
    property Name: String read mapped.Name;
    property ReturnType: &Type read mapped.ReturnType;
    property IsStatic: Boolean read mapped.IsStatic;
    property IsFinal: Boolean read mapped.IsFinal;
    property IsAbstract: Boolean read mapped.IsAbstract;
    property Parameters: array of Parameter read mapped.GetParameters();
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    property Visibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeEchoesVisibiliy(mapped);
    [Obsolete("Use Visibility")] property IsPublic: Boolean read mapped.IsPublic;
    [Obsolete("Use Visibility")] property IsPrivate: Boolean read mapped.IsPrivate;
    {$ELSEIF ISLAND}
    property Name: String read mapped.Name;
    property ReturnType: &Type read mapped.Type;
    property IsStatic: Boolean read mapped.IsStatic;
    property IsFinal: Boolean read (mapped.Flags and MethodFlags.Static) = MethodFlags.Static;
    property IsAbstract: Boolean read (mapped.Flags and MethodFlags.Abstract) = MethodFlags.Abstract;
    property DeclaringType: &Type read RemObjects.Elements.RTL.Reflection.Type(mapped.DeclaringType);
    property Visibility: Visibility read RemObjects.Elements.RTL.Reflection.Helpers.DecodeIslandVisibiliy(mapped.Access);
    {$ENDIF}
  end;

implementation

{$IF TOFFEE AND NOT ISLAND}

constructor &Method withClass(aClass: &Type) &method(aMethod: rtl.Method);
begin
  fClass := aClass;
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

method &Method.Invoke(aInstance: Object; params aArgs: array of Object): Object;
begin
  var lInvokation := NSInvocation.invocationWithMethodSignature(aInstance.methodSignatureForSelector(Selector));
  lInvokation.setSelector(Selector);
  lInvokation.setTarget(aInstance);
  for each a in aArgs index i do
    lInvokation.setArgument(@a) atIndex(i+2);
  lInvokation.invoke();
  lInvokation.getReturnValue(@result);
end;

{$ELSEIF COOPER}

method &Method.Invoke(aInstance: Object; params aArgs: array of Object): Object;
begin
  mapped.invoke(aInstance, aArgs);
end;

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