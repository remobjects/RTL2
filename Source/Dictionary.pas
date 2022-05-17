namespace RemObjects.Elements.RTL;

interface

type
  PlatformImmutableDictionary<T,U> = public {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF TOFFEE}Foundation.NSDictionary<T, U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.ImmutableDictionary<T,U>{$ENDIF};
  PlatformDictionary<T,U> = public {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF TOFFEE}Foundation.NSMutableDictionary<T, U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T,U>{$ENDIF};

  IImmutableDictionary<T, U> = public interface(PlatformSequence<KeyValuePair<T,U>>)
    method ContainsKey(Key: not nullable T): Boolean;
    method ContainsValue(Value: not nullable U): Boolean;
    property Item[Key: not nullable T]: nullable U read; default; // will return nil for unknown keys
    property Keys: not nullable ImmutableList<T> read;
    property Values: not nullable sequence of U read;
    property Count: Integer read;
  end;

  ImmutableDictionary<T, U> = public class (IImmutableDictionary<T, U>) mapped to PlatformImmutableDictionary<T,U>
  {$IFDEF ISLAND AND NOT TOFFEEV2}where T is unconstrained, U is unconstrained;{$ENDIF}
  {$IFDEF ISLAND AND TOFFEV2}where T is NSObject, U is NSOBject;{$ENDIF}
  {$IF TOFFEE} where T is class, U is class; {$ENDIF}
  private
    method GetKeys: not nullable ImmutableList<T>;
    method GetValues: not nullable sequence of U;
    method GetItem(aKey: not nullable T): nullable U; inline;
  protected

  public
    constructor; mapped to constructor();

    method ContainsKey(Key: not nullable T): Boolean;
    method ContainsValue(Value: not nullable U): Boolean;

    method ForEach(Action: Action<KeyValuePair<T, U>>);

    property Item[Key: not nullable T]: nullable U read GetItem; default; inline; // will return nil for unknown keys
    property Keys: not nullable ImmutableList<T> read GetKeys;
    property Values: not nullable sequence of U read GetValues;
    property Count: Integer read {$IF COOPER}mapped.size{$ELSE}mapped.Count{$ENDIF};

    method UniqueCopy: not nullable ImmutableDictionary<T,U>;
    method UniqueMutableCopy: not nullable Dictionary<T,U>;
    method MutableVersion: not nullable Dictionary<T,U>;

    //[&Sequence]
    method GetSequence: sequence of KeyValuePair<T,U>;
    begin
      exit DictionaryHelpers.GetSequence<T, U>(self);
    end;

    {$IF DARWIN AND NOT TOFFEE}
    //operator Explicit(aDictionary: NSDictionary<T, U>): ImmutableDictionary<T, U>;
    //begin
      //result := aDictionary as PlatformImmutableDictionary<T,U> as ImmutableDictionary<T, U>;
    //end;
    {$ENDIF}

    //[&Sequence]
    //method GetSequence: sequence of tuple of (String, JsonNode); iterator;
    //begin
      //for each kv in fItem do
        //yield (kv.Key, kv.Value);
    //end;

  end;

  IDictionary<T, U> = public interface(IImmutableDictionary<T, U>)
    method &Add(Key: not nullable T; Value: nullable U);
    method &Remove(Key: not nullable T): Boolean;
    method RemoveAll;
    property Item[aKey: not nullable T]: nullable U read write; default; // will return nil for unknown keys
  end;

  Dictionary<T, U> = public class(ImmutableDictionary<T, U>) mapped to PlatformDictionary<T,U>
  {$IF TOFFEE}
  where T is class, U is class;
  {$ENDIF}
  private
    method SetItem(Key: not nullable T; Value: nullable U); inline;
    method GetItem(aKey: not nullable T): nullable U; inline; // duped for performance optimization/inlining

  public
    constructor; mapped to constructor();
    constructor(aCapacity: Integer);

    method &Add(Key: not nullable T; Value: nullable U); inline;
    method &Add(aDictionary: nullable ImmutableDictionary<T, U>);
    method &Remove(Key: not nullable T): Boolean;
    method RemoveAll;

    property Item[aKey: not nullable T]: nullable U read GetItem write SetItem; default;  // will return nil for unknown keys
  end;

  ObjectDictionary = public Dictionary<String,Object>;

  StringDictionary = public Dictionary<String,String>;
  StringDictionary2 = public Dictionary<String,StringDictionary>;
  StringDictionary3 = public Dictionary<String,StringDictionary2>;
  StringDictionary4 = public Dictionary<String,StringDictionary3>;

  ImmutableObjectDictionary = public ImmutableDictionary<String,Object>;
  ImmutableStringDictionary = public ImmutableDictionary<String,String>;
  ImmutableStringDictionary2 = public ImmutableDictionary<String,ImmutableStringDictionary>;
  ImmutableStringDictionary3 = public ImmutableDictionary<String,ImmutableStringDictionary2>;
  ImmutableStringDictionary4 = public ImmutableDictionary<String,ImmutableStringDictionary3>;

implementation

constructor Dictionary<T,U>(aCapacity: Integer);
begin
  {$IF COOPER}
  result := new java.util.HashMap<T,U>(aCapacity);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSMutableDictionary withCapacity(aCapacity);
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.Dictionary<T,U>(aCapacity);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.Dictionary<T,U>(aCapacity);
  {$ENDIF}
end;

method Dictionary<T, U>.Add(Key: not nullable T; Value: nullable U);
begin
  self[Key] := Value;
end;

