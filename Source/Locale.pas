namespace RemObjects.Elements.RTL;

interface

type
  NumberFormatInfo = public class
  private
    fCurrency: String;
    fThousandsSeparator: Char;
    fDecimalSeparator: Char;
    fIsReadOnly: Boolean;
    method SetDecimalSeparator(aValue: Char);
    method SetThousandsSeparator(aValue: Char);
    method SetCurrency(aValue: String);
  public
    property DecimalSeparator: Char read fDecimalSeparator write SetDecimalSeparator;
    property ThousandsSeparator: Char read fThousandsSeparator write SetThousandsSeparator;
    property Currency: String read fCurrency write SetCurrency;
    property IsReadOnly: Boolean read fIsReadOnly;
    constructor(aIsReadOnly: Boolean := false);
    constructor(aDecimalSeparator: Char; aThousandsSeparator: Char; aCurrency: String; aIsReadOnly: Boolean := false);
  end;

  DateTimeFormatInfo = public class
  private
    fShortDayNames := new String[7];
    fLongDayNames := new String[7];
    fShortMonthNames := new String[12];
    fLongMonthNames := new String[12];
    fDateSeparator: String;
    fTimeSeparator: String;
    fAMString: String;
    fPMString: String;
    fShortDatePattern: String;
    fLongDatePattern: String;
    fShortTimePattern: String;
    fLongTimePattern: String;
    fIsReadOnly: Boolean;
    method SetShortDayNames(aValue: array of String);
    method SetLongDayNames(aValue: array of String);
    method SetShortMonthNames(aValue: array of String);
    method SetLongMonthNames(aValue: array of String);
    method SetDateSeparator(aValue: String);
    method SetTimeSeparator(aValue: String);
    method SetAMString(aValue: String);
    method SetPMString(aValue: String);
    method SetShortTimePattern(aValue: String);
    method SetLongTimePattern(aValue: String);
    method SetShortDatePattern(aValue: String);
    method SetLongDatePattern(aValue: String);
    method CheckReadOnly;
  public
    constructor(aLocale: PlatformLocale; aIsReadonly: Boolean := false);
    property ShortDayNames: array of String read fShortDayNames write SetShortDayNames;
    property LongDayNames: array of String read fLongDayNames write SetLongDayNames;
    property ShortMonthNames: array of String read fShortMonthNames write SetShortMonthNames;
    property LongMonthNames: array of String read fLongMonthNames write SetLongMonthNames;
    property DateSeparator: String read fDateSeparator write SetDateSeparator;
    property TimeSeparator: String read fTimeSeparator write SetTimeSeparator;
    property AMString: String read fAMString write SetAMString;
    property PMString: String read fPMString write SetPMString;
    property ShortTimePattern: String read fShortTimePattern write SetShortTimePattern;
    property LongTimePattern: String read fLongTimePattern write SetLongTimePattern;
    property ShortDatePattern: String read fShortDatePattern write SetShortDatePattern;
    property LongDatePattern: String read fLongDatePattern write SetLongDatePattern;
    property IsReadOnly: Boolean read fIsReadOnly;
  end;

  PlatformLocale = {$IF ECHOES}System.Globalization.CultureInfo{$ELSEIF COOPER}java.util.Locale{$ELSEIF TOFFEE}Foundation.NSLocale{$ELSEIF ISLAND}RemObjects.Elements.System.Locale{$ENDIF};

  Locale = public class
  private
    fNumberFormat: NumberFormatInfo;
    fDateTimeFormat: DateTimeFormatInfo;
    fLocaleID: PlatformLocale;
    class method GetInvariant: not nullable Locale;
    class method GetCurrent: not nullable Locale;
    method GetIdentifier: not nullable String;
    class var fCurrent: Locale;
    class var fInvariant: Locale;
  protected
    constructor(aLocaleID: PlatformLocale);
  public
    operator Implicit(aValue: Locale): PlatformLocale;
    constructor(aLocale: String);
    class property Invariant: Locale read GetInvariant;
    class property Current: Locale read GetCurrent;
    property Identifier: not nullable String read GetIdentifier;
    property NumberFormat: NumberFormatInfo read fNumberFormat;
    property DateTimeFormat: DateTimeFormatInfo read fDateTimeFormat;
    property PlatformLocale: PlatformLocale read fLocaleID;
  end;

