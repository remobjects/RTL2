namespace RemObjects.Elements.RTL;

interface

uses
  RemObjects.Elements.RTL.Units;

{$IF (ECHOES OR MACOS OR WINDOWS OR LINUX) AND NOT MACCATALYST} // OR LINUX

type
  {$IF JAVA}
  //PlatformProcess = {$ERROR Unsupported platform};
  {$ELSEIF TOFFEE}
  PlatformProcess = public Foundation.NSTask;
  {$ELSEIF ECHOES}
  PlatformProcess = public System.Diagnostics.Process;
  {$ELSEIF ISLAND}
  PlatformProcess = public RemObjects.Elements.System.Process;
  {$ENDIF}

  Process = public partial class {$IF ECHOES OR COCOA OR ISLAND}mapped to PlatformProcess{$ENDIF}
  public

    method WaitFor; inline;
    method WaitFor(aTimeout: Milliseconds): Boolean;
    method WaitFor(aTimeout: TimeSpan): Boolean;
    method Start; inline;
    method Stop; inline;

    {$IF TOFFEEV1 OR TOFFEEV2}
    property PID: Integer read mapped.processIdentifier;
    {$ELSEIF ECHOES OR ISLAND}
    property PID: Integer read mapped.Id;
    {$ENDIF}

    property ExitCode: Integer read {$IF TOFFEE}mapped.terminationStatus{$ELSEIF ECHOES OR ISLAND}mapped.ExitCode{$ENDIF};
    property IsRunning: Boolean read {$IF TOFFEE}mapped.isRunning{$ELSEIF ECHOES}not mapped.HasExited{$ELSEIF ISLAND}mapped.IsRunning{$ENDIF};

    class method Run(aCommand: not nullable String): Integer; inline;
    class method RunAsync(aCommand: not nullable String): Process; inline;

    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: array of Byte; out aStdErr: array of Byte): Integer;
    class method Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
    class method RunAsync(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process;

    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer; inline;
    class method Run(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer; inline;
    class method RunAsync(aCommand: not nullable String; aArguments: array of string; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process; inline;

  private

    class method SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;

  end;

{$ENDIF}

type
  Process = public partial class
  private
    class method QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;

  public
    class method JoinAndQuoteArgumentsForCommandLine(aArguments: not nullable ImmutableList<String>): not nullable String;
    class method SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
    class method SplitQuotedCEscapedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
    class method StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable ImmutableList<String>): not nullable String;

    class method ProcessStringToLines(rawString: String) LastIncompleteLogLine(out lastIncompleteLogLine: String) Callback(callback: block(aLine: String));
  end;

implementation

{$IF (ECHOES OR MACOS OR WINDOWS OR LINUX) AND NOT MACCATALYST} // OR LINUX

method Process.WaitFor;
begin
  {$IF TOFFEE}
  mapped.waitUntilExit();
  {$ELSEIF ECHOES}
  mapped.WaitForExit();
  {$ELSEIF ISLAND}
  mapped.WaitFor();
  {$ENDIF}
end;

method Process.WaitFor(aTimeout: Milliseconds): Boolean;
begin
  var lDeadline := DateTime.UtcNow.Add(aTimeout);
  while IsRunning do begin
    var lRemaining := (lDeadline-DateTime.UtcNow).TotalMilliSeconds;
    if lRemaining <= 0ms then
      exit false;
    Thread.Sleep(if lRemaining > 10ms then 10ms else lRemaining);
  end;
  WaitFor;
  result := true;
end;

method Process.WaitFor(aTimeout: TimeSpan): Boolean;
begin
  result := WaitFor(aTimeout.TotalMilliSeconds);
end;

method Process.Start;
begin
  {$IF TOFFEE}
  var lError: NSError;
  if not mapped.launchAndReturnError(var lError) then begin
    if assigned(lError) then
      raise new NSErrorException withError(lError);
    raise new Exception($"Could not start process '{mapped.executableURL:path}'.");
  end;
  {$ELSEIF ECHOES}
  mapped.Start();
  {$ELSEIF ISLAND}
  mapped.Start();
  {$ENDIF}
end;

method Process.Stop;
begin
  {$IF TOFFEE}
  mapped.terminate();
  {$ELSEIF ECHOES}
  mapped.Kill();
  {$ELSEIF ISLAND}
  mapped.Stop();
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
  {$IF TOFFEE}
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
  {$ELSEIF ECHOES}
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
  {$ENDIF}
end;

class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: array of Byte; out aStdErr: array of Byte): Integer;
begin
  {$IF TOFFEE}
  using lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory) do begin
    (lTask as NSTask).standardOutput := NSPipe.pipe();
    (lTask as NSTask).standardError := NSPipe.pipe();
    var stdOut := (lTask as NSTask).standardOutput.fileHandleForReading;
    var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
    var lStdOutData: NSData;
    var lStdErrData: NSData;
    var lStdOutFinished := new &Event;
    var lStdErrFinished := new &Event;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) begin
      try
        var error: NSError;
        lStdOutData := stdOut.readDataToEndOfFileAndReturnError(var error);
      finally
        lStdOutFinished.Set();
      end;
    end;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) begin
      try
        var error: NSError;
        lStdErrData := stdErr.readDataToEndOfFileAndReturnError(var error);
      finally
        lStdErrFinished.Set();
      end;
    end;

    lTask.Start();
    lTask.WaitFor();

    var error: NSError;
    lStdOutFinished.WaitFor();
    //aStdOut := new array of Byte withNSData(stdOutData);
    aStdOut := new Byte[lStdOutData.length];
    lStdOutData.getBytes(@aStdOut[0]) length(lStdOutData.length);
    stdOut.closeAndReturnError(var error);

    lStdErrFinished.WaitFor();
    //aStdErr := new array of Byte withNSData(stdErrData);
    aStdErr := new Byte[lStdErrData.length];
    lStdErrData.getBytes(@aStdErr[0]) length(lStdErrData.length);
    stdErr.closeAndReturnError(var error);
  end;
  {$ELSEIF ECHOES}
  var lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  (lTask as PlatformProcess).StartInfo.RedirectStandardOutput := true;
  (lTask as PlatformProcess).StartInfo.RedirectStandardError := true;
  using lStdOut := new MemoryStream do
  using lStdErr := new MemoryStream do begin
    lTask.Start();
    var lStdOutThread := new System.Threading.Thread(() -> (lTask as PlatformProcess).StandardOutput.BaseStream.CopyTo(lStdOut));
    var lStdErrThread := new System.Threading.Thread(() -> (lTask as PlatformProcess).StandardError.BaseStream.CopyTo(lStdErr));
    lStdOutThread.Start();
    lStdErrThread.Start();
    lTask.WaitFor();
    lStdOutThread.Join();
    lStdErrThread.Join();
    aStdOut := lStdOut.ToArray;
    aStdErr := lStdErr.ToArray;
  end;
  result := lTask.ExitCode;
  {$ELSEIF ISLAND}
  raise new NotImplementedException("Process.Run(aStdOut: array of Byte) is not implemented for Island yet.")
  //result := PlatformProcess.Run(aCommand, aArguments, aEnvironment, aWorkingDirectory, out aStdOut, out aStdErr);
  {$ENDIF}
