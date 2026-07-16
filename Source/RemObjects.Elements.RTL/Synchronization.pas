namespace RemObjects.Elements.RTL;

interface

type
  {$IF COOPER}
  PlatformMonitor = public java.util.concurrent.locks.ReentrantLock;
  {$ELSEIF ISLAND}
  PlatformMonitor = public RemObjects.Elements.System.Monitor;
  {$ELSEIF TOFFEE}
  PlatformMonitor = public Foundation.NSRecursiveLock;
  {$ELSEIF ECHOES}
  PlatformMonitor = public System.Threading.ManualResetEvent;
  {$ENDIF}

  Monitor = public class({$IF ISLAND AND NOT TOFFEE}RemObjects.Elements.System.IMonitor{$ENDIF}) mapped to PlatformMonitor
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
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.Monitor();
  {$ELSEIF TOFFEE}
  result := new Foundation.NSRecursiveLock();
  {$ELSEIF ECHOES}
  result := new System.Threading.ManualResetEvent(true);
  {$ENDIF}
end;

method Monitor.Lock;
begin
  {$IF ISLAND}
  mapped.Wait;
  {$ELSEIF COOPER OR TOFFEE}
  mapped.lock;
  {$ELSEIF ECHOES}
  mapped.WaitOne;
  {$ENDIF}
end;

method Monitor.Unlock;
begin
  {$IF ISLAND}
  mapped.Release;
  {$ELSEIF COOPER OR TOFFEE}
  mapped.unlock;
  {$ELSEIF ECHOES}
  mapped.Set;
  {$ENDIF}
end;


end.