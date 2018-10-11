namespace RemObjects.Elements.RTL;

interface

uses
{$IF COOPER}
  java.nio,
  java.util,
{$ELSEIF TOFFEE}
  Foundation,
{$ENDIF}
  RemObjects.Elements.RTL;

type
  PlatformDateTime = public {$IF COOPER}java.util.Calendar{$ELSEIF ECHOES}System.DateTime{$ELSEIF ISLAND}RemObjects.Elements.System.DateTime{$ELSEIF TOFFEE}NSDate{$ENDIF};

  DateTime = public partial class {$IF COOPER OR TOFFEE} mapped to PlatformDateTime{$ENDIF}
  private
    {$IF ECHOES OR ISLAND}
    fDateTime: PlatformDateTime;
    {$ENDIF}
    const DEFAULT_FORMAT = "dd/MM/yyyy hh:mm:ss";
    const DEFAULT_FORMAT_DATE = "dd/MM/yyyy";
    const DEFAULT_FORMAT_DATE_SHORT = "d/M/yyyy";
    const DEFAULT_FORMAT_TIME = "hh:mm:ss";
    const DEFAULT_FORMAT_TIME_SHORT = "hh:mm";
    const MILLISECONDS_PER_DAY = 86400000;
    const OADATE_OFFSET: Int64 = 599264352000000000;
    const TICKS_PER_MILLISECOND: Int64 = 10000;
  public
    constructor;
    constructor(aTicks: Int64);
    constructor(aYear, aMonth, aDay: Integer);
    constructor(aYear, aMonth, aDay, anHour, aMinute: Integer);
    constructor(aYear, aMonth, aDay, anHour, aMinute, aSecond: Integer);
    {$IF COOPER}
    constructor(aDate: date);
    {$ENDIF}
    {$IF ECHOES OR ISLAND}
    constructor (aDateTime: PlatformDateTime);
    {$ENDIF}

    class method Compare(Value1, Value2: DateTime): Integer;

    method AddDays(Value: Integer): DateTime;
    method AddHours(Value: Integer): DateTime;
    method AddMinutes(Value: Integer): DateTime;
    method AddMonths(Value: Integer): DateTime;
    method AddSeconds(Value: Integer): DateTime;
    method AddMilliSeconds(Value: Integer): DateTime;
    method AddYears(Value: Integer): DateTime;
    method &Add(Value: TimeSpan): DateTime;

    method CompareTo(Value: DateTime): Integer;
    method ToString(aTimeZone: TimeZone := nil): String;
    method ToString(Format: String; aTimeZone: TimeZone := nil): String;
    method ToString(Format: String; Culture: String; aTimeZone: TimeZone := nil): String;

    method ToShortDateString(aTimeZone: TimeZone := nil): String;
    method ToShortTimeString(aTimeZone: TimeZone := nil): String;

    method ToShortPrettyDateAndTimeString(aTimeZone: TimeZone := nil): String;
    method ToShortPrettyDateString(aTimeZone: TimeZone := nil): String;
    method ToLongPrettyDateString(aTimeZone: TimeZone := nil): String;

    class method ToOADate(aDateTime: DateTime): Double;
    class method FromOADate(aOADate: Double): DateTime;

    {$IF ECHOES OR ISLAND}
    method ToString: PlatformString; override;
    {$ENDIF}

    property Hour: Integer read {$IF COOPER}mapped.get(Calendar.HOUR_OF_DAY){$ELSEIF ECHOES OR ISLAND}fDateTime.Hour{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSHourCalendarUnit){$ENDIF};
    property Minute: Integer read {$IF COOPER}mapped.get(Calendar.MINUTE){$ELSEIF ECHOES OR ISLAND}fDateTime.Minute{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSMinuteCalendarUnit){$ENDIF};
    property Second: Integer read {$IF COOPER}mapped.get(Calendar.SECOND){$ELSEIF ECHOES OR ISLAND}fDateTime.Second{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSSecondCalendarUnit){$ENDIF};
    property Year: Integer read {$IF COOPER}mapped.get(Calendar.YEAR){$ELSEIF ECHOES OR ISLAND}fDateTime.Year{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSYearCalendarUnit){$ENDIF};
    property Month: Integer read {$IF COOPER}mapped.get(Calendar.MONTH)+1{$ELSEIF ECHOES OR ISLAND}fDateTime.Month{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSMonthCalendarUnit){$ENDIF};
    property Day: Integer read {$IF COOPER}mapped.get(Calendar.DAY_OF_MONTH){$ELSEIF ECHOES OR ISLAND}fDateTime.Day{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSDayCalendarUnit){$ENDIF};
    property DayOfWeek: Integer read {$IF COOPER}mapped.get(Calendar.DAY_OF_WEEK){$ELSEIF ECHOES OR ISLAND}Integer(fDateTime.DayOfWeek)+1{$ELSEIF TOFFEE}DateTimeHelpers.GetComponent(mapped, NSCalendarUnit.NSWeekdayCalendarUnit){$ENDIF};
    property Date: DateTime read {$IF COOPER OR TOFFEE}new DateTime(self.Year, self.Month, self.Day, 0, 0, 0){$ELSEIF ECHOES OR ISLAND}new DateTime(fDateTime.Date){$ENDIF};

    class property Today: DateTime read {$IF COOPER OR TOFFEE}UtcNow.Date{$ELSEIF ECHOES OR ISLAND}new DateTime(PlatformDateTime.Today){$ENDIF};
    class property UtcNow: DateTime read {$IF COOPER OR TOFFEE}new DateTime(){$ELSEIF ECHOES OR ISLAND}new DateTime(PlatformDateTime.UtcNow){$ENDIF};
    const TicksSince1970: Int64 = 621355968000000000;

    property TimeSince: TimeSpan read (UtcNow-self);
    class method TimeSince(aOtherDateTime: DateTime): TimeSpan;

    property Ticks: Int64 read{$IFDEF COOPER}(mapped.TimeInMillis +mapped.TimeZone.getOffset(mapped.TimeInMillis)) * TimeSpan.TicksPerMillisecond + TicksSince1970{$ELSEIF ECHOES OR ISLAND}fDateTime.Ticks{$ELSE}Int64((mapped.timeIntervalSince1970 + DateTimeHelpers.LocalTimezone.secondsFromGMTForDate(mapped)) * TimeSpan.TicksPerSecond) + TicksSince1970{$ENDIF};
    class operator &Add(a: DateTime; b: TimeSpan): DateTime;
    class operator Subtract(a: DateTime; b: DateTime): TimeSpan;
    class operator Subtract(a: DateTime; b: TimeSpan): DateTime;

    class operator Equal(a,b: DateTime): Boolean;
    class operator NotEqual(a,b: DateTime): Boolean;
    class operator Less(a,b: DateTime): Boolean;
    class operator LessOrEqual(a,b: DateTime): Boolean;
    class operator Greater(a, b: DateTime): Boolean;
    class operator GreaterOrEqual(a,b: DateTime): Boolean;

    {$IF COOPER}
    operator Implicit(aDateTime: java.util.Date): DateTime;
    operator Implicit(aDateTime: DateTime): java.util.Date;
    {$ENDIF}
    {$IF ECHOES OR ISLAND}
    operator Implicit(aDateTime: PlatformDateTime): DateTime;
    operator Implicit(aDateTime: DateTime): PlatformDateTime;
    {$ENDIF}
    {$IF ISLAND AND DARWIN}
    operator Implicit(aDateTime: Foundation.NSDate): DateTime;
    operator Implicit(aDateTime: DateTime): Foundation.NSDate;
    {$ENDIF}
  end;

  {$IF ECHOES OR ISLAND}
  DateTime = public partial class(IComparable<DateTime>)
  end;
  {$ENDIF}