end;

class method Process.Run(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
begin
  var lFinished := new &Event;
  using lTask := RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback, () -> lFinished.Set()) do begin
    lFinished.WaitFor();
    result := lTask.ExitCode;
  end;
end;

class method Process.RunAsync(aCommand: not nullable String; aArguments: ImmutableList<String> := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Process;
begin
  var lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  result := lTask;

  {$IF TOFFEE}
  var lClosingOutput := false;

  method HandleOutput(aOutput: nullable NSPipe; aCallback: block(aLine: String); aEvent: nullable &Event);
  begin
    if not assigned(aOutput) then begin
      if assigned(aEvent) then
        aEvent.Set();
      exit;
    end;

    var lHandle := aOutput.fileHandleForReading;
    var lastIncompleteLogLine: String;
    try
      loop begin
        using autoreleasepool do begin
          var d := lHandle.availableData;
          if (d = nil) or (d.length = 0) then begin
            if not (lTask as PlatformProcess).isRunning then
              break;
            NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
            continue;
          end;
          var lOutputString := new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
          if assigned(lOutputString) then
            ProcessStringToLines(lOutputString) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aCallback);
        end;
      end;

      var d := lHandle.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        var lRemainingOutputString := new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
        if assigned(lRemainingOutputString) then
          ProcessStringToLines(lRemainingOutputString) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aCallback);
        d := lHandle.availableData;
      end;

      if length(lastIncompleteLogLine) > 0 then
        aCallback(lastIncompleteLogLine);

      var lError: NSError;
      if available("macOS 10.15") then
        lHandle.closeAndReturnError(var lError)
      else
        lHandle.closeFile();
    except
      on E: Exception do begin
        if not lClosingOutput then
          Log($"Exception processing output from '{aCommand.LastPathComponent}': {E.Message}");
      end;
    finally
      if assigned(aEvent) then
        aEvent.Set();
    end;
  end;

  method CloseOutput(aOutput: nullable NSPipe);
  begin
    if not assigned(aOutput) then
      exit;
    try
      lClosingOutput := true;
      var lError: NSError;
      var lHandle := aOutput.fileHandleForReading;
      if available("macOS 10.15") then
        lHandle.closeAndReturnError(var lError)
      else
        lHandle.closeFile();
    except
      on E: Exception do begin
        Log($"Exception closing output from '{aCommand.LastPathComponent}': {E.Message}");
      end;
    end;
  end;

  method WaitForOutput(aEvent: nullable &Event; aOutput: nullable NSPipe);
  begin
    if not assigned(aEvent) then
      exit;
    if not aEvent:WaitFor(1s) then begin
      CloseOutput(aOutput);
      aEvent:WaitFor(1s);
    end;
  end;

  var lStdOutFinished: nullable &Event;
  var lStdErrFinished: nullable &Event;
  var lStdOutPipe: NSPipe;
  var lStdErrPipe: NSPipe;

  (lTask as PlatformProcess).standardInput := NSFileHandle.fileHandleWithNullDevice;

  if assigned(aStdOutCallback) then begin
    lStdOutFinished := new &Event;
    lStdOutPipe := NSPipe.pipe;
    (lTask as PlatformProcess).standardOutput := lStdOutPipe;
  end;

  if assigned(aStdErrCallback) then begin
    lStdErrFinished := new &Event;
    lStdErrPipe := NSPipe.pipe;
    (lTask as PlatformProcess).standardError := lStdErrPipe;
  end;

  var lStartError: NSError;
  if not (lTask as PlatformProcess).launchAndReturnError(var lStartError) then begin
    if not assigned(aFinishedCallback) then begin
      CloseOutput(lStdOutPipe);
      CloseOutput(lStdErrPipe);

      if assigned(lStartError) then
        raise new NSErrorException withError(lStartError);
      raise new Exception($"Could not start process '{(lTask as PlatformProcess).executableURL:path}'.");
    end;

    var lStartErrorMessage := if assigned(lStartError) then lStartError.description else $"Could not start process '{(lTask as PlatformProcess).executableURL:path}'.";
    async begin
      CloseOutput(lStdOutPipe);
      CloseOutput(lStdErrPipe);
      if assigned(aStdErrCallback) then
        aStdErrCallback(lStartErrorMessage);
      aFinishedCallback(-1);
    end;
    exit;
  end;

  if assigned(aStdOutCallback) then begin
    var lStdOutOutput := lStdOutPipe;
    var lStdOutCallback := aStdOutCallback;
    var lStdOutEvent := lStdOutFinished;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) begin
      HandleOutput(lStdOutOutput, lStdOutCallback, lStdOutEvent)
    end;
  end;

  if assigned(aStdErrCallback) then begin
    var lStdErrOutput := lStdErrPipe;
    var lStdErrCallback := aStdErrCallback;
    var lStdErrEvent := lStdErrFinished;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) begin
      HandleOutput(lStdErrOutput, lStdErrCallback, lStdErrEvent)
    end;
  end;

  if assigned(aFinishedCallback) then async begin
    lTask.WaitFor();
    WaitForOutput(lStdOutFinished, lStdOutPipe);
    WaitForOutput(lStdErrFinished, lStdErrPipe);
    aFinishedCallback(lTask.ExitCode);
  end;
  {$ELSEIF ECHOES}
  var lOutputWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  var lErrorWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  if assigned(aStdOutCallback) then begin
    (lTask as PlatformProcess).StartInfo.RedirectStandardOutput := true;
    (lTask as PlatformProcess).StartInfo.StandardOutputEncoding := System.Text.Encoding.UTF8;
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
    (lTask as PlatformProcess).StartInfo.StandardErrorEncoding := System.Text.Encoding.UTF8;
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

