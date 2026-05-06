namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.EUnit;

type
  String_CollapseSpaces = public class(Test)
  public

    method RepeatedSpacesAndTabs;
    begin
      Check.AreEqual("".CollapseSpaces, "");
      Check.AreEqual("plain text".CollapseSpaces, "plain text");
      Check.AreEqual("foo  bar".CollapseSpaces, "foo bar");
      Check.AreEqual("foo   bar    baz".CollapseSpaces, "foo bar baz");

      var lTabs := #9#9"foo"#9#32#9"bar";
      Check.AreEqual(lTabs.CollapseSpaces, #9"foo"#9"bar");
    end;

    method LineBreaksArePreserved;
    begin
      var lUnix := "foo"#10"   bar";
      Check.AreEqual(lUnix.CollapseSpaces, "foo"#10"bar");

      var lWindows := "foo"#13#10#9#9"bar";
      Check.AreEqual(lWindows.CollapseSpaces, "foo"#13#10"bar");

      var lTrailingBeforeBreak := "foo   "#10"   bar";
      Check.AreEqual(lTrailingBeforeBreak.CollapseSpaces, "foo "#10"bar");
    end;

  end;

end.
