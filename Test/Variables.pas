namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

type
  Variables = public class(Test)
  private
  protected
  public

    method TestEBuildVariables;
    begin

      var d := new Dictionary<String,String>;
      d["test"] := "_test_";
      d["foo"] := "_foo_";

      Check.AreEqual("hello $(test) this is $(foo)".ProcessVariables(VariableStyle.EBuild, d), "hello _test_ this is _foo_");
      Check.AreEqual("hello $$(test) this is $(foo)".ProcessVariables(VariableStyle.EBuild, d), "hello $(test) this is _foo_");
      Check.AreEqual("hello $$$(test) this is $(foo)".ProcessVariables(VariableStyle.EBuild, d), "hello $$(test) this is _foo_");

      /*~!code!~*/
    end;

  end;

end.