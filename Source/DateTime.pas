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
  {$IF COOPER}
  PlatformDateTime = public java.util.Calendar;
  {$ELSEIF TOFFEE}
  PlatformDateTime = public NSDate;
  {$ELSEIF ECHOES}
  PlatformDateTime = public System.DateTime;
  {$ELSEIF ISLAND}
  PlatformDateTime = public RemObjects.Elements.System.DateTime;
  {$ENDIF}

  ISO8601Format = public enum(Standard, DateOnly, StandardWithTimeZone, Full) of Integer;

  [assembly:DefaultTypeOverride("DateTime", "RemObjects.Elements.RTL", typeOf(RemObjects.Elements.RTL.DateTime))]
  {$IFDEF ISLAND AND NOT TOFFEE}
  DateTime = public partial class(IComparable)
  public
    method CompareTo(other: Object): Integer;
    begin
      exit fDateTime.CompareTo(DateTime(other).fDateTime);
    end;
  end;
  {$ENDIF}

  DateTime = public partial class {$IF COOPER OR TOFFEE} mapped to PlatformDateTime{$ENDIF}
  private
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
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
    constructor(aTicks: Int64);
    constructor(aYear, aMonth, aDay: Integer);
    constructor(aYear, aMonth, aDay, anHour, aMinute: Integer);
    constructor(aYear, aMonth, aDay, anHour, aMinute, aSecond: Integer);
    constructor(aYear, aMonth, aDay, anHour, aMinute, aSecond, aMSec: Integer);
    {$IF COOPER}
    constructor(aDate: date);
    {$ENDIF}
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    constructor (aDateTime: PlatformDateTime);
    {$ENDIF}
    {$IF ECHOES}
    constructor;
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

    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    [ToString]
    method ToString: PlatformString; override;
    {$ENDIF}
    method ToString(aTimeZone: TimeZone := nil): String;
    method ToString(Format: String; aTimeZone: TimeZone := nil): String;
    method ToString(Format: String; Culture: String; aTimeZone: TimeZone := nil): String;

    method ToShortDateString(aTimeZone: TimeZone := nil): String;
    method ToShortTimeString(aTimeZone: TimeZone := nil): String;

    method ToShortPrettyDateAndTimeString(aTimeZone: TimeZone := nil): String;
    method ToShortPrettyDateString(aTimeZone: TimeZone := nil): String;
    method ToLongPrettyDateString(aTimeZone: TimeZone := nil): String;

    method ToISO8601String(aFormat: ISO8601Format := ISO8601Format.Standard; aTimeZone: TimeZone := nil): String;

    class method ToOADate(aDateTime: DateTime): Double;
    class method FromOADate(aOADate: Double): DateTime;

    class method TryParse(aDateTime: String; aOptions: DateParserOptions := []): nullable DateTime;
    class method TryParse(aDateTime: String; aLocale: Locale; aOptions: DateParserOptions := []): nullable DateTime;
    class method TryParse(aDateTime: String; aFormat: String; aOptions: DateParserOptions := []): nullable DateTime;
    class method TryParseISO8601(aDateTime: String): nullable DateTime;
    class method TryParse(aDateTime: String; aFormat: String; aLocale: Locale; aOptions: DateParserOptions := []): nullable DateTime;


    property Hour: Integer read {$IF COOPER}mapped.get(Calendar.HOUR_OF_DAY){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSHourCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Hour{$ENDIF};
    property Minute: Integer read {$IF COOPER}mapped.get(Calendar.MINUTE){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSMinuteCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Minute{$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSMinuteCalendarUnit){$ENDIF};
    property Second: Integer read {$IF COOPER}mapped.get(Calendar.SECOND){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSSecondCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Second{$ENDIF};
    property Year: Integer read {$IF COOPER}mapped.get(Calendar.YEAR){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSYearCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Year{$ENDIF};
    property Month: Integer read {$IF COOPER}mapped.get(Calendar.MONTH)+1{$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSMonthCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Month{$ENDIF};
    property Day: Integer read {$IF COOPER}mapped.get(Calendar.DAY_OF_MONTH){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSDayCalendarUnit){$ELSEIF ECHOES OR ISLAND}fDateTime.Day{$ENDIF};
    property DayOfWeek: Integer read {$IF COOPER}mapped.get(Calendar.DAY_OF_WEEK){$ELSEIF TOFFEE}GetComponent(NSCalendarUnit.NSWeekdayCalendarUnit){$ELSEIF ECHOES OR ISLAND}Integer(fDateTime.DayOfWeek)+1{$ENDIF};
    property Date: DateTime read {$IF COOPER OR TOFFEE}new DateTime(self.Year, self.Month, self.Day, 0, 0, 0){$ELSEIF ECHOES OR ISLAND}new DateTime(fDateTime.Date){$ENDIF};

    class property Today: DateTime read {$IF COOPER OR TOFFEE}UtcNow.Date{$ELSEIF ECHOES OR ISLAND}new DateTime(PlatformDateTime.Today){$ENDIF};
    class property UtcNow: DateTime read {$IF COOPER}Calendar.Instance{$ELSEIF TOFFEE}new PlatformDateTime(){$ELSEIF ECHOES OR ISLAND}new DateTime(PlatformDateTime.UtcNow){$ENDIF};
    const TicksTill1970: Int64 = 621355968000000000;

    property TimeSince: TimeSpan read (UtcNow-self);
    class method TimeSince(aOtherDateTime: DateTime): TimeSpan;

    property Ticks: Int64 read
      {$IF COOPER}(mapped.TimeInMillis +mapped.TimeZone.getOffset(mapped.TimeInMillis)) * TimeSpan.TicksPerMillisecond + TicksTill1970
      {$ELSEIF TOFFEE}Int64((mapped.timeIntervalSince1970 + NSTimeZone.localTimeZone.secondsFromGMTForDate(mapped)) * TimeSpan.TicksPerSecond) + TicksTill1970
      {$ELSEIF ECHOES OR ISLAND}fDateTime.Ticks
      {$ENDIF};
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
    {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
    operator Implicit(aDateTime: PlatformDateTime): DateTime;
    operator Implicit(aDateTime: DateTime): PlatformDateTime;
    {$ENDIF}
    {$IF ISLAND AND DARWIN AND NOT TOFFEE}
    operator Implicit(aDateTime: Foundation.NSDate): DateTime;
    operator Implicit(aDateTime: DateTime): Foundation.NSDate;
    {$ENDIF}

  private

    {$IF TOFFEE}
    method GetComponent(Component: NSCalendarUnit): Integer;
    begin
      var lComponents := NSCalendar.currentCalendar.components(Component) fromDate(self);
      case Component of
        NSCalendarUnit.WeekdayCalendarUnit: result := lComponents.weekday;
        NSCalendarUnit.DayCalendarUnit: result := lComponents.day;
        NSCalendarUnit.HourCalendarUnit: result := lComponents.hour;
        NSCalendarUnit.MinuteCalendarUnit: result := lComponents.minute;
        NSCalendarUnit.MonthCalendarUnit: result := lComponents.month;
        NSCalendarUnit.SecondCalendarUnit: result := lComponents.second;
        NSCalendarUnit.YearCalendarUnit: result := lComponents.year;
        NSCalendarUnit.CalendarUnitNanosecond: result := lComponents.nanosecond;
      end;
    end;
    {$ENDIF}

  end;

  {$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
  DateTime = public partial class(IComparable<DateTime>)

  end;
  {$ENDIF}

implementation

{$IF ECHOES}
[Error("This constructor is provided only for compatibility with .NET Serialization")]
constructor DateTime;
begin
  raise new Exception("This constructor is provided only for compatibility with .NET Serialization");
end;
{$ENDIF}

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
constructor DateTime(aDateTime: PlatformDateTime);
begin
  fDateTime := aDateTime;
end;
{$ENDIF}

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer);
begin
  {$IF COOPER OR TOFFEE}
  constructor(aYear, aMonth, aDay, 0, 0, 0, 0);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay);
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer; anHour: Integer; aMinute: Integer);
begin
  {$IF COOPER OR TOFFEE}
  constructor(aYear, aMonth, aDay, anHour, aMinute, 0, 0);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay, anHour, aMinute, 0, 0);
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer; anHour: Integer; aMinute: Integer; aSecond: Integer);
begin
  {$IF COOPER OR TOFFEE}
  constructor(aYear, aMonth, aDay, anHour, aMinute, aSecond, 0);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay, anHour, aMinute, aSecond, 0);
  {$ENDIF}
end;

constructor DateTime(aYear: Integer; aMonth: Integer; aDay: Integer; anHour: Integer; aMinute: Integer; aSecond: Integer; aMSec: Integer);
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
  lCalendar.set(Calendar.MILLISECOND, aMSec);
  result := lCalendar;
  {$ELSEIF TOFFEE}
  var Components: NSDateComponents := new NSDateComponents();
  Components.setYear(aYear);
  Components.setMonth(aMonth);
  Components.setDay(aDay);
  Components.setHour(anHour);
  Components.setMinute(aMinute);
  Components.setSecond(aSecond);
  Components.setNanosecond(aMSec * 1000000);
  var lCalendar := NSCalendar.currentCalendar();
  result := lCalendar.dateFromComponents(Components);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aYear, aMonth, aDay, anHour, aMinute, aSecond, aMSec);
  {$ENDIF}
