namespace RemObjects.Elements.RTL;

interface

type
  DateParser = public class
  private
    class method GetNextStringToken(var aFormat: String): String;
    class method GetNextNumberToken(var aFormat: String): String;
    class method GetNextNumberToken(var aFormat: String; var aNumber: Integer): Boolean;
    class method GetNextNumberToken(var aFormat: String; var aNumber: Integer; aMin: Integer; aMax: Integer): Boolean;
    class method GetNextSepOrStringToken(var aFormat: String): String;
    class method SkipToNextToken(var aFormat: String; var aDateTime: String): Boolean;
    class method ParseStandard(aDateTime: String; aFormat: String; var output: DateTime): Boolean;
    class method ParsePersonalized(aDateTime: String; aFormat: String; var output: DateTime): Boolean;  
  public
    class method Parse(aDateTime: String; aFormat: String; var output: DateTime): Boolean;
  end;

implementation

class method DateParser.GetNextStringToken(var aFormat: String): String;
begin
  if aFormat.Length = 0 then exit '';

  var lIndex := 0;
  var lChar := aFormat[lIndex];
  while (lIndex < aFormat.Length) and (((lChar >= chr('a')) and (lChar <= chr('z'))) or ((lChar >= chr('A')) and (lChar <= chr('Z')))) do begin
    inc(lIndex);
    if lIndex < aFormat.Length then
      lChar := aFormat[lIndex];
  end;
  result := aFormat.Substring(0, lIndex);
  aFormat := aFormat.Substring(lIndex);
end;

class method DateParser.GetNextNumberToken(var aFormat: String): String;
begin
  if aFormat.Length = 0 then exit '';

  var lIndex := 0;
  var lChar := aFormat[lIndex];
  while (lIndex < aFormat.Length) and (((lChar >= chr('0')) and (lChar <= chr('9')))) do begin
    inc(lIndex);
    if lIndex < aFormat.Length then
      lChar := aFormat[lIndex];
  end;
  result := aFormat.Substring(0, lIndex);
  aFormat := aFormat.Substring(lIndex);
end;

class method DateParser.GetNextNumberToken(var aFormat: String; var aNumber: Integer): Boolean;
begin
  var lToken := GetNextNumberToken(var aFormat);
  aNumber := Convert.TryToInt32(lToken);
  result := aNumber <> nil;  
end;

class method DateParser.GetNextNumberToken(var aFormat: String; var aNumber: Integer; aMin: Integer; aMax: Integer): Boolean;
begin
  result := GetNextNumberToken(var aFormat, var aNumber) and (aNumber >= aMin) and (aNumber <= aMax);
end;