implementation

{$IF TOFFEE}
type
  DateTimeHelpers = static class
  public
    method GetComponent(aSelf: NSDate; Component: NSCalendarUnit): Integer;
    method AdjustDate(aSelf: NSDate; Component: NSCalendarUnit; Value: NSInteger): DateTime;
    class property LocalTimezone: NSTimeZone := NSTimeZone.localTimeZone;
  end;
{$ENDIF}

{$IF ECHOES OR ISLAND}
constructor DateTime(aDateTime: PlatformDateTime);
begin
  fDateTime := aDateTime;
end;
{$ENDIF}

constructor DateTime;
begin
  {$IF COOPER}
  result := Calendar.Instance;
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime();
  {$ELSE IF TOFFEE}
  result := new PlatformDateTime();
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer);
begin
  {$IF COOPER OR TOFFEE}
  constructor(aYear, aMonth, aDay, 0, 0, 0);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay);
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer; anHour: Integer; aMinute: Integer);
begin
  {$IF COOPER OR TOFFEE}
  constructor(aYear, aMonth, aDay, anHour, aMinute, 0);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay, anHour, aMinute, 0);
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer; anHour: Integer; aMinute: Integer; aSecond: Integer);
begin
  {$IF COOPER}
  var lCalendar := Calendar.Instance;
  lCalendar.Time := new Date;
  lCalendar.set(Calendar.YEAR, aYear);
  lCalendar.set(Calendar.MONTH, aMonth-1);
  lCalendar.set(Calendar.DATE, aDay);
  lCalendar.set(Calendar.HOUR_OF_DAY, anHour);
  lCalendar.set(Calendar.MINUTE, aMinute);
  lCalendar.set(Calendar.SECOND, aSecond);
  lCalendar.set(Calendar.MILLISECOND, 0);
  result := lCalendar;
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay, anHour, aMinute, aSecond);
  {$ELSEIF TOFFEE}
  var Components: NSDateComponents := new NSDateComponents();
  Components.setYear(aYear);
  Components.setMonth(aMonth);
  Components.setDay(aDay);
  Components.setHour(anHour);
  Components.setMinute(aMinute);
  Components.setSecond(aSecond);
  var lCalendar := NSCalendar.currentCalendar();
  result := lCalendar.dateFromComponents(Components);
  {$ENDIF}
