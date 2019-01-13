namespace RemObjects.Elements.RTL.Reflection;

interface

uses
  RemObjects.Elements.RTL;

{$IF TOFFEE AND (TARGET_OS_IPHONE OR TARGET_IPHONESIMULATOR)}
type Protocol = id;
{$ENDIF}

type
  {$IF COOPER}
  PlatformType = public java.lang.Class;
  {$ELSEIF TOFFEE}
  PlatformType = public &Class;
  {$ELSEIF ECHOES}
  PlatformType = public System.Type;
  {$ELSEIF ISLAND}
  PlatformType = public RemObjects.Elements.System.Type;
  {$ENDIF}

  &Type = public class {$IF NOT TOFFEE} mapped to PlatformType {$ENDIF}
  private
    {$IF COOPER}
    {$ELSEIF TOFFEE}
    fIsID: Boolean;
    fClass: &Class;
    fProtocol: Protocol;
    fSimpleType: String;
    method GetName: String;
    method Get_Interfaces: ImmutableList<&Type>;
    method Get_Methods: ImmutableList<&Method>;
    method Get_Properties: ImmutableList<&Property>;
    {$ENDIF}
    {$IF NETFX_CORE}
    method Get_Interfaces: ImmutableList<&Type>;
    method Get_Methods: ImmutableList<&Method>;
    {$ENDIF}
    class method GetAllTypes: ImmutableList<&Type>;

  public
    class property AllTypes: ImmutableList<&Type> read GetAllTypes;
    class method GetType(aName: not nullable String): nullable &Type;
    {$IF COOPER}
    property Interfaces: ImmutableList<&Type> read mapped.getInterfaces().ToList() as ImmutableList<&Type>;
    property Methods: ImmutableList<&Method> read mapped.getMethods().ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.getSuperclass();
    property IsClass: Boolean read (not mapped.isInterface()) and (not mapped.isPrimitive());
    property IsInterface: Boolean read mapped.isInterface();
    property IsArray: Boolean read mapped.isArray();
    property IsEnum: Boolean read mapped.isEnum();
    property IsValueType: Boolean read mapped.isPrimitive();
    {$ELSEIF TOFFEE}
    constructor withID;
    constructor withClass(aClass: &Class);
    constructor withProtocol(aProtocol: id);
    constructor withSimpleType(aTypeEncoding: String);
    method IsSubclassOf(aType: &Type): Boolean;
    property Interfaces: ImmutableList<&Type> read Get_Interfaces();
    property Methods: ImmutableList<&Method> read Get_Methods();
    property Properties: ImmutableList<&Property> read get_Properties();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    //operator Explicit(aClass: rtl.Class): &Type;
    //operator Explicit(aProtocol: Protocol): &Type;
    property TypeClass: &Class read fClass;
    property Name: String read getName;
    property BaseType: nullable &Type read if IsClass then new &Type withClass(class_getSuperclass(fClass));
    property IsClass: Boolean read assigned(fClass) or fIsID;
    property IsInterface: Boolean read assigned(fProtocol);
    property IsArray: Boolean read false;
    property IsEnum: Boolean read false;
    property IsValueType: Boolean read false;
    property IsDelegate: Boolean read fSimpleType = '^?';
    {$ELSEIF NETFX_CORE}
    property Interfaces: ImmutableList<&Type> read Get_Interfaces;
    property Methods: ImmutableList<&Method> read Get_Methods;
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.GetTypeInfo().BaseType;
    property IsClass: Boolean read mapped.GetTypeInfo().IsClass;
    property IsInterface: Boolean read mapped.GetTypeInfo().IsInterface;
    property IsArray: Boolean read mapped.IsArray;
    property IsEnum: Boolean read mapped.GetTypeInfo().IsEnum;
    property IsValueType: Boolean read mapped.GetTypeInfo().IsValueType;
    {$ELSEIF ECHOES}
    property Interfaces: ImmutableList<&Type> read mapped.GetInterfaces().ToList();
    property Methods: ImmutableList<&Method> read mapped.GetMethods().ToList();
    property Properties: ImmutableList<&Property> read mapped.GetProperties().ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.BaseType;
    property IsClass: Boolean read mapped.IsClass;
    property IsInterface: Boolean read mapped.IsInterface;
    property IsArray: Boolean read mapped.IsArray;
    property IsEnum: Boolean read mapped.IsEnum;
    property IsValueType: Boolean read mapped.IsValueType;
    {$ELSEIF ISLAND}
    property Interfaces: ImmutableList<&Type> read mapped.Interfaces.ToList();
    property Methods: ImmutableList<&Method> read mapped.Methods.ToList();
    property Properties: ImmutableList<&Property> read mapped.Properties.ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.BaseType;
    property IsClass: Boolean read mapped.Flags = IslandTypeFlags.Class;
    property IsInterface: Boolean read mapped.Flags = IslandTypeFlags.Interface;
    property IsArray: Boolean read mapped.Flags = IslandTypeFlags.Array;
    property IsEnum: Boolean read mapped.Flags = IslandTypeFlags.Enum;
    property IsValueType: Boolean read mapped.IsValueType;
    {$ENDIF}
  end;