end;

constructor DateTime(aTicks: Int64);
begin
  {$IFDEF COOPER}
  var lCalendar := Calendar.Instance;
  var dt := (aTicks - TicksTill1970) / TimeSpan.TicksPerMillisecond;
  lCalendar.Time := new Date(dt - lCalendar.TimeZone.getOffset(dt));
  result := lCalendar;
  {$ELSEIF TOFFEE}
  var dt := NSDate.dateWithTimeIntervalSince1970(Double(aTicks - TicksTill1970) / TimeSpan.TicksPerSecond);
  result := NSDate.dateWithTimeInterval(-NSTimeZone.localTimeZone.secondsFromGMTForDate(dt)) sinceDate(dt);
  {$ELSEIF ECHOES OR ISLAND}
  fDateTime := new PlatformDateTime(aTicks);
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

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
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
  {$ELSEIF TOFFEE}
  var lFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.locale := if not String.IsNullOrEmpty(Culture) then
    new NSLocale withLocaleIdentifier(Culture)
  else
    NSLocale.localeWithLocaleIdentifier("en_US_POSIX"); // without this, i sometimes get rogue AM/PMs
  lFormatter.dateFormat := DateFormatter.Format(Format);
  result := lFormatter.stringFromDate(mapped);
  {$ELSEIF ECHOES}
  if Format = "" then
    exit "";
  var lDateInTimeZone := if assigned(aTimeZone) then PlatformTimeZone.ConvertTimeFromUtc(fDateTime, aTimeZone) else fDateTime;
  if String.IsNullOrEmpty(Culture) then
    result := lDateInTimeZone.ToString(DateFormatter.Format(Format))
  else
    result := lDateInTimeZone.ToString(DateFormatter.Format(Format), new System.Globalization.CultureInfo(Culture));
  {$ELSEIF ISLAND}
  result := fDateTime.ToString(Format, Culture, aTimeZone);
  {$ENDIF}
