namespace RemObjects.Elements.RTL;

interface

type
  PlatformHashSet<T> = public {$IF COOPER}java.util.HashSet<T>{$ELSEIF TOFFEE}Foundation.NSMutableSet{$ELSEIF ECHOES}System.Collections.Generic.HashSet<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Dictionary<T, Byte>{$ENDIF};

  IHashSet<T> = public interface(PlatformSequence<T>)
    method &Add(aItem: T): Boolean;
    method &Add(aItems: nullable sequence of T);
    method Clear;
    method Contains(aItem: T): Boolean;
    method ForEach(aAction: Action<T>);
    method Intersect(aSet: nullable HashSet<T>);
    method &Remove(aItem: T): Boolean;
    method SetEquals(aSet: nullable HashSet<T>): Boolean;
    method ToArray: not nullable array of T;
    method &Union(aSet: nullable HashSet<T>);
    method IsSubsetOf(aSet: nullable HashSet<T>): Boolean;
    method IsSupersetOf(aSet: nullable HashSet<T>): Boolean;
    property Count: Integer read;
  end;

  HashSet<T> = public class(PlatformSequence<T>, IHashSet<T>) mapped to PlatformHashSet<T>
  {$IFDEF TOFFEE} where T is class;{$ENDIF}
  public
    constructor; mapped to constructor();
    constructor(aSet: nullable HashSet<T>);
    constructor(aItems: nullable sequence of T);
    constructor(params aItems: nullable array of T);

    method &Add(aItem: T): Boolean;
    method &Add(aItems: nullable sequence of T);
    method Clear;
    method Contains(aItem: T): Boolean;
    method ForEach(aAction: Action<T>);
    method Intersect(aSet: nullable HashSet<T>);
    method &Remove(aItem: T): Boolean;
    method SetEquals(aSet: nullable HashSet<T>): Boolean;
    method ToArray: not nullable array of T;
    method &Union(aSet: nullable HashSet<T>);
    method IsSubsetOf(aSet: nullable HashSet<T>): Boolean;
    method IsSupersetOf(aSet: nullable HashSet<T>): Boolean;

    property Count: Integer read {$IF COOPER}mapped.size{$ELSEIF TOFFEE}mapped.count{$ELSE}mapped.Count{$ENDIF};

    method GetSequence: sequence of T; iterator;
    begin
      {$IF COOPER OR ECHOES}
      for each lItem in mapped do
        yield lItem;
      {$ELSEIF TOFFEE}
      for each lItem in mapped do begin
        var lValue := id(lItem);
        if lValue = NSNull.null then
          lValue := nil;
        yield T(lValue);
      end;
      {$ELSEIF ISLAND}
      for each lItem in mapped.Keys do
        yield lItem;
      {$ENDIF}
    end;

    {$IF TOFFEE}
    operator Implicit(aSet: Foundation.NSSet<T>): HashSet<T>;
    {$ENDIF}
  end;

implementation

type
  HashSetHelpers = static class
  public
    method ValidateSet<T>(aSet: nullable HashSet<T>);
    begin
      if not assigned(aSet) then
        raise new ArgumentNullException("aSet");
    end;

    method Foreach<T>(aSelf: HashSet<T>; aAction: Action<T>);
    begin
      for each lItem in aSelf do
        aAction(lItem);
    end;

    method IsSubsetOf<T>(aSelf, aSet: nullable HashSet<T>): Boolean;
    begin
      ValidateSet(aSet);

      if aSelf.Count = 0 then
        exit true;

      if aSelf.Count > aSet.Count then
        exit false;

      for each lItem in aSelf do
        if not aSet.Contains(lItem) then
          exit false;

      exit true;
    end;
  end;

constructor HashSet<T>(aSet: nullable HashSet<T>);
begin
  if not assigned(aSet) then
    exit new HashSet<T>;

  {$IF COOPER}
  exit new java.util.HashSet<T>(aSet);
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.HashSet<T>(aSet);
  {$ELSEIF TOFFEE}
  var lNewSet := new Foundation.NSMutableSet();
  lNewSet.setSet(aSet);
  exit lNewSet;
  {$ELSEIF ISLAND}
  result := new HashSet<T>;
  result.Add(aSet);
  {$ENDIF}
end;

constructor HashSet<T>(aItems: nullable sequence of T);
begin
  result := new HashSet<T>;
  result.Add(aItems);
end;

constructor HashSet<T>(params aItems: nullable array of T);
begin
  result := new HashSet<T>(aItems as sequence of T);
end;

