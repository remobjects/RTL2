namespace RemObjects.Elements.RTL;

interface

type
  PlatformMonitor = {$IF COOPER}java.util.concurrent.locks.ReentrantLock{$ELSEIF ECHOES}System.Threading.ManualResetEvent{$ELSEIF ISLAND}RemObjects.Elements.System.Monitor{$ELSEIF TOFFEE}Foundation.NSRecursiveLock{$ENDIF};

  Monitor = public class mapped to PlatformMonitor
  public
    constructor;
    method Lock;
    method Unlock;
  end;

implementation

constructor Monitor;
begin
  {$IF COOPER}
  result := new java.util.concurrent.locks.ReentrantLock();
  {$ELSEIF ECHOES}
  result := new System.Threading.ManualResetEvent(true);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.Monitor();
  {$ELSEIF TOFFEE}
  result := new Foundation.NSRecursiveLock();
  {$ENDIF}
end;

method Monitor.Lock;
begin
  {$IF COOPER OR TOFFEE}
  mapped.lock;
  {$ELSEIF ECHOES}
  mapped.WaitOne;
  {$ELSEIF ISLAND}
  mapped.Wait;
  {$ENDIF}
end;

method Monitor.Unlock;
begin
  {$IF COOPER OR TOFFEE}
  mapped.unlock;
  {$ELSEIF ECHOES}
  mapped.Set;
  {$ELSEIF ISLAND}
  mapped.Release;
  {$ENDIF}
end;


end.