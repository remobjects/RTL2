namespace Elements.RTL2.ExternalConsumers.Echoes;

uses
  RemObjects.Elements.RTL;

type
  Program = class
  private

    class method CheckPaths(aExpected: array of String);
    begin
      var lActual := [Environment.UserApplicationSupportFolder.FullPath,
                      Environment.UserCachesFolder.FullPath,
                      Environment.UserLibraryFolder.FullPath,
                      Environment.SystemApplicationSupportFolder.FullPath];
      for i: Integer := 0 to 3 do
        if lActual[i] ≠ aExpected[i] then
          raise new Exception(String.Format('Folder {0}: expected "{1}", got "{2}"', i, aExpected[i], lActual[i]));
    end;

  public

    class method Main(aArgs: array of String): Integer;
    begin
      if Environment.OS ≠ OperatingSystem.macOS then begin
        writeLn('SKIP: macOS folder lookup');
        exit 0;
      end;
      if length(aArgs) ≠ 4 then begin
        writeLn('Supply native Cocoa paths for user Application Support, Caches, Library, and local Application Support.');
        exit 2;
      end;
      CheckPaths(aArgs);
      var lFailure: System.Exception;
      var lWorker := new System.Threading.Thread(-> begin
        try
          for i: Integer := 1 to 100 do
            CheckPaths(aArgs);
        except
          on e: System.Exception do
            lFailure := e;
        end;
      end);
      lWorker.IsBackground := true;
      lWorker.Start;
      if not lWorker.Join(10000) then
        raise new Exception('Worker folder lookups did not finish in ten seconds.');
      if assigned(lFailure) then
        raise lFailure;
      writeLn('PASS: four native Cocoa paths matched; 400 worker-thread lookups completed.');
      result := 0;
    end;

  end;

end.
