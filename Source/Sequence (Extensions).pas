namespace RemObjects.Elements.RTL;

{$IF ISLAND}
type
  ISequence_Extensions<T> = public extension class (ISequence<T>)
  private
  protected
  public
    //method ToList<U>: not nullable ImmutableList<U>; {$IF TOFFEE}where U is class;{$ENDIF}
    //begin
      //result := &Select(i -> i as U).ToList();
    //end;
  end;
{$ENDIF}

end.