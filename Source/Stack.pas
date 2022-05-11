namespace RemObjects.Elements.RTL;

interface

type
  PlatformImmutableStack<T> = public {$IF COOPER}java.util.Stack<T>{$ELSEIF TOFFEE}Foundation.NSArray{$ELSEIF ECHOES}System.Collections.Generic.Stack<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Stack<T>{$ENDIF};
  PlatformStack<T> = public {$IF COOPER}java.util.Stack<T>{$ELSEIF TOFFEE}Foundation.NSMutableArray{$ELSEIF ECHOES}System.Collections.Generic.Stack<T>{$ELSEIF ISLAND}RemObjects.Elements.System.Stack<T>{$ENDIF};

  IImmutableStack<T> = public interface
    method Contains(Item: T): Boolean;
    method Peek: T;
    method ToArray: array of T;
    property Count: Integer read;
  end;

  ImmutableStack<T> = public class (IImmutableStack<T>) mapped to PlatformImmutableStack<T>
  {$IFDEF ISLAND AND NOT TOFFEEV2}where T is unconstrained;{$ENDIF}
  {$IFDEF ISLAND AND TOFFEV2}where T is NSObject;{$ENDIF}
  {$IFDEF TOFFEE} where T is class;{$ENDIF}
  public
    constructor; mapped to constructor();

    method Contains(Item: T): Boolean;
    method Peek: T;
    method ToArray: array of T;

    property Count: Integer read {$IF COOPER}mapped.size{$ELSEIF ECHOES OR TOFFEE OR ISLAND}mapped.Count{$ENDIF};

    method UniqueCopy: ImmutableStack<T>;
    method UniqueMutableCopy: Stack<T>;
    method MutableVersion: Stack<T>;
  end;

  IStack<T> = public interface(IImmutableStack<T>)
    method Clear;
    method Push(Item: T);
    method Pop: T;
  end;

  Stack<T> = public class(ImmutableStack<T>, IStack<T>) mapped to PlatformStack<T>
  public
    constructor; mapped to constructor();

    method Clear;
    method Push(Item: T);
    method Pop: T;
  end;

implementation

method ImmutableStack<T>.Contains(Item: T): Boolean;
begin
  {$IF NOT TOFFEE}
  exit mapped.Contains(Item);
  {$ELSE}
  exit mapped.containsObject(NullHelper.coalesce(Item, NSNull.null));
  {$ENDIF}
end;

method ImmutableStack<T>.Peek: T;
begin
  {$IF NOT TOFFEE}
  exit mapped.Peek;
  {$ELSE}
  var n := mapped.lastObject;
  if n = nil then raise new StackEmptyException;
  if n = NSNull.null then n := nil;
  result := T(n);
  {$ENDIF}
end;

method ImmutableStack<T>.ToArray: array of T;
begin
  {$IF COOPER}
  exit ListHelpers.ToArrayReverse<T>(mapped, new T[Count]);
  {$ELSEIF TOFFEE}
  exit ListHelpers.ToArrayReverse<T>(self);
  {$ELSEIF ECHOES OR ISLAND}
  exit mapped.ToArray;
  {$ENDIF}
end;

method ImmutableStack<T>.UniqueCopy: ImmutableStack<T>;
begin
  {$IF NOT TOFFEE}
  result := UniqueMutableCopy();
  {$ELSEIF TOFFEE}
  result := mapped.copy;
  {$ENDIF}
end;

method ImmutableStack<T>.UniqueMutableCopy: Stack<T>;
begin
  {$IF NOT TOFFEE}
  result := new Stack<T>();
  for each k in mapped do
    result.Push(k);
  {$ELSEIF TOFFEE}
  result := mapped.mutableCopy;
  {$ENDIF}
end;

method ImmutableStack<T>.MutableVersion: Stack<T>;
begin
  {$IF NOT TOFFEE}
  result := Stack<T>(self);
  {$ELSEIF TOFFEE}
  if self is NSMutableArray then
    result := self as NSMutableArray
  else
    result := mapped.mutableCopy;
  {$ENDIF}
end;

method Stack<T>.Clear;
begin
  {$IF NOT TOFFEE}
  mapped.Clear;
  {$ELSE}
  mapped.removeAllObjects;
  {$ENDIF}
end;

method Stack<T>.Pop: T;
begin
  {$IF NOT TOFFEE}
  exit mapped.Pop;
  {$ELSE}
  var n := mapped.lastObject;
  if n = nil then raise new StackEmptyException;
  if n = NSNull.null then n := nil;
  mapped.removeLastObject;
  result := T(n);
  {$ENDIF}
end;

method Stack<T>.Push(Item: T);
begin
  {$IF NOT TOFFEE}
  mapped.Push(Item);
  {$ELSE}
  mapped.addObject(NullHelper.coalesce(Item, NSNull.null));
  {$ENDIF}
end;

end.