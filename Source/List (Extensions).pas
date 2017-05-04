namespace RemObjects.Elements.RTL;

{$IF ECHOES}
type
  List_Extensions<T> = public extension class(System.Collections.Generic.List<T>)
  private
  protected
  public

    method ToSortedList: ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).ToSortedList();
    end;

    method ToSortedList(aComparison: Comparison<T>): ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).ToSortedList(aComparison);
    end;

    method UniqueCopy: not nullable ImmutableList<T>;
    begin
      result := (self as ImmutableList<T>).UniqueCopy();
    end;

  end;
{$ENDIF}

end.