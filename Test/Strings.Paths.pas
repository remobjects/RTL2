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
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then begin
        var lPath: RemObjects.Elements.RTL.String := "/Users/mh/Desktop/test.txt";
        Check.AreEqual(lPath.LastPathComponent, "test.txt");
        Check.AreEqual(lPath.LastPathComponent.PathWithoutExtension, "test");
        Check.AreEqual(lPath.PathExtension, ".txt");
        Check.AreEqual(lPath.PathWithoutExtension, "/Users/mh/Desktop/test");
        Check.AreEqual(lPath.NetworkServerName, nil);
      end;

      if Environment.OS in [OperatingSystem.Windows] then begin
        var lPath: RemObjects.Elements.RTL.String := "C:\Users\mh\Desktop\test.txt";
        Check.AreEqual(lPath.LastPathComponent, "test.txt");
        Check.AreEqual(lPath.LastPathComponent.PathWithoutExtension, "test");
        Check.AreEqual(lPath.PathExtension, ".txt");
        Check.AreEqual(lPath.PathWithoutExtension, "C:\Users\mh\Desktop\test");
        Check.AreEqual(lPath.NetworkServerName, nil);
      end;

      var lPath2: RemObjects.Elements.RTL.String := "\\RIBBONS\Users\mh\Desktop\test.txt";
      Check.AreEqual(lPath2.NetworkServerName, "RIBBONS");
    end;

    method PlatformConversions;
    begin
      //76784: Make `DefaultStringType` work in current project
      var lWindowsPath: RemObjects.Elements.RTL.String := "C:\Program Files\test.txt";
      var lUnixPath: RemObjects.Elements.RTL.String := "/Users/mh/Desktop/test.txt";

      Check.AreEqual(lWindowsPath.ToWindowsPath, lWindowsPath);
      //Check.AreEqual(lWindowsPath.ToUnixPath, "C:/Program Files/text.txt"); // should succeed on Windows
      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lWindowsPath.ToPlatformPathFromWindowsPath, "C:/Program Files/test.txt");
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreEqual(lWindowsPath.ToPlatformPathFromWindowsPath, lWindowsPath);

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUnixPath.ToWindowsPath, "\Users\mh\Desktop\test.txt");
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreNotEqual(lUnixPath.ToWindowsPath, "\Users\mh\Desktop\test.txt"); // should fail on Windows

      Check.AreEqual(lUnixPath.ToWindowsPathFromUnixPath, "\Users\mh\Desktop\test.txt");
      Check.AreEqual(lUnixPath.ToUnixPath, lUnixPath);

      if Environment.OS in [OperatingSystem.macOS, OperatingSystem.Linux] then
        Check.AreEqual(lUnixPath.ToPlatformPathFromWindowsPath, lUnixPath);
      if Environment.OS in [OperatingSystem.Windows] then
        Check.AreNotEqual(lUnixPath.ToPlatformPathFromWindowsPath, "\Users\mh\Desktop\test.txt"); // should fail on Windows
    end;
  end;

end.