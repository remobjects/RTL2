namespace RemObjects.Elements.RTL;

interface

uses
  RemObjects.Elements.RTL.Units;

type
  PlatformTimer = public {$IF COOPER}java.util.Timer{$ELSEIF TOFFEE}NSTimer{$ELSEIF ECHOES}System.Timers.Timer{$ELSEIF ISLAND}RemObjects.Elements.System.Timer{$ENDIF};

  Timer = public class
  private
    fTimer: PlatformTimer;
    fEnabled: Boolean;
    fInterval: Milliseconds;
    fRepeat: Boolean;
    fCallback: block(aTimer: Timer); unit;
    method CheckIfEnabled;
  public
    [Obsolete("Use the unit-typed interval overload")]
    constructor(aInterval: Integer; aRepeat: Boolean := true; aCallback: block(aTimer: Timer));
    constructor(aInterval: Milliseconds; aRepeat: Boolean := true; aCallback: block(aTimer: Timer));
    method Start;
    method Stop;
    property Interval: Milliseconds read fInterval;
    property &Repeat: Boolean read fRepeat;
    property Enabled: Boolean read fEnabled;
  end;

implementation

constructor Timer(aInterval: Integer; aRepeat: Boolean := true; aCallback: block(aTimer: Timer));
begin
  constructor(Milliseconds(aInterval), aRepeat, aCallback);
end;

constructor Timer(aInterval: Milliseconds; aRepeat: Boolean := true; aCallback: block(aTimer: Timer));
begin
  fInterval := aInterval;
  fRepeat := aRepeat;
  fCallback := aCallback;

  {$IF NOT TOFFEE}
  fTimer := new PlatformTimer();
  {$ENDIF}
  {$IF ECHOES}
  fTimer.Elapsed += () -> fCallback(self);
  {$ENDIF}
  {$IF ISLAND AND NOT TOFFEE}
  fTimer.Elapsed := () -> fCallback(self);
  {$ENDIF}
end;

method Timer.Start;
begin
  if fEnabled then exit;
  {$IF COOPER}
  if fRepeat then
    fTimer.scheduleAtFixedRate(new FixedTimerTask(self), Int64(fInterval), Int64(fInterval))
  else
    fTimer.schedule(new FixedTimerTask(self), Int64(fInterval));
  {$ELSEIF TOFFEE}
  fTimer := PlatformTimer.scheduledTimerWithTimeInterval(Double(Seconds(fInterval))) repeats(fRepeat) &block(() -> fCallback(Self));
  {$ELSEIF ECHOES}
  fTimer.AutoReset := fRepeat;
  fTimer.Interval := Double(fInterval);
  fTimer.Start;
  {$ELSEIF ISLAND}
  fTimer.Interval := Int32(fInterval);
  fTimer.Repeat := fRepeat;
  fTimer.Start;
  {$ENDIF}
  fEnabled := true;
end;

method Timer.Stop;
begin
  if not fEnabled then exit;
  {$IF COOPER}
  fTimer.cancel;
  {$ELSEIF TOFFEE}
  fTimer.invalidate;
  {$ELSEIF ECHOES}
  fTimer.Stop;
  {$ELSEIF ISLAND}
  fTimer.Stop;
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
      fTimer.fCallback(fTimer);
    end;
  end;
{$ENDIF}

end.
