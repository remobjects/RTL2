namespace RemObjects.Elements.RTL.Reflection;

interface

uses
  RemObjects.Elements.RTL;

{$IF TOFFEE AND (TARGET_OS_IPHONE OR TARGET_IPHONESIMULATOR) AND NOT ISLAND}
type Protocol = id;
{$ENDIF}

type
  {$IF COOPER}
  PlatformType = public java.lang.Class;
  {$ELSEIF TOFFEE AND NOT ISLAND}
  PlatformType = public &Class;
  {$ELSEIF ECHOES}
  PlatformType = public System.Type;
  {$ELSEIF ISLAND}
  PlatformType = public RemObjects.Elements.System.Type;
  {$ENDIF}
  {$IFNDEF TOFFEEV2}
  Visibility = public enum(&Private, &Unit, UnitAndProtected, UnitOrProtected, &Assembly, AssemblyAndProtected, AssemblyOrProtected, &Protected, &Public, &Published);

  [assembly:DefaultTypeOverride("Type", "RemObjects.Elements.RTL.Reflection", typeOf(RemObjects.Elements.RTL.Reflection.Type))]

  &Type = public class {$IF NOT TOFFEE OR ISLAND} mapped to PlatformType {$ENDIF}
  private
    {$IF COOPER}
    {$ELSEIF TOFFEE AND NOT ISLAND}
    fIsID: Boolean;
    fClass: &Class;
    fProtocol: Protocol;
    fSimpleType: String;
    method GetName: String;
    method Get_Interfaces: ImmutableList<&Type>;
    method Get_Methods: ImmutableList<&Method>;
    method Get_Properties: ImmutableList<&Property>;
    method Get_Fields: ImmutableList<Field>;
    {$ENDIF}
    {$IF NETFX_CORE}
    method Get_Interfaces: ImmutableList<&Type>;
    method Get_Methods: ImmutableList<&Method>;
    {$ENDIF}
    class method GetAllTypes: ImmutableList<&Type>;

  public
    class property AllTypes: ImmutableList<&Type> read GetAllTypes;
    class method GetType(aName: not nullable String): nullable &Type;
    constructor withPlatformType(aType: PlatformType);
    {$IF COOPER}
    //method IsSubclassOf(aType: &Type): Boolean;
    property Interfaces: ImmutableList<&Type> read mapped.getInterfaces().ToList() as ImmutableList<&Type>;
    property Methods: ImmutableList<&Method> read mapped.getMethods().ToList();
    property MethodFields: ImmutableList<Field> read mapped.getFields().ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.getSuperclass();
    property IsClass: Boolean read (not mapped.isInterface()) and (not mapped.isPrimitive());
    property IsInterface: Boolean read mapped.isInterface();
    property IsArray: Boolean read mapped.isArray();
    property IsEnum: Boolean read mapped.isEnum();
    property IsValueType: Boolean read mapped.isPrimitive();
    {$ELSEIF TOFFEE AND NOT ISLAND}
    constructor withID;
    constructor withClass(aClass: &Class);
    constructor withProtocol(aProtocol: id);
    constructor withSimpleType(aTypeEncoding: String);
    method IsSubclassOf(aType: &Type): Boolean;
    property Interfaces: ImmutableList<&Type> read Get_Interfaces();
    property Methods: ImmutableList<&Method> read Get_Methods();
    property Properties: ImmutableList<&Property> read get_Properties();
    property Fields: ImmutableList<Field> read get_Fields();
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
    method IsSubclassOf(aType: &Type): Boolean;
    property Interfaces: ImmutableList<&Type> read mapped.GetInterfaces().ToList();
    property Methods: ImmutableList<&Method> read mapped.GetMethods().ToList();
    property Properties: ImmutableList<&Property> read mapped.GetProperties().ToList();
    property Fields: ImmutableList<Field> read mapped.GetFields(System.Reflection.BindingFlags.Public or System.Reflection.BindingFlags.NonPublic or System.Reflection.BindingFlags.Instance or System.Reflection.BindingFlags.Static).ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.BaseType;
    property IsClass: Boolean read mapped.IsClass;
    property IsInterface: Boolean read mapped.IsInterface;
    property IsArray: Boolean read mapped.IsArray;
    property IsEnum: Boolean read mapped.IsEnum;
    property IsValueType: Boolean read mapped.IsValueType;
    {$ELSEIF ISLAND}
    method IsSubclassOf(aType: &Type): Boolean;
    property Interfaces: ImmutableList<&Type> read sequence of &Type(mapped.Interfaces).ToList();
    property Methods: ImmutableList<&Method> read sequence of &Method(mapped.Methods).ToList();
    property Properties: ImmutableList<&Property> read sequence of &Property(mapped.Properties).ToList();
    property Fields: ImmutableList<Field> read sequence of Field(mapped.Fields).ToList();
    //property Attributes: ImmutableList<Sugar.Reflection.AttributeInfo> read mapped.().ToList();
    property Name: String read mapped.Name;
    property BaseType: nullable &Type read mapped.BaseType;
    property IsClass: Boolean read mapped.Flags = IslandTypeFlags.Class;
    property IsInterface: Boolean read mapped.Flags = IslandTypeFlags.Interface;
    property IsArray: Boolean read mapped.Flags = IslandTypeFlags.Array;
    property IsEnum: Boolean read mapped.Flags = IslandTypeFlags.Enum;
    property IsValueType: Boolean read mapped.IsValueType;

    property ObjectModel: ObjectModel read ObjectModel.Island; // for now
    {$ENDIF}

    method Instantiate: Object;
    begin
      {$IF COOPER}
      result := mapped.newInstance()
      {$ELSEIF TOFFEE AND NOT ISLAND}
      result := fClass.alloc.init;
      {$ELSEIF ECHOES}
      result := Activator.CreateInstance(mapped);
      {$ELSEIF ISLAND}
      result := mapped.Instantiate();
      {$ENDIF}
    end;
  end;
  {$ENDIF}

