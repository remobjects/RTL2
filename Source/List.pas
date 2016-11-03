namespace Elements.RTL;

interface

type
  PlatformImmutableList<T> = public {$IF COOPER}java.util.ArrayList<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.List<T>{$ELSEIF TOFFEE}Foundation.NSArray;{$ENDIF};
  PlatformList<T> = public {$IF COOPER}java.util.ArrayList<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.List<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray;{$ENDIF};

  ImmutableList<T> = public class (sequence of T) mapped to {$IF COOPER}java.util.ArrayList<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.List<T>{$ELSEIF TOFFEE}Foundation.NSArray where T is class;{$ENDIF}
  private
    method GetItem(&Index: Integer): T;
    
  public

    constructor; mapped to constructor();
    constructor(Items: List<T>);
    constructor(anArray: array of T);

    method Contains(aItem: T): Boolean;
    method Exists(Match: Predicate<T>): Boolean;
    method FindIndex(Match: Predicate<T>): Integer;
    method FindIndex(StartIndex: Integer; Match: Predicate<T>): Integer;
    method FindIndex(StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;

    method Find(Match: Predicate<T>): T;
    method FindAll(Match: Predicate<T>): sequence of T;
    method TrueForAll(Match: Predicate<T>): Boolean;
    method ForEach(Action: Action<T>);

    method IndexOf(aItem: T): Integer; 
    method LastIndexOf(aItem: T): Integer;

    method ToSortedList(Comparison: Comparison<T>): ImmutableList<T>; 
    method ToArray: array of T; {$IF COOPER}inline;{$ENDIF}
    method ToList<U>: ImmutableList<U>; {$IF TOFFEE}where U is class;{$ENDIF}
    
    property Count: Integer read {$IF COOPER}mapped.Size{$ELSE}mapped.count{$ENDIF};
    property Item[i: Integer]: T read GetItem; default;
  end;

  List<T> = public class (ImmutableList<T>, sequence of T) mapped to {$IF COOPER}java.util.ArrayList<T>{$ELSEIF ECHOES}System.Collections.Generic.List<T>{$ELSEIF ISLAND}RemObjects.Elements.System.List<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray where T is class;{$ENDIF}
  private
    method GetItem(&Index: Integer): T;
    method SetItem(&Index: Integer; Value: T);

  public
    
    constructor; mapped to constructor();
    constructor(Items: List<T>);
    constructor(anArray: array of T);

    method &Add(aItem: T);
    method &Add(Items: List<T>);
    method &Add(Items: array of T);
    method Add(Items: sequence of T);

    method &Remove(aItem: T): Boolean;
    method &Remove(aItems: List<T>);
    method &Remove(aItems: sequence of T);
    method RemoveAll;
    method RemoveAt(aIndex: Integer);
    method RemoveRange(aIndex: Integer; aCount: Integer);

    method Insert(&Index: Integer; aItem: T);
    method InsertRange(&Index: Integer; Items: List<T>);
    method InsertRange(&Index: Integer; Items: array of T);

    method Sort(Comparison: Comparison<T>);
    method ToList<U>: List<U>; {$IF TOFFEE}where U is class;{$ENDIF}

    property Item[i: Integer]: T read GetItem write SetItem; default;

    {$IF TOFFEE}
    operator Implicit(aArray: NSArray<T>): List<T>;
    {$ENDIF}
  end;
  
  ImmutableListProxy<T> = public class
  end;
  
  Predicate<T> = public block (Obj: T): Boolean;
  Action<T> = public block (Obj: T);
  Comparison<T> = public block (x: T; y: T): Integer;

  {$IF TOFFEE}
  NullHelper = public static class
  public
    method ValueOf(Value: id): id;
  end;
  {$ENDIF}

  ListHelpers = assembly static class
  public
    method AddRange<T>(aSelf: List<T>; aArr: array of T);
    method FindIndex<T>(aSelf: ImmutableList<T>;StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;
    method Find<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): T;
    method ForEach<T>(aSelf: ImmutableList<T>;Action: Action<T>);
    method TrueForAll<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): Boolean;
    method FindAll<T>(aSelf: ImmutableList<T>;Match: Predicate<T>): sequence of T; iterator;
    method InsertRange<T>(aSelf: List<T>; &Index: Integer; Items: array oF T);
    {$IFDEF TOFFEE}
    method LastIndexOf<T>(aSelf: NSArray; aItem: T): Integer;
    method ToArray<T>(aSelf: NSArray): array of T;
    method ToArrayReverse<T>(aSelf: NSArray): array of T;
    {$ENDIF}
    {$IFDEF COOPER}
    method ToArrayReverse<T>(aSelf: java.util.Vector<T>; aDest: array of T): array of T;
    {$ENDIF}
  end;

implementation

constructor ImmutableList<T>(Items: List<T>);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(Items);
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(Items);
  {$ELSEIF ISLAND}
  exit new RemObjects.Elements.System.List<T>(Items);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSArray withArray(Items);
  {$ENDIF}