end;

method DateTime.ToString(aTimeZone: TimeZone := nil): String;
begin
  result := ToString(DEFAULT_FORMAT, nil, aTimeZone);
end;

method DateTime.ToISO8601String(aFormat: ISO8601Format := ISO8601Format.Standard; aTimeZone: TimeZone := nil): String;
begin
  var lFormat: String;
  {$IF COOPER OR TOFFEE OR DARWIN}
  case aFormat of
    ISO8601Format.Standard: lFormat := "yyyy-MM-dd'T'HH:mm:ss";
    ISO8601Format.DateOnly: lFormat := 'yyyy-MM-dd';
    ISO8601Format.StandardWithTimeZone: lFormat := "yyyy-MM-dd'T'HH:mm:ssZ";
    ISO8601Format.Full: lFormat := "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ";
  end;
  {$ELSEIF ECHOES}
  case aFormat of
    ISO8601Format.Standard: lFormat := 'yyyy-MM-ddTHH:mm:ss';
    ISO8601Format.DateOnly: lFormat := 'yyyy-MM-dd';
    ISO8601Format.StandardWithTimeZone: lFormat := 'yyyy-MM-ddTHH:mm:sszzz';
    ISO8601Format.Full: lFormat := 'yyyy-MM-ddTHH:mm:ss.fffffffzzz';
  end;
  {$ELSEIF ISLAND}
  // Not supported yet
  lFormat := DEFAULT_FORMAT;
  {$ENDIF}
  result := ToString(lFormat, aTimeZone);
end;

method DateTime.ToShortDateString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getDateInstance(java.text.DateFormat.SHORT);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.ShortStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ELSEIF ECHOES OR ISLAND }
  result := fDateTime.ToShortDateString;
  {$ENDIF}
