namespace RemObjects.Elements.RTL;

interface

uses
  RemObjects.Elements.RTL.Units;

type
  TimeSpan = public record mapped to {$IFDEF ECHOES}System.TimeSpan{$ELSEIF TOFFEE}NSTimeInterval{$ELSE}Int64{$ENDIF}
  private

    method get_Days: Integer;
    method get_Hours: Integer;
    method get_Minutes: Integer;
    method get_Seconds: Integer;
    method get_Milliseconds: Integer;
    method get_Ticks: Int64;
    method get_TotalDays: Days;
    method get_TotalHours: Hours;
    method get_TotalMinutes: Minutes;
    method get_TotalSeconds: Seconds;
    method get_TotalMilliSeconds: Milliseconds;

  public

    const
      TicksPerMillisecond: Int64 = 10000;
      TicksPerSecond: Int64 = TicksPerMillisecond * 1000;
      TicksPerMinute: Int64 = TicksPerSecond * 60;
      TicksPerHour: Int64 = TicksPerMinute * 60;
      TicksPerDay: Int64 = TicksPerHour * 24;

    property Days: Integer read get_Days;
    property Hours: Integer read get_Hours;
    property Minutes: Integer read get_Minutes;
    property Seconds: Integer read get_Seconds;
    property Milliseconds: Integer read get_Milliseconds;
    property Ticks: Int64 read get_Ticks;

    property TotalDays: Days read get_TotalDays;
    property TotalHours: Hours read get_TotalHours;
    property TotalMinutes: Minutes read get_TotalMinutes;
    property TotalSeconds: Seconds read get_TotalSeconds;
    property TotalMilliSeconds: Milliseconds read get_TotalMilliSeconds;

    constructor(aTicks: Int64);
    constructor(h,m,s: Int32);
    constructor(d,h,m,s: Int32; ms: Int32 := 0);

    method &Add(ts: TimeSpan): TimeSpan;
    method Subtract(ts: TimeSpan): TimeSpan;
    method Negate: TimeSpan;

    class method &From(aDuration: Shakes): TimeSpan;
    class method &From(aDuration: Microseconds): TimeSpan;
    class method &From(aDuration: Milliseconds): TimeSpan;
    class method &From(aDuration: Seconds): TimeSpan;
    class method &From(aDuration: Minutes): TimeSpan;
    class method &From(aDuration: Hours): TimeSpan;
    class method &From(aDuration: Days): TimeSpan;
    class method &From(aDuration: Weeks): TimeSpan;
    class method &From(aDuration: Fortnights): TimeSpan;
    [Obsolete("Use From with a unit value")]
    class method FromDays(aDuration: Days): TimeSpan;
    [Obsolete("Use From with a unit value")]
    class method FromHours(aDuration: Hours): TimeSpan;
    [Obsolete("Use From with a unit value")]
    class method FromMinutes(aDuration: Minutes): TimeSpan;
    [Obsolete("Use From with a unit value")]
    class method FromSeconds(aDuration: Seconds): TimeSpan;
    [Obsolete("Use From with a unit value")]
    class method FromMilliseconds(aDuration: Milliseconds): TimeSpan;
    class method FromTicks(d: Int64): TimeSpan;

    class operator Equal(a,b: TimeSpan): Boolean;
    class operator NotEqual(a,b: TimeSpan): Boolean;

    class operator &Add(a,b: TimeSpan): TimeSpan;
    class operator Subtract(a,b: TimeSpan): TimeSpan;
    class operator Plus(a: TimeSpan): TimeSpan;
    class operator Minus(a: TimeSpan): TimeSpan;

    class operator Less(a,b: TimeSpan): Boolean;
    class operator LessOrEqual(a,b: TimeSpan): Boolean;
    class operator Greater(a,b: TimeSpan): Boolean;
    class operator greaterOrEqual(a,b: TimeSpan): Boolean;
  end;

implementation

constructor TimeSpan(aTicks: Int64);
begin
  {$IFDEF ECHOES}
  exit new System.TimeSpan(aTicks);
  {$ELSEIF TOFFEE}
  exit aTicks / Double(TicksPerSecond);
  {$ELSEIF COOPER OR ISLAND}
  exit aTicks / 1000;
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

constructor TimeSpan(h: Int32; m: Int32; s: Int32);
begin
  exit new TimeSpan(((((h * 60) + m) * 60) + s) * TicksPerSecond);
end;

constructor TimeSpan(d: Int32; h: Int32; m: Int32; s: Int32; ms: Int32);
begin
  exit new TimeSpan(((((((((Int64(d) * 24) + h) * 60) + m) * 60) + s) * 1000) + ms) * TicksPerMillisecond);
end;

method TimeSpan.get_TotalMilliSeconds: Milliseconds;
begin
  exit Double(Ticks) / TicksPerMillisecond;
end;

method TimeSpan.get_TotalSeconds: Seconds;
begin
  exit Double(Ticks) / TicksPerSecond;