end;

constructor ImmutableList<T>(anArray: array of T);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(java.util.Arrays.asList(anArray));
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(anArray);
  {$ELSEIF TOFFEE}
  result := Foundation.NSArray.arrayWithObjects(^id(@anArray[0])) count(length(anArray));
  {$ENDIF}
end;

constructor List<T>(Items: List<T>);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(Items);
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(Items);
  {$ELSEIF ISLAND}
  exit new RemObjects.Elements.System.List<T>(Items);
  {$ELSEIF TOFFEE}
  result := new Foundation.NSMutableArray withArray(Items);
  {$ENDIF}
end;

constructor List<T>(anArray: array of T);
begin
  {$IF COOPER}
  result := new java.util.ArrayList<T>(java.util.Arrays.asList(anArray));
  {$ELSEIF ECHOES}
  exit new System.Collections.Generic.List<T>(anArray);
  {$ELSEIF TOFFEE}
  result := Foundation.NSMutableArray.arrayWithObjects(^id(@anArray[0])) count(length(anArray));
  {$ENDIF}
end;

method List<T>.Add(aItem: T);
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  mapped.Add(aItem);
  {$ELSEIF TOFFEE}
  mapped.addObject(NullHelper.ValueOf(aItem));
  {$ENDIF}
end;

method List<T>.SetItem(&Index: Integer; Value: T);
begin
  {$IF TOFFEE}
  mapped[&Index] := NullHelper.ValueOf(Value);
  {$ELSE}  
  mapped[&Index] := Value;
  {$ENDIF}
end;

method ImmutableList<T>.GetItem(&Index: Integer): T;
begin
  {$IF TOFFEE}
  exit NullHelper.ValueOf(mapped.objectAtIndex(&Index));
  {$ELSE}  
  exit mapped[&Index];
  {$ENDIF}
end;

method List<T>.GetItem(&Index: Integer): T;
begin
  {$IF TOFFEE}
  exit NullHelper.ValueOf(mapped.objectAtIndex(&Index));
  {$ELSE}  
  exit mapped[&Index];
  {$ENDIF}
end;

method List<T>.Add(Items: List<T>);
begin
  {$IF COOPER}
  mapped.AddAll(Items);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.AddRange(Items);
  {$ELSEIF TOFFEE}
  mapped.addObjectsFromArray(Items);
  {$ENDIF}
end;

method List<T>.Add(Items: sequence of T);
begin
  {$IF COOPER}
  mapped.AddAll(Items.ToList());
  {$ELSEIF ECHOES}
  mapped.AddRange(Items);
  {$ELSEIF ISLAND}
  mapped.AddRange(Items.ToList());
  {$ELSEIF TOFFEE}
  mapped.addObjectsFromArray(Items.array());
  {$ENDIF}
end;

method List<T>.Add(Items: array of T);
begin
  ListHelpers.AddRange(self, Items);
end;

method List<T>.RemoveAll;
begin
  {$IF COOPER}
  mapped.Clear;
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Clear;
  {$ELSEIF TOFFEE}
  mapped.RemoveAllObjects;
  {$ENDIF}
end;

method ImmutableList<T>.Contains(aItem: T): Boolean;
begin
  {$IF COOPER}
  exit mapped.Contains(aItem);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Contains(aItem);
  {$ELSEIF TOFFEE}
  exit mapped.ContainsObject(NullHelper.ValueOf(aItem));
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

method ImmutableList<T>.FindAll(Match: Predicate<T>): sequence of T;
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
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.IndexOf(aItem);
  {$ELSEIF TOFFEE}
  var lIndex := mapped.indexOfObject(NullHelper.ValueOf(aItem));
  exit if lIndex = NSNotFound then -1 else Integer(lIndex);
  {$ENDIF}
end;

method List<T>.Insert(&Index: Integer; aItem: T);
begin
  {$IF COOPER}
  mapped.Add(&Index, aItem);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Insert(&Index, aItem);
  {$ELSEIF TOFFEE}
  mapped.insertObject(NullHelper.ValueOf(aItem)) atIndex(&Index);
  {$ENDIF}
end;

method List<T>.InsertRange(&Index: Integer; Items: List<T>);
begin
  {$IF COOPER}
  mapped.AddAll(&Index, Items);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.InsertRange(&Index, Items);
  {$ELSEIF TOFFEE}
  mapped.insertObjects(Items) atIndexes(new NSIndexSet withIndexesInRange(NSMakeRange(&Index, Items.Count)));
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
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.LastIndexOf(aItem);
  {$ELSEIF TOFFEE}
  exit ListHelpers.LastIndexOf(self, aItem);
  {$ENDIF}
end;

method List<T>.Remove(aItem: T): Boolean;
begin
  {$IF COOPER}
  exit mapped.Remove(Object(aItem));
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Remove(aItem);
  {$ELSEIF TOFFEE}
  var lIndex := mapped.indexOfObject(NullHelper.ValueOf(aItem));
  if lIndex = NSNotFound then
    exit false;
  RemoveAt(lIndex);
  exit true;
  {$ENDIF}
