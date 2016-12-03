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
      Assert.AreEqual(lPath.NetworkServerName, nil);

      var lPath2: RemObjects.Elements.RTL.String := "\\RIBBONS\Users\mh\Desktop\test.txt";
      Assert.AreEqual(lPath2.NetworkServerName, "RIBBONS");
    end;
    
    method PlatformConversions;
    begin
      //76784: Make `DefaultStringType` work in current project
      var lWindowsPath: RemObjects.Elements.RTL.String := "C:\Program Files\test.txt";
      var lUnixPath: RemObjects.Elements.RTL.String := "/Users/mh/Desktop/test.txt";
      
      Assert.AreEqual(lWindowsPath.ToWindowsPath, lWindowsPath);
      //Assert.AreEqual(lWindowsPath.ToUnixPath, "C:/Program Files/text.txt"); // should succeed on Windowd?
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lWindowsPath.ToPlatformPathFromWindowsPath, "C:/Program Files/test.txt");
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lWindowsPath.ToPlatformPathFromWindowsPath, lWindowsPath);
      
      Assert.AreEqual(lUnixPath.ToWindowsPath, "\Users\mh\Desktop\test.txt"); //should fail on Windows? test
      Assert.AreEqual(lUnixPath.ToUnixPath, lUnixPath);
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Assert.AreEqual(lUnixPath.ToPlatformPathFromWindowsPath, lUnixPath);
      if Environment.OS in [OperatingSystem.Windows] then
        Assert.AreEqual(lUnixPath.ToPlatformPathFromWindowsPath, "\Users\mh\Desktop\test.txt");
    end;
  end;

end.