implementation

class method &Type.GetAllTypes: ImmutableList<&Type>;
begin
  {$IF COOPER}
  {$ELSEIF ECHOES}
  result := new List<&Type>();
  for each a in AppDomain.CurrentDomain.GetAssemblies do
    (result as List<&Type>).Add(a.GetTypes());
  {$ELSEIF ISLAND}
  result := mapped.AllTypes.ToList();
  {$ELSEIF TOFFEE}

  var lCount := objc_getClassList(nil, 0);
  result := new List<&Type> withCapacity(lCount);

  var lClasses := new unretained &Class[lCount];
  lCount := objc_getClassList(lClasses, lCount);

  for i: Integer := 0 to lCount-1 do begin
    var lClass: unretained &Class := lClasses[i];
    (result as List<&Type>).Add(new &Type withClass(lClass));
  end;
  {$ENDIF}
end;

class method &Type.GetType(aName: not nullable String): nullable &Type;
begin
  {$IF COOPER}
  {$ELSEIF ECHOES}
  result := PlatformType.GetType(aName);
  {$ELSEIF ISLAND}
  //result := mapped.AllTypes.ToList();
  {$ELSEIF TOFFEE}
  var lClass := NSClassFromString(aName);
  if assigned(lClass) then
    result := new &Type withClass(lClass);
  {$ENDIF}
end;

{$IF COOPER}
{$ELSEIF TOFFEE}
constructor &Type withID;
begin
  self := inherited init;
  if assigned(self) then begin
    fIsID := true;
  end;
  result := self;
end;

constructor &Type withClass(aClass: &Class);
begin
  self := inherited init;
  if assigned(self) then begin
    fClass := aClass;
  end;
  result := self;
end;

constructor &Type withProtocol(aProtocol: id);
begin
  self := inherited init;
  if assigned(self) then begin
    fProtocol := aProtocol;
  end;
  result := self;
end;

constructor &Type withSimpleType(aTypeEncoding: String);
begin
  self := inherited init;
  if assigned(self) then begin
    fSimpleType := aTypeEncoding;
  end;
  result := self;
end;

method &Type.GetName: String;
begin
  if fIsID then exit ('id');
  if assigned(fClass) then exit fClass.description;
  if assigned(fProtocol) then exit fProtocol.description;
  if assigned(fSimpleType) then begin
    case fSimpleType of
      'c': exit 'char';
      'i': exit 'NSInteger';
      's': exit 'Int16';
      'l': exit 'Int32';
      'q': exit 'Int64';
      'C': exit 'Char';
      'I': exit 'NSUInteger';
      'S': exit 'UInt16';
      'L': exit 'UInt32';
      'Q': exit 'UInt64';
      'f': exit 'Float';
      'd': exit 'Double';
      'B': exit 'Boolean';
      'v': exit 'Void';
      '*': exit 'Char *';
      '@': exit 'id';
      '#': exit 'Class';
      ':': exit 'SEL';
      '?': exit '<Unknown Type>';
    end;
  end;

  // Todo: handle simple types;
end;

method &Type.Get_Interfaces: ImmutableList<&Type>;
begin
end;

method &Type.Get_Methods: ImmutableList<&Method>;
begin
  var methodInfos: ^rtl.Method;
  var methodCount: UInt32;
  methodInfos := class_copyMethodList(fClass, var methodCount);
  result := NSMutableArray<&Method>.arrayWithCapacity(methodCount);
  for i: Int32 := 0 to methodCount-1 do
    NSMutableArray<&Method>(result).addObject(new &Method withClass(fClass) &method(methodInfos[i]));
end;

method &Type.Get_Properties: ImmutableList<&Property>;
begin
  var propInfos: ^rtl.Method;
  var propCount: UInt32;
  propInfos := class_copyPropertyList(fClass, var propCount);
  result := NSMutableArray<&Property>.arrayWithCapacity(propCount);
  for i: Int32 := 0 to propCount-1 do
    NSMutableArray<&Property>(result).addObject(new &Property withClass(fClass) &property(propInfos[i]));
end;

method &Type.IsSubclassOf(aType: &Type): Boolean;
begin
  result := fClass.isSubclassOfClass(aType.fClass);
end;
{$ENDIF}

{$IF NETFX_CORE}
method &Type.Get_Interfaces: ImmutableList<&Type>;
begin
  exit System.Linq.Enumerable.ToArray( mapped.GetTypeInfo().ImplementedInterfaces);
end;

method &Type.Get_Methods: ImmutableList<&Method>;
begin
  exit System.Linq.Enumerable.ToArray(System.Linq.Enumerable.OfType<&Method>(mapped.GetTypeInfo().DeclaredMembers));
end;
{$ENDIF}
end.