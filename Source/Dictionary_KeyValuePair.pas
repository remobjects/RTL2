namespace RemObjects.Elements.RTL;

type
  KeyValuePair<T, U> = public class
  public
    constructor(aKey: T; aValue: U);
    begin
      if aKey = nil then
        raise new ArgumentNullException("Key");

      Key := aKey;
      Value := aValue;
    end;

    [&Equals] method &Equals(Obj: Object): Boolean; override;
    begin
      if not assigned(Obj) or (Obj is not KeyValuePair<T,U>) then
        exit false;

      var Item := KeyValuePair<T, U>(Obj);
      result := Key.Equals(Item.Key) and ( ((Value = nil) and (Item.Value = nil)) or ((Value <> nil) and Value.Equals(Item.Value)));
    end;

    [ToString] method ToString: PlatformString; override;
    begin
      result := String.Format("<Key: {0} Value: {1}>", Key, Value);
    end;

    [Hash] method GetHashCode: Integer; override;
    begin
      result := Key.GetHashCode + Value:GetHashCode;
    end;


    property Key: T read write; readonly;
    property Value: U read write; readonly;
    property &Tuple: tuple of (T,U) read (Key, Value);
  end;

end.