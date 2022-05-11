namespace RemObjects.Elements.RTL;

interface

type
  PlatformImmutableList<T> = public {$IF COOPER}java.util.ArrayList<T>{$ELSEIF TOFFEE}Foundation.NSArray<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.ImmutableList<T>{$ENDIF};
  PlatformList<T> = public {$IF COOPER}java.util.ArrayList<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.List<T>{$ENDIF};
  {$IFDEF TOFFEE and ISLAND}
  PlatformSequence<T> = public Foundation.INSFastEnumeration;
  {$ELSE}
  PlatformSequence<T> = public sequence of T;
  {$ENDIF}

  IImmutableList<T> = public interface(PlatformSequence<T>)
    method Contains(aItem: T): Boolean;
    method IndexOf(aItem: T): Integer;
    method LastIndexOf(aItem: T): Integer;
    property Item[i: Integer]: T read; default;
    property Count: Integer read;
  end;

  ImmutableList<T> = public class (PlatformSequence<T>, IImmutableList<T>) mapped to PlatformImmutableList<T>
  //{$IFDEF ISLAND AND NOT TOFFEV2}where T is unconstrained;{$ENDIF}
  {$IFDEF ISLAND AND TOFFEV2}where T is NSObject;{$ENDIF}
  {$IFDEF TOFFEE} where T is class;{$ENDIF}
  private
    method GetItem(&Index: Integer): T;

  public
    constructor; mapped to constructor();
    constructor(Items: ImmutableList<T>);
    constructor(Items: sequence of T);
    constructor(params anArray: array of T);

    method Contains(aItem: T): Boolean; inline;
    method Exists(Match: Predicate<T>): Boolean;
    method FindIndex(Match: Predicate<T>): Integer;
    method FindIndex(StartIndex: Integer; Match: Predicate<T>): Integer;
    method FindIndex(StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;

    method Find(Match: Predicate<T>): T;
    method FindAll(Match: Predicate<T>): not nullable sequence of T;
    method TrueForAll(Match: Predicate<T>): Boolean;
    method ForEach(Action: Action<T>);

    method IndexOf(aItem: T): Integer;
    method LastIndexOf(aItem: T): Integer;

    {$IF TOFFEEV2}
    method GetSequence: sequence of T;
    begin
      exit RemObjects.Elements.System.INSFastEnumeration<T>(mapped).GetSequence();
    end;

    operator Implicit(aList: ImmutableList<T>): sequence of T;
    begin
      result := aList.GetSequence;
    end;
    {$ENDIF}

    method ToSortedList(Comparison: Comparison<T>): not nullable ImmutableList<T>;
    {$IFDEF COOPER}
    method ToArray: not nullable array of T; inline;
    {$ELSE}
    method ToArray: not nullable array of T;
    {$ENDIF}
    method ToList<U>: not nullable ImmutableList<U>; {$IF TOFFEE}where U is class;{$ENDIF}

    method UniqueCopy: not nullable ImmutableList<T>;
    method UniqueMutableCopy: not nullable List<T>;
    method MutableVersion: not nullable List<T>;

    method SubList(aStartIndex: Int32): not nullable ImmutableList<T>; inline;
    method SubList(aStartIndex: Int32; aLength: Int32): not nullable ImmutableList<T>; inline;
    //method Partition<K>(aKeyBlock: block (aItem: T): K): ImmutableDictionary<K,ImmutableList<T>>; where K is IEquatable<K>;

    method JoinedString(aSeparator: nullable String := nil): not nullable String;

    //76766: Echoes: Problem with using generic type in property reader
    property FirstObject: not nullable T read self[0];
    property LastObject: not nullable T read self[Count-1];

    property Count: Integer read {$IF COOPER}mapped.Size{$ELSE}mapped.count{$ENDIF}; inline;
    property Item[i: Integer]: T read GetItem; default;
  end;

  ImmutableList_Extensions_Compararable<T> = public extension class (ImmutableList<T>)
    where T is IComparable<T>;
  public
    method ToSortedList: ImmutableList<T>;
    begin
      result := ToSortedList( (a, b) -> a.CompareTo(b) );
    end;
  end;

  IList<T> = public interface (IImmutableList<T>)
    method &Add(aItem: T): T;
    method &Add(params Items: nullable array of T);
    method &Add(Items: nullable sequence of T);

    method &Remove(aItem: T): Boolean;
    method &Remove(aItems: sequence of T);
    method RemoveAll;
    method RemoveAt(aIndex: Integer);
    method RemoveRange(aIndex: Integer; aCount: Integer);
  end;

  List<T> = public class (ImmutableList<T>, IList<T>) mapped to PlatformList<T>
  {$IFDEF TOFFEE}
    where T is class;
  {$ENDIF}
  private
    method GetItem(&Index: Integer): T;
    method SetItem(&Index: Integer; Value: T);

  public

    constructor; mapped to constructor();
    constructor(Items: ImmutableList<T>);
    constructor(Items: sequence of T);
    constructor(params anArray: array of T);
    constructor withCapacity(aCapacity: Integer);
    constructor withRepeatedValue(aValue: T; aCount: Integer);

    method &Add(aItem: T): T; inline;
    {$IF TOFFEEV2}
    method &Add(Items: nullable List<T>); inline; // prevents "ambiguous ovwerload" with Add(sequence of T))
    {$ENDIF}
    method &Add(Items: nullable ImmutableList<T>); inline;
    method &Add(params Items: nullable array of T);
    method &Add(Items: nullable sequence of T); inline;

    method &Remove(aItem: T): Boolean; inline;
    method &Remove(aItems: ImmutableList<T>); inline;
    method &Remove(aItems: sequence of T); inline;
    method RemoveAll; inline;
    method RemoveAt(aIndex: Integer); inline;
    method RemoveRange(aIndex: Integer; aCount: Integer); inline;

    method ReplaceAt(aIndex: Integer; aNewObject: T): T; inline;
    method ReplaceRange(aIndex: Integer; aCount: Integer; aNewObjects: ImmutableList<T>): T;

    method RemoveFirstObject; inline;
    method RemoveLastObject; inline;

    method Insert(&Index: Integer; aItem: T); inline;
    method InsertRange(&Index: Integer; Items: List<T>); inline;
    method InsertRange(&Index: Integer; Items: array of T);

    method Sort(Comparison: Comparison<T>);
    method ToList<U>: not nullable List<U>; {$IF TOFFEE}where U is class;{$ENDIF} reintroduce;

    method SubList(aStartIndex: Int32): not nullable List<T>; reintroduce; inline;
    method SubList(aStartIndex: Int32; aLength: Int32): not nullable List<T>; reintroduce; inline;

    property Item[i: Integer]: T read GetItem write SetItem; default;
  end;

  ImmutableListProxy<T> = public class
  end;

  Predicate<T> = public block (Obj: T): Boolean;
  Action<T> = public block (Obj: T);
  Comparison<T> = public block (x: T; y: T): Integer;

  {$IF TOFFEE}
  NullHelper = public static class
  public
    //77623: Coalesce fails with generic types
    method coalesce(a: id; b: id): id;
    begin
      if assigned(a) then
        result := a
      else
        result := b;
    end;

  end;
  {$ENDIF}

  ListHelpers = assembly static class
  public
    method AddRange<T>(aSelf: List<T>; aArr: array of T);
    method FindIndex<T>(aSelf: ImmutableList<T>;StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;
    method Find<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): T;
    method ForEach<T>(aSelf: ImmutableList<T>;Action: Action<T>);
    method TrueForAll<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): Boolean;
    method FindAll<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): not nullable sequence of T; iterator;
    method InsertRange<T>(aSelf: List<T>; &Index: Integer; Items: array oF T);
    {$IFDEF TOFFEE}
    method LastIndexOf<T>(aSelf: NSArray; aItem: T): Integer;
    method ToArray<T>(aSelf: NSArray): not nullable array of T;
    method ToArrayReverse<T>(aSelf: NSArray): not nullable array of T;
    {$ENDIF}
    {$IFDEF COOPER}
    method ToArrayReverse<T>(aSelf: java.util.Vector<T>; aDest: not nullable array of T): not nullable array of T;
    {$ENDIF}
  end;