end;

method List<T>.RemoveAt(aIndex: Integer);
begin
  {$IF COOPER}
  mapped.remove(aIndex);
  {$ELSEIF ECHOES OR ISLAND}
  mapped.RemoveAt(aIndex);
  {$ELSEIF TOFFEE}
  mapped.removeObjectAtIndex(aIndex);
  {$ENDIF}
end;

method List<T>.Remove(aItems: List<T>);
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  for each i in aItems do
    &Remove(i);
  {$ELSEIF TOFFEE}
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
  {$ELSEIF ECHOES OR ISLAND}
  mapped.RemoveRange(aIndex, aCount);
  {$ELSEIF TOFFEE}
  mapped.removeObjectsInRange(Foundation.NSMakeRange(aIndex, aCount));
  {$ENDIF}
end;

method List<T>.Sort(Comparison: Comparison<T>);
begin
  {$IF COOPER}  
  java.util.Collections.sort(mapped, new class java.util.Comparator<T>(compare := (x, y) -> Comparison(x, y)));
  {$ELSEIF ECHOES OR ISLAND} 
  mapped.Sort((x, y) -> Comparison(x, y));
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
  {$ENDIF}
end;

method ImmutableList<T>.ToSortedList(Comparison: Comparison<T>): ImmutableList<T>;
begin
  {$IF COOPER}  
  result := self.ToList();
  java.util.Collections.sort(result, new class java.util.Comparator<T>(compare := (x, y) -> Comparison(x, y)));
  {$ELSEIF ECHOES OR ISLAND}
  result := self.ToList();
  (result as PlatformList<T>).Sort((x, y) -> Comparison(x, y));
  {$ELSEIF TOFFEE}
  mapped.sortedArrayUsingComparator((x, y) -> begin
    var lResult := Comparison(x, y);
    exit if lResult < 0 then
           NSComparisonResult.NSOrderedAscending
         else if lResult = 0 then
           NSComparisonResult.NSOrderedSame
         else
           NSComparisonResult.NSOrderedDescending;
  end);
  {$ENDIF}
end;

method ImmutableList<T>.ToArray: array of T;
begin
  {$IF COOPER}
  exit mapped.toArray(new T[mapped.size()]); 
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToArray;
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArray<T>(self);
  {$ENDIF}
end;

method ImmutableList<T>.ToList<U>: ImmutableList<U>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  self.Select(x -> x as U).ToList();
  {$ELSEIF TOFFEE}
  exit self as ImmutableList<U>;
  {$ENDIF}
end;

method List<T>.ToList<U>: List<U>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  self.Select(x -> x as U).ToList();
  {$ELSEIF TOFFEE}
  exit self as List<U>;
  {$ENDIF}
end;


{$IF TOFFEE}
operator List<T>.Implicit(aArray: NSArray<T>): List<T>;
begin
  if aArray is NSMutableArray then
    result := List<T>(aArray)
  else
    result := List<T>(aArray:mutableCopy);
end;
{$ENDIF}

{ NullHelper }

{$IF TOFFEE}
class method NullHelper.ValueOf(Value: id): id;
begin
  exit if Value = NSNull.null then nil else if Value = nil then NSNull.null else Value;
end;
{$ENDIF}

{ ListHelpers }

method ListHelpers.AddRange<T>(aSelf: List<T>; aArr: array of T);
begin
  for i: Integer := 0 to length(aArr) - 1 do
    aSelf.Add(aArr[i]);
end;

method ListHelpers.FindIndex<T>(aSelf: ImmutableList<T>;StartIndex: Integer; aCount: Integer; Match: Predicate<T>): Integer;
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

method ListHelpers.FindAll<T>(aSelf: ImmutableList<T>; Match: Predicate<T>): sequence of T;
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
  var o := NullHelper.ValueOf(aItem);
  for i: Integer := aSelf.count -1 downto 0 do 
    if aSelf[i] = o then exit i;
  exit -1;
end;

method ListHelpers.ToArray<T>(aSelf: NSArray): array of T;
begin
  result := new T[aSelf.count];
  for i: Integer := 0 to aSelf.count - 1 do
    result[i] := aSelf[i];
end;

method ListHelpers.ToArrayReverse<T>(aSelf: NSArray): array of T;
begin
  result := new T[aSelf.count];
  for i: Integer := aSelf.count - 1 downto 0 do
    result[aSelf.count - i - 1] := NullHelper.ValueOf(aSelf.objectAtIndex(i));

end;

{$ENDIF}
{$IFDEF COOPER}
method ListHelpers.ToArrayReverse<T>(aSelf: java.util.Vector<T>; aDest: array of T): array of T;
begin
  result := aDest;
  for i: Integer := aSelf.size - 1 downto 0 do
    result[aSelf.size - i - 1] := aSelf[i];

end;
{$ENDIF}

end.
