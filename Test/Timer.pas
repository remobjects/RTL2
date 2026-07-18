namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units,
  RemObjects.Elements.EUnit;

{$IF NOT TOFFEE}
// For OS X and iOS an NSRunLoop is needed
type
  TimerTests = public class(Test)
  public

    method TestBasicTimer;
    begin
      var lTest := 0;
      var lTimer := new RemObjects.Elements.RTL.Timer(100 Milliseconds, (aData) -> begin inc(lTest, 1); end);
      lTimer.Start;
      Thread.Sleep(350 Milliseconds);
      lTimer.Stop;
      Check.IsTrue(lTest > 1);
    end;

    method TestNoRepeatTimer;
    begin
      var lTest := 0;
      var lTimer := new RemObjects.Elements.RTL.Timer(100 Milliseconds, false, (aData) -> begin inc(lTest, 1); end);
      lTimer.Start;
      Thread.Sleep(500 Milliseconds);
      lTimer.Stop;
      Check.AreEqual(lTest, 1);
    end;
  end;
{$ENDIF}

end.
