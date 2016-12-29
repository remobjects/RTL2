namespace RemObjects.Elements.RTL;

interface

type
  ImmutableQueue<T> = public class mapped to {$IF COOPER}java.util.LinkedList<T>{$ELSEIF ECHOES}System.Collections.Generic.Queue<T>{$ELSEIF TOFFEE}Foundation.NSArray{$ENDIF}
  public
    constructor; mapped to constructor();

    method Contains(Item: T): Boolean;
  
    method Peek: T;
    method ToArray: array of T;

    property Count: Integer read {$IF COOPER}mapped.size{$ELSEIF ECHOES OR TOFFEE}mapped.Count{$ENDIF};

    method UniqueCopy: ImmutableQueue<T>;
    method UniqueMutableCopy: Queue<T>;
    method MutableVersion: Queue<T>;
  end;

  Queue<T> = public class(ImmutableQueue<T>) mapped to {$IF COOPER}java.util.LinkedList<T>{$ELSEIF ECHOES}System.Collections.Generic.Queue<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray{$ENDIF}
  public
    constructor; mapped to constructor();

    method Clear;
    method Enqueue(Item: T);
    method Dequeue: T;
  end;

implementation

method ImmutableQueue<T>.Contains(Item: T): Boolean;
begin
  {$IF COOPER OR ECHOES}
  exit mapped.Contains(Item);
  {$ELSEIF TOFFEE}
  exit mapped.containsObject(NullHelper.ValueOf(Item));
  {$ENDIF}
end;

method ImmutableQueue<T>.Peek: T;
begin
  {$IF COOPER OR ECHOES}
  {$IFDEF COOPER}
  if self.Count = 0 then
    raise new QueueEmptyException;
    {$ENDIF}
  exit mapped.Peek;
  {$ELSEIF TOFFEE}
  if self.Count = 0 then
    raise new QueueEmptyException;
  exit NullHelper.ValueOf(mapped.objectAtIndex(0));
  {$ENDIF}
end;

method ImmutableQueue<T>.ToArray: array of T;
begin
  {$IF COOPER}
  exit mapped.toArray(new T[0]);
  {$ELSEIF ECHOES}
  exit mapped.ToArray;
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArray<T>(self);
  {$ENDIF}
end;

method ImmutableQueue<T>.UniqueCopy: ImmutableQueue<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy;
  {$ENDIF}
end;

method ImmutableQueue<T>.UniqueMutableCopy: Queue<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := new Queue<T>();
  for each k in mapped do 
    result.Enqueue(k);
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy;
  {$ENDIF}
end;

method ImmutableQueue<T>.MutableVersion: Queue<T>;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  result := self;
  {$ELSEIF TOFFEE}
  if self is NSMutableArray then
    result := self as NSMutableArray
  else
    result := mapped.mutableCopy;
  {$ENDIF}
end;

method Queue<T>.Clear;
begin
  {$IF COOPER OR ECHOES}
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
  {$ELSEIF ECHOES}
  exit mapped.Dequeue;
  {$ELSEIF TOFFEE}
  if self.Count = 0 then
    raise new QueueEmptyException;
  result := NullHelper.ValueOf(mapped.objectAtIndex(0));
  mapped.removeObjectAtIndex(0);
  {$ENDIF}
end;

method Queue<T>.Enqueue(Item: T);
begin
  {$IF COOPER}
  mapped.add(Item);
  {$ELSEIF ECHOES}
  mapped.Enqueue(Item);
  {$ELSEIF TOFFEE}
  mapped.addObject(NullHelper.ValueOf(Item));
  {$ENDIF}
end;

end.