end;

method TimeSpan.get_TotalMinutes: Minutes;
begin
  exit Double(Ticks) / TicksPerMinute;
end;

method TimeSpan.get_TotalHours: Hours;
begin
  exit Double(Ticks) / TicksPerHour;
end;

method TimeSpan.get_TotalDays: Days;
begin
  exit Double(Ticks) / TicksPerDay;
end;

method TimeSpan.get_Ticks: Int64;
begin
  {$IFDEF ECHOES}
  exit mapped.Ticks;
  {$ELSEIF TOFFEE}
  exit Int64(mapped * TicksPerSecond);
  {$ELSEIF COOPER OR ISLAND}
  exit mapped * 1000;
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

method TimeSpan.get_Milliseconds: Integer;
begin
  exit (Ticks / TicksPerMillisecond) mod 1000;
end;

method TimeSpan.get_Seconds: Integer;
begin
  exit (Ticks / TicksPerSecond) mod 60;
end;

method TimeSpan.get_Minutes: Integer;
begin
  exit (Ticks / TicksPerMinute) mod 60;
end;

method TimeSpan.get_Hours: Integer;
begin
  exit (Ticks / TicksPerHour) mod 24;
end;

method TimeSpan.get_Days: Integer;
begin
  exit (Ticks / TicksPerDay);
end;

method TimeSpan.Add(ts: TimeSpan): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit mapped + System.TimeSpan(ts);
  {$ELSEIF TOFFEE}
  exit mapped + NSTimeInterval(ts);
  {$ELSEIF COOPER OR ISLAND}
  exit mapped + Int64(ts);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

method TimeSpan.Subtract(ts: TimeSpan): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit mapped - System.TimeSpan(ts);
  {$ELSEIF TOFFEE}
  exit mapped - NSTimeInterval(ts);
  {$ELSEIF COOPER OR ISLAND}
  exit mapped - Int64(ts);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

method TimeSpan.Negate: TimeSpan;
begin
  {$IFDEF ECHOES}
  exit - mapped;
  {$ELSEIF TOFFEE}
  exit - mapped;
  {$ELSEIF COOPER OR ISLAND}
  exit - mapped;
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

class method TimeSpan.From(aDuration: Shakes): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Microseconds): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Milliseconds): TimeSpan;
begin
  exit FromTicks(Int64(Double(aDuration) * TicksPerMillisecond));
end;

class method TimeSpan.From(aDuration: Seconds): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Minutes): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Hours): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Days): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Weeks): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.From(aDuration: Fortnights): TimeSpan;
begin
  exit &From(Milliseconds(aDuration));
end;

class method TimeSpan.FromDays(aDuration: Days): TimeSpan;
begin
  exit &From(aDuration);
end;

class method TimeSpan.FromHours(aDuration: Hours): TimeSpan;
begin
  exit &From(aDuration);
end;

class method TimeSpan.FromMinutes(aDuration: Minutes): TimeSpan;
begin
  exit &From(aDuration);
end;

class method TimeSpan.FromSeconds(aDuration: Seconds): TimeSpan;
begin
  exit &From(aDuration);
end;

class method TimeSpan.FromMilliseconds(aDuration: Milliseconds): TimeSpan;
begin
  exit &From(aDuration);
end;

class method TimeSpan.FromTicks(d: Int64): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan.FromTicks(d);
  {$ELSEIF TOFFEE}
  exit double(d) / TicksPerSecond;
  {$ELSEIF COOPER OR ISLAND}
  exit d / 1000;
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Equal(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) = System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) = NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) = Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.NotEqual(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) <> System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) <> NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) <> Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Add(a: TimeSpan; b: TimeSpan): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) + System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) + NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) + Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Subtract(a: TimeSpan; b: TimeSpan): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) - System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) - NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) - Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Plus(a: TimeSpan): TimeSpan;
begin
  exit a;
end;

operator TimeSpan.Minus(a: TimeSpan): TimeSpan;
begin
  {$IFDEF ECHOES}
  exit -System.TimeSpan(a);
  {$ELSEIF TOFFEE}
  exit -NSTimeInterval(a);
  {$ELSEIF COOPER OR ISLAND}
  exit -Int64(a);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Less(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) < System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) < NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) < Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.LessOrEqual(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) <= System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) <= NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) <= Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.Greater(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) > System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) > NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) > Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

operator TimeSpan.GreaterOrEqual(a: TimeSpan; b: TimeSpan): Boolean;
begin
  {$IFDEF ECHOES}
  exit System.TimeSpan(a) >= System.TimeSpan(b);
  {$ELSEIF TOFFEE}
  exit NSTimeInterval(a) >= NSTimeInterval(b);
  {$ELSEIF COOPER OR ISLAND}
  exit Int64(a) >= Int64(b);
  {$ELSE}
  {$ERROR Unknown platform}
  {$ENDIF}
end;

end.
