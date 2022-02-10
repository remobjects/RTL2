namespace RemObjects.Elements.RTL;

type
  PlatformList_Extensions<T> = public extension class(PlatformList<T>)
  public

    method ToSortedList(aComparison: Comparison<T>): ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).ToSortedList(aComparison);
    end;

    method UniqueCopy: not nullable ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).UniqueCopy();
    end;

    method JoinedString(aSeparator: nullable String := nil): not nullable String;
    begin
      result := (self as ImmutableList<T>).JoinedString(aSeparator);
    end;

  end;

  //PlatformList_Extensions_Compararable<T> = public extension class (ImmutableList<T>)
    //where T is IComparable<T>;
  //public

    //method ToSortedList: ImmutableList<T>;
    //begin
      //self.ToSortedList( (a, b) -> a.CompareTo(b) );
    //end;

  //end;

end.