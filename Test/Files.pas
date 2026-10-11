// EmptyBinary: negative regression guard for the missing Island backing stream in a new empty binary.
// EmptyFileReadText: negative regression guard for zero-byte reads, with a positive one-byte content control.
namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Files = public class(Test)
  public

    method EmptyBinary;
    begin
      var lBinary := new ImmutableBinary;
      Check.AreEqual(lBinary.Length, 0);
      Check.AreEqual(length(lBinary.ToArray), 0);
    end;

    method EmptyFileReadText;
    begin
      var lFilename := Path.Combine(Environment.TempFolder.FullPath, Guid.NewGuid.ToString+".txt");
      try
        File.WriteBytes(lFilename, new Byte[0]);
        Check.AreEqual(File.ReadText(lFilename), "");
        Check.AreEqual(length(File.ReadBytes(lFilename)), 0);
        File.WriteText(lFilename, "x");
        Check.AreEqual(File.ReadText(lFilename), "x");
      finally
        File.Delete(lFilename);
      end;
    end;

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
