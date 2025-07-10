namespace RemObjects.Elements.RTL;

type
  Stopwatch = public class
  public

    constructor;
    begin
      Start;
    end;

    method Start;
    begin
      StartTime := DateTime.UtcNow;
    end;

    property ElapsedTime: Double read (DateTime.UtcNow-StartTime).TotalMilliSeconds;
    property StartTime: DateTime read private write;

    [ToString]
    method ToString: String; override;
    begin
      result := Convert.MillisecondsToTimeString(ElapsedTime)+"s";

    end;

  end;

end.