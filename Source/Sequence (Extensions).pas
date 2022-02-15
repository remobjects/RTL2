namespace RemObjects.Elements.RTL;

type
  ISequence_Extensions<T> = public extension class (ISequence<T>)
  {$IFDEF ISLAND AND TOFFEV2}where T is NSObject;{$ENDIF}
  {$IFDEF TOFFEE} where T is class;{$ENDIF}
  public
    //method ToList<U>: not nullable ImmutableList<U>; {$IF TOFFEE}where U is class;{$ENDIF}
    //begin
      //result := &Select(i -> i as U).ToList();
    //end;

    method ToSortedList(aComparison: Comparison<T>): ImmutableList<T>;
    begin
      {$IF TOFFEEV2}
      //raise new NotImplementedException("Not implemented for ToffeV2 right now");
      result := self.ToList().ToSortedList(aComparison);
      {$ELSE}
      if self is ImmutableList<T> then
        result := (self as ImmutableList<T>).ToSortedList(aComparison)
      else
        result := self.ToList().ToSortedList(aComparison);
      {$ENDIF}
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

    {$IF TOFFEEV2}
    //operator Implicit(aList: INSFastEnumeration<T>): sequence of T;
    //begin
      //result := nil;
    //end;

    //operator Implicit(aList: INSFastEnumeration): sequence of T;
    //begin
      //result := nil;
    //end;
    {$ENDIF}

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