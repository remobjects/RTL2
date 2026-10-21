// Shared production Stopwatch implementation; durations retain compiler units.
  private

    {$IF ISLAND AND (WINDOWS OR DARWIN)}
    field fStartCounter: Int64;
    field fFrequency: Int64;

    class method Counter: Int64;
    begin
      {$IF WINDOWS}
      var lCounter: rtl.LARGE_INTEGER;
      if not rtl.QueryPerformanceCounter(@lCounter) then
        raise new Exception('QueryPerformanceCounter failed');
      exit lCounter.QuadPart;
      {$ELSE}
      var lTime: rtl.__struct_timespec;
      if rtl.clock_gettime(rtl.clockid_t._CLOCK_MONOTONIC, @lTime) <> 0 then
        raise new Exception('clock_gettime failed');
      exit Int64(lTime.tv_sec) * 1000000000 + lTime.tv_nsec;
      {$ENDIF}
    end;
    {$ENDIF}

    method GetElapsedTime: Milliseconds;
    begin
      {$IF ISLAND AND (WINDOWS OR DARWIN)}
      // Subtract integer counters before converting: absolute timestamps lose
      // precision in Double, and wall-clock corrections must not change elapsed time.
      exit Seconds(Double(Counter - fStartCounter) / fFrequency);
      {$ELSE}
      exit (DateTime.UtcNow - StartTime).TotalMilliSeconds;
      {$ENDIF}
    end;

  public

    constructor;
    begin
      {$IF ISLAND AND WINDOWS}
      var lFrequency: rtl.LARGE_INTEGER;
      if not rtl.QueryPerformanceFrequency(@lFrequency) then
        raise new Exception('QueryPerformanceFrequency failed');
      fFrequency := lFrequency.QuadPart;
      {$ELSEIF ISLAND AND DARWIN}
      fFrequency := 1000000000;
      {$ENDIF}
      Start;
    end;

    method Start;
    begin
      StartTime := DateTime.UtcNow;
      {$IF ISLAND AND (WINDOWS OR DARWIN)}
      fStartCounter := Counter;
      {$ENDIF}
    end;

    property ElapsedTime: Milliseconds read GetElapsedTime;
    property StartTime: DateTime read private write;

    [ToString]
    method ToString: String; override;
    begin
      result := Convert.DurationToTimeString(ElapsedTime)+"s";
    end;
