namespace Elements.RTL2.Tests.Shared;

interface

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Files = public class(Test)
  private
  protected
  public
    
    method Fileexist;
  end;

implementation

method Files.Fileexist;
var Filename : String;
begin
    if Environment.OS in [OperatingSystem.Windows] then begin
        Filename := 'C:\test\notthere.txt';

        try
            if Filename.FileExists then;
            Assert.AreEqual(Filename.FileExists, false);
            Assert.AreEqual(File.Exists(Filename), false);
        except
            on e : Exception do
                Assert.Fail('Should not raise a Exception '+e.Message);
        end;
    end;

end;

end.
