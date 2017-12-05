namespace RemObjects.Elements.RTL;

interface

type
  ImmutableDictionary<T, U> = public class mapped to
  {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T,U>{$ELSEIF TOFFEE}Foundation.NSDictionary{$ENDIF}
  {$IFDEF TOFFEE}
  where T is class, U is class;
  {$ENDIF}
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

    {$IF NOT ECHOES}
    method GetSequence: sequence of KeyValuePair<T,U>;
    {$ENDIF}
  end;

  Dictionary<T, U> = public class(ImmutableDictionary<T, U>) mapped to {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T,U>{$ELSEIF TOFFEE}Foundation.NSMutableDictionary{$ENDIF}
  {$IFDEF TOFFEE}
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

    property Item[aKey: not nullable T]: nullable U read GetItem write SetItem; default; inline; // will return nil for unknown keys
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
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.Dictionary<T,U>(aCapacity);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.Dictionary<T,U>(aCapacity);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSMutableDictionary withCapacity(aCapacity);
  {$ENDIF}
end;

method Dictionary<T, U>.Add(Key: not nullable T; Value: nullable U);
begin
  self[Key] := Value;
end;

method Dictionary<T, U>.Add(aDictionary: nullable ImmutableDictionary<T, U>);
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  for each item in aDictionary do
    self[item.Key] := item.Value;
  {$ELSEIF TOFFEE}
  mapped.addEntriesFromDictionary(aDictionary);
  {$ENDIF}
end;

method Dictionary<T, U>.RemoveAll;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  mapped.Clear;
  {$ELSEIF TOFFEE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ContainsKey(Key: not nullable T): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.ContainsKey(Key);
  {$ELSEIF TOFFEE}
  exit mapped.objectForKey(Key) <> nil;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ContainsValue(Value: not nullable U): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.ContainsValue(Value);
  {$ELSEIF TOFFEE}
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
  {$ELSEIF ECHOES OR ISLAND}
  if not mapped.TryGetValue(aKey, out result) then
    result := nil; // should be unnecessary?
  {$ELSEIF TOFFEE}
  result := mapped.objectForKey(aKey);
  {$ENDIF}
end;

method Dictionary<T, U>.GetItem(aKey: not nullable T): nullable U;
begin
  {$IF COOPER}
  result := mapped[aKey];
  {$ELSEIF ECHOES OR ISLAND}
  if not mapped.TryGetValue(aKey, out result) then
    result := nil; // should be unnecessary?
  {$ELSEIF TOFFEE}
  result := mapped.objectForKey(aKey);
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetKeys: not nullable ImmutableList<T>;
begin
  {$IF COOPER}
  exit mapped.keySet.ToList();
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Keys.ToList();
  {$ELSEIF TOFFEE}
  exit mapped.allKeys;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetValues: not nullable sequence of U;
begin
  {$IF COOPER}
  exit mapped.values;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Values;
  {$ELSEIF TOFFEE}
  exit mapped.allValues;
  {$ENDIF}
end;

method Dictionary<T, U>.Remove(Key: not nullable T): Boolean;
begin
  {$IF COOPER}
  exit mapped.remove(Key) <> nil;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(Key);
  {$ELSEIF TOFFEE}
  result := ContainsKey(Key);
  if result then
    mapped.removeObjectForKey(Key);
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

{$IF NOT ECHOES}
method ImmutableDictionary<T,U>.GetSequence: sequence of KeyValuePair<T,U>;
begin
  exit DictionaryHelpers.GetSequence<T, U>(self);
end;
{$ENDIF}

method ImmutableDictionary<T,U>.UniqueCopy: not nullable ImmutableDictionary<T,U>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy;
  {$ENDIF}
end;

method ImmutableDictionary<T,U>.UniqueMutableCopy: not nullable Dictionary<T,U>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := new Dictionary<T,U>();
  for each k in Keys do
    result[k] := self[k];
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

method ImmutableDictionary<T,U>.MutableVersion: not nullable Dictionary<T,U>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := self;
  {$ELSEIF TOFFEE}
  if self is NSMutableDictionary then
    result := self as NSMutableDictionary
  else
    result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

{ DictionaryHelpers }

type
  DictionaryHelpers = static class
  public
    {$IFDEF TOFFEE}
    method GetSequence<T, U>(aSelf: NSDictionary) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.allKeys do
       yield new KeyValuePair<T,U>(el, aSelf[el]);
    end;
    {$ENDIF}

    {$IFDEF ISLAND}
    method GetSequence<T, U>(aSelf: RemObjects.Elements.System.Dictionary<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.Keys do
        yield new KeyValuePair<T,U>(el, aSelf[el]);
    end;
    {$ENDIF}

    {$IFDEF COOPER}
    method GetSequence<T, U>(aSelf: java.util.HashMap<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    begin
      for each el in aSelf.entrySet do
        yield new KeyValuePair<T,U>(el.Key, el.Value);
    end;
    {$ENDIF}

    method Foreach<T, U>(aSelf: ImmutableDictionary<T, U>; aAction: Action<KeyValuePair<T, U>>);
    begin
      for each el in aSelf.Keys do
        aAction(new KeyValuePair<T,U>(T(el), U(aSelf.Item[el])));
    end;
  end;

end.