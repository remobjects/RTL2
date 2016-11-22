namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  String_Paths = public class(Test)
  public

    method PathComponents;
    begin
      //76784: Make `DefaultStringType` work in current project
      var lPath: RemObjects.Elements.RTL.String := "/Users/mh/Desktop/test.txt";
      Assert.AreEqual(lPath.LastPathComponent, "test.txt");
      Assert.AreEqual(lPath.LastPathComponent.PathWithoutExtension, "test");
      Assert.AreEqual(lPath.PathExtension, ".txt");
      Assert.AreEqual(lPath.PathWithoutExtension, "/Users/mh/Desktop/test");
      
    end;
    
  end;

end.
