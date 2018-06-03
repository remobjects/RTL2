namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

{$IF NOT TOFFEE}
// For OS X and iOS an NSRunLoop is needed
type
  TimerTests = public class(Test)
  private
  protected
  public
    method TestBasicTimer;
    begin
      var lTimer := new RemObjects.Elements.RTL.Timer(100);
      var lTest := 0;
      lTimer.Elapsed := (aData) -> begin
        inc(lTest, 1);
      end;
      lTimer.Start;
      Thread.Sleep(350);
      lTimer.Stop;
      Assert.IsTrue(lTest > 1);
    end;

    method TestNoRepeatTimer;
    begin
      var lTimer := new RemObjects.Elements.RTL.Timer(100);
      var lTest := 0;
      lTimer.Repeat := false;
      lTimer.Elapsed := (aData) -> begin
        inc(lTest, 1);
      end;
      lTimer.Start;
      Thread.Sleep(500);
      lTimer.Stop;
      Assert.AreEqual(lTest, 1);
    end;
  end;
{$ENDIF}

end.