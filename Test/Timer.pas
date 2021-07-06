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
      var lTest := 0;
      var lTimer := new RemObjects.Elements.RTL.Timer(100, (aData) -> begin inc(lTest, 1); end);
      //lTimer.Elapsed := (aData) -> begin
        //inc(lTest, 1);
      //end;
      lTimer.Start;
      Thread.Sleep(350);
      lTimer.Stop;
      Check.IsTrue(lTest > 1);
    end;

    method TestNoRepeatTimer;
    begin
      var lTest := 0;
      var lTimer := new RemObjects.Elements.RTL.Timer(100, false, (aData) -> begin inc(lTest, 1); end);

      //lTimer.Repeat := false;
      //lTimer.Elapsed := (aData) -> begin
        //inc(lTest, 1);
      //end;
      lTimer.Start;
      Thread.Sleep(500);
      lTimer.Stop;
      Check.AreEqual(lTest, 1);
    end;
  end;
{$ENDIF}

end.