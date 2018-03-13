namespace RemObjects.Elements.RTL;

{$IF NOT WEBASSEMBLY}

interface

{$IF COOPER}
type PlatformEvent = public java.util.concurrent.locks.ReentrantLock;
{$ELSEIF ECHOES}
type PlatformEvent = public System.Threading.EventWaitHandle;
{$ELSEIF ISLAND}
type PlatformEvent = public RemObjects.Elements.System.EventWaitHandle;
{$ELSEIF TOFFEE}
type PlatformEvent = public NSCondition;
{$ENDIF}

type
  EventMode = public enum(Manual, AutoReset);

  &Event = public class
  private
    fPlatformEvent: PlatformEvent;
    {$IF COOPER}
    fCond: java.util.concurrent.locks.Condition;
    {$ENDIF}
    {$IF COOPER OR TOFFEE}
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
  {$ELSEIF COOPER OR TOFFEE}
  fMode := aMode;
  fState := aState;
  fPlatformEvent := new PlatformEvent;
  {$IF COOPER}
  fCond := fPlatformEvent.newCondition;
  {$ENDIF}
  {$ELSEIF ISLAND}
  fPlatformEvent := new PlatformEvent(aMode = EventMode.AutoReset, aState);
  {$ENDIF}
end;

method &Event.Set;
begin
  {$IF COOPER}
  fPlatformEvent.lock();
  fState := true;
  fCond.signal();
  fPlatformEvent.unlock();
  {$ELSEIF ECHOES OR ISLAND}
  fPlatformEvent.Set();
  {$ELSEIF TOFFEE}
  fPlatformEvent.lock();
  fState := true;
  fPlatformEvent.signal();
  fPlatformEvent.unlock();
  {$ENDIF}
end;

method &Event.Reset;
begin
  {$IF ECHOES OR ISLAND}
  fPlatformEvent.Reset();
  {$ELSEIF COOPER OR TOFFEE}
  fPlatformEvent.lock();
  fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

method &Event.WaitFor;
begin
  {$IF ECHOES}
  fPlatformEvent.WaitOne();
  {$ELSEIF COOPER OR TOFFEE}
  fPlatformEvent.lock();
  while not fState do
  {$IF COOPER}
    fCond.await();
  {$ELSE}
    fPlatformEvent.wait();
  {$ENDIF}
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ELSEIF ISLAND}
  fPlatformEvent.Wait();
  {$ENDIF}
end;

method &Event.WaitFor(aTimeoutInMilliseconds: Int32);
begin
  {$IF COOPER}
  fPlatformEvent.lock();
  if not fState then
    fCond.await(aTimeoutInMilliseconds, java.util.concurrent.TimeUnit.MILLISECONDS);
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ELSEIF ECHOES}
  fPlatformEvent.WaitOne(aTimeoutInMilliseconds);
  {$ELSEIF ISLAND}
  fPlatformEvent.Wait(aTimeoutInMilliseconds);
  {$ELSEIF TOFFEE}
  WaitFor(TimeSpan.FromMilliseconds(aTimeoutInMilliseconds));
  {$ENDIF}
end;

method &Event.WaitFor(aTimeout: Timespan);
begin
  {$IF COOPER}
  WaitFor(Int32(aTimeout.TotalMilliSeconds));
  {$ELSEIF ECHOES}
  fPlatformEvent.WaitOne(aTimeout);
  {$ELSEIF ISLAND}
  fPlatformEvent.Wait(Int32(aTimeout.TotalMilliSeconds));
  {$ELSEIF TOFFEE}
  fPlatformEvent.lock();
  var lWaitTime := DateTime.UtcNow.Add(aTimeout);
  if not fState then
    fPlatformEvent.waitUntilDate(lWaitTime);
  if fMode = EventMode.AutoReset then
    fState := false;
  fPlatformEvent.unlock();
  {$ENDIF}
end;

{$ENDIF}

end.