end;

constructor DateTime(aTicks: Int64);
begin
  {$IFDEF COOPER}
  var lCalendar := Calendar.Instance;
  var dt := (aTicks - TicksSince1970) / TimeSpan.TicksPerMillisecond;
  lCalendar.Time := new Date(dt - lCalendar.TimeZone.getOffset(dt));
  result := lCalendar;
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aTicks);
  {$ELSEIF TOFFEE}
  var dt := NSDate.dateWithTimeIntervalSince1970(Double(aTicks - TicksSince1970) / TimeSpan.TicksPerSecond);
  result := NSDate.dateWithTimeInterval(-DateTimeHelpers.LocalTimezone.secondsFromGMTForDate(dt)) sinceDate(dt);
  {$ENDIF}
end;

{$IF COOPER}
constructor DateTime(aDate: Date);
begin
  result := Calendar.Instance;
  (result as Calendar).Time := aDate;
end;
{$ENDIF}

class method DateTime.TimeSince(aOtherDateTime: DateTime): TimeSpan;
begin
  result := (UtcNow-aOtherDateTime);
end;

//
// ToString
//

{$IF ECHOES OR ISLAND}
method DateTime.ToString: PlatformString;
begin
  result := ToString(DEFAULT_FORMAT);
end;
{$ENDIF}

method DateTime.ToString(Format: String; aTimeZone: TimeZone := nil): String;
begin
  result := ToString(Format, nil, aTimeZone);
end;

method DateTime.ToString(Format: String; Culture: String; aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := if String.IsNullOrEmpty(Culture) then
                      new java.text.SimpleDateFormat(DateFormatter.Format(Format))
                    else
                      new java.text.SimpleDateFormat(DateFormatter.Format(Format), RemObjects.Elements.RTL.Cooper.LocaleUtils.ForLanguageTag(Culture));
  lFormatter.TimeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF ECHOES}
  if Format = "" then
    exit "";
  var lDateInTimeZone := if assigned(aTimeZone) then PlatformTimeZone.ConvertTimeFromUtc(fDateTime, aTimeZone) else fDateTime;
  if String.IsNullOrEmpty(Culture) then
    result := lDateInTimeZone.ToString(DateFormatter.Format(Format))
  else
    result := lDateInTimeZone.ToString(DateFormatter.Format(Format), new System.Globalization.CultureInfo(Culture));
  {$ELSEIF TOFFEE}
  var lFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  if not String.IsNullOrEmpty(Culture) then begin
    var Locale := new NSLocale withLocaleIdentifier(Culture);
    lFormatter.locale := Locale;
  end;
  lFormatter.setDateFormat(DateFormatter.Format(Format));
  result := lFormatter.stringFromDate(mapped);
  {$ENDIF}
end;

method DateTime.ToString(aTimeZone: TimeZone := nil): String;
begin
  result := ToString(DEFAULT_FORMAT, nil, aTimeZone);
end;

method DateTime.ToShortDateString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getDateInstance(java.text.DateFormat.SHORT);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF ECHOES}
  result := fDateTime.ToShortDateString;
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.ShortStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ENDIF}
end;

method DateTime.ToShortTimeString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF ECHOES}
  result := fDateTime.ToShortTimeString();
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.NoStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.ShortStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ENDIF}
end;

method DateTime.ToShortPrettyDateAndTimeString(aTimeZone: TimeZone := nil): String;
begin
  result := ToShortPrettyDateString(aTimeZone)+" "+ToShortTimeString(aTimeZone);
end;

