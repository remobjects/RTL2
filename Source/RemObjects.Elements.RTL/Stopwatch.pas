namespace RemObjects.Elements.RTL;

uses RemObjects.Elements.RTL.Units;

type
  // Benchmarks compile this same implementation with a separate type identity
  // so it can coexist with the Stopwatch metadata in a historical RTL library.
  {$IF RTL_STOPWATCH_SOURCE_TEST}
  SourceTestStopwatch = public class
    {$INCLUDE Stopwatch.Implementation.inc}
  end;
  {$ELSE}
  Stopwatch = public class
    {$INCLUDE Stopwatch.Implementation.inc}
  end;
  {$ENDIF}

end.
