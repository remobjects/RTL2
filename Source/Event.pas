namespace RemObjects.Elements.RTL;

interface

{$IF ECHOES}
type PlatformEvent = System.Threading.EventWaitHandle;
{$ELSEIF TOFFEE}
type PlatformEvent = NSCondition;
{$ENDIF}

type
  &Event = public class
  private
    fPlatformEvent: PlatformEvent;
    {$IF TOFFEE}
    fAutoReset: Boolean;
    fState: Boolean;
    {$ENDIF}
  protected
  public
    constructor withState(aState: Boolean := false) mode(aAutoReset: Boolean := true);

    method &Set;
    method Reset;
    method WaitFor;
    method WaitFor(aTimeoutInMilliseconds: Int32);
    method WaitFor(aTimeout: TimeSpan);
  end;

implementation

constructor &Event withState(aState: Boolean := false) mode(aAutoReset: Boolean := true);
begin
  {$IF ECHOES}
  fPlatformEvent := if aAutoReset then new System.Threading.AutoResetEvent(aState) else new System.Threading.ManualResetEvent(aState);
  {$ELSEIF TOFFEE}
  fAutoReset := aAutoReset;
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
  if fAutoReset then
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
  if fAutoReset then
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
  if fAutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

end.