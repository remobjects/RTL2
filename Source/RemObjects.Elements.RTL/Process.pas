namespace RemObjects.Elements.RTL;

interface

{$IF (ECHOES OR MACOS OR WINDOWS) AND NOT MACCATALYST} // OR LINUX

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
  private
    class method SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;
  assembly
    class method ProcessStringToLines(rawString: String) LastIncompleteLogLine(out lastIncompleteLogLine: String) Callback(callback: block(aLine: String));
  protected
  public

    method WaitFor; inline;
    method Start; inline;
    method Stop; inline;

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
  end;

implementation

{$IF (ECHOES OR MACOS OR WINDOWS) AND NOT MACCATALYST} // OR LINUX

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

method Process.Start;
begin
  {$IF TOFFEE}
  mapped.launch();
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
    lTask.Start();
    lTask.WaitFor();

    var error: NSError;
    var lStdOutData := stdOut.readDataToEndOfFileAndReturnError(var error);
    //aStdOut := new array of Byte withNSData(stdOutData);
    aStdOut := new Byte[lStdOutData.length];
    lStdOutData.getBytes(@aStdOut[0]) length(lStdOutData.length);
    stdOut.closeAndReturnError(var error);

    var lStdErrData := stdErr.readDataToEndOfFileAndReturnError(var error);
    //aStdErr := new array of Byte withNSData(stdErrData);
    aStdErr := new Byte[lStdErrData.length];
    lStdErrData.getBytes(@aStdErr[0]) length(lStdErrData.length);
    stdErr.closeAndReturnError(var error);
  end;
  {$ELSEIF ECHOES}
  var lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  (lTask as PlatformProcess).StartInfo.RedirectStandardOutput := true;
  (lTask as PlatformProcess).StartInfo.RedirectStandardError := true;
  lTask.Start();
  lTask.WaitFor();
  using m := new MemoryStream do begin
    (lTask as PlatformProcess).StandardOutput.BaseStream.CopyTo(m);
    aStdOut := m.ToArray;
  end;
  using m := new MemoryStream do begin
    (lTask as PlatformProcess).StandardError.BaseStream.CopyTo(m);
    aStdOut := m.ToArray;
  end;
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
  var lStdOutFinished := if assigned(aStdOutCallback) then new &Event;
  var lStdErrFinished := if assigned(aStdErrCallback) then new &Event;
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
            ProcessStringToLines(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aStdOutCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdOut.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        ProcessStringToLines(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aStdOutCallback);
        d := stdOut.availableData;
      end;
      if length(lastIncompleteLogLine) > 0 then
        aStdOutCallback(lastIncompleteLogLine);
      var lError: NSError;
      if available("macOS 10.15") then
        stdOut.closeAndReturnError(var lError)
      else
        stdOut.closeFile();
      lStdOutFinished.Set();
    end);

  if assigned(aStdErrCallback) then
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
      var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
      var lastIncompleteLogLine: String;
      while (lTask as PlatformProcess).isRunning do begin
        using autoreleasepool do begin
          var d := stdErr.availableData;
          if (d ≠ nil) and (d.length > 0) then
            ProcessStringToLines(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aStdErrCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdErr.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        ProcessStringToLines(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) LastIncompleteLogLine(out lastIncompleteLogLine) Callback(aStdErrCallback);
        d := stdErr.availableData;
      end;
      if length(lastIncompleteLogLine) > 0 then
        aStdOutCallback(lastIncompleteLogLine);
      var lError: NSError;
      if available("macOS 10.15") then
        stdErr.closeAndReturnError(var lError)
      else
        stdErr.closeFile();
      lStdErrFinished.Set();
    end);

  lTask.Start();

  if assigned(aFinishedCallback) then async begin
    lTask.WaitFor();
    lStdOutFinished:WaitFor();
    lStdErrFinished:WaitFor();
    aFinishedCallback(lTask.ExitCode);
  end;
  {$ELSEIF ECHOES}
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

class method Process.ProcessStringToLines(rawString: String) LastIncompleteLogLine(out lastIncompleteLogLine: String) Callback(callback: block(aLine: string));
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
      Callback(s);
    end;
  end;
end;

class method Process.SetUpTask(aCommand: String; aArguments: ImmutableList<String>; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Process;
begin
  {$IF TOFFEE}
  var lResult := new PlatformProcess();
  lResult.launchPath := aCommand;
  if assigned(aArguments) then
    lResult.arguments := aArguments;
  if assigned(aEnvironment) then
    lResult.environment := aEnvironment;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.currentDirectoryPath := aWorkingDirectory;
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

class method Process.QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
begin
  result := aArgument;
  if result.Contains(" ") or result.Contains(";") then
    result := String('"'+result.Replace('"', '\"')+'"')
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

class method Process.SplitQuotedCEscapedArgumentString(aArgumentString: not nullable String): not nullable ImmutableList<String>;
begin
  var lResult := new List<String>;
  var lCurrent: String := ""; // why is this needed for lCurrent to not become an NSString?
  var lInQuotes := false;
  var lEscaped := false;
  for i: Integer := 0 to length(aArgumentString)-1 do begin
    var ch := aArgumentString[i];
    if lEscaped then begin
      lCurrent := lCurrent+ch;
    end
    else begin
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
        '\': begin
            if lInQuotes then begin
              lEscaped := true;
            end
            else begin
              lCurrent := lCurrent+ch;
            end;
          end;
        '"': lInQuotes := not lInQuotes;
        else begin
            lCurrent := lCurrent+ch;
          end;
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
    if length(a) > 0 then begin
      if length(result) > 0 then
        result := result+" ";
      result := result+QuoteArgumentIfNeeded(a);
    end;
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

end.