method HashSet<T>.Add(aItem: T): Boolean;
begin
  {$IF COOPER OR ECHOES}
  exit mapped.Add(aItem);
  {$ELSEIF TOFFEE}
  var lCount := mapped.count;
  mapped.addObject(NullHelper.coalesce(aItem, NSNull.null));
  exit lCount < mapped.count;
  {$ELSEIF ISLAND}
  if mapped.ContainsKey(aItem) then
    exit false;
  mapped[aItem] := 1;
  exit true;
  {$ENDIF}
end;

method HashSet<T>.Add(aItems: nullable sequence of T);
begin
  if not assigned(aItems) then
    exit;

  for each lItem in aItems do
    Add(lItem);
end;

method HashSet<T>.Clear;
begin
  {$IF NOT TOFFEE}
  mapped.Clear;
  {$ELSE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method HashSet<T>.Contains(aItem: T): Boolean;
begin
  {$IF COOPER OR ECHOES}
  exit mapped.Contains(aItem);
  {$ELSEIF TOFFEE}
  exit mapped.containsObject(NullHelper.coalesce(aItem, NSNull.null));
  {$ELSEIF ISLAND}
  exit mapped.ContainsKey(aItem);
  {$ENDIF}
end;

method HashSet<T>.ForEach(aAction: Action<T>);
begin
  HashSetHelpers.Foreach(self, aAction);
end;

method HashSet<T>.Intersect(aSet: nullable HashSet<T>);
begin
  HashSetHelpers.ValidateSet(aSet);

  {$IF COOPER}
  mapped.retainAll(aSet);
  {$ELSEIF ECHOES}
  mapped.IntersectWith(aSet);
  {$ELSEIF TOFFEE}
  mapped.intersectSet(aSet);
  {$ELSEIF ISLAND}
  var lItems := ToArray;
  for each lItem in lItems do
    if not aSet.Contains(lItem) then
      mapped.Remove(lItem);
  {$ENDIF}
end;

method HashSet<T>.Remove(aItem: T): Boolean;
begin
  {$IF COOPER OR ECHOES}
  exit mapped.Remove(aItem);
  {$ELSEIF TOFFEE}
  var lCount := mapped.count;
  mapped.removeObject(NullHelper.coalesce(aItem, NSNull.null));
  exit lCount > mapped.count;
  {$ELSEIF ISLAND}
  exit mapped.Remove(aItem);
  {$ENDIF}
end;

method HashSet<T>.SetEquals(aSet: nullable HashSet<T>): Boolean;
begin
  HashSetHelpers.ValidateSet(aSet);

  {$IF COOPER}
  exit mapped.equals(aSet);
  {$ELSEIF ECHOES}
  exit mapped.SetEquals(aSet);
  {$ELSEIF TOFFEE}
  exit mapped.isEqualToSet(aSet);
  {$ELSEIF ISLAND}
  if Count <> aSet.Count then
    exit false;

  exit HashSetHelpers.IsSubsetOf(self, aSet);
  {$ENDIF}
end;

method HashSet<T>.ToArray: not nullable array of T;
begin
  {$IF COOPER}
  exit mapped.toArray(new T[0]) as not nullable;
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArray<T>(mapped.allObjects);
  {$ELSEIF ECHOES}
  exit mapped.ToArray as not nullable;
  {$ELSEIF ISLAND}
  result := new T[mapped.Count];
  var lIndex := 0;
  for each lItem in mapped.Keys do begin
    result[lIndex] := lItem;
    inc(lIndex);
  end;
  {$ENDIF}
end;

method HashSet<T>.Union(aSet: nullable HashSet<T>);
begin
  HashSetHelpers.ValidateSet(aSet);

  {$IF COOPER}
  mapped.addAll(aSet);
  {$ELSEIF ECHOES}
  mapped.UnionWith(aSet);
  {$ELSEIF TOFFEE}
  mapped.unionSet(aSet);
  {$ELSEIF ISLAND}
  for each lItem in aSet do
    mapped[lItem] := 1;
  {$ENDIF}
end;

method HashSet<T>.IsSubsetOf(aSet: nullable HashSet<T>): Boolean;
begin
  exit HashSetHelpers.IsSubsetOf(self, aSet);
end;

method HashSet<T>.IsSupersetOf(aSet: nullable HashSet<T>): Boolean;
begin
  exit HashSetHelpers.IsSubsetOf(aSet, self);
end;

{$IF TOFFEE}
operator HashSet<T>.Implicit(aSet: Foundation.NSSet<T>): HashSet<T>;
begin
  if aSet is Foundation.NSMutableSet then
    result := HashSet<T>(aSet)
  else
    result := HashSet<T>(aSet.mutableCopy);
end;
{$ENDIF}

end.
