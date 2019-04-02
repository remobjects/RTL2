namespace RemObjects.Elements.RTL;

interface

type
  {$IF COOPER}
  PlatformMonitor = public java.util.concurrent.locks.ReentrantLock;
  {$ELSEIF TOFFEE}
  PlatformMonitor = public Foundation.NSRecursiveLock;
  {$ELSEIF ECHOES}
  PlatformMonitor = public System.Threading.ManualResetEvent;
  {$ELSEIF ISLAND}
  PlatformMonitor = public RemObjects.Elements.System.Monitor;
  {$ENDIF};

  Monitor = public class({$IF ISLAND}RemObjects.Elements.System.IMonitor{$ENDIF}) mapped to PlatformMonitor
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
  {$ELSEIF TOFFEE}
  result := new Foundation.NSRecursiveLock();
  {$ELSEIF ECHOES}
  result := new System.Threading.ManualResetEvent(true);
  {$ELSEIF ISLAND}
  result := new RemObjects.Elements.System.Monitor();
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