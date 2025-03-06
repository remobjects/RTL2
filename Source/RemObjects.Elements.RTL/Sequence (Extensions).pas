namespace RemObjects.Elements.RTL;

type
  ISequence_Extensions<T> = public extension class(ISequence<T>)
  public
    //method ToList<U>: not nullable ImmutableList<U>; {$IF TOFFEE}where U is class;{$ENDIF}
    //begin
      //result := &Select(i -> i as U).ToList();
    //end;

    method ToSortedList(aComparison: Comparison<T>): ImmutableList<T>;
    begin
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

  {$IF NOT COOPER}
  ISequence_Extensions_Compararable<T> = public extension class (ISequence<T>)
    where T is IComparable<T>;
  public

    method ToSortedList: ImmutableList<T>;
    begin
      self.ToSortedList( (a, b) -> a.CompareTo(b) );
    end;

  end;
  {$ENDIF}

end.