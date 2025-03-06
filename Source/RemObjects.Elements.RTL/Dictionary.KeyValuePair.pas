namespace RemObjects.Elements.RTL;

interface

type
  KeyValuePair<T, U> = public class
  public
    constructor(aKey: T; aValue: U);

    [&Equals] method &Equals(Obj: Object): Boolean; override;
    [ToString] method ToString: PlatformString; override;
    [Hash] method GetHashCode: Integer; override;

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

method KeyValuePair<T, U>.&Equals(Obj: Object): Boolean;
begin
  if not assigned(Obj) or (Obj is not KeyValuePair<T,U>) then
    exit false;

  var Item := KeyValuePair<T, U>(Obj);
  result := Key.Equals(Item.Key) and ( ((Value = nil) and (Item.Value = nil)) or ((Value <> nil) and Value.Equals(Item.Value)));
end;

method KeyValuePair<T, U>.GetHashCode: Integer;
begin
  result := Key.GetHashCode + Value:GetHashCode;
end;

method KeyValuePair<T, U>.ToString: PlatformString;
begin
  result := String.Format("<Key: {0} Value: {1}>", Key, Value);
end;

end.