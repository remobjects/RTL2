namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

type
  ListTests = public class(Test)
  public
    method RemoveMatchingItems;
    begin
      var lValues := new List<String>(["one", "remove", "three", "remove", "four", "remove"]);

      lValues.Remove(aValue -> aValue = "remove");

      Check.AreEqual(lValues.JoinedString(","), "one,three,four");
    end;
  end;

end.
