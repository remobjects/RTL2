namespace RemObjects.Elements.RTL;

interface

type
TimerElapsedBlock = public block (aData: Object);
PlatformTimer = public {$IF COOPER}java.util.Timer{$ELSEIF ECHOES}System.Timers.Timer{$ELSEIF ISLAND}RemObjects.Elements.System.Timer{$ELSEIF TOFFEE}NSTimer{$ENDIF};

Timer = public class
private
  fTimer: PlatformTimer;
  fElapsed: TimerElapsedBlock;
  fEnabled: Boolean;
  fInterval: Integer := 100;
  fRepeat: Boolean := true;
  method SetRepeat(value: Boolean);
  method SetInterval(value: Integer);
  method SetEnabled(value: Boolean);
  method CheckIfEnabled;
  method Initialize;
  {$IF ECHOES}
  method ElapsedEventHandler(Sender: Object; e: System.Timers.ElapsedEventArgs);
  {$ENDIF}
public
  constructor;
  constructor(aInterval: Integer);
  constructor(aInterval: Integer; aRepeat: Boolean);
  method Start;
  method Stop;
  property Enabled: Boolean read fEnabled write SetEnabled;
  property Interval: Integer read fInterval write SetInterval;
  property &Repeat: Boolean read fRepeat write SetRepeat;
  property Elapsed: TimerElapsedBlock read fElapsed write fElapsed;
  property Data: Object;
end;

implementation

method Timer.Initialize;
begin
  {$IF COOPER OR ECHOES OR ISLAND}
  fTimer := new PlatformTimer();
  {$ENDIF}
  {$IF ECHOES}
  fTimer.Elapsed += ElapsedEventHandler;
  {$ENDIF}
  {$IF ISLAND}
  fTimer.Elapsed := () -> begin
    Elapsed(Data);
    end;
  {$ENDIF}
end;

constructor Timer;
begin
  Initialize;
end;

constructor Timer(aInterval: Integer);
begin
  constructor;
  fInterval := aInterval;
end;

constructor Timer(aInterval: Integer; aRepeat: Boolean);
begin
  constructor;
  fInterval := aInterval;
  fRepeat := aRepeat;
end;

method Timer.SetEnabled(value: Boolean);
begin
  if value <> fEnabled then begin
    if fEnabled then Start
    else Stop;
  end;
end;

method Timer.SetInterval(value: Integer);
begin
  CheckIfEnabled;
  fInterval := value;
end;

method Timer.SetRepeat(value: Boolean);
begin
  CheckIfEnabled;
  fRepeat := value;
end;

method Timer.Start;
begin
  if fEnabled then exit;
  {$IF COOPER}
  if fRepeat then
    fTimer.scheduleAtFixedRate(new FixedTimerTask(self), fInterval, fInterval)
  else
    fTimer.schedule(new FixedTimerTask(self), fInterval);
  {$ELSEIF ECHOES}
  fTimer.AutoReset := fRepeat;
  fTimer.Interval := fInterval;
  fTimer.Start;
  {$ELSEIF ISLAND}
  fTimer.Interval := fInterval;
  fTimer.Repeat := fRepeat;
  fTimer.Start;
  {$ELSEIF TOFFEE}
  fTimer := PlatformTimer.scheduledTimerWithTimeInterval(fInterval / 1000) repeats(fRepeat) &block(() -> begin Elapsed(Data); end);
  {$ENDIF}
  fEnabled := true;
end;

method Timer.Stop;
begin
  if not fEnabled then exit;
  {$IF COOPER}
  fTimer.cancel;
  {$ELSEIF ECHOES}
  fTimer.Stop;
  {$ELSEIF ISLAND}
  fTimer.Stop;
  {$ELSEIF TOFFEE}
  fTimer.invalidate;
  {$ENDIF}
  fEnabled := false;
end;

method Timer.CheckIfEnabled;
begin
  if fEnabled then
    raise new Exception('Can not change properties in enabled timer');
end;

{$IF COOPER}
type
  FixedTimerTask = class(java.util.TimerTask)
  private
    fTimer: Timer;
  public
    constructor(aTimer: Timer);
    begin
      fTimer := aTimer;
    end;

    method run; override;
    begin
      fTimer.Elapsed(fTimer.Data);
    end;
  end;
{$ENDIF}

{$IF ECHOES}
method Timer.ElapsedEventHandler(Sender: Object; e: System.Timers.ElapsedEventArgs);
begin
  Elapsed(Data);
end;
{$ENDIF}

end.