implementation

constructor ImmutableList<T>(Items: ImmutableList<T>);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(Items);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSArray withArray(Items);
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.List<T>(Items);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.List<T>(Items);
  {$ENDIF}
end;

constructor ImmutableList<T>(Items: sequence of T);
begin
  result := coalesce(Items:ToList, new ImmutableList<T>);
end;

constructor ImmutableList<T>(params anArray: array of T);
begin
  {$IF COOPER}
  result := new PlatformImmutableList<T>(java.util.Arrays.asList(anArray));
  {$ELSEIF TOFFEE}
  result := Foundation.NSArray.arrayWithObjects(^id(@anArray[0])) count(length(anArray));
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.List<T>(anArray);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.List<T>(anArray);
  {$ENDIF}
end;

constructor List<T>(Items: ImmutableList<T>);
begin
  {$IF COOPER}
  result := new PlatformImmutableList<T>(Items);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSMutableArray<T> withArray(Items);
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.List<T>(Items);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.List<T>(Items);
  {$ENDIF}
end;

constructor List<T>(Items: sequence of T);
begin
  result := coalesce(Items:ToList, new List<T>);
end;

constructor List<T>(params anArray: array of T);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(java.util.Arrays.asList(anArray));
  {$ELSEIF TOFFEE}
  result := Foundation.NSMutableArray<T>.arrayWithObjects(^T(@anArray[0])) count(length(anArray)) as List<T>;
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(anArray);
  {$ELSEIF ISLAND}
  exit new RemObjects.Elements.System.List<T>(anArray);
  {$ENDIF}