class method DateParser.GetNextSepOrStringToken(var aFormat: String): String;
begin
  if aFormat.Length = 0 then exit '';

  var lIndex := 0;
  var lChar := aFormat[lIndex];
  case lChar of
    '"', '''': begin
      inc(lIndex);
      while (aFormat[lIndex] <> lChar) and (lIndex < aFormat.Length) do inc(lIndex);
      result := aFormat.Substring(1, lIndex - 1);
      aFormat := aFormat.Substring(lIndex);
    end

    else begin
      while (lIndex < aFormat.Length) and (not (lChar in ['a'..'z'])) and (not (lChar in ['A'..'Z'])) do begin
        inc(lIndex);
        lChar := aFormat[lIndex];
      end;
      if lIndex > 0 then begin
        result := aFormat.Substring(0, lIndex);
        aFormat := aFormat.Substring(lIndex);
      end
      else exit '';
    end;
  end;
end;

class method DateParser.SkipToNextToken(var aFormat: String; var aDateTime: String): Boolean;
begin
  var lToken := GetNextSepOrStringToken(var aFormat);
  while lToken.Length > 0 do begin
    if aDateTime.StartsWith(lToken) then
      aDateTime := aDateTime.SubString(lToken.Length)
    else
      exit false;    
    lToken := GetNextSepOrStringToken(var aFormat);
  end;
  result := true;
end;

class method DateParser.ParseStandard(aDateTime: String; aFormat: String; var output: DateTime): Boolean;
begin
  if aFormat.Length <> 1 then exit false;

  case aFormat of
    'd': begin

    end;

    'D': begin

    end;

    'f': begin

    end;

    'F': begin

    end;

    'g': begin

    end;

    'G': begin

    end;

    'M', 'm': begin

    end;

    'O', 'o': begin

    end;

    'R', 'r': begin

    end;

    's': begin

    end;

    't': begin

    end;

    'T': begin

    end;

    'u': begin

    end;

    'U': begin

    end;

    'y', 'Y': begin

    end;
  end;
end;

// "mm/dd/yyyy hh:nn:ss" --> "1/23/2018 4:55:23"
class method DateParser.ParsePersonalized(aDateTime: String; aFormat: String; var output: DateTime): Boolean;
begin
  if aFormat.Length = 1 then
    exit ParseStandard(aDateTime, aFormat, var output);
    
    var lDay, lMonth, lYear, lHour, lMin, lSec: Integer;
    var lTmp: String;
    var lFormat := aFormat.Trim;
    var lDateTime := aDateTime.Trim;
    if not SkipToNextToken(var lFormat, var lDateTime) then exit false;
    var lToken := GetNextStringToken(var lFormat);

    while lToken.Length > 0 do begin
      case lToken of
        'd': begin // day 1 --> 31
          if not GetNextNumberToken(var lDateTime, var lDay, 1, 31) then exit false;
        end;

        'dd': begin // day 01 --> 31
          if not GetNextNumberToken(var lDateTime, var lDay, 1, 31) then exit false;
        end;

        'ddd': begin // day, short name, Wed
          lTmp := GetNextStringToken(var lDateTime);
        end;

        'dddd': begin // day, long name, Wednesday
          lTmp := GetNextStringToken(var lDateTime);
        end;

        'M': begin // month 1 --> 12
          if not GetNextNumberToken(var lDateTime, var lMonth, 1, 12) then exit false;
        end;

        'MM': begin // month 01 --> 12
          if not GetNextNumberToken(var lDateTime, var lMonth, 1, 12) then exit false;
        end;

        'MMM': begin // month, short name, Jun
          lTmp := GetNextStringToken(var lDateTime);
        end;

        'MMMM': begin // month, long name, June
          lTmp := GetNextStringToken(var lDateTime);
        end;

        'y': begin // year, 0 --> 99
          if not GetNextNumberToken(var lDateTime, var lYear, 0, Int32.MaxValue) then exit false;
        end;

        'yy': begin // year, 00 --> 99
          if not GetNextNumberToken(var lDateTime, var lYear, 0, Int32.MaxValue) then exit false;
        end;

        'yyy': begin // year, 001 --> 900 , 1900 --> 2018, minimum three digits
          if not GetNextNumberToken(var lDateTime, var lYear, 0, Int32.MaxValue) then exit false;
        end;

        'yyyy': begin // year, 0001 --> 2018 , four digits
          if not GetNextNumberToken(var lDateTime, var lYear, 0, Int32.MaxValue) then exit false;
        end;

        'yyyyy': begin // year, 00001 --> 02018, five digits
          if not GetNextNumberToken(var lDateTime, var lYear, 0, Int32.MaxValue) then exit false;
        end;

        'h': begin // hour, 1 --> 12
          if not GetNextNumberToken(var lDateTime, var lHour, 1, 12) then exit false;
        end;

        'hh': begin // hour, 01 --> 12
          if not GetNextNumberToken(var lDateTime, var lHour, 1, 12) then exit false;
        end;

        'H': begin // hour, 0 --> 23
          if not GetNextNumberToken(var lDateTime, var lHour, 0, 23) then exit false;
        end;

        'HH': begin // hour, 00 --> 23
          if not GetNextNumberToken(var lDateTime, var lHour, 0, 23) then exit false;
        end;

        'm': begin // minutes, 0 --> 59
          if not GetNextNumberToken(var lDateTime, var lMin, 0, 59) then exit false;
        end;

        'mm': begin // minutes, 00 --> 59
          if not GetNextNumberToken(var lDateTime, var lMin, 0, 59) then exit false;
        end;

        's': begin // seconds, 0 --> 59
          if not GetNextNumberToken(var lDateTime, var lSec, 0, 59) then exit false;
        end;

        'ss': begin // seconds, 00 --> 59
          if not GetNextNumberToken(var lDateTime, var lSec, 0, 59) then exit false;
        end;

        't': begin // am/pm, first character only

        end;

        'tt': begin // am/pm, full string

        end;

        'z': begin // timezone, with no '0', -2

        end;

        'zz': begin // timezone, -02

        end;

        'zzz': begin // timezone, with minutes, -02:00

        end;

        else begin // separators or literals
          lTmp := GetNextSepOrStringToken(var lFormat)
        end;
      end;

      if not SkipToNextToken(var lFormat, var lDateTime) then exit false;
      lToken := GetNextStringToken(var lFormat);
    end;
    result := true;
end;

class method DateParser.Parse(aDateTime: String; aFormat: String; var output: DateTime): Boolean;
begin
  result := ParsePersonalized(aDateTime, aFormat, var output);
end;

end.