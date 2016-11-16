namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  String_Paths = public class(Test)
  public

    method PathComponents;
    begin
      var lPath = "/Users/mh/Desktop/test.txt";
      Assert.AreEqual(lPath.LastPathComponent, "test.txt");
      Assert.AreEqual(lPath.LastPathComponent.PathWithoutExtension, "test");
      Assert.AreEqual(lPath.PathExtension, ".txt");
      Assert.AreEqual(lPath.PathWithoutExtension, "/Users/mh/Desktop/test");
    end;
    
  end;

end.
