namespace RemObjects.Elements.RTL;

interface

type
  ImmutableDictionary<T, U> = public class mapped to {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T,U>{$ELSEIF TOFFEE}Foundation.NSDictionary where T is class, U is class;{$ENDIF}
  private
    method GetKeys: ImmutableList<T>;
    method GetValues: sequence of U;
    method GetItem(aKey: T): U; inline;

  public
    constructor; mapped to constructor();

    method ContainsKey(Key: T): Boolean;
    method ContainsValue(Value: U): Boolean;

    method ForEach(Action: Action<KeyValuePair<T, U>>);

    property Item[Key: T]: U read GetItem; default; inline; // will return nil for unknown keys
    property Keys: ImmutableList<T> read GetKeys;
    property Values: sequence of U read GetValues;
    property Count: Integer read {$IF COOPER}mapped.size{$ELSE}mapped.Count{$ENDIF};

    method UniqueCopy: not nullable ImmutableDictionary<T,U>;
    method UniqueMutableCopy: not nullable Dictionary<T,U>;
    method MutableVersion: not nullable Dictionary<T,U>;

    {$IF NOT ECHOES}
    method GetSequence: sequence of KeyValuePair<T,U>;
    {$ENDIF}
  end;

  Dictionary<T, U> = public class(ImmutableDictionary<T, U>) mapped to {$IF COOPER}java.util.HashMap<T,U>{$ELSEIF ECHOES}System.Collections.Generic.Dictionary<T,U>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T,U>{$ELSEIF TOFFEE}Foundation.NSMutableDictionary where T is class, U is class;{$ENDIF}
  private
    method SetItem(Key: T; Value: U); inline;
    method GetItem(aKey: T): U; inline; // 76792: Descendant mapped type can't see `protected` members from ancestor, for property getter
    method ContainsKey(Key: T): Boolean; // 76792: Descendant mapped type can't see `protected` members from ancestor, for property getter

  public
    constructor; mapped to constructor();
    constructor(aCapacity: Integer);

    method &Add(Key: T; Value: U);
    method &Add(aDictionary: ImmutableDictionary<T, U>);
    method &Remove(Key: T): Boolean;
    method RemoveAll;

    property Item[Key: T]: U read GetItem write SetItem; default; inline; // will return nil for unknown keys
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

type
  DictionaryHelpers = static class
  public
  {$IFDEF COOPER}
    method Add<T, U>(aSelf: java.util.HashMap<T,U>; aKey: T; aVal: U);
    method GetSequence<T, U>(aSelf: java.util.HashMap<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    {$ELSEIF TOFFEE}
    method Add<T, U>(aSelf: NSMutableDictionary; aKey: T; aVal: U);
    method GetSequence<T, U>(aSelf: NSDictionary) : sequence of KeyValuePair<T,U>; iterator;
    {$ELSEIF ISLAND}
    method GetSequence<T, U>(aSelf: RemObjects.Elements.System.Dictionary<T,U>) : sequence of KeyValuePair<T,U>; iterator;
    {$ENDIF}
    method Foreach<T, U>(aSelf: ImmutableDictionary<T, U>; aAction: Action<KeyValuePair<T, U>>);
  end;

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

method Dictionary<T, U>.Add(Key: T; Value: U);
begin
  {$IF COOPER}
  DictionaryHelpers.Add(mapped, Key, Value);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Add(Key, Value);
  {$ELSEIF TOFFEE}
  DictionaryHelpers.Add(mapped, Key, Value);
  {$ENDIF}
end;

method Dictionary<T, U>.Add(aDictionary: ImmutableDictionary<T, U>);
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

method ImmutableDictionary<T, U>.ContainsKey(Key: T): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.ContainsKey(Key);
  {$ELSEIF TOFFEE}
  exit mapped.objectForKey(Key) <> nil;
  {$ENDIF}
end;

method Dictionary<T, U>.ContainsKey(Key: T): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.ContainsKey(Key);
  {$ELSEIF TOFFEE}
  exit mapped.objectForKey(Key) <> nil;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ContainsValue(Value: U): Boolean;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  exit mapped.ContainsValue(Value);
  {$ELSEIF TOFFEE}
  exit mapped.allValues.containsObject(NullHelper.ValueOf(Value));
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.ForEach(Action: Action<KeyValuePair<T, U>>);
begin
  DictionaryHelpers.Foreach(self, Action);
end;

method ImmutableDictionary<T, U>.GetItem(aKey: T): U;
begin
  {$IF COOPER}
  result := mapped[aKey];
  {$ELSEIF ECHOES OR ISLAND}
  if not mapped.TryGetValue(aKey, out result) then
    result := nil;
  {$ELSEIF TOFFEE}
  result := mapped.objectForKey(aKey);
  if assigned(result) then
    result := NullHelper.ValueOf(result);
  {$ENDIF}
end;

method Dictionary<T, U>.GetItem(aKey: T): U;
begin
  {$IF COOPER}
  result := mapped[aKey];
  {$ELSEIF ECHOES OR ISLAND}
  if not mapped.TryGetValue(aKey, out result) then
    result := nil;
  {$ELSEIF TOFFEE}
  result := mapped.objectForKey(aKey);
  if assigned(result) then
    result := NullHelper.ValueOf(result);
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetKeys: ImmutableList<T>;
begin
  {$IF COOPER}
  exit mapped.keySet.ToList();
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Keys.ToList();
  {$ELSEIF TOFFEE}
  exit mapped.allKeys;
  {$ENDIF}
end;

method ImmutableDictionary<T, U>.GetValues: sequence of U;
begin
  {$IF COOPER}
  exit mapped.values;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Values;
  {$ELSEIF TOFFEE}
  exit mapped.allValues;
  {$ENDIF}
end;

method Dictionary<T, U>.&Remove(Key: T): Boolean;
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

method Dictionary<T, U>.SetItem(Key: T; Value: U);
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  mapped[Key] := Value;
  {$ELSEIF TOFFEE}
  mapped.setObject(NullHelper.ValueOf(Value)) forKey(Key);
  {$ENDIF}
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
  result := mapped.mutableCopy;
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
    result := mapped.mutableCopy;
  {$ENDIF}
end;

{ DictionaryHelpers }

{$IFDEF TOFFEE}
method DictionaryHelpers.Add<T, U>(aSelf: NSMutableDictionary; aKey: T; aVal: U);
begin
  if aSelf.objectForKey(aKey) <> nil then raise new ArgumentException(RTLErrorMessages.KEY_EXISTS);
  aSelf.setObject(NullHelper.ValueOf(aVal)) forKey(aKey);
end;

method DictionaryHelpers.GetSequence<T, U>(aSelf: NSDictionary) : sequence of KeyValuePair<T,U>;
begin
   for each el in aSelf.allKeys do
    yield new KeyValuePair<T,U>(el, aSelf[el]);
end;
{$ENDIF}

{$IFDEF ISLAND}
/*method DictionaryHelpers.Add<T, U>(aSelf: NSMutableDictionary; aKey: T; aVal: U);
begin
  if aSelf.objectForKey(aKey) <> nil then raise new ArgumentException(RTLErrorMessages.KEY_EXISTS);
  aSelf.setObject(NullHelper.ValueOf(aVal)) forKey(aKey);
end;

method DictionaryHelpers.GetItem<T, U>(aSelf: NSDictionary; aKey: T): U;
begin
  var o := aSelf.objectForKey(aKey);
  if o = nil then raise new KeyNotFoundException();
  exit NullHelper.ValueOf(o);
end;*/

method DictionaryHelpers.GetSequence<T, U>(aSelf: RemObjects.Elements.System.Dictionary<T,U>) : sequence of KeyValuePair<T,U>;
begin
   for each el in aSelf.Keys do
    yield new KeyValuePair<T,U>(el, aSelf[el]);
end;
{$ENDIF}

{$IFDEF COOPER}
method DictionaryHelpers.GetSequence<T, U>(aSelf: java.util.HashMap<T,U>) : sequence of KeyValuePair<T,U>;
begin
  for each el in aSelf.entrySet do
    yield new KeyValuePair<T,U>(el.Key, el.Value);
end;

method DictionaryHelpers.Add<T, U>(aSelf: java.util.HashMap<T,U>; aKey: T; aVal: U);
begin
  if aSelf.containsKey(aKey) then raise new ArgumentException(RTLErrorMessages.KEY_EXISTS);
  aSelf.put(aKey, aVal)
end;

{$ENDIF}

method DictionaryHelpers.Foreach<T, U>(aSelf: ImmutableDictionary<T, U>; aAction: Action<KeyValuePair<T, U>>);
begin
  for each el in aSelf.Keys do
    aAction(new KeyValuePair<T,U>(T(el), U(aSelf.Item[el])));
end;

end.