implementation

operator Locale.Implicit(aValue: Locale): PlatformLocale;
begin
  result := aValue.fLocaleID;
end;

constructor Locale(aLocale: String);
begin
  {$IF COOPER}
  aLocale := aLocale.Replace('_', '-');
  constructor(java.util.Locale.forLanguageTag(aLocale));
  {$ELSEIF ECHOES}
  aLocale := aLocale.Replace('_', '-');
  constructor(new System.Globalization.CultureInfo(aLocale));
  {$ELSEIF ISLAND}
  constructor(new RemObjects.Elements.System.Locale(aLocale));
  {$ENDIF}
end;

constructor Locale(aLocaleID: PlatformLocale);
begin
  fLocaleID := aLocaleID;
  fNumberFormat := new NumberFormatInfo();
  fDateTimeFormat := new DateTimeFormatInfo(aLocaleID);
  {$IF COOPER}
  var lFormat := java.text.SimpleDateFormat(java.text.DateFormat.getDateInstance(java.text.DateFormat.LONG, aLocaleID));
  fDateTimeFormat.LongDatePattern := lFormat.toPattern;
  lFormat := java.text.SimpleDateFormat(java.text.DateFormat.getDateInstance(java.text.DateFormat.SHORT, aLocaleID));
  fDateTimeFormat.ShortDatePattern := lFormat.toPattern;
  fDateTimeFormat.LongTimePattern := 'hh:mm:ss';
  fDateTimeFormat.ShortTimePattern := 'hh:mm';
  var lDateSymbols := lFormat.getDateFormatSymbols;
  fDateTimeFormat.ShortDayNames := lDateSymbols.getShortWeekdays();
  fDateTimeFormat.LongDayNames := lDateSymbols.getWeekdays();
  fDateTimeFormat.ShortMonthNames := lDateSymbols.getShortMonths();
  fDateTimeFormat.LongMonthNames := lDateSymbols.getMonths();
  if lDateSymbols.AmPmStrings.length > 1 then begin
    fDateTimeFormat.AMString := lDateSymbols.AmPmStrings[0];
    fDateTimeFormat.PMString := lDateSymbols.AmPmStrings[1];
  end;
  fDateTimeFormat.DateSeparator := '/';

  var lCurrency := java.util.Currency.getInstance(aLocaleID);
  fNumberFormat.Currency := lCurrency.getSymbol;
  //fNumberFormat.CurrencyDecimals := lCurrency.DefaultFractionDigits;
  var lSymbols := new java.text.DecimalFormat().getDecimalFormatSymbols;
  fNumberFormat.DecimalSeparator := lSymbols.getDecimalSeparator;
  fNumberFormat.ThousandsSeparator := lSymbols.getGroupingSeparator;
  {$ELSEIF ECHOES}
  fDateTimeFormat.LongDatePattern := aLocaleID.DateTimeFormat.LongDatePattern;
  fDateTimeFormat.ShortDatePattern := aLocaleID.DateTimeFormat.ShortDatePattern;
  fDateTimeFormat.LongTimePattern := aLocaleID.DateTimeFormat.LongTimePattern;
  fDateTimeFormat.ShortTimePattern := aLocaleID.DateTimeFormat.ShortTimePattern;
  fDateTimeFormat.PMString := aLocaleID.DateTimeFormat.PMDesignator;
  fDateTimeFormat.AMString := aLocaleID.DateTimeFormat.AMDesignator;
  fDateTimeFormat.DateSeparator := aLocaleID.DateTimeFormat.DateSeparator;
  fDateTimeFormat.ShortDayNames := aLocaleID.DateTimeFormat.AbbreviatedDayNames;
  fDateTimeFormat.LongDayNames := aLocaleID.DateTimeFormat.DayNames;
  fDateTimeFormat.ShortMonthNames := aLocaleID.DateTimeFormat.AbbreviatedMonthNames;
  fDateTimeFormat.LongMonthNames := aLocaleID.DateTimeFormat.MonthNames;

  fNumberFormat.Currency := aLocaleID.NumberFormat.CurrencySymbol;
  //if length(aLocaleID.NumberFormat.CurrencyGroupSizes) > 0 then
    //fNumberFormat.CurrencyDecimals := lLocale.NumberFormat.CurrencyGroupSizes[0];
  if aLocaleID.NumberFormat.NumberDecimalSeparator.Length > 0 then
    fNumberFormat.DecimalSeparator := aLocaleID.NumberFormat.NumberDecimalSeparator[0];
  if aLocaleID.NumberFormat.NumberGroupSeparator.Length > 0 then
    fNumberFormat.ThousandsSeparator := aLocaleID.NumberFormat.NumberGroupSeparator[0];
  {$ELSEIF TOFFEE}
  var lDateFormatter := new NSDateFormatter();
  lDateFormatter.locale := aLocaleID;
  lDateFormatter.dateStyle := NSDateFormatterStyle.NSDateFormatterFullStyle;
  lDateFormatter.timeStyle := NSDateFormatterStyle.NSDateFormatterNoStyle;
  fDateTimeFormat.LongDatePattern := lDateFormatter.dateFormat;

  lDateFormatter.dateStyle := NSDateFormatterStyle.NSDateFormatterShortStyle;
  lDateFormatter.timeStyle := NSDateFormatterStyle.NSDateFormatterNoStyle;
  fDateTimeFormat.ShortDatePattern := lDateFormatter.dateFormat;

  lDateFormatter.dateStyle := NSDateFormatterStyle.NSDateFormatterNoStyle;
  lDateFormatter.timeStyle := NSDateFormatterStyle.NSDateFormatterMediumStyle;
  fDateTimeFormat.LongTimePattern := lDateFormatter.dateFormat;

  lDateFormatter.dateStyle := NSDateFormatterStyle.NSDateFormatterNoStyle;
  lDateFormatter.timeStyle := NSDateFormatterStyle.NSDateFormatterShortStyle;
  fDateTimeFormat.ShortTimePattern := lDateFormatter.dateFormat;

  var lNumberFormatter := new NSNumberFormatter();
  lNumberFormatter.locale := aLocaleID;
  fNumberFormat.Currency := lNumberFormatter.currencySymbol;
  if lNumberFormatter.decimalSeparator.length > 0 then
    fNumberFormat.DecimalSeparator := lNumberFormatter.decimalSeparator[0];
  if lNumberFormatter.groupingSeparator.length > 0 then
    fNumberFormat.ThousandsSeparator := lNumberFormatter.groupingSeparator[0];
  {$ELSEIF ISLAND}
  fDateTimeFormat.LongDatePattern := aLocaleID.DateTimeFormat.LongDatePattern;
  fDateTimeFormat.ShortDatePattern := aLocaleID.DateTimeFormat.ShortDatePattern;
  fDateTimeFormat.LongTimePattern := aLocaleID.DateTimeFormat.LongTimePattern;
  fDateTimeFormat.ShortTimePattern := aLocaleID.DateTimeFormat.ShortTimePattern;
  fDateTimeFormat.PMString := aLocaleID.DateTimeFormat.PMString;
  fDateTimeFormat.AMString := aLocaleID.DateTimeFormat.AMString;
  fDateTimeFormat.DateSeparator := aLocaleID.DateTimeFormat.DateSeparator;
  fDateTimeFormat.ShortDayNames := aLocaleID.DateTimeFormat.ShortDayNames;
  fDateTimeFormat.LongDayNames := aLocaleID.DateTimeFormat.LongDayNames;
  fDateTimeFormat.ShortMonthNames := aLocaleID.DateTimeFormat.ShortMonthNames;
  fDateTimeFormat.LongMonthNames := aLocaleID.DateTimeFormat.LongMonthNames;

  fNumberFormat.Currency := aLocaleID.NumberFormat.Currency;
  fNumberFormat.DecimalSeparator := aLocaleID.NumberFormat.DecimalSeparator;
  fNumberFormat.ThousandsSeparator := aLocaleID.NumberFormat.ThousandsSeparator;
  {$ENDIF}
