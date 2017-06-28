namespace RemObjects.Elements.RTL;

interface

type
  KeyValuePair<T, U> = public class
  public
    constructor(aKey: T; aValue: U);
    {$IF TOFFEE}
    method isEqual(obj: id): Boolean;
    {$ELSE}
    method &Equals(Obj: Object): Boolean; override;
    {$ENDIF}
    [ToString] method ToString: PlatformString; override;
    {$IF COOPER}
    method hashCode: Integer; override;
    {$ELSEIF ECHOES OR ISLAND}
    method GetHashCode: Integer; override;
    {$ELSEIF TOFFEE}
    method hash: Foundation.NSUInteger; override
    ;{$ENDIF}

    property Key: T read write; readonly;
    property Value: U read write; readonly;
    property &Tuple: tuple of (T,U) read (Key, Value);
  end;

implementation

constructor KeyValuePair<T,U>(aKey: T; aValue: U);
begin
  if aKey = nil then
    raise new ArgumentNullException("Key");

  Key := aKey;
  Value := aValue;
end;

{$IFDEF TOFFEE}
method KeyValuePair<T, U>.isEqual(obj: id): Boolean;
begin
  if not assigned(Obj) or (Obj is not KeyValuePair<T,U>) then
    exit false;

  var Item := KeyValuePair<T, U>(Obj);
  result := Key.Equals(Item.Key) and ( ((Value = nil) and (Item.Value = nil)) or ((Value <> nil) and Value.Equals(Item.Value)));
end;
{$ELSE}
method KeyValuePair<T, U>.&Equals(Obj: Object): Boolean;
begin
  if not assigned(Obj) or (Obj is not KeyValuePair<T,U>) then
    exit false;

  var Item := KeyValuePair<T, U>(Obj);
  result := Key.Equals(Item.Key) and ( ((Value = nil) and (Item.Value = nil)) or ((Value <> nil) and Value.Equals(Item.Value)));
end;
{$ENDIF}

{$IF COOPER}
method KeyValuePair<T, U>.hashCode: Integer;
begin
  result := Key.GetHashCode + Value:GetHashCode;
end;
{$ELSEIF ECHOES OR ISLAND}
method KeyValuePair<T, U>.GetHashCode: Integer;
begin
  result := Key.GetHashCode + Value:GetHashCode;
end;
{$ELSEIF TOFFEE}
method KeyValuePair<T, U>.hash: Foundation.NSUInteger;
begin
  result := Key.GetHashCode + Value:GetHashCode;
end;

{$ENDIF}

method KeyValuePair<T, U>.ToString: PlatformString;
begin
  result := String.Format("<Key: {0} Value: {1}>", Key, Value);
end;

end.