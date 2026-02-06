namespace Elements.RTL2.Tests.Shared;

{$IF NOT TOFFEE}
// String is not IComparable<T> on Toffee.

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Diff = public class(Test)
  public

    method TotalDifference;
    begin
      var a := ["a", "b", "c"];
      var b := ["d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), 'd,e,f');
      Check.AreEqual(diff.Removed.JoinedString(","), 'a,b,c');
    end;

    method OneChanged;
    begin
      var a := ["a", "b", "c", "d", "e", "f"];
      var b := ["a", "b", "x", "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), 'x');
      Check.AreEqual(diff.Removed.JoinedString(","), 'c');
    end;

    method OneRemoved;
    begin
      var a := ["a", "b", "c", "d", "e", "f"];
      var b := ["a", "b",      "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), '');
      Check.AreEqual(diff.Removed.JoinedString(","), 'c');
    end;

    method OneRemovedAtEnd;
    begin
      var a := ["a", "b", "c", "d", "e", "f"];
      var b := ["a", "b", "c", "d", "e"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), '');
      Check.AreEqual(diff.Removed.JoinedString(","), 'f');
    end;

    method OneRemovedAtStart;
    begin
      var a := ["a", "b", "c", "d", "e", "f"];
      var b := [     "b", "c", "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), '');
      Check.AreEqual(diff.Removed.JoinedString(","), 'a');
    end;

    method AFewRemoved;
    begin
      var a := ["a", "b", "c", "d", "e", "f"];
      var b := [     "b", "c", "d",      "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), '');
      Check.AreEqual(diff.Removed.JoinedString(","), 'a,e');
    end;

    method OneAdded;
    begin
      var a := ["a", "b",      "d", "e", "f"];
      var b := ["a", "b", "c", "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), 'c');
      Check.AreEqual(diff.Removed.JoinedString(","), '');
    end;

    method OneAddeddAtEnd;
    begin
      var a := ["a", "b", "c", "d", "e"];
      var b := ["a", "b", "c", "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), 'f');
      Check.AreEqual(diff.Removed.JoinedString(","), '');
    end;

    method OneAddedAtStart;
    begin
      var a := [     "b", "c", "d", "e", "f"];
      var b := ["a", "b", "c", "d", "e", "f"];
      var diff := new Difference<String> betweenSequences(a, b);
      Check.AreEqual(diff.Added.JoinedString(","), 'a');
      Check.AreEqual(diff.Removed.JoinedString(","), '');
    end;
  end;

{$ENDIF}

end.