end;

class method Locale.GetInvariant: not nullable Locale;
begin
  if fInvariant = nil then begin
    {$IF COOPER}
    fInvariant := new Locale(java.util.Locale.ROOT);
    {$ELSEIF ECHOES}
    fInvariant := new Locale(System.Globalization.CultureInfo.InvariantCulture);
    {$ELSEIF ISLAND}
    fInvariant := new Locale(RemObjects.Elements.System.Locale.Invariant);
    {$ENDIF}
  end;
  result := fInvariant as not nullable;
end;

class method Locale.GetCurrent: not nullable Locale;
begin
  if fCurrent = nil then begin
    {$IF COOPER}
    fCurrent := new Locale(java.util.Locale.getDefault());
    {$ELSEIF ECHOES}
    fCurrent := new Locale(System.Threading.Thread.CurrentThread.CurrentCulture);
    {$ELSEIF ISLAND}
    fCurrent := new Locale(RemObjects.Elements.System.Locale.Current);
    {$ENDIF}
  end;
  result := fCurrent as not nullable;
end;

method Locale.GetIdentifier: not nullable String;
begin
  {$IF COOPER}
  result := fLocaleID.toString() as not nullable;
  {$ELSE}
  result := '' as not nullable;
  {$ENDIF}
end;

method DateTimeFormatInfo.SetShortDayNames(aValue: array of String);
begin
  fShortDayNames := aValue;