end;

method DateTime.ToShortTimeString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.NoStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.ShortStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ELSEIF ECHOES OR ISLAND}
  result := fDateTime.ToShortTimeString();
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
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.MediumStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ELSEIF ECHOES}
  result := ToShortDateString();
  {$ELSEIF ISLAND}
  result := fDateTime.ToShortPrettyDateString();
  {$ENDIF}
end;

method DateTime.ToLongPrettyDateString(aTimeZone: TimeZone := nil): String;
begin
  {$IF COOPER}
  var lFormatter := java.text.DateFormat.getDateInstance(java.text.DateFormat.LONG);
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  result := lFormatter.format(mapped.Time);
  {$ELSEIF TOFFEE}
  var lFormatter: NSDateFormatter := new NSDateFormatter();
  lFormatter.timeZone := coalesce(aTimeZone, TimeZone.Utc);
  lFormatter.dateStyle := NSDateFormatterStyle.LongStyle;
  lFormatter.timeStyle := NSDateFormatterStyle.NoStyle;
  result := lFormatter.stringFromDate(mapped);
  {$ELSEIF ECHOES}
  result := fDateTime.ToLongDateString;
  {$ELSEIF ISLAND}
  result := fDateTime.ToLongPrettyDateString();
  {$ENDIF}
end;

//
// Mutating Dates
//

method DateTime.AddDays(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.DATE, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.DayCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddDays(Value));
  {$ENDIF}
end;

method DateTime.AddHours(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.HOUR_OF_DAY, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.HourCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddHours(Value));
  {$ENDIF}
end;

method DateTime.AddMinutes(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MINUTE, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.MinuteCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMinutes(Value));
  {$ENDIF}
end;

method DateTime.AddMonths(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MONTH, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.MonthCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMonths(Value));
  {$ENDIF}
end;

method DateTime.AddSeconds(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.SECOND, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.SecondCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddSeconds(Value));
  {$ENDIF}
end;

method DateTime.AddMilliSeconds(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.MILLISECOND, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitNanosecond) value(Int64(Value)*Int64(1 000 000)) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddMilliseconds(Value));
  {$ENDIF}
end;

method DateTime.AddYears(Value: Integer): DateTime;
begin
  {$IF COOPER}
  result := DateTime(mapped.clone);
  Calendar(result).add(Calendar.YEAR, Value);
  {$ELSEIF TOFFEE}
  result := NSCalendar.currentCalendar.dateByAddingUnit(NSCalendarUnit.YearCalendarUnit) value(Value) toDate(self) options(0)
  {$ELSEIF ECHOES OR ISLAND}
  result := new DateTime(fDateTime.AddYears(Value));
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
  {$ELSEIF TOFFEE}
  result := mapped.compare(new DateTime(Value.Year, Value.Month, Value.Day, Value.Hour, Value.Minute, Value.Second));
  {$ELSEIF ECHOES OR ISLAND}
  result := fDateTime.CompareTo(Value:fDateTime);
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

{$IF ECHOES OR (ISLAND AND NOT TOFFEE)}
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

{$IF ISLAND AND DARWIN AND NOT TOFFEE}
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

class method DateTime.TryParse(aDateTime: String; aOptions: DateParserOptions := []): nullable DateTime;
begin
  if DateParser.TryParse(aDateTime, out var lResult, aOptions) then
    result := lResult;
end;

class method DateTime.TryParse(aDateTime: String; aLocale: Locale; aOptions: DateParserOptions := []): nullable DateTime;
begin
  if DateParser.TryParse(aDateTime, aLocale, out var lResult, aOptions) then
    result := lResult;
end;

class method DateTime.TryParse(aDateTime: String; aFormat: String; aOptions: DateParserOptions := []): nullable DateTime;
begin
  if DateParser.TryParse(aDateTime, aFormat, out var lResult, aOptions) then
    result := lResult;
end;

class method DateTime.TryParseISO8601(aDateTime: String): nullable DateTime;
begin
  if DateParser.TryParseISO8601(aDateTime, out var lResult) then
    result := lResult;
end;

class method DateTime.TryParse(aDateTime: String; aFormat: String; aLocale: Locale; aOptions: DateParserOptions := []): nullable DateTime;
begin
  if DateParser.TryParse(aDateTime, aFormat, aLocale, out var lResult, aOptions) then
    result := lResult;
end;

end.