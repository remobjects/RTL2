namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Units,
  RemObjects.Elements.EUnit;

type
  DateTimeTests = public class(Test)
  private
  protected
  public
    method TestAddTimeUnits;
    begin
      var lStart := new DateTime(2000, 1, 1);

      {$IF COOPER}
      // java.util.Calendar only stores millisecond precision.
      Check.AreEqual(lStart.Add(100 Shakes).Ticks-lStart.Ticks, Int64(0));
      Check.AreEqual(lStart.Add(1 Microseconds).Ticks-lStart.Ticks, Int64(0));
      {$ELSE}
      Check.AreEqual(lStart.Add(100 Shakes).Ticks-lStart.Ticks, Int64(10));
      Check.AreEqual(lStart.Add(1 Microseconds).Ticks-lStart.Ticks, Int64(10));
      {$ENDIF}
      Check.AreEqual(lStart.Add(1 Milliseconds).Ticks-lStart.Ticks, TimeSpan.TicksPerMillisecond);
      Check.AreEqual(lStart.Add(1 Seconds).Ticks-lStart.Ticks, TimeSpan.TicksPerSecond);
      Check.AreEqual(lStart.Add(1 Minutes).Ticks-lStart.Ticks, TimeSpan.TicksPerMinute);
      Check.AreEqual(lStart.Add(1 Hours).Ticks-lStart.Ticks, TimeSpan.TicksPerHour);
      Check.AreEqual(lStart.Add(2 Days).Ticks-lStart.Ticks, TimeSpan.TicksPerDay*2);
      Check.AreEqual(lStart.Add(1 Weeks).Ticks-lStart.Ticks, TimeSpan.TicksPerDay*7);
      Check.AreEqual(lStart.Add(1 Fortnights).Ticks-lStart.Ticks, TimeSpan.TicksPerDay*14);
    end;

    method TestTimeSpanFactoriesUseUnits;
    begin
      Check.AreEqual(TimeSpan.From(2 Days).Ticks, TimeSpan.TicksPerDay*2);
      Check.AreEqual(TimeSpan.From(2 Minutes).Ticks, TimeSpan.TicksPerMinute*2);
      Check.AreEqual(TimeSpan.From(5 Hours).Ticks, TimeSpan.TicksPerHour*5);
    end;

    method TestUnixTimeSecondsSupportsInt64;
    begin
      var lDate := new DateTime(2100, 1, 1);
      var lUnixTime := lDate.ToUnixTimeSeconds;

      Check.IsTrue(lUnixTime > 2147483647);
      Check.AreEqual(lUnixTime, DateTime.FromUnixTimeSeconds(lUnixTime).ToUnixTimeSeconds);
    end;

    method TestOADate;
    begin
      var lToTest: Double := -36518.3785891204; // 5 - 1 - 1800 09:05:10 100ns <-- OADate;
      var lDateTime := DateTime.FromOADate(lToTest);
      Check.IsTrue(lDateTime.Year = 1800);
      Check.IsTrue(lDateTime.Month = 1);
      Check.IsTrue(lDateTime.Day = 5);
      Check.IsTrue(lDateTime.Hour = 9);
      Check.IsTrue(lDateTime.Minute = 5);
      var lOADate: Double := DateTime.ToOADate(lDateTime);
      Check.AreEqual(lToTest.ToString, lOADate.ToString);

      lToTest := 43105.3785891204; // 5 - 1 - 2018 09:05:10 100ns <-- OADate;
      lDateTime := DateTime.FromOADate(lToTest);
      Check.IsTrue(lDateTime.Year = 2018);
      Check.IsTrue(lDateTime.Month = 1);
      Check.IsTrue(lDateTime.Day = 5);
      Check.IsTrue(lDateTime.Hour = 9);
      Check.IsTrue(lDateTime.Minute = 5);
      lOADate := DateTime.ToOADate(lDateTime);
      Check.AreEqual(lToTest.ToString, lOADate.ToString);
    end;

    method TestDateTimeParse;
    begin
      var lDateTime := DateTime.TryParse('12/04/2019', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Assert.AreEqual(lDateTime.Month, 12);
      Check.AreEqual(lDateTime.Day, 4);
      Check.AreEqual(lDateTime.Year, 2019);

      lDateTime := DateTime.TryParse('11/20/2019 17:34', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 11);
      Check.AreEqual(lDateTime.Day, 20);
      Check.AreEqual(lDateTime.Year, 2019);
      Check.AreEqual(lDateTime.Hour, 17);
      Check.AreEqual(lDateTime.Minute, 34);

      lDateTime := DateTime.TryParse('11/20/2019 17:34:45', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 11);
      Check.AreEqual(lDateTime.Day, 20);
      Check.AreEqual(lDateTime.Year, 2019);
      Check.AreEqual(lDateTime.Hour, 17);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 45);

      lDateTime := DateTime.TryParse('17:34', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Hour, 17);
      Check.AreEqual(lDateTime.Minute, 34);

      lDateTime := DateTime.TryParse('17:34:45', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Hour, 17);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 45);

      lDateTime := DateTime.TryParse('20190814-125000', 'yyyyMMdd-HHmmss', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 8);
      Check.AreEqual(lDateTime.Day, 14);
      Check.AreEqual(lDateTime.Year, 2019);
      Check.AreEqual(lDateTime.Hour, 12);
      Check.AreEqual(lDateTime.Minute, 50);
      Check.AreEqual(lDateTime.Second, 00);

      lDateTime := DateTime.TryParse('2020-01-26T23:34:00.1+1:00', 'yyyy-MM-ddTHH:mm:ss.fK', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 1);
      Check.AreEqual(lDateTime.Day, 26);
      Check.AreEqual(lDateTime.Year, 2020);
      Check.AreEqual(lDateTime.Hour, 22);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 00);

      lDateTime := DateTime.TryParse('2020-01-26T23:34:00+1:00', 'yyyy-MM-ddTHH:mm:ssK', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 1);
      Check.AreEqual(lDateTime.Day, 26);
      Check.AreEqual(lDateTime.Year, 2020);
      Check.AreEqual(lDateTime.Hour, 22);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 00);

      lDateTime := DateTime.TryParse('2020-01-26T23:34:00.6175425+1:00', 'yyyy-MM-ddTHH:mm:ss.fffffffK', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 1);
      Check.AreEqual(lDateTime.Day, 26);
      Check.AreEqual(lDateTime.Year, 2020);
      Check.AreEqual(lDateTime.Hour, 22);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 00);

      lDateTime := DateTime.TryParse('2020-01-26T23:34:00.6175425+1:00', 'yyyy-MM-ddTHH:mm:ss.fffffffzzz', Locale.Invariant);
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 1);
      Check.AreEqual(lDateTime.Day, 26);
      Check.AreEqual(lDateTime.Year, 2020);
      Check.AreEqual(lDateTime.Hour, 22);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 00);

      lDateTime := DateTime.TryParseISO8601('2020-01-26T23:34:00.6175425+1:00');
      Check.IsNotNil(lDateTime);
      Check.AreEqual(lDateTime.Month, 1);
      Check.AreEqual(lDateTime.Day, 26);
      Check.AreEqual(lDateTime.Year, 2020);
      Check.AreEqual(lDateTime.Hour, 22);
      Check.AreEqual(lDateTime.Minute, 34);
      Check.AreEqual(lDateTime.Second, 00);
    end;
  end;
end.
