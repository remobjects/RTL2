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

    {$IF NOT ISLAND}
    method ToSortedList: ImmutableList<T>;
    begin
      if self is ImmutableList<T> then
        result := (self as ImmutableList<T>).ToSortedList()
      else
        result := self.ToList().ToSortedList();
    end;
    {$ENDIF}

    method ToSortedList(aComparison: Comparison<T>): ImmutableList<T>;
    begin
      if self is ImmutableList<T> then
        result := (self as ImmutableList<T>).ToSortedList(aComparison)
      else
        result := self.ToList().ToSortedList(aComparison)
    end;


    method JoinedString(aSeparator: nullable String := nil): not nullable String;
    begin
      var lResult := new StringBuilder();
      for each e in self index i do begin
        if (i ≠ 0) and assigned(aSeparator) then
          lResult.Append(aSeparator);
        lResult.Append(e:ToString());
      end;
      result := lResult.ToString() as not nullable;
    end;

  end;
{$ENDIF}

end.