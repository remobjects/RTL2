namespace Elements.RTL2.ExternalConsumers.Echoes;

uses
  Foundation;

type
  Program = class
  public

    class method Main: Integer;
    begin
      writeLn(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
      writeLn(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
      writeLn(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true).objectAtIndex(0));
      writeLn(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true).objectAtIndex(0));
      result := 0;
    end;

  end;

end.