end;

constructor List<T> withCapacity(aCapacity: Integer);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(aCapacity);
  {$ELSEIF TOFFEE}
  result := Foundation.NSMutableArray.arrayWithCapacity(aCapacity)
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(aCapacity);
  {$ELSEIF ISLAND}
  exit new RemObjects.Elements.System.List<T>(aCapacity);
  {$ENDIF}
end;

constructor List<T> withRepeatedValue(aValue: T; aCount: Integer);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(aCount);
  {$ELSEIF TOFFEE}
  result := Foundation.NSMutableArray.arrayWithCapacity(aCount);
  {$ELSEIF ECHOES}
  result := new System.Collections.Generic.List<T>(aCount);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.List<T>(aCount);
  {$ENDIF}
  for i: Integer := 0 to aCount-1 do
    result.Add(aValue);
end;

method List<T>.Add(aItem: T): T;
begin
  {$IF NOT TOFFEE}
  mapped.Add(aItem);
  {$ELSE}
  Foundation.NSMutableArray(mapped).addObject(NullHelper.coalesce(aItem, NSNull.null));
  {$ENDIF}
  result := aItem;
end;

method List<T>.SetItem(&Index: Integer; Value: T);
begin
  {$IF TOFFEE}
  Foundation.NSMutableArray(mapped)[&Index] := NullHelper.coalesce(Value, NSNull.null);
  {$ELSE}
  mapped[&Index] := Value;
  {$ENDIF}
end;

method ImmutableList<T>.GetItem(&Index: Integer): T;
begin
  {$IF TOFFEE}
  var lResult := Foundation.NSArray(mapped).objectAtIndex(&Index);
  if lResult = NSNull.null then exit nil;
  result := lResult;
  {$ELSE}
  exit mapped[&Index];
  {$ENDIF}
end;

method List<T>.GetItem(&Index: Integer): T;
begin
  {$IF TOFFEE}
  var lResult := Foundation.NSArray(mapped).objectAtIndex(&Index);
  if lResult = NSNull.null then exit nil;
  result := T(lResult);
  {$ELSE}
  exit mapped[&Index];
  {$ENDIF}
end;

{$IF TOFFEEV2}
method List<T>.Add(Items: nullable List<T>);
begin
  if assigned(Items) then
    mapped.addObjectsFromArray(Items);
end;
{$ENDIF}

method List<T>.Add(Items: nullable ImmutableList<T>);
begin
  if assigned(Items) then begin
    {$IF COOPER}
    mapped.AddAll(Items);
    {$ELSEIF TOFFEE}
    mapped.addObjectsFromArray(Items);
    {$ELSEIF ECHOES OR ISLAND}
    mapped.AddRange(Items);
    {$ENDIF}
  end;
end;

method List<T>.Add(Items: nullable sequence of T);
begin
  if assigned(Items) then begin
    {$IF COOPER}
    mapped.AddAll(Items.ToList());
    {$ELSEIF TOFFEE}
    mapped.addObjectsFromArray(Items.array());
    {$ELSEIF ECHOES}
    mapped.AddRange(Items);
    {$ELSEIF ISLAND}
    mapped.AddRange(Items.ToList());
    {$ENDIF}
  end;
end;

method List<T>.Add(params Items: nullable array of T);
begin
  if assigned(Items) then
    ListHelpers.AddRange(self, Items);
