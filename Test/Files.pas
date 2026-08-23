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
      Check.AreEqual(lFilename.FileExists, false);
      Check.AreEqual(File.Exists(lFilename), false);
    end;

    method UserCachesFolder;
    begin
      if Environment.OS ≠ OperatingSystem.Linux then
        exit;

      var lExpected := Environment.EnvironmentVariable["XDG_CACHE_HOME"];
      if length(lExpected) = 0 then
        lExpected := Path.Combine(Environment.UserHomeFolder.FullPath, ".cache");
      Check.AreEqual(Environment.UserCachesFolder.FullPath, lExpected);
    end;
  end;

end.
