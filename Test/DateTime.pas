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

    method TestPortableDateFormatting;
    begin
      var lDate := new DateTime(2026, 8, 9, 17, 4, 5);

      Check.AreEqual(lDate.ToString('yyyy', 'en-US', TimeZone.Utc), '2026');
      Check.AreEqual(lDate.ToString('yy', 'en-US', TimeZone.Utc), '26');
      Check.AreEqual(lDate.ToString('MMMM', 'en-US', TimeZone.Utc), 'August');
      Check.AreEqual(lDate.ToString('MMM', 'en-US', TimeZone.Utc), 'Aug');
      Check.AreEqual(lDate.ToString('MM', 'en-US', TimeZone.Utc), '08');
      Check.AreEqual(lDate.ToString('M', 'en-US', TimeZone.Utc), '8');
      Check.AreEqual(lDate.ToString('dddd', 'en-US', TimeZone.Utc), 'Sunday');
      Check.AreEqual(lDate.ToString('ddd', 'en-US', TimeZone.Utc), 'Sun');
      Check.AreEqual(lDate.ToString('dd', 'en-US', TimeZone.Utc), '09');
      Check.AreEqual(lDate.ToString('d', 'en-US', TimeZone.Utc), '9');
    end;

    method TestPortableTimeFormatting;
    begin
      var lDate := new DateTime(2026, 8, 9, 17, 4, 5);

      Check.AreEqual(lDate.ToString('HH', 'en-US', TimeZone.Utc), '17');
      Check.AreEqual(lDate.ToString('H', 'en-US', TimeZone.Utc), '17');
      Check.AreEqual(lDate.ToString('hh', 'en-US', TimeZone.Utc), '05');
      Check.AreEqual(lDate.ToString('h', 'en-US', TimeZone.Utc), '5');
      Check.AreEqual(lDate.ToString('mm', 'en-US', TimeZone.Utc), '04');
      Check.AreEqual(lDate.ToString('m', 'en-US', TimeZone.Utc), '4');
      Check.AreEqual(lDate.ToString('ss', 'en-US', TimeZone.Utc), '05');
      Check.AreEqual(lDate.ToString('s', 'en-US', TimeZone.Utc), '5');
      Check.AreEqual(lDate.ToString('a', 'en-US', TimeZone.Utc), 'PM');
    end;

    method TestPortableTwelveHourFormatting;
    begin
      var lMidnight := new DateTime(2026, 8, 9, 0, 4, 5);
      var lNoon := new DateTime(2026, 8, 9, 12, 4, 5);

      Check.AreEqual(lMidnight.ToString('hh:mma', 'en-US', TimeZone.Utc), '12:04AM');
      Check.AreEqual(lNoon.ToString('hh:mma', 'en-US', TimeZone.Utc), '12:04PM');
    end;

    method TestPortableCombinedFormatting;
    begin
      var lDate := new DateTime(2026, 8, 9, 17, 4, 5);

      Check.AreEqual(lDate.ToString('yyyy-MM-dd HH:mm:ss', 'en-US', TimeZone.Utc), '2026-08-09 17:04:05');
      Check.AreEqual(lDate.ToString("ddd, MMM d 'at' h:mma", 'en-US', TimeZone.Utc), 'Sun, Aug 9 at 5:04PM');
      Check.AreEqual(lDate.ToString("'ddd' ddd 'a' a", 'en-US', TimeZone.Utc), 'ddd Sun a PM');
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
      Check.IsTrue(Math.Abs(lToTest-lOADate) <= (1.0/86400000.0));

      lToTest := 43105.3785891204; // 5 - 1 - 2018 09:05:10 100ns <-- OADate;
      lDateTime := DateTime.FromOADate(lToTest);
      Check.IsTrue(lDateTime.Year = 2018);
      Check.IsTrue(lDateTime.Month = 1);
      Check.IsTrue(lDateTime.Day = 5);
      Check.IsTrue(lDateTime.Hour = 9);
      Check.IsTrue(lDateTime.Minute = 5);
      lOADate := DateTime.ToOADate(lDateTime);
      Check.IsTrue(Math.Abs(lToTest-lOADate) <= (1.0/86400000.0));
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
