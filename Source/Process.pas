namespace RemObjects.Elements.RTL;

{$IF ECHOES OR MACOS OR WINDOWS} // OR LINUX

interface

type
  {$IF JAVA}
  //PlatformProcess = {$ERROR Unsupported platform};
  {$ELSEIF ECHOES}
  PlatformProcess = public System.Diagnostics.Process;
  {$ELSEIF ISLAND}
  PlatformProcess = public RemObjects.Elements.System.Process;
  {$ELSEIF COCOA}
  PlatformProcess = public Foundation.NSTask;
  {$ENDIF}

  Process = public class {$IF ECHOES OR COCOA OR ISLAND}mapped to PlatformProcess{$ENDIF}
  private
    class method QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
    class method SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;
    {$IF TOFFEE}
    class method processStdOutData(rawString: String) lastIncompleteLogLine(out lastIncompleteLogLine: String) callback(callback: block(aLine: String));
    {$ENDIF}
  protected
  public

    class method JoinAndQuoteArgumentsForCommandLine(aArguments: not nullable ImmutableList<String>): not nullable String;
    class method SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;

    class method StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable ImmutableList<String>): not nullable String;

    method WaitFor; inline;
    method Start; inline;
    method Stop; inline;

    property ExitCode: Integer read {$IF ECHOES OR ISLAND}mapped.ExitCode{$ELSEIF TOFFEE}mapped.terminationStatus{$ENDIF};
    property IsRunning: Boolean read {$IF ECHOES}not mapped.HasExited{$ELSEIF ISLAND}mapped.IsRunning{$ELSEIF TOFFEE}mapped.isRunning{$ENDIF};

    class method Run(aCommand: not nullable String): Integer; inline;
    class method RunAsync(aCommand: not nullable String): Process; inline;

    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
    class method RunAsync(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process;

    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer; inline;
    class method RunAsync(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process; inline;

  end;

implementation

method Process.WaitFor;
begin
  {$IF ECHOES}
  mapped.WaitForExit();
  {$ELSEIF ISLAND}
  mapped.WaitFor();
  {$ELSEIF TOFFEE}
  mapped.waitUntilExit();
  {$ENDIF}
end;

method Process.Start;
begin
  {$IF ECHOES}
  mapped.Start();
  {$ELSEIF ISLAND}
  mapped.Start();
  {$ELSEIF TOFFEE}
  mapped.launch();
  {$ENDIF}
end;

method Process.Stop;
begin
  {$IF ECHOES}
  mapped.Kill();
  {$ELSEIF ISLAND}
  mapped.Stop();
  {$ELSEIF TOFFEE}
  mapped.terminate();
  {$ENDIF}
end;

//
// Static Methods
//

class method Process.Run(aCommand: not nullable String): Integer;
begin
  result := Run(aCommand, []);
end;

class method Process.RunAsync(aCommand: not nullable String): Process;
begin
  result := RunAsync(aCommand, [], nil, nil, nil);
end;


class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
begin
  using lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory) do begin
    lTask.Start();
    lTask.WaitFor();
    result := lTask.ExitCode;
  end;
end;

class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer;
begin
  var lIgnoreStdErr: String;
  result := Run(aCommand, aArguments, aEnvironment, aWorkingDirectory, out aStdOut, out lIgnoreStdErr);
end;

class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
begin
  {$IF ECHOES}
  using lDone := new System.Threading.AutoResetEvent(false) do begin
    var lStdOut := new StringBuilder;
    var lStdErr := new StringBuilder;
    var lResult: Integer;
    Process.RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, method (aLine: String) begin
      lStdOut.Append(Environment.LineBreak+aLine);
    end, method (aLine: String) begin
      lStdErr.Append(Environment.LineBreak+aLine);
    end, method(aExitCode: Integer) begin
      lResult := aExitCode;
      lDone.Set();
    end);
    lDone.WaitOne();
    aStdOut := lStdOut.ToString();
    aStdErr := lStdErr.ToString();
    result := lResult;
  end;
  {$ELSEIF ISLAND}
  result := PlatformProcess.Run(aCommand, aArguments, aEnvironment, aWorkingDirectory, out aStdOut, out aStdErr);
  {$ELSEIF TOFFEE}
  using lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory) do begin
    (lTask as NSTask).standardOutput := NSPipe.pipe();
    (lTask as NSTask).standardError := NSPipe.pipe();
    var stdOut := (lTask as NSTask).standardOutput.fileHandleForReading;
    var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
    lTask.Start();
    lTask.WaitFor();
    aStdOut := "";
    aStdErr := "";
    var d := stdOut.availableData();
    while (d ≠ nil) and (d.length() > 0) do begin
      aStdOut := aStdOut+new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
      d := stdOut.availableData();
    end;
    stdOut.closeFile();
    d := stdErr.availableData();
    while (d ≠ nil) and (d.length() > 0) do begin
      aStdErr := aStdErr+new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
      d := stdErr.availableData();
    end;
    stdErr.closeFile();
  end;
  {$ENDIF}
