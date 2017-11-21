namespace RemObjects.Elements.RTL;

interface

{$IF ECHOES}
type PlatformEvent = System.Threading.EventWaitHandle;
{$ENDIF}

type
  &Event = public class
  private
    fPlatformEvent: PlatformEvent;
  protected
  public
    constructor withState(aState: Boolean := false) mode(aAutoReset: Boolean := true);

    method &Set;
    method Reset;
    method WaitFor;
    method WaitFor(aTimeoutInMiliseconds: Int32);
    method WaitFor(aTimeout: TimeSpan);
  end;

implementation

constructor &Event withState(aState: Boolean := false) mode(aAutoReset: Boolean := true);
begin
  {$IF ECHOES}
  fPlatformEvent := if aAutoReset then new System.Threading.AutoResetEvent(aState) else new System.Threading.ManualResetEvent(aState);
  {$ENDIF}
end;

method &Event.Set;
begin
  {$IF ECHOES}
  fPlatformEvent.Set();
  {$ENDIF}
end;

method &Event.Reset;
begin
  {$IF ECHOES}
  fPlatformEvent.Reset();
  {$ENDIF}
end;

method &Event.WaitFor;
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne();
  {$ENDIF}
end;

method &Event.WaitFor(aTimeoutInMiliseconds: Int32);
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne(aTimeoutInMiliseconds);
  {$ENDIF}
end;

method &Event.WaitFor(aTimeout: Timespan);
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne(aTimeout);
  {$ENDIF}
end;

end.