namespace RemObjects.Elements.RTL;

type
  LinkedListNode<T> = public class
  public
    constructor (aValue: T);
    begin
      Value := aValue;
    end;

    property List: LinkedList<T> read unit write;
    property Next: LinkedListNode<T> read unit write;
    property Previous: LinkedListNode<T> read unit write;
    property Value: T; readonly;
  end;

  IImmutableLinkedList<T> = public interface
    //method Contains(aValue: T): Boolean;
    //method Find(aValue: T): nullable LinkedListNode<T>;
    //method FindLast(aValue: T): nullable LinkedListNode<T>;

    property First: nullable LinkedListNode<T> read;
    property Last: nullable LinkedListNode<T> read;
    property Count: Integer read;

    {$IF NOT TOFFEE}
    [&Sequence]
    method GetSequence: sequence of T;
    {$ENDIF}
  end;

  ImmutableLinkedList<T> = public class(IImmutableLinkedList<T>)
  public
    property First: nullable LinkedListNode<T> read fFirst;
    property Last: nullable LinkedListNode<T> read fLast;
    property Count: Integer read fCount;

    {$IF NOT TOFFEE}
    [&Sequence]
    method GetSequence: sequence of T; iterator;
    begin
      var p := First;
      while assigned(p) do begin
        yield p.Value;
        p := p.Next;
      end;
    end;
    {$ENDIF}

  unit
    fFirst: LinkedListNode<T>;
    fLast: LinkedListNode<T>;
    fCount: Integer;
  end;

  ImmutableLinkedList_Equatable<T> = public extension class(ImmutableLinkedList<T>)
    where T is IEquatable<T>;

  public
    method Contains(aValue: T): Boolean;
    begin
      var p := First;
      while assigned(p) do begin
        var lIsEqual := if assigned(p.Value) then p.Value.Equals(aValue) else not assigned(aValue);
        if lIsEqual then
          exit true;
        p := p.Next;
      end;
    end;

    method Find(aValue: T): nullable LinkedListNode<T>;
    begin
      var p := First;
      while assigned(p) do begin
        var lIsEqual := if assigned(p.Value) then p.Value.Equals(aValue) else not assigned(aValue);
        if lIsEqual then
          exit p;
        p := p.Next;
      end;
    end;

    method FindLast(aValue: T): nullable LinkedListNode<T>;
    begin
      var p := Last;
      while assigned(p) do begin
        var lIsEqual := if assigned(p.Value) then p.Value.Equals(aValue) else not assigned(aValue);
        if lIsEqual then
          exit p;
        p := p.Previous;
      end;
    end;

  end;

  ILinkedList<T> = public interface(IImmutableLinkedList<T>)
    method AddAfter(aNode: LinkedListNode<T>; aNewNode: LinkedListNode<T>);
    method AddBefore(aNode: LinkedListNode<T>; aNewNode: LinkedListNode<T>);
    method AddFirst(aNewNode: LinkedListNode<T>);
    method AddLast(aNewNode: LinkedListNode<T>);

    method AddAfter(aNode: LinkedListNode<T>; aValue: T): LinkedListNode<T>;
    method AddBefore(aNode: LinkedListNode<T>; aValue: T): LinkedListNode<T>;
    method AddFirst(aValue: T): LinkedListNode<T>;
    method AddLast(aValue: T): LinkedListNode<T>;

    method Clear;

    method &Remove(aNode: LinkedListNode<T>);
    method RemoveFirst;
    method RemoveLast;
  end;

  LinkedList<T> = public partial class(ImmutableLinkedList<T>)
  public

    method AddAfter(aNode: LinkedListNode<T>; aNewNode: LinkedListNode<T>);
    begin
      aNewNode.Next := aNode.Next;
      aNewNode.Previous := aNode;
      aNode:Next:Previous := aNewNode;
      aNode:Next := aNewNode;
      if fLast = aNode then
        fLast := aNewNode;
      inc(fCount);
    end;

    method AddBefore(aNode: LinkedListNode<T>; aNewNode: LinkedListNode<T>);
    begin
      aNewNode.Next := aNode;
      aNewNode.Previous := aNode.Previous;
      aNode:Previous:Next := aNewNode;
      aNode:Previous := aNewNode;
      if fFirst = aNode then
        fFirst := aNewNode;
      inc(fCount);
    end;

    method AddFirst(aNewNode: LinkedListNode<T>);
    begin
      aNewNode.Next := fFirst;
      aNewNode.Previous := nil;
      fFirst := aNewNode;
      if not assigned(fLast) then
        fLast := aNewNode;
      inc(fCount);
    end;

    method AddLast(aNewNode: LinkedListNode<T>);
    begin
      aNewNode.Previous := fLast;
      aNewNode.Next := nil;
      fLast := aNewNode;
      if not assigned(fFirst) then
        fFirst := aNewNode;
      inc(fCount);
    end;

    //
    //
    //

    method AddAfter(aNode: LinkedListNode<T>; aValue: T): LinkedListNode<T>; inline;
    begin
      AddAfter(aNode, new LinkedListNode<T>(aValue));
    end;

    method AddBefore(aNode: LinkedListNode<T>; aValue: T): LinkedListNode<T>; inline;
    begin
      AddBefore(aNode, new LinkedListNode<T>(aValue));
    end;

    method AddFirst(aValue: T): LinkedListNode<T>; inline;
    begin
      AddFirst(new LinkedListNode<T>(aValue));
    end;

    method AddLast(aValue: T): LinkedListNode<T>; inline;
    begin
      AddLast(new LinkedListNode<T>(aValue));
    end;

    method Clear;
    begin
      fFirst := nil;
      fLast := nil;
      fCount := 0;
    end;

    //method CopyTo(&array: array of T; &index: Integer);
    //begin
      //var p := First;
      //while assigned(p) do begin
        //yield p.Value;
        //p := p.Next;
      //end;
    //end;

    method &Remove(aNode: LinkedListNode<T>);
    begin
      if fFirst = aNode then
        fFirst := aNode.Next;
      if fLast = aNode then
        fLast := aNode.Previous;

      var lTemp := aNode.Previous;
      aNode.Previous := aNode.Next;
      aNode.Next := lTemp;
      dec(fCount);
    end;

    method RemoveFirst;
    begin
      if assigned(fFirst) then begin
        if fFirst = fLast then
          fLast := nil;
        fFirst := fFirst.Next;
        fFirst.Previous := nil;
        dec(fCount);
      end;
    end;

    method RemoveLast;
    begin
      if assigned(fLast) then begin
        if fLast = fFirst then
          fFirst := nil;
        fLast := fLast.Next;
        fLast.Previous := nil;
        dec(fCount);
      end;
    end;

  end;

  LinkedList_Equatable<T> = public extension class(LinkedList<T>)
    where T is IEquatable<T>;
  public

    method &Remove(aValue: T): Boolean;
    begin
      var p := First;
      while assigned(p) do begin
        var lIsEqual := if assigned(p.Value) then p.Value.Equals(aValue) else not assigned(aValue);
        if lIsEqual then begin
          result := true;
          p := p.Next;
          &Remove(p);
        end
        else begin
          p := p.Next;
        end;
      end;
    end;
  end;

end.