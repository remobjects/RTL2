namespace RemObjects.Elements.RTL;

{$IF NOT WEBASSEMBLY}

interface

type
  {$IF COOPER}
  PlatformThread = public java.lang.Thread;
  {$ELSEIF ECHOES}
  PlatformThread = public System.Threading.Thread;
  {$ELSEIF ISLAND}
  PlatformThread = public RemObjects.Elements.System.Thread;
  {$ELSEIF TOFFEE}
  PlatformThread = public Foundation.NSThread;
  {$ENDIF}

  Thread = public class mapped to PlatformThread
  private
    method GetPriority: ThreadPriority;
    method SetPriority(Value: ThreadPriority);
    {$IF TOFFEE}
    method GetThreadID: IntPtr;
    {$ENDIF}
  public
    constructor (aEntrypoint: not nullable block);
    method Start; mapped to Start;

    {$IF COOPER OR ECHOES}
    method &Join; mapped to &Join;
    method &Join(Timeout: Integer);  mapped to &Join(Timeout);
    {$ENDIF}
    {$IF TOFFEE}
    method &Join;
    method &Join(Timeout: Integer);
    {$ENDIF}

    {$HIDE W28}
    method Abort; mapped to {$IF ECHOES OR ISLAND}Abort{$ELSEIF COOPER}stop{$ELSEIF TOFFEE}cancel{$ENDIF};
    {$SHOW W28}
    class method Sleep(aTimeout: Integer); mapped to {$IF COOPER OR ECHOES OR ISLAND}Sleep(aTimeout){$ELSEIF TOFFEE}sleepForTimeInterval(aTimeout / 1000){$ENDIF};

    //property State: ThreadState read GetState write SetState;
    property IsAlive: Boolean read {$IF COOPER OR ECHOES OR ISLAND}mapped.IsAlive{$ELSEIF TOFFEE}mapped.isExecuting{$ENDIF};
    property Name: String read mapped.Name write {$IF COOPER OR ECHOES OR ISLAND}mapped.Name{$ELSEIF TOFFEE}mapped.setName{$ENDIF};

    {$IF COOPER OR ECHOES}
    property ThreadId: Int64 read {$IF COOPER}mapped.Id{$ELSEIF ECHOES}mapped.ManagedThreadId{$ENDIF};
    {$ELSEIF TOFFEE}
    property ThreadId: IntPtr read GetThreadID;
    {$ENDIF}

    property Priority: ThreadPriority read GetPriority write SetPriority;

    {$IF TOFFEE}class property MainThread: Thread read mapped.mainThread;{$ENDIF}

    {$IF ISLAND}[Error("Not Implemented for Island")]{$ENDIF}
    class property CurrentThread: Thread read {$IF NOT ISLAND}mapped.currentThread{$ELSE}nil{$ENDIF};

    class method &Async(aBlock: block);
    begin
      async aBlock();
    end;

    {$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
    {$IF ECHOES}[Warning("Not Implemented for Echoes")]{$ENDIF}
    property CallStack: List<String> read
    begin
      {$IF COOPER}
      result := mapped.getStackTrace().ToList() as not nullable;
      {$ELSEIF ECHOES}
      result := new ImmutableList<String>("Call stack not available."); {$WARNING Not implemented/supported for Island yet}
      {$ELSEIF ISLAND}
      result := new ImmutableList<String>("Call stack not available."); {$WARNING Not implemented/supported for Island yet}
      {$ELSEIF TOFFEE}
      result := mapped.callStackSymbols as List<String>;
      {$ENDIF}
    end;


    {$IF ISLAND}[Warning("Not Implemented for Island")]{$ENDIF}
    class property CurrentCallStack: not nullable ImmutableList<String> read
    begin
      {$IF COOPER}
      result := new Throwable().getStackTrace().ToList() as not nullable;
      {$ELSEIF ECHOES}
      result := (System.Environment.StackTrace.Replace(#13, "") as String).Split(#10);
      {$ELSEIF ISLAND}
      result := new ImmutableList<String>("Call stack not available."); {$WARNING Not implemented/supported for Island yet}
      {$ELSEIF TOFFEE}
      result := NSThread.callStackSymbols as not nullable;
      {$ENDIF}
    end;
  end;

  ThreadState = public enum(
    Unstarted,
    Running,
    Waiting,
    Stopped
  );

  ThreadPriority = public enum(
    Lowest,
    BelowNormal,
    Normal,
    AboveNormal,
    Highest
  );

  {$IF COOPER}
  BlockRunnable = unit class(Runnable)
  private
    var fBlock: block;
    method Run();
    begin
      fBlock();
    end;
  unit
    constructor(aBlock: block);
    begin
      fBlock := aBlock;
    end;
  end;
  {$ENDIF}

implementation

constructor Thread(aEntrypoint: not nullable block);
begin
  {$IF COOPER}
  result := new PlatformThread(new BlockRunnable(aEntrypoint));
  {$ELSEIF ECHOES}
  result := new PlatformThread(a -> aEntrypoint());
  {$ELSEIF ISLAND}
  result := new PlatformThread(a -> aEntrypoint());
  {$ELSEIF TOFFEE}
  result := new PlatformThread withBlock(aEntrypoint);
  {$ENDIF}
end;

{$IF TOFFEE}
{$ENDIF}

method Thread.GetPriority: ThreadPriority;
begin
  {$IF ECHOES}
  exit ThreadPriority(mapped.Priority);
  {$ELSEIF COOPER}
  case mapped.Priority of
    1,2: exit ThreadPriority.Lowest;
    3,4: exit ThreadPriority.BelowNormal;
    5: exit ThreadPriority.Normal;
    6,7: exit ThreadPriority.AboveNormal;
    8,9,10: exit ThreadPriority.Highest;
  end;
  {$ENDIF}
end;

method Thread.SetPriority(Value: ThreadPriority);
begin
  {$IF ECHOES}
  mapped.Priority := System.Threading.ThreadPriority(Value);
  {$ELSEIF COOPER}
  case Value of
    ThreadPriority.Lowest: mapped.Priority := 2;
    ThreadPriority.BelowNormal: mapped.Priority := 4;
    ThreadPriority.Normal: mapped.Priority := 5;
    ThreadPriority.AboveNormal: mapped.Priority := 7;
    ThreadPriority.Highest: mapped.Priority := 9;
  end;
  {$ENDIF}
end;

{$IF TOFFEE}
method Thread.GetThreadID: IntPtr;
begin
  result := valueForKeyPath("private.seqNum").integerValue;
end;

method Thread.&Join;
begin
end;

method Thread.&Join(Timeout: Integer);
begin

end;
{$ENDIF}

{$ENDIF}

end.