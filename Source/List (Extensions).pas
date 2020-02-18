namespace RemObjects.Elements.RTL;

type
  List_Extensions<T> = public extension class(PlatformList<T>)
  private
  protected
  public

    {$IF NOT (ISLAND OR COOPER)}
    method ToSortedList: ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).ToSortedList();
    end;
    {$ENDIF}

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

end.