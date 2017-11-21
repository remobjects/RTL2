namespace RemObjects.Elements.RTL;

interface

{$IF ECHOES}
type PlatformEvent = System.Threading.EventWaitHandle;
{$ELSEIF TOFFEE}
type PlatformEvent = NSCondition;
{$ENDIF}

type
  EventMode = public enum(Manual, AutoReset);

  &Event = public class
  private
    fPlatformEvent: PlatformEvent;
    {$IF TOFFEE}
    fMode: EventMode;
    fState: Boolean;
    {$ENDIF}
  protected
  public
    constructor withState(aState: Boolean := false) mode(aMode: EventMode := EventMode.AutoReset);

    method &Set;
    method Reset;
    method WaitFor;
    method WaitFor(aTimeoutInMilliseconds: Int32);
    method WaitFor(aTimeout: TimeSpan);
  end;

implementation

constructor &Event withState(aState: Boolean := false) mode(aMode: EventMode := EventMode.AutoReset);
begin
  {$IF ECHOES}
  fPlatformEvent := if aMode = EventMode.AutoReset then new System.Threading.AutoResetEvent(aState) else new System.Threading.ManualResetEvent(aState);
  {$ELSEIF TOFFEE}
  fMode := aMode;
  fState := aState;
  fPlatformEvent := new NSCondition;
  {$ENDIF}
end;

method &Event.Set;
begin
  {$IF ECHOES}
  fPlatformEvent.Set();
  {$ELSEIF TOFFEE}
  fPlatformEvent.lock();
  fState := true;
  fPlatformEvent.unlock();
  fPlatformEvent.signal();
  {$ENDIF}
end;

method &Event.Reset;
begin
  {$IF ECHOES}
  fPlatformEvent.Reset();
  {$ELSEIF TOFFEE}
  fPlatformEvent.lock();
  fState := false;
  fPlatformEvent.unlock();
  fPlatformEvent.signal();
  {$ENDIF}
end;

method &Event.WaitFor;
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne();
  {$ELSEIF TOFFEE}
  fPlatformEvent.lock();
  while not fState do
    fPlatformEvent.wait();
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

method &Event.WaitFor(aTimeoutInMilliseconds: Int32);
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne(aTimeoutInMilliseconds);
  {$ELSE IF TOFFEE}
  fPlatformEvent.lock();
  var lWaitTime := DateTime.UtcNow.AddMilliseconds(aTimeoutInMilliseconds);
  while not fState do
    fPlatformEvent.waitUntilDate(lWaitTime);
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

method &Event.WaitFor(aTimeout: Timespan);
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne(aTimeout);
  {$ELSE IF TOFFEE}
  fPlatformEvent.lock();
  var lWaitTime := DateTime.UtcNow.Add(aTimeout);
  while not fState do
    fPlatformEvent.waitUntilDate(lWaitTime);
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

end.