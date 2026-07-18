namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units,
  RemObjects.Elements.EUnit;

type
  ProcessArgumentTests = public class(Test)
  public

    method SplitQuotedArgumentStringPreservesEmptyQuotedArguments;
    begin
      var lArguments := RemObjects.Elements.RTL.Process.SplitQuotedArgumentString('  one "two words" "" three'+#9+'four  ');

      Check.AreEqual(5, lArguments.Count);
      Check.AreEqual("one", lArguments[0]);
      Check.AreEqual("two words", lArguments[1]);
      Check.AreEqual("", lArguments[2]);
      Check.AreEqual("three", lArguments[3]);
      Check.AreEqual("four", lArguments[4]);
    end;

    method JoinAndSplitQuotedCEscapedArgumentsRoundTrip;
    begin
      var lOriginal := ["plain", "two words", "", 'a"b', 'trailing\', 'path with slash\', "semi;colon", "tab"+#9+"value"].ToList;
      var lCommandLine := RemObjects.Elements.RTL.Process.JoinAndQuoteArgumentsForCommandLine(lOriginal);
      var lParsed := RemObjects.Elements.RTL.Process.SplitQuotedCEscapedArgumentString(lCommandLine);

      Check.AreEqual(lOriginal.Count, lParsed.Count);
      for i: Integer := 0 to lOriginal.Count-1 do
        Check.AreEqual(lOriginal[i], lParsed[i]);
    end;

    method JoinSkipsNilButPreservesEmptyArguments;
    begin
      var lOriginal := new List<String>;
      lOriginal.Add(nil);
      lOriginal.Add("");
      lOriginal.Add("value");

      Check.AreEqual('"" value', RemObjects.Elements.RTL.Process.JoinAndQuoteArgumentsForCommandLine(lOriginal));
    end;

  end;

{$IF TOFFEE AND MACOS}
  ProcessTests = public class(Test)
  public

    method WaitForAcceptsTypedTimeouts;
    begin
      using lTask := RemObjects.Elements.RTL.Process.RunAsync("/bin/sh", ["-c", "/bin/sleep 1"]) do begin
        Check.IsFalse(lTask.WaitFor(100 Milliseconds));
        Check.IsTrue(lTask.WaitFor(2 Seconds));
      end;
    end;

    method RunAsyncFinishesWhenChildKeepsStdOutOpen;
    begin
      var lFinished := new &Event;
      var lSawOutput := new &Event;
      var lExitCode := -1;

      using lTask := RemObjects.Elements.RTL.Process.RunAsync("/bin/sh",
          ["-c", "echo process-runasync-parent-done; /bin/sleep 5 &"],
          nil,
          nil,
          method(aLine: String) begin
            if aLine = "process-runasync-parent-done" then
              lSawOutput.Set();
          end,
          nil,
          method(aExitCode: Integer) begin
            lExitCode := aExitCode;
            lFinished.Set();
          end) do begin
        Check.IsTrue(lSawOutput:WaitFor(1 Seconds));
        Check.IsTrue(lFinished:WaitFor(3 Seconds));
        Check.AreEqual(0, lExitCode);
      end;
    end;

  end;
{$ENDIF}

end.