end;

method List<T>.RemoveAll;
begin
  {$IF COOPER}
  mapped.Clear;
  {$ELSEIF TOFFEE}
  mapped.RemoveAllObjects;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Clear;
  {$ENDIF}
end;

method ImmutableList<T>.Contains(aItem: T): Boolean;
begin
  {$IF COOPER}
  exit mapped.Contains(aItem);
  {$ELSEIF TOFFEE}
  exit Foundation.NSArray(mapped).ContainsObject(NullHelper.coalesce(aItem, NSNull.null));
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Contains(aItem);
  {$ENDIF}
end;

method ImmutableList<T>.Exists(Match: Predicate<T>): Boolean;
begin
  exit self.FindIndex(Match) <> -1;
end;

method ImmutableList<T>.FindIndex(Match: Predicate<T>): Integer;
begin
  exit self.FindIndex(0, Count, Match);
end;

method ImmutableList<T>.FindIndex(StartIndex: Integer; Match: Predicate<T>): Integer;
begin
  exit self.FindIndex(StartIndex, Count - StartIndex, Match);
end;

method ImmutableList<T>.FindIndex(StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;
begin
  exit ListHelpers.FindIndex(self, StartIndex, aCount, Match);
end;

method ImmutableList<T>.Find(Match: Predicate<T>): T;
begin
  exit ListHelpers.Find(self, Match);
end;

method ImmutableList<T>.FindAll(Match: Predicate<T>): not nullable sequence of T;
begin
  exit ListHelpers.FindAll(self, Match);
end;

method ImmutableList<T>.TrueForAll(Match: Predicate<T>): Boolean;
begin
  exit ListHelpers.TrueForAll(self, Match);
end;

method ImmutableList<T>.ForEach(Action: Action<T>);
begin
  ListHelpers.ForEach(self, Action);
end;

method ImmutableList<T>.IndexOf(aItem: T): Integer;
begin
  {$IF COOPER}
  exit mapped.IndexOf(aItem);
  {$ELSEIF TOFFEE}
  var lIndex := Foundation.NSArray(mapped).indexOfObject(NullHelper.coalesce(aItem, NSNull.null));
  exit if lIndex = NSNotFound then -1 else Integer(lIndex);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.IndexOf(aItem);
  {$ENDIF}
end;

method List<T>.Insert(&Index: Integer; aItem: T);
begin
  {$IF COOPER}
  mapped.Add(&Index, aItem);
  {$ELSEIF TOFFEE}
  Foundation.NSMutableArray(mapped).insertObject(NullHelper.coalesce(aItem, NSNull.null)) atIndex(&Index);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Insert(&Index, aItem);
  {$ENDIF}
end;

method List<T>.InsertRange(&Index: Integer; Items: List<T>);
begin
  {$IF COOPER}
  mapped.AddAll(&Index, Items);
  {$ELSEIF TOFFEE}
  mapped.insertObjects(Items) atIndexes(new NSIndexSet withIndexesInRange(NSMakeRange(&Index, Items.Count)));
  {$ELSEIF ECHOES OR ISLAND}
  mapped.InsertRange(&Index, Items);
  {$ENDIF}
end;

method List<T>.InsertRange(&Index: Integer; Items: array of T);
begin
  ListHelpers.InsertRange(self, &Index, Items);
end;

method ImmutableList<T>.LastIndexOf(aItem: T): Integer;
begin
  {$IF COOPER}
  exit mapped.LastIndexOf(aItem);
  {$ELSEIF TOFFEE}
  exit ListHelpers.LastIndexOf(self, aItem);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.LastIndexOf(aItem);
  {$ENDIF}
end;

method List<T>.Remove(aItem: T): Boolean;
begin
  if not assigned(aItem) then
    exit false;
  {$IF COOPER}
  exit mapped.Remove(Object(aItem));
  {$ELSEIF TOFFEE}
  var lIndex := Foundation.NSMutableArray(mapped).indexOfObject(NullHelper.coalesce(aItem, NSNull.null));
  if lIndex = NSNotFound then
    exit false;
  RemoveAt(lIndex);
  exit true;
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(aItem);
  {$ENDIF}
end;

method List<T>.RemoveAt(aIndex: Integer);
begin
  {$IF COOPER}
  mapped.remove(aIndex);
  {$ELSEIF TOFFEE}
  mapped.removeObjectAtIndex(aIndex);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.RemoveAt(aIndex);
  {$ENDIF}
end;

method List<T>.Remove(aItems: ImmutableList<T>);
begin
  {$IF NOT TOFFEE}
  for each i in aItems do
    &Remove(i);
  {$ELSE}
  mapped.removeObjectsInArray(aItems);
  {$ENDIF}
end;

method List<T>.Remove(aItems: sequence of T);
begin
  for each i in aItems do
    &Remove(i);
end;

method List<T>.RemoveRange(aIndex: Integer; aCount: Integer);
begin
  {$IF COOPER}
  mapped.subList(aIndex, aIndex+aCount).clear;
  {$ELSEIF TOFFEE}
  mapped.removeObjectsInRange(Foundation.NSMakeRange(aIndex, aCount));
  {$ELSEIF ECHOES OR ISLAND}
  mapped.RemoveRange(aIndex, aCount);
  {$ENDIF}
end;

method List<T>.ReplaceAt(aIndex: Integer; aNewObject: T): T;
begin
  result := self[aIndex];
  self[aIndex] := aNewObject;
end;

method List<T>.ReplaceRange(aIndex: Integer; aCount: Integer; aNewObjects: ImmutableList<T>): T;
begin
  {$IF COOPER}
  mapped.subList(aIndex, aIndex+aCount).clear();
  mapped.addAll(aIndex, aNewObjects);
  {$ELSEIF TOFFEE}
  var range := NSMakeRange(aIndex, aCount);
  mapped.replaceObjectsInRange(range) withObjectsFromArray(aNewObjects);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.RemoveRange(aIndex, aCount);
  mapped.InsertRange(aIndex, aNewObjects);
  {$ENDIF}
end;

method List<T>.Sort(Comparison: Comparison<T>);
begin
  {$IF COOPER}
  java.util.Collections.sort(mapped, new class java.util.Comparator<T>(compare := (x, y) -> Comparison(x, y)));
  {$ELSEIF TOFFEE}
  mapped.sortUsingComparator((x, y) -> begin
    var lResult := Comparison(x, y);
    exit if lResult < 0 then
           NSComparisonResult.NSOrderedAscending
         else if lResult = 0 then
           NSComparisonResult.NSOrderedSame
         else
           NSComparisonResult.NSOrderedDescending;
  end);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Sort((x, y) -> Comparison(x, y));
  {$ENDIF}
end;

method ImmutableList<T>.ToSortedList(Comparison: Comparison<T>): not nullable ImmutableList<T>;
begin
  {$IF COOPER}
  result := self.ToList() as not nullable;
  java.util.Collections.sort(result, new class java.util.Comparator<T>(compare := (x, y) -> Comparison(x, y)));
  {$ELSEIF TOFFEE}
  result := mapped.sortedArrayUsingComparator((x, y) -> begin
    var lResult := Comparison(x, y);
    exit if lResult < 0 then
           NSComparisonResult.NSOrderedAscending
         else if lResult = 0 then
           NSComparisonResult.NSOrderedSame
         else
           NSComparisonResult.NSOrderedDescending;
  end) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  result := self.ToList() as not nullable;
  (result as PlatformList<T>).Sort((x, y) -> Comparison(x, y));
  {$ENDIF}
end;

{$IFDEF COOPER}
method ImmutableList<T>.ToArray: not nullable array of T;
begin
  exit mapped.toArray(new T[mapped.size()]) as not nullable;
end;
{$ELSE}
method ImmutableList<T>.ToArray: not nullable array of T;
begin
  {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
  exit mapped.ToArray as not nullable;
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArray<T>(self);
  {$ENDIF}
end;
{$ENDIF}

method ImmutableList<T>.ToList<U>: not nullable ImmutableList<U>;
begin
  {$IF NOT TOFFEE}
  var lResult := new List<U> withCapacity(Count);
  for each i in self do
    lResult.Add(i as U);
  result := lResult;
  {$ELSE}
  result :=  self as ImmutableList<U>;
  {$ENDIF}
end;

method List<T>.ToList<U>: not nullable List<U>;
begin
  {$IF NOT TOFFEE}
  result := new List<U> withCapacity(Count);
  for each i in self do
    result.Add(i as U);
  //result := self.Select(x -> x as U).ToList(); {$HINT largely inefficient. rewrite}
  {$ELSE}
  result := self as Object as List<U>;
  {$ENDIF}
end;

method ImmutableList<T>.SubList(aStartIndex: Int32): not nullable ImmutableList<T>;
begin
  result := SubList(aStartIndex, Count-aStartIndex);
end;

method ImmutableList<T>.SubList(aStartIndex: Int32; aLength: Int32): not nullable ImmutableList<T>;
begin
  {$IF COOPER}
  result := mapped.subList(aStartIndex, aStartIndex+aLength).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.subarrayWithRange(NSMakeRange(aStartIndex, aLength)) as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  var lArray := new T[aLength];
  mapped.CopyTo(aStartIndex, lArray, 0, aLength);
  result := new List<T>(lArray);
  {$ENDIF}
end;

method List<T>.SubList(aStartIndex: Int32): not nullable List<T>;
begin
  result := SubList(aStartIndex, Count-aStartIndex);
end;

method List<T>.SubList(aStartIndex: Int32; aLength: Int32): not nullable List<T>;
begin
  {$IF COOPER}
  result := mapped.subList(aStartIndex, aStartIndex+aLength).ToList() as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.subarrayWithRange(NSMakeRange(aStartIndex, aLength)).mutableCopy as not nullable;
  {$ELSEIF ECHOES OR ISLAND}
  var lArray := new T[aLength];
  mapped.CopyTo(aStartIndex, lArray, 0, aLength);
  result := new List<T>(lArray);
  {$ENDIF}
end;

method ImmutableList<T>.UniqueCopy: not nullable ImmutableList<T>;
begin
  {$IF NOT TOFFEE}
  result := new ImmutableList<T>(self);
  {$ELSE}
  result := mapped.copy as NSArray<T>;
  {$ENDIF}
end;

method ImmutableList<T>.UniqueMutableCopy: not nullable List<T>;
begin
  {$IF NOT TOFFEE}
  result := new List<T>(self);
  {$ELSE}
  result := mapped.mutableCopy as not nullable;
  {$ENDIF}
end;

method ImmutableList<T>.MutableVersion: not nullable List<T>;
begin
  {$IF TOFFEE}
  result := coalesce(NSMutableArray<T>(self), mapped.mutableCopy) as not nullable;
  {$ELSEIF ISLAND}
  result := coalesce(List<T>(self), new List<T>(self)) as not nullable;
  {$ELSE}
  result := List<T>(self);
  {$ENDIF}
end;

method ImmutableList<T>.JoinedString(aSeparator: nullable String := nil): not nullable String;
begin
  {$IF NOT TOFFEE}
  var lResult := new StringBuilder();
  for each e in self index i do begin
    if (i ≠ 0) and assigned(aSeparator) then
      lResult.Append(aSeparator);
      {$IF ISLAND}
      case modelOf(T) of
        "Island": lResult.Append((e as IslandObject):ToString());
        "Cocoa": {$IF DARWIN}lResult.Append((e as CocoaObject):description());{$ENDIF}
        "Swift": {$IF DARWIN}lResult.Append((e as SwiftObject):ToString());{$ENDIF}
        "Delphi": raise new Exception($"This feature is not supported for Delphi Objects (yet)");
        "COM": raise new Exception($"This feature is not supported for COM Objects");
        "JNI": raise new Exception($"This feature is not supported for JNI Objects");
        else raise new Exception($"Unexpected object model {modelOf(T)}");
      end;
      {$ELSE}
      lResult.Append(e:ToString());
      {$ENDIF}
  end;
  result := lResult.ToString() as not nullable;
  {$ELSEIF TOFFEE}
  result := mapped.componentsJoinedByString(aSeparator) as not nullable;
  {$ENDIF}
end;

method List<T>.RemoveFirstObject;
begin
  if Count > 0 then RemoveAt(0);
end;

method List<T>.RemoveLastObject;
begin
  if Count > 0 then RemoveAt(Count-1);
end;

/*method ImmutableList<T>.Partition<K>(aKeyBlock: block (aItem: T): K): ImmutableDictionary<K,ImmutableList<T>>;
begin
  result := new Dictionary<K,ImmutableList<T>>();
  var items := OrderBy(aKeyBlock);
  var currentKey: K := nil;
  var currentItems: List<T> := nil;
  //var count := items.count();
  for each i in Items do begin
    var lKey := aKeyBlock(i);
    if lKey ≠ currentKey then begin
      currentKey := lKey;
      currentItems := new List<T>();
      (result as Dictionary<K,T>)[lKey] := currentItems;
    end;
    currentItems.Add(i);
  end;
end;*/

{ NullHelper }

{$IF TOFFEE}
/*class method NullHelper.ValueOf(aValue: nullable id): nullable id;
begin
  exit if aValue = NSNull.null then nil else if aValue = nil then NSNull.null else aValue;
end;

class method NullHelper.WrapNil(aValue: nullable id): not nullable id;
begin
  if aValue = nil then
    result := NSNull.null
  else
    result := aValue;
end;

class method NullHelper.UnWrapNSNull(aValue: not nullable id): nullable id;
begin
  if aValue ≠ NSNull.null then result := aValue;
  // implied: else result := nil
end;*/
{$ENDIF}

{ ListHelpers }

method ListHelpers.AddRange<T>(aSelf: List<T>; aArr: array of T);
begin
  for i: Integer := 0 to length(aArr) - 1 do
    aSelf.Add(aArr[i]);
end;

method ListHelpers.FindIndex<T>(aSelf: ImmutableList<T>; StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;
begin
  if StartIndex > aSelf.Count then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "StartIndex");

  if (aCount < 0) or (StartIndex > aSelf.Count - aCount) then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "Count");

  if Match = nil then
    raise new ArgumentNullException("Match");

  var Length := StartIndex + aCount;

  for i: Int32 := StartIndex to Length - 1 do
    if Match(aSelf[i]) then
      exit i;

  exit -1;
end;

method ListHelpers.Find<T>(aSelf: ImmutableList<T>; Match: Predicate<T>): T;
begin
  if Match = nil then
    raise new ArgumentNullException("Match");

  for i: Integer := 0 to aSelf.Count-1 do begin
    if Match(aSelf[i]) then
      exit aSelf[i];
  end;

  exit &default(T);
end;

method ListHelpers.FindAll<T>(aSelf: ImmutableList<T>; Match: Predicate<T>): not nullable sequence of T;
begin
  if Match = nil then
    raise new ArgumentNullException("Match");

  for i: Integer := 0 to aSelf.Count-1 do begin
    if Match(aSelf[i]) then
      yield aSelf[i];
  end;
end;

method ListHelpers.TrueForAll<T>(aSelf: ImmutableList<T>; Match: Predicate<T>): Boolean;
begin
  if Match = nil then
    raise new ArgumentNullException("Match");

  for i: Integer := 0 to aSelf.Count-1 do begin
    if not Match(aSelf[i]) then
      exit false;
  end;

  exit true;
end;

method ListHelpers.ForEach<T>(aSelf: ImmutableList<T>; Action: Action<T>);
begin
  if Action = nil then
    raise new ArgumentNullException("Action");

  for i: Integer := 0 to aSelf.Count-1 do
    Action(aSelf[i]);
end;

method ListHelpers.InsertRange<T>(aSelf: List<T>; &Index: Integer; Items: array oF T);
begin

  for i: Integer := length(Items) - 1 downto 0 do
    aSelf.Insert(&Index, Items[i]);
end;

{$IFDEF TOFFEE}

method ListHelpers.LastIndexOf<T>(aSelf: NSArray; aItem: T): Integer;
begin
  var o := NullHelper.coalesce(aItem, NSNull.null);
  for i: Integer := aSelf.count -1 downto 0 do
    if aSelf[i] = o then exit i;
  exit -1;
end;

method ListHelpers.ToArray<T>(aSelf: NSArray): not nullable array of T;
begin
  result := new T[aSelf.count];
  for i: Integer := 0 to aSelf.count - 1 do
    result[i] := T(aSelf[i]);
end;

method ListHelpers.ToArrayReverse<T>(aSelf: NSArray): not nullable array of T;
begin
  result := new T[aSelf.count];
  for i: Integer := aSelf.count - 1 downto 0 do begin
    var lValue := aSelf.objectAtIndex(i);
    if lValue = NSNull.null then
      lValue := nil;
    result[aSelf.count - i - 1] := T(lValue);
  end;
end;

{$ENDIF}
{$IFDEF COOPER}
method ListHelpers.ToArrayReverse<T>(aSelf: java.util.Vector<T>; aDest: not nullable array of T): not nullable array of T;
begin
  result := aDest;
  for i: Integer := aSelf.size - 1 downto 0 do
    result[aSelf.size - i - 1] := aSelf[i];
end;
{$ENDIF}

end.