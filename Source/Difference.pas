namespace RemObjects.Elements.RTL;

type
  Difference<T> = public class
    where T is IComparable<T>;

  public
    constructor betweenSequences(aSequence, bSequence: sequence of T);
    begin
      constructor betweenSortedLists(aSequence.ToSortedList( (a, b) -> a.CompareTo(b) ), bSequence.ToSortedList( (a, b) -> a.CompareTo(b) ) );
    end;

    constructor betweenSequences(aSequence, bSequence: sequence of T; aComparison: Comparison<T>);
    begin
      constructor betweenSortedLists(aSequence.ToSortedList(aComparison), bSequence.ToSortedList(aComparison), aComparison);
    end;

    constructor betweenSortedLists(aList, bList: ImmutableList<T>);
    begin
      constructor betweenSortedLists(aList, bList, (a, b) -> a.CompareTo(b) );
    end;

    constructor betweenSortedLists(aList, bList: ImmutableList<T>; aComparison: Comparison<T>);
    begin
      var a := 0;
      var b := 0;
      var aCount := aList.Count;
      var bCount := bList.Count;
      while a < aCount do begin
        if b < bCount then begin

          var aValue := aList[a];
          var bValue := bList[b];
          var lCompare := aComparison(aValue, bValue);
          if lCompare = 0 then begin
            // value is in both lists, just move on
            inc(a);
            inc(b);
          end
          else if lCompare < 0 then begin
            // value in b is larger, meaning aValue got removed
            fRemoved.Add(aValue);
            inc(a);
            continue;
          end
          else /*if lCompare > 0 then*/ begin
            // value in b is smaller, meaning bValue got added
            fAdded.Add(bValue);
            inc(b);
            continue;
          end;
        end
        else begin
          // reached of B? consider all the rest in A as removed
          for i: Integer := a to aCount-1 do
            fRemoved.Add(aList[i]);
          break;
        end;
      end;
      if (b < bCount) then begin
        // reached of A? consider all the rest in B as added
        for i: Integer := b to bCount-1 do
          fAdded.Add(bList[i]);
      end;
    end;

    property Added: ImmutableList<T> read fAdded;
    property Removed: ImmutableList<T> read fRemoved;

  private

    var fAdded := new List<T>;
    var fRemoved := new List<T>;

  end;

end.