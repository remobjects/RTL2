namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Files = public class(Test)
  public

    method FileExist;
    begin
      var lFilename := case Environment.OS of
          OperatingSystem.Windows: 'C:\test\notthere.txt';
          OperatingSystem.macOS: '/test/notthere.txt';
        end;

      if lFilename.FileExists then;
      Assert.AreEqual(lFilename.FileExists, false);
      Assert.AreEqual(File.Exists(lFilename), false);
    end;
  end;

end.