method DateTime.ToShortPrettyDateString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getDateInstance(java.text.DateFormat.SHORT);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF ECHOES}
  result := ToShortDateString();
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.MediumStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ENDIF}
end;

method DateTime.ToLongPrettyDateString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getDateInstance(java.text.DateFormat.LONG);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF ECHOES}
  result := fDateTime.ToShortDateString;
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.LongStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ENDIF}
end;

//
// Mutating Dates
//

{$IF TOFFEE}
method DateTimeHelpers.AdjustDate(aSelf: NSDate; Component: NSCalendarUnit; Value: NSInteger): DateTime;
begin
  var Components: NSDateComponents := new NSDateComponents();

  case Component of
    NSCalendarUnit.NSDayCalendarUnit: Components.setDay(Value);
    NSCalendarUnit.NSHourCalendarUnit: Components.setHour(Value);
    NSCalendarUnit.NSMinuteCalendarUnit: Components.setMinute(Value);
    NSCalendarUnit.NSMonthCalendarUnit: Components.setMonth(Value);
    NSCalendarUnit.NSSecondCalendarUnit: Components.setSecond(Value);
    NSCalendarUnit.NSYearCalendarUnit: Components.setYear(Value);
  end;

  var lCalendar := NSCalendar.currentCalendar();
  result := lCalendar.dateByAddingComponents(Components) toDate(aSelf) options(0);
end;

method DateTimeHelpers.GetComponent(aSelf: NSDate; Component: NSCalendarUnit): Integer;
begin
  var lComponents := NSCalendar.currentCalendar().components(Component) fromDate(aSelf);
  case Component of
    NSCalendarUnit.NSDayCalendarUnit: result := lComponents.day;
    NSCalendarUnit.NSHourCalendarUnit: result := lComponents.hour;
    NSCalendarUnit.NSMinuteCalendarUnit: result := lComponents.minute;
    NSCalendarUnit.NSMonthCalendarUnit: result := lComponents.month;
    NSCalendarUnit.NSSecondCalendarUnit: result := lComponents.second;
    NSCalendarUnit.NSYearCalendarUnit: result := lComponents.year;
  end;
end;
{$ENDIF}

