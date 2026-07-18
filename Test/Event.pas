namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units,
  RemObjects.Elements.EUnit;

type
  EventTests = public class(Test)
  public

    method IntegerTimeoutOverloadReturnsSignaledState;
    begin
      var lEvent := new &Event withState(true) Mode(EventMode.Manual);

      Check.IsTrue(lEvent.WaitFor(1));
    end;

    method IntegerTimeoutOverloadPreservesAutoResetBehavior;
    begin
      var lEvent := new &Event;
      lEvent.Set;

      Check.IsTrue(lEvent.WaitFor(1));
      Check.IsFalse(lEvent.WaitFor(1));
    end;

    method UnitTimeoutPreservesAutoResetBehavior;
    begin
      var lEvent := new &Event;
      lEvent.Set;

      Check.IsTrue(lEvent.WaitFor(1 Milliseconds));
      Check.IsFalse(lEvent.WaitFor(1 Milliseconds));
    end;

    method TimeSpanTimeoutUsesTotalDuration;
    begin
      var lEvent := new &Event;
      async begin
        Thread.Sleep(100 Milliseconds);
        lEvent.Set;
      end;

      Check.IsTrue(lEvent.WaitFor(TimeSpan.From(2 Seconds)));
    end;

  end;

end.
