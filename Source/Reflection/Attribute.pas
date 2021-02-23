namespace RemObjects.Elements.RTL.Reflection;

uses
  RemObjects.Elements.RTL;

type
  {$IF COOPER}
  //PlatformAttribute = public java.lang.reflect.Attribute;
  {$ELSEIF ECHOES}
  PlatformAttribute = public System.Attribute;
  {$ELSEIF ISLAND}
  PlatformAttribute = public RemObjects.Elements.System.CustomAttribute;
  {$ENDIF}

  Attribute = public class {$IF ECHOES OR (ISLAND AND NOT TOFFEEV1)} mapped to PlatformAttribute {$ENDIF}
  private
  end;

end.