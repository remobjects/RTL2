namespace RemObjects.Elements.RTL.Reflection;

interface

type
  {$IF ECHOES}
  PlatformParameter = public System.Reflection.ParameterInfo;
  {$ELSEIF ISLAND}
  PlatformParameter = public RemObjects.Elements.System.ArgumentInfo;
  {$ENDIF}

  Parameter = public class
  {$IF ECHOES OR ISLAND}
  mapped to PlatformParameter
  {$ENDIF}
  private
  protected
  public
    {$IF ECHOES}
    property Name: String read mapped.Name;
    property Position: Integer read mapped.Position;
    property ParameterType: &Type read mapped.ParameterType;
    {$IFDEF NETFX_CORE}
    property CustomAttributes: array of Object read System.Linq.Enumerable.ToArray(mapped.GetCustomAttributes(false));
    {$ELSE}
    property CustomAttributes: array of Object read mapped.GetCustomAttributes(false);
    {$ENDIF}
    {$ENDIF}
    {$IF COOPER}
    property Name: String;
    property Position: Integer;
    property ParameterType: &Type;
    property CustomAttributes: array of Object;
    {$ENDIF}
    {$IF TOFFEE}
    constructor withIndex(aPosition: Int32) &type(aType: &Type);
    property Name: String read nil;
    property Position: Integer; readonly;
    property ParameterType: &Type; readonly;
    property CustomAttributes: array of Object read [];
    {$ENDIF}
  end;

implementation

{$IF TOFFEE}
constructor Parameter withIndex(aPosition: Int32) &type(aType: &Type);
begin
  Position := aPosition;
  &ParameterType := aType;
end;
{$ENDIF}

end.