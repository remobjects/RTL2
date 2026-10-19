// Positive timing guard: the public RTL Stopwatch measures subsecond intervals,
// accumulates elapsed time, and resets on Start. This is not a performance assertion.
namespace Elements.RTL2.Tests.Shared;

uses RemObjects.Elements.RTL, RemObjects.Elements.RTL.Units, RemObjects.Elements.EUnit;

type
  {$IF RTL_STOPWATCH_SOURCE_TEST}
  Stopwatch = RemObjects.Elements.RTL.SourceTestStopwatch;
  {$ENDIF}

  StopwatchTest = public class(Test)
  public

    method SubsecondIntervalsAndRestart;
    begin
      var lWatch := new Stopwatch;
      for i := 1 to 3 do begin
        lWatch.Start;
        var lInitial :=  lWatch.ElapsedTime;
        Thread.Sleep(20 Milliseconds);
        var lElapsed :=  lWatch.ElapsedTime;
        Assert.IsTrue(lElapsed >= lInitial + 10 Milliseconds);
        Assert.IsTrue(lWatch.ElapsedTime >= lElapsed);
      end;
    end;

  end;
end.