end;

class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
begin
  using lTask := RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback) do begin
    lTask.WaitFor();
    result := lTask.ExitCode;
  end;
end;

class method Process.RunAsync(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process;
begin
  var lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  result := lTask;

  {$IF ECHOES}
  var lOutputWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  var lErrorWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  if assigned(aStdOutCallback) then begin
    (lTask as PlatformProcess).StartInfo.RedirectStandardOutput := true;
    (lTask as PlatformProcess).OutputDataReceived += method (sender: Object; e: System.Diagnostics.DataReceivedEventArgs) begin
      if assigned(e.Data) then
        aStdOutCallback(e.Data)
      else
        lOutputWaitHandle:&Set();
    end;
    //(lTask as PlatformProcess).BeginOutputReadLine();
  end;
  if assigned(aStdErrCallback) then begin
    (lTask as PlatformProcess).StartInfo.RedirectStandardError := true;
    (lTask as PlatformProcess).ErrorDataReceived += method (sender: Object; e: System.Diagnostics.DataReceivedEventArgs) begin
      if assigned(e.Data) then
        aStdErrCallback(e.Data)
      else
        lErrorWaitHandle:&Set();
    end;
    //(lTask as PlatformProcess).BeginErrorReadLine();
  end;
  if assigned(aFinishedCallback) then begin
    (lTask as PlatformProcess).Exited += method (sender: Object; e: System.EventArgs) begin
      lOutputWaitHandle.WaitOne();
      lOutputWaitHandle:Dispose();
      lErrorWaitHandle.WaitOne();
      lErrorWaitHandle:Dispose();
      aFinishedCallback(lTask.ExitCode);
    end;
  end;
  lTask.Start();

  if assigned(aStdOutCallback) then
    (lTask as PlatformProcess).BeginOutputReadLine();
  if assigned(aStdErrCallback) then
    (lTask as PlatformProcess).BeginErrorReadLine();
  {$ELSEIF ISLAND}
  result := PlatformProcess.RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback, aFinishedCallback);
  {$ELSEIF TOFFEE}
  if assigned(aStdOutCallback) then
    (lTask as PlatformProcess).standardOutput := NSPipe.pipe();
  if assigned(aStdErrCallback) then
    (lTask as PlatformProcess).standardError := NSPipe.pipe();

  if assigned(aStdOutCallback) then
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
      var stdOut := (lTask as NSTask).standardOutput.fileHandleForReading;
      var lastIncompleteLogLine: String;
      while (lTask as PlatformProcess).isRunning do begin
        using autoreleasepool do begin
          var d := stdOut.availableData;
          if (d ≠ nil) and (d.length > 0) then
            processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdOutCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdOut.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdOutCallback);
        d := stdOut.availableData;
      end;
      stdOut.closeFile();
    end);

  if assigned(aStdErrCallback) then
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
      var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
      var lastIncompleteLogLine: String;
      while (lTask as PlatformProcess).isRunning do begin
        using autoreleasepool do begin
          var d := stdErr.availableData;
          if (d ≠ nil) and (d.length > 0) then
            processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdErrCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdErr.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdErrCallback);
        d := stdErr.availableData;
      end;
      stdErr.closeFile();
    end);

  lTask.Start();

  if assigned(aFinishedCallback) then async begin
    lTask.WaitFor();
    aFinishedCallback(lTask.ExitCode);
  end;
  {$ENDIF}
end;

class method Process.Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
begin
  result := Run(aCommand, aArguments.ToList, aEnvironment, aWorkingDirectory);
