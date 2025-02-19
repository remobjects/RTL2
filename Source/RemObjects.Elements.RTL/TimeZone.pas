namespace RemObjects.Elements.RTL;

interface

type
  PlatformTimeZone = public {$IFDEF ECHOES}System.TimeZoneInfo{$ELSEIF TOFFEE}Foundation.NSTimeZone{$ELSEIF COOPER}java.util.TimeZone{$ELSEIF ISLAND}RemObjects.Elements.System.TimeZone{$ENDIF};

  TimeZone = public class mapped to PlatformTimeZone
  private
    class method get_LocalTimeZone: not nullable TimeZone;
    class method get_UtcTimeZone: not nullable TimeZone;
    class method get_TimeZoneWithAbreviation(aAbbreviation: String): nullable TimeZone;
    class method get_TimeZoneWithName(aName: String): nullable TimeZone;
    class method get_TimeZoneNames: not nullable sequence of String;
  protected
  public
    class property Local: not nullable TimeZone read get_LocalTimeZone;
    class property Utc: not nullable TimeZone read get_UtcTimeZone;
    //class property TimeZone[aAbbreviation: String]: nullable TimeZone read get_TimeZoneWithAbreviation;
    class property TimeZoneByName[aName: String]: nullable TimeZone read get_TimeZoneWithName;
    class property TimeZoneNames: not nullable sequence of String read get_TimeZoneNames;

    {$IF COOPER}
    property Name: String read mapped.DisplayName;
    property Identifier: String read mapped.getID;
    property OffsetToUTC: TimeSpan read TimeSpan.FromMilliseconds(mapped.RawOffset);
    {$ELSEIF TOFFEE}
    property Name: String read mapped.name;
    property Identifier: String read mapped.abbreviation;
    property OffsetToUTC: TimeSpan read TimeSpan.FromSeconds(mapped.secondsFromGMT);
    {$ELSEIF ECHOES}
    property Name: String read mapped.DisplayName;
    property Identifier: String read mapped.Id;
    property OffsetToUTC: TimeSpan read mapped.BaseUtcOffset;
    {$ELSEIF ISLAND}
    property Identifier: String read mapped.Identifier;
    property OffsetToUTC: TimeSpan read new TimeSpan(0, mapped.OffsetToUTC, 0);
    {$ENDIF}
  end;

implementation

class method TimeZone.get_TimeZoneNames: not nullable sequence of String;
begin
  {$IF COOPER}
  result := java.util.TimeZone.getAvailableIDs() as not nullable;
  {$ELSEIF TOFFEE}
  result := NSTimeZone.knownTimeZoneNames as List<String> as not nullable;
  {$ELSEIF ECHOES}
  result := System.TimeZoneInfo.GetSystemTimeZones().Select(tz -> tz.Id) as not nullable;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.TimeZone.TimeZoneNames;
  {$ENDIF}
end;

{$IF ECHOES}[Warning("TimeZoneWithAbreviation is not suppoprted on .NET")]{$ENDIF}
{$IF ISLAND AND NOT TOFFEE}[Warning("Not Implemented for Island")]{$ENDIF}
class method TimeZone.get_TimeZoneWithAbreviation(aAbbreviation: String): nullable TimeZone;
begin
  {$IF COOPER}
  result := java.util.TimeZone.getTimeZone(aAbbreviation);
  {$ELSEIF TOFFEE}
  result := NSTimeZone.timeZoneWithAbbreviation(aAbbreviation);
  {$ELSEIF ECHOES}
  raise new NotSupportedException("TimeZoneWithAbreviation is not suppoprted on .NET");
  {$ELSEIF ISLAND}
  raise new NotImplementedException();
  {$ENDIF}
end;

class method TimeZone.get_TimeZoneWithName(aName: String): nullable TimeZone;
begin
  {$IF COOPER}
  result := java.util.TimeZone.getTimeZone(aName);
  {$ELSEIF TOFFEE}
  result := NSTimeZone.timeZoneWithName(aName);
  {$ELSEIF ECHOES}
  result := System.TimeZoneInfo.FindSystemTimeZoneById(aName);
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.TimeZone.TimeZoneByName[aName];
  {$ENDIF}
end;

class method TimeZone.get_LocalTimeZone: not nullable TimeZone;
begin
  {$IF COOPER}
  result := java.util.TimeZone.getDefault() as not nullable;
  {$ELSEIF TOFFEE}
  result := NSTimeZone.localTimeZone as not nullable;
  {$ELSEIF ECHOES}
  result := System.TimeZoneInfo.Local as not nullable;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.TimeZone.Local;
  {$ENDIF}
end;

class method TimeZone.get_UtcTimeZone: not nullable TimeZone;
begin
  {$IF COOPER}
  result := java.util.TimeZone.getTimeZone("UTC") as not nullable;
  {$ELSEIF TOFFEE}
  result := NSTimeZone.timeZoneWithAbbreviation("UTC") as not nullable;
  {$ELSEIF ECHOES}
  result := System.TimeZoneInfo.Utc as not nullable;
  {$ELSEIF ISLAND}
  result := RemObjects.Elements.System.TimeZone.Utc;
  {$ENDIF}
end;

end.