method DateTime.AddDays(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.DATE, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddDays(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSDayCalendarUnit, Value);
  {$ENDIF}
end;

method DateTime.AddHours(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.HOUR_OF_DAY, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddHours(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSHourCalendarUnit, Value);
  {$ENDIF}
end;

method DateTime.AddMinutes(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MINUTE, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMinutes(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSMinuteCalendarUnit, Value);
  {$ENDIF}
end;

method DateTime.AddMonths(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MONTH, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMonths(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSMonthCalendarUnit, Value);
  {$ENDIF}
end;

method DateTime.AddSeconds(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.SECOND, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddSeconds(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSSecondCalendarUnit, Value);
  {$ENDIF}
end;

method DateTime.AddMilliSeconds(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MILLISECOND, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMilliseconds(Value));
  {$ELSEIF TOFFEE}
  result := DateTimeHelpers.AdjustDate(mapped, NSCalendarUnit.NSCalendarUnitNanosecond, Int64(Value)*Int64(1 000 000));
  {$ENDIF}
end;

method DateTime.AddYears(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.YEAR, Value);
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddYears(Value));
  {$ELSEIF TOFFEE}
  result := &Add(TimeSpan.FromMilliseconds(Value));
  {$ENDIF}
end;

method DateTime.Add(Value: TimeSpan): DateTime;
begin
  result := new DateTime(self.Ticks + Value.Ticks);
end;

operator DateTime.Add(a: DateTime; b: TimeSpan): DateTime;
begin
  result := new DateTime(a.Ticks + b.Ticks);
end;

operator DateTime.Subtract(a: DateTime; b: DateTime): TimeSpan;
begin
  result := new TimeSpan(a.Ticks - b.Ticks);
end;

operator DateTime.Subtract(a: DateTime; b: TimeSpan): DateTime;
begin
  result := new DateTime(a.Ticks - b.Ticks);
end;

//
// Comparing Dates
//

class method DateTime.Compare(Value1, Value2: DateTime): Integer;
begin
  if not assigned(Value1) and not assigned(Value2) then
    exit 0;

  if not assigned(Value1) then
    exit -1;

  if not assigned(Value2) then
    exit 1;

  exit Value1.CompareTo(Value2);
end;

method DateTime.CompareTo(Value: DateTime): Integer;
begin
  {$IF COOPER}
  result := mapped.compareTo(new DateTime(Value.Year, Value.Month, Value.Day, Value.Hour, Value.Minute, Value.Second));
  {$ELSEIF ECHOES OR ISLAND}
  result := fDateTime.CompareTo(Value:fDateTime);
  {$ELSEIF TOFFEE}
  result := mapped.compare(new DateTime(Value.Year, Value.Month, Value.Day, Value.Hour, Value.Minute, Value.Second));
  {$ENDIF}
end;

operator DateTime.Equal(a: DateTime; b: DateTime): Boolean;
begin
  if Object(a) = nil then exit Object(b) = nil;
  if Object(b) = nil then exit Object(a) = nil;
  result := a.Ticks = b.Ticks;
end;

operator DateTime.NotEqual(a: DateTime; b: DateTime): Boolean;
begin
  if Object(a) = nil then exit Object(b) ≠ nil;
  if Object(b) = nil then exit Object(a) ≠ nil;
  result := a.Ticks <> b.Ticks;
end;

operator DateTime.Less(a: DateTime; b: DateTime): Boolean;
begin
  if (Object(a) = nil) and (Object(b) = nil) then exit false;
  if (Object(a) = nil) then exit true;
  if (Object(b) = nil) then exit false;
  result := a.Ticks < b.Ticks;
end;

operator DateTime.LessOrEqual(a: DateTime; b: DateTime): Boolean;
begin
  if (Object(a) = nil) and (Object(b) = nil) then exit true;
  if (Object(a) = nil) then exit true;
  if (Object(b) = nil) then exit false;
  result := a.Ticks <= b.Ticks;
end;

operator DateTime.Greater(a: DateTime; b: DateTime): Boolean;
begin
  if (Object(a) = nil) and (Object(b) = nil) then exit false;
  if (Object(a) = nil) then exit false;
  if (Object(b) = nil) then exit true;
  result := a.Ticks > b.Ticks;
end;

operator DateTime.GreaterOrEqual(a: DateTime; b: DateTime): Boolean;
begin
  if (Object(a) = nil) and (Object(b) = nil) then exit true;
  if (Object(a) = nil) then exit false;
  if (Object(b) = nil) then exit true;
  result := a.Ticks >= b.Ticks;
end;

{$IF COOPER}
operator DateTime.Implicit(aDateTime: java.util.Date): DateTime;
begin
  result := Calendar.Instance;
  (result as PlatformDateTime).setTime(aDateTime);
end;

operator DateTime.Implicit(aDateTime: DateTime): java.util.Date;
begin
  if not assigned(aDateTime) then
    exit nil;
  result := (aDateTime as PlatformDateTime).getTime();
end;
{$ENDIF}

{$IF ECHOES OR ISLAND}
operator DateTime.Implicit(aDateTime: PlatformDateTime): DateTime;
begin
  result := new DateTime(aDateTime);
end;

operator DateTime.Implicit(aDateTime: DateTime): PlatformDateTime;
begin
  if not assigned(aDateTime) then
    raise new InvalidCastException("Cannot cast null DateTime to platform DateTime type.");
  result := aDateTime.fDateTime;
end;
{$ENDIF}

{$IF ISLAND AND DARWIN}
operator DateTime.Implicit(aDateTime: Foundation.NSDate): DateTime;
begin
  result := aDateTime as PlatformDateTime;
end;

operator DateTime.Implicit(aDateTime: DateTime): Foundation.NSDate;
begin
  result := PlatformDateTime(aDateTime) as Foundation.NSDate;
end;
{$ENDIF}

class method DateTime.ToOADate(aDateTime: DateTime): Double;
begin
  var lTicks := aDateTime.Ticks;
  if lTicks = 0 then
    exit 0.0;

  var lMillis: Int64 := (lTicks - OADATE_OFFSET) / TICKS_PER_MILLISECOND;
  if lMillis < 0 then begin
    var lMod := lMillis mod MILLISECONDS_PER_DAY;
    if lMod <> 0 then
      lMillis := lMillis - ((MILLISECONDS_PER_DAY + lMod) * 2);
  end;
  result := Double(lMillis) / MILLISECONDS_PER_DAY;
end;

class method DateTime.FromOADate(aOADate: Double): DateTime;
begin
  var lValue := if aOADate > 0 then 0.5 else -0.5;
  var lMillis: Int64 := Int64((aOADate * MILLISECONDS_PER_DAY) + lValue);

  if lMillis < 0 then
    lMillis := lMillis - ((lMillis mod MILLISECONDS_PER_DAY) * 2);

  lMillis := lMillis + (OADATE_OFFSET / TICKS_PER_MILLISECOND);
  result := new DateTime(lMillis * TICKS_PER_MILLISECOND);
end;

end.