end;

class method Process.Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer;
begin
  result := Run(aCommand, aArguments.ToList, aEnvironment, aWorkingDirectory, out aStdOut);
end;

class method Process.Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
begin
  result := Run(aCommand, aArguments.ToList, aEnvironment, aWorkingDirectory, out aStdOut, out aStdErr);
end;

class method Process.Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
begin
  result := Run(aCommand, aArguments.ToList, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback);
end;

class method Process.RunAsync(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process;
begin
  result := RunAsync(aCommand, aArguments.ToList, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback, aFinishedCallback);
end;

{$IF TOFFEE}
class method Process.processStdOutData(rawString: String) lastIncompleteLogLine(out lastIncompleteLogLine: String) callback(callback: block(aLine: string));
begin
  if length(rawString) > 0 then begin
    if length(rawString) > 0 then begin
      rawString := lastIncompleteLogLine+rawString;
      lastIncompleteLogLine := nil;
    end;
    var lines := rawString.Split(Environment.LineBreak);
    for i: Int32 := 0 to lines.Count-1 do begin
      var s := lines[i];
      if (i = lines.Count-1) and not s.EndsWith(Environment.LineBreak) then begin
        if length(s) > 0 then
          lastIncompleteLogLine := s;
        break;
      end;
      callback(s);
    end;
  end;
end;
{$ENDIF}

class method Process.SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;
begin
  {$IF ECHOES}
  var lResult := new PlatformProcess();
  lResult.StartInfo := new System.Diagnostics.ProcessStartInfo();
  lResult.StartInfo.FileName := aCommand;
  lResult.StartInfo.CreateNoWindow := true;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.StartInfo.WorkingDirectory := aWorkingDirectory;
  if length(aArguments) > 0 then
    lResult.StartInfo.Arguments := JoinAndQuoteArgumentsForCommandLine(aArguments);
  for each k in aEnvironment:Keys do
    lResult.StartInfo.EnvironmentVariables[k] := aEnvironment[k];
  lResult.StartInfo.UseShellExecute := false;
  lResult.EnableRaisingEvents := true;
  result := lResult;
  {$ELSEIF ISLAND}
  result := new PlatformProcess(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  {$ELSEIF TOFFEE}
  var lResult := new PlatformProcess();
  lResult.launchPath := aCommand;
  if assigned(aArguments) then
    lResult.arguments := aArguments.ToList();
  if assigned(aEnvironment) then
    lResult.environment := aEnvironment;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.currentDirectoryPath := aWorkingDirectory;
  result := lResult;
  {$ENDIF}
end;

class method Process.QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
begin
  result := aArgument;
  if result.Contains(" ") then
    result := '"'+result.Replace('"', '\"')+'"'
end;

class method Process.SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
begin
  var lResult := new List<String>;
  var lCurrent: String := ""; // why is this needed for lCurrent to not become an NSString?
  var lInQuotes := false;
  for i: Integer := 0 to length(aArgumentString)-1 do begin
    var ch := aArgumentString[i];
    case ch of
      ' ': begin
          if lInQuotes then begin
            lCurrent := lCurrent+ch;
          end
          else begin
            lCurrent := lCurrent.Trim();
            if length(lCurrent) > 0 then
              lResult.Add(lCurrent);
            lCurrent := "";
          end;
        end;
      '"': lInQuotes := not lInQuotes;
      else begin
          lCurrent := lCurrent+ch;
        end;
    end;
  end;

  lCurrent := lCurrent.Trim();
  if length(lCurrent) > 0 then
    lResult.Add(lCurrent);

  result := lResult;
end;

class method Process.JoinAndQuoteArgumentsForCommandLine(aArguments: not nullable ImmutableList<String>): not nullable String;
begin
  result := "";
  for each a in aArguments do begin
    if length(result) > 0 then
      result := result+" ";
    result := result+QuoteArgumentIfNeeded(a);
  end;
end;

class method Process.StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable ImmutableList<String>): not nullable String;
begin
  if aCommand.Contains(" ") then
    aCommand := String.Format('"{0}"', aCommand);
  if length(aArguments) > 0 then
    aCommand := aCommand+" "+JoinAndQuoteArgumentsForCommandLine(aArguments);
  result := aCommand;
end;

{$ENDIF}

end.