class method Process.SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;
begin
  {$IF TOFFEE}
  var lResult := new PlatformProcess();
  lResult.executableURL := NSURL.fileURLWithPath(aCommand);
  if assigned(aArguments) then
    lResult.arguments := aArguments;
  var lEnvironment: NSMutableDictionary := if assigned(aEnvironment) then aEnvironment.mutableCopy else NSMutableDictionary.dictionaryWithDictionary(NSProcessInfo.processInfo.environment);
  if not assigned(lEnvironment["LANG"]) then lEnvironment["LANG"] := "en_US.UTF-8";
  if not assigned(lEnvironment["LC_ALL"]) then lEnvironment["LC_ALL"] := "en_US.UTF-8";
  if not assigned(lEnvironment["LC_CTYPE"]) then lEnvironment["LC_CTYPE"] := "UTF-8";
  lResult.environment := lEnvironment;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.currentDirectoryURL := NSURL.fileURLWithPath(aWorkingDirectory) isDirectory(true);
  result := lResult;
  {$ELSEIF ECHOES}
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
  {$ENDIF}
end;

{$ENDIF}

class method Process.ProcessStringToLines(rawString: String) LastIncompleteLogLine(out lastIncompleteLogLine: String) Callback(callback: block(aLine: string));
begin
  if length(rawString) > 0 then begin
    if length(rawString) > 0 then begin
      rawString := lastIncompleteLogLine+rawString;
      lastIncompleteLogLine := nil;
    end;
    var lines := rawString.Split(#10);
    for i: Int32 := 0 to lines.Count-1 do begin
      var s := lines[i].Trim(#13);
      if (i = lines.Count-1) and not s.EndsWith(Environment.LineBreak) then begin
        if length(s) > 0 then
          lastIncompleteLogLine := s;
        break;
      end;
      Callback(s);
    end;
  end;
end;

class method Process.QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
begin
  var lNeedsQuoting := length(aArgument) = 0;
  var lBackslashCount := 0;

  if not lNeedsQuoting then begin
    for i: Integer := 0 to length(aArgument)-1 do begin
      var lCharacter := aArgument.Substring(i, 1);
      if (lCharacter = " ") or (lCharacter = #9) or (lCharacter = #10) or (lCharacter = #13) or (lCharacter = #34) or (lCharacter = ";") then begin
        lNeedsQuoting := true;
        break;
      end;
    end;
  end;

  if not lNeedsQuoting then begin
    result := aArgument;
    exit;
  end;

  var lResult := new StringBuilder;
  lResult.Append(#34);

  for i: Integer := 0 to length(aArgument)-1 do begin
    var lCharacter := aArgument.Substring(i, 1);
    if lCharacter = #92 then begin
      inc(lBackslashCount);
    end
    else begin
      if lCharacter = #34 then begin
        for j: Integer := 0 to (lBackslashCount*2) do
          lResult.Append(#92);
        lResult.Append(#34);
        lBackslashCount := 0;
      end
      else begin
        for j: Integer := 0 to lBackslashCount-1 do
          lResult.Append(#92);
        lBackslashCount := 0;
        lResult.Append(lCharacter);
      end;
    end;
  end;

  for j: Integer := 0 to (lBackslashCount*2)-1 do
    lResult.Append(#92);

  lResult.Append(#34);
  result := lResult.ToString as not nullable;
end;

class method Process.SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
begin
  var lResult := new List<String>;
  var lCurrent: String := ""; // why is this needed for lCurrent to not become an NSString?
  var lInQuotes := false;
  var lArgumentStarted := false;
  for i: Integer := 0 to length(aArgumentString)-1 do begin
    var ch := aArgumentString[i];
    case ch of
      ' ', #9: begin
          if lInQuotes then begin
            lCurrent := lCurrent+ch;
          end
          else begin
            if lArgumentStarted then
              lResult.Add(lCurrent);
            lCurrent := "";
            lArgumentStarted := false;
          end;
        end;
      '"': begin
          lInQuotes := not lInQuotes;
          lArgumentStarted := true;
        end;
      else begin
          lCurrent := lCurrent+ch;
          lArgumentStarted := true;
        end;
    end;
  end;

  if lArgumentStarted then
    lResult.Add(lCurrent);

  result := lResult;
end;

class method Process.SplitQuotedCEscapedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
begin
  var lResult := new List<String>;
  var lCurrent: String := ""; // why is this needed for lCurrent to not become an NSString?
  var lInQuotes := false;
  var lArgumentStarted := false;
  var lBackslashCount := 0;
  for i: Integer := 0 to length(aArgumentString)-1 do begin
    var ch := aArgumentString[i];
    if ch = '\' then begin
      inc(lBackslashCount);
      lArgumentStarted := true;
    end
    else begin
      if ch = '"' then begin
        for j: Integer := 0 to (lBackslashCount div 2)-1 do
          lCurrent := lCurrent+'\';

        if (lBackslashCount mod 2) = 0 then begin
          lInQuotes := not lInQuotes;
        end
        else begin
          lCurrent := lCurrent+'"';
        end;

        lArgumentStarted := true;
        lBackslashCount := 0;
      end
      else begin
        for j: Integer := 0 to lBackslashCount-1 do
          lCurrent := lCurrent+'\';
        lBackslashCount := 0;

        case ch of
          ' ', #9: begin
              if lInQuotes then begin
                lCurrent := lCurrent+ch;
                lArgumentStarted := true;
              end
              else begin
                if lArgumentStarted then
                  lResult.Add(lCurrent);
                lCurrent := "";
                lArgumentStarted := false;
              end;
            end;
          else begin
              lCurrent := lCurrent+ch;
              lArgumentStarted := true;
            end;
        end;
      end;
    end;
  end;

  if lBackslashCount > 0 then begin
    for j: Integer := 0 to lBackslashCount-1 do
      lCurrent := lCurrent+'\';
    lArgumentStarted := true;
  end;

  if lArgumentStarted then
    lResult.Add(lCurrent);

  result := lResult;
end;

class method Process.JoinAndQuoteArgumentsForCommandLine(aArguments: not nullable ImmutableList<String>): not nullable String;
begin
  result := "";
  for each a in aArguments do begin
    if assigned(a) then begin
      if length(result) > 0 then
        result := result+" ";
      result := result+QuoteArgumentIfNeeded(a);
    end;
  end;
end;

class method Process.StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable ImmutableList<String>): not nullable String;
begin
  result := QuoteArgumentIfNeeded(aCommand);
  if length(aArguments) > 0 then
    result := result+" "+JoinAndQuoteArgumentsForCommandLine(aArguments);
end;

end.