implementation
{$IFNDEF TOFFEEV2}
{$IF COOPER}[Warning("Type.GetAllTypes is not supported for Java")]{$ENDIF}
class method &Type.GetAllTypes: ImmutableList<&Type>;
begin
  {$IF COOPER}
  {$ELSEIF TOFFEE AND NOT ISLAND}

  var lCount := objc_getClassList(nil, 0);
  result := new List<&Type> withCapacity(lCount);

  var lClasses := new unretained &Class[lCount];
  lCount := objc_getClassList(lClasses, lCount);

  for i: Integer := 0 to lCount-1 do begin
    var lClass: unretained &Class := lClasses[i];
    (result as List<&Type>).Add(new &Type withClass(lClass));
  end;
  {$ELSEIF ECHOES}
  result := new List<&Type>();
  for each a in AppDomain.CurrentDomain.GetAssemblies do
    (result as List<&Type>).Add(a.GetTypes());
  {$ELSEIF ISLAND}
  result := sequence of &Type(mapped.AllTypes).ToList();
  {$ENDIF}
end;

class method &Type.GetType(aName: not nullable String): nullable &Type;
begin
  {$IF COOPER}
  try
    result := PlatformType.forName(aName);
  except
  end;
  {$ELSEIF TOFFEE AND NOT ISLAND}
  var lClass := NSClassFromString(aName);
  if assigned(lClass) then
    result := new &Type withClass(lClass);
  {$ELSEIF ECHOES}
  result := PlatformType.GetType(aName);
  {$ELSEIF ISLAND}
  result := &Type.AllTypes.FirstOrDefault(a -> a.Name = aName);
  {$ENDIF}
end;

constructor &Type withPlatformType(aType: PlatformType);
begin
  {$IF ECHOES OR COOPER OR ISLAND}
  result := aType as &Type;
  {$ELSEIF TOFFEE AND NOT ISLAND}
  constructor withClass(aType);
  {$ENDIF}
end;

{$IF COOPER}
//method &Type.IsSubclassOf(aType: &Type): Boolean;
//begin
  //result := mapped.IsSubclassOf(aType);
//end;
{$ELSEIF TOFFEE AND NOT ISLAND}
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
    NSMutableArray<&Method>(result).addObject(new &Method withClass(self) &method(methodInfos[i]));
end;

method &Type.Get_Properties: ImmutableList<&Property>;
begin
  var propInfos: ^rtl.Method;
  var propCount: UInt32;
  propInfos := class_copyPropertyList(fClass, var propCount);
  result := NSMutableArray<&Property>.arrayWithCapacity(propCount);
  for i: Int32 := 0 to propCount-1 do
    NSMutableArray<&Property>(result).addObject(new &Property withClass(self) &property(propInfos[i]));
end;

method &Type.Get_Fields: ImmutableList<Field>;
begin
  raise new NotImplementedException("Reflection for Fields is not implemented yet for Cocoa")
  //var propInfos: ^rtl.Method;
  //var propCount: UInt32;
  //propInfos := class_copyPropertyList(fClass, var propCount);
  //result := NSMutableArray<&Property>.arrayWithCapacity(propCount);
  //for i: Int32 := 0 to propCount-1 do
    //NSMutableArray<&Property>(result).addObject(new &Property withClass(self) &property(propInfos[i]));
end;

method &Type.IsSubclassOf(aType: &Type): Boolean;
begin
  result := fClass.isSubclassOfClass(aType.fClass);
end;
{$ELSEIF NETFX_CORE}
{$ELSEIF ECHOES}
method &Type.IsSubclassOf(aType: &Type): Boolean;
begin
  result := mapped.IsSubclassOf(aType);
end;
{$ELSEIF ISLAND}
method &Type.IsSubclassOf(aType: &Type): Boolean;
begin
  result := mapped.IsSubclassOf(aType);
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


{$ENDIF}
end.