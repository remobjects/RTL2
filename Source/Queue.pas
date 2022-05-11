namespace RemObjects.Elements.RTL;

interface

type
  PlatformImmutableQueue<T> = public {$IF COOPER}java.util.LinkedList<T>{$ELSEIF ECHOES}System.Collections.Generic.Queue<T>{$ELSEIF TOFFEE}Foundation.NSArray<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Queue<T>{$ENDIF};
  PlatformQueue<T> = public {$IF COOPER}java.util.LinkedList<T>{$ELSEIF ECHOES}System.Collections.Generic.Queue<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Queue<T>{$ENDIF};

  IImmutableQueue<T> = public interface
    method Contains(Item: T): Boolean;
    method Peek: T;
    method ToArray: array of T;
    property Count: Integer read;
  end;

  ImmutableQueue<T> = public class(IImmutableQueue<T>) mapped to PlatformImmutableQueue<T>
  {$IFDEF ISLAND AND NOT TOFFEEV2}where T is unconstrained;{$ENDIF}
  {$IFDEF ISLAND AND TOFFEV2}where T is NSObject;{$ENDIF}
  {$IFDEF TOFFEE} where T is class;{$ENDIF}
  public
    constructor; mapped to constructor();

    method Contains(Item: T): Boolean;

    method Peek: T;
    method ToArray: array of T;

    property Count: Integer read {$IF COOPER}mapped.size{$ELSEIF ECHOES OR TOFFEE OR ISLAND}mapped.Count{$ENDIF};

    method UniqueCopy: ImmutableQueue<T>;
    method UniqueMutableCopy: Queue<T>;
    method MutableVersion: Queue<T>;
  end;

  IQueue<T> = public interface(IImmutableQueue<T>)
    method Clear;
    method Enqueue(Item: T);
    method Dequeue: T;
  end;

  Queue<T> = public class(ImmutableQueue<T>, IQueue<T>) mapped to PlatformQueue<T>
  public
    constructor; mapped to constructor();

    method Clear;
    method Enqueue(Item: T);
    method Dequeue: T;
  end;

implementation

method ImmutableQueue<T>.Contains(Item: T): Boolean;
begin
  {$IF NOT TOFFEE}
  exit mapped.Contains(Item);
  {$ELSEIF TOFFEE}
  exit Foundation.NSMutableArray(mapped).containsObject(NullHelper.coalesce(Item, NSNull.null));
  {$ENDIF}
end;

method ImmutableQueue<T>.Peek: T;
begin
  {$IF NOT TOFFEE}
  {$IFDEF COOPER}
  if self.Count = 0 then
    raise new QueueEmptyException;
    {$ENDIF}
  exit mapped.Peek;
  {$ELSEIF TOFFEE}
  if self.Count = 0 then
    raise new QueueEmptyException;
  var lResult := Foundation.NSMutableArray(mapped).objectAtIndex(0);
  if lResult = NSNull.null then
    lResult := nil;
  result := T(lResult);
  {$ENDIF}
end;

method ImmutableQueue<T>.ToArray: array of T;
begin
  {$IF COOPER}
  exit mapped.toArray(new T[0]);
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArray<T>(self);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToArray;
  {$ENDIF}
end;

method ImmutableQueue<T>.UniqueCopy: ImmutableQueue<T>;
begin
  {$IF NOT TOFFEE}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy;
  {$ENDIF}
end;

method ImmutableQueue<T>.UniqueMutableCopy: Queue<T>;
begin
  {$IF NOT TOFFEE}
  result := new Queue<T>();
  for each k in mapped do
    result.Enqueue(k);
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy;
  {$ENDIF}
end;

method ImmutableQueue<T>.MutableVersion: Queue<T>;
begin
  {$IF NOT TOFFEE}
  result := Queue<T>(self);
  {$ELSEIF TOFFEE}
  if self is NSMutableArray then
    result := self as NSMutableArray<T>
  else
    result := mapped.mutableCopy;
  {$ENDIF}
end;

method Queue<T>.Clear;
begin
  {$IF NOT TOFFEE}
  mapped.Clear;
  {$ELSEIF TOFFEE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method Queue<T>.Dequeue: T;
begin
  {$IF COOPER}
  if self.Count = 0 then
    raise new QueueEmptyException;
  exit mapped.poll;
  {$ELSEIF TOFFEE}
  if self.Count = 0 then
    raise new QueueEmptyException;
  var lResult := Foundation.NSMutableArray(mapped).objectAtIndex(0);
  if lResult = NSNull.null then
    lResult := nil;
  result := T(lResult);
  mapped.removeObjectAtIndex(0);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.Dequeue;
  {$ENDIF}
end;

method Queue<T>.Enqueue(Item: T);
begin
  {$IF COOPER}
  mapped.add(Item);
  {$ELSEIF TOFFEE}
  Foundation.NSMutableArray(mapped).addObject(NullHelper.coalesce(Item, NSNull.null));
  {$ELSEIF ECHOES OR ISLAND}
  mapped.Enqueue(Item);
  {$ENDIF}
end;

end.