method Dictionary<T, U>.Add(aDictionary: nullable ImmutableDictionary<T, U>);
begin
  {$IF NOT TOFFEE}
  for each item in aDictionary do
    self[item.Key] := item.Value;
  {$ELSEIF TOFFEE}
  mapped.addEntriesFromDictionary(aDictionary);
  {$ENDIF}
end;

method Dictionary<T, U>.RemoveAll;
begin
  {$IF NOT TOFFEE}
  mapped.Clear;
  {$ELSE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ContainsKey(Key: not nullable T): Boolean;
begin
  {$IF NOT TOFFEE}
  exit mapped.ContainsKey(Key);
  {$ELSE}
  exit mapped.objectForKey(Key) <> nil;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ContainsValue(Value: not nullable U): Boolean;
begin
  {$IF NOT TOFFEE}
  exit mapped.ContainsValue(Value);
  {$ELSE}
  exit mapped.allValues.containsObject(Value);
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ForEach(Action: Action<KeyValuePair<T, U>>);
begin
  DictionaryHelpers.Foreach(self, Action);
end;

method ImmutableDictionary<T, U>.GetItem(aKey: not nullable T): nullable U;
begin
  {$IF COOPER}
  result := mapped[aKey];
  {$ELSEIF TOFFEE}
  result := mapped.objectForKey(aKey);
  {$ELSEIF ECHOES OR ISLAND}
  var lRes: U;
  if not mapped.TryGetValue(aKey, out lRes) then
    result := nil
  else
    result := lRes;
  {$ENDIF}
end;

method Dictionary<T, U>.GetItem(aKey: not nullable T): nullable U;
begin
  {$IF COOPER}
  result := mapped[aKey];
  {$ELSEIF TOFFEE}
  result := U(mapped.objectForKey(aKey));
  {$ELSEIF ECHOES OR ISLAND}
    var lRes: U;
  if not mapped.TryGetValue(aKey, out lRes) then
    result := nil
  else
    result := lRes;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetKeys: not nullable ImmutableList<T>;
begin
  {$IF COOPER}
  exit mapped.keySet.ToList() as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.allKeys as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Keys.ToList() as not nullable;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetValues: not nullable sequence of U;
begin
  {$IF COOPER}
  exit mapped.values as not nullable;
  {$ELSEIF TOFFEE}
  exit mapped.allValues as ImmutableList<U> as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Values as not nullable;
  {$ENDIF}
end;

method Dictionary<T, U>.Remove(Key: not nullable T): Boolean;
begin
  {$IF COOPER}
  exit mapped.remove(Key) <> nil;
  {$ELSEIF TOFFEE}
  result := ContainsKey(Key);
  if result then
    mapped.removeObjectForKey(Key);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(Key);
  {$ENDIF}
end;

method Dictionary<T, U>.SetItem(Key: not nullable T; Value: nullable U);
begin
  if not assigned(Value) then begin
    {$IF TOFFEE}
    if assigned(mapped[Key]) then
      &Remove(Key);
    {$ELSE}
    if mapped.ContainsKey(Key) then
      &Remove(Key);
    {$ENDIF}
    exit;
  end;
  mapped[Key] := Value;
end;

method ImmutableDictionary<T,U>.UniqueCopy: not nullable ImmutableDictionary<T,U>;
begin
  {$IF NOT TOFFEE}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy as not nullable;
  {$ENDIF}
end;

method ImmutableDictionary<T,U>.UniqueMutableCopy: not nullable Dictionary<T,U>;
begin
  {$IF NOT TOFFEE}
  result := new Dictionary<T,U>();
  for each k in Keys do
    result[k] := self[k];
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

method ImmutableDictionary<T,U>.MutableVersion: not nullable Dictionary<T,U>;
begin
  {$IF TOFFEE}
  result := coalesce(NSMutableDictionary<T,U>(self), mapped.mutableCopy) as not nullable;
  {$ELSEIF ISLAND}
  result := coalesce(Dictionary<T,U>(self), new PlatformDictionary<T,U>(self)) as not nullable;
  {$ELSE}
  result := not nullable Dictionary<T, U>(self);
  {$ENDIF}
end;

{ DictionaryHelpers }

type
  DictionaryHelpers = static class
  public
    {$IF COOPER}
    method GetSequence<T, U>(aSelf: java.util.HashMap<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.entrySet do
        yield new KeyValuePair<T,U>(el.Key, el.Value);
    end;
    {$ELSEIF TOFFEE}
    method GetSequence<T, U>(aSelf: NSDictionary<T,U>) : sequence of KeyValuePair<T,U>; where T is NSObject, U is NSObject; iterator;
    begin
      for each el in aSelf.allKeys do
       yield new KeyValuePair<T,U>(T(el), aSelf[el]);
    end;
    {$ELSEIF ECHOES}
    method GetSequence<T, U>(aSelf: System.Collections.Generic.Dictionary<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.Keys do
        yield new KeyValuePair<T,U>(el, aSelf[el]);
    end;
    {$ELSEIF ISLAND}
    method GetSequence<T, U>(aSelf: RemObjects.Elements.System.ImmutableDictionary<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.Keys do
        yield new KeyValuePair<T,U>(el, aSelf[el]);
    end;
    {$ENDIF}

    method Foreach<T, U>(aSelf: ImmutableDictionary<T, U>; aAction: Action<KeyValuePair<T, U>>);
    begin
      for each el in aSelf.Keys do
        aAction(new KeyValuePair<T,U>(T(el), U(aSelf.Item[el])));
    end;
  end;

end.