end;

method DateTimeFormatInfo.SetLongDayNames(aValue: array of String);
begin
  fLongDayNames := aValue;
end;

method DateTimeFormatInfo.SetShortMonthNames(aValue: array of String);
begin
  fShortMonthNames := aValue;
end;

method DateTimeFormatInfo.SetLongMonthNames(aValue: array of String);
begin
  fLongMonthNames := aValue;
end;

method DateTimeFormatInfo.SetDateSeparator(aValue: String);
begin
  fDateSeparator := aValue;
end;

method DateTimeFormatInfo.SetTimeSeparator(aValue: String);
begin
  fTimeSeparator := aValue;
end;

method DateTimeFormatInfo.SetAMString(aValue: String);
begin
  fAMString := aValue;
end;

method DateTimeFormatInfo.SetPMString(aValue: String);
begin
  fPMString := aValue;
end;

method DateTimeFormatInfo.SetShortTimePattern(aValue: String);
begin
  fShortTimePattern := aValue;
end;

method DateTimeFormatInfo.SetLongTimePattern(aValue: String);
begin
  fLongTimePattern := aValue;
end;

method DateTimeFormatInfo.SetShortDatePattern(aValue: String);
begin
  fShortDatePattern := aValue;
end;

method DateTimeFormatInfo.SetLongDatePattern(aValue: String);
begin
  fLongDatePattern := aValue;
end;

method DateTimeFormatInfo.CheckReadOnly;
begin

end;

constructor DateTimeFormatInfo(aLocale: PlatformLocale; aIsReadonly: Boolean := false);
begin
  fIsReadOnly := aIsReadonly;
end;

constructor NumberFormatInfo(aDecimalSeparator: Char; aThousandsSeparator: Char; aCurrency: String; aIsReadOnly: Boolean := false);
begin
  fIsReadOnly := aIsReadOnly;
  fDecimalSeparator := aDecimalSeparator;
  fThousandsSeparator := aThousandsSeparator;
  fCurrency := aCurrency;
end;

method NumberFormatInfo.SetDecimalSeparator(aValue: Char);
begin
  fDecimalSeparator := aValue;
end;

method NumberFormatInfo.SetThousandsSeparator(aValue: Char);
begin
  fThousandsSeparator := aValue;
end;

method NumberFormatInfo.SetCurrency(aValue: String);
begin
  fCurrency := aValue;
end;

constructor NumberFormatInfo(aIsReadOnly: Boolean := false);
begin
  fIsReadOnly := aIsReadOnly;
end;

end.