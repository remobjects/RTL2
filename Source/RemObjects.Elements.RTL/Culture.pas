namespace RemObjects.Elements.RTL;

interface

{$IF COOPER}
uses
  java.text,
  java.util;
{$ELSEIF TOFFEE}
uses
  Foundation;
{$ENDIF}

type
  // A locale/culture wrapper — decimal/group separators, number/currency
  // formatting, and locale-aware string comparison. Wraps
  // System.Globalization.CultureInfo (Echoes), java.util.Locale +
  // java.text.NumberFormat/DecimalFormatSymbols/Collator (Cooper), and
  // NSLocale + NSNumberFormatter (Toffee).
  //
  // Island (every sub-target, Darwin included) is not implemented here —
  // every method raises NotImplementedException on Island, for the same
  // two reasons documented in UnicodeSupport.pas: Island's own runtime has
  // no locale API of its own, and Island.Darwin's Foundation-based path
  // (identical code to Toffee's, which works) crashes the Elements
  // compiler itself when compiled for Island specifically.
  Culture = public class
  private
    {$IF ECHOES}
    fCulture: System.Globalization.CultureInfo;
    {$ELSEIF COOPER}
    fLocale: java.util.Locale;
    {$ELSEIF TOFFEE}
    fLocale: NSLocale;
    {$ENDIF}
  public
    constructor (aName: not nullable String);
    method get_DecimalSeparator: not nullable String;
    method get_GroupSeparator: not nullable String;
    property DecimalSeparator: not nullable String read get_DecimalSeparator;
    property GroupSeparator: not nullable String read get_GroupSeparator;
    method FormatNumber(aValue: Double; aFractionDigits: Integer): not nullable String;
    method FormatCurrency(aValue: Double): not nullable String;
    method Compare(aFirst: not nullable String; aSecond: not nullable String; aIgnoreCase: Boolean): Integer;
  end;

implementation

constructor Culture(aName: not nullable String);
begin
  {$IF ECHOES}
  fCulture := new System.Globalization.CultureInfo(aName);
  {$ELSEIF COOPER}
  fLocale := java.util.Locale.forLanguageTag(aName.Replace("_", "-"));
  {$ELSEIF TOFFEE}
  fLocale := NSLocale.alloc.initWithLocaleIdentifier(aName);
  {$ELSE}
  raise new NotImplementedException("Culture is not implemented for this Island platform yet");
  {$ENDIF}
end;

method Culture.get_DecimalSeparator: not nullable String;
begin
  {$IF ECHOES}
  result := fCulture.NumberFormat.NumberDecimalSeparator;
  {$ELSEIF COOPER}
  var lSymbols := new java.text.DecimalFormatSymbols(fLocale);
  result := String(lSymbols.getDecimalSeparator());
  {$ELSEIF TOFFEE}
  result := String(fLocale.objectForKey(NSLocaleDecimalSeparator));
  {$ELSE}
  raise new NotImplementedException("Culture.DecimalSeparator is not implemented for this Island platform yet");
  {$ENDIF}
end;

method Culture.get_GroupSeparator: not nullable String;
begin
  {$IF ECHOES}
  result := fCulture.NumberFormat.NumberGroupSeparator;
  {$ELSEIF COOPER}
  var lSymbols := new java.text.DecimalFormatSymbols(fLocale);
  result := String(lSymbols.getGroupingSeparator());
  {$ELSEIF TOFFEE}
  result := String(fLocale.objectForKey(NSLocaleGroupingSeparator));
  {$ELSE}
  raise new NotImplementedException("Culture.GroupSeparator is not implemented for this Island platform yet");
  {$ENDIF}
end;

method Culture.FormatNumber(aValue: Double; aFractionDigits: Integer): not nullable String;
begin
  {$IF ECHOES}
  result := aValue.ToString("N" + aFractionDigits, fCulture);
  {$ELSEIF COOPER}
  var lFormat := java.text.NumberFormat.getNumberInstance(fLocale);
  lFormat.setMaximumFractionDigits(aFractionDigits);
  lFormat.setMinimumFractionDigits(aFractionDigits);
  result := lFormat.format(aValue);
  {$ELSEIF TOFFEE}
  var lFormatter := NSNumberFormatter.alloc.init;
  lFormatter.locale := fLocale;
  lFormatter.numberStyle := NSNumberFormatterStyle.DecimalStyle;
  lFormatter.maximumFractionDigits := aFractionDigits;
  lFormatter.minimumFractionDigits := aFractionDigits;
  result := lFormatter.stringFromNumber(NSNumber.numberWithDouble(aValue));
  {$ELSE}
  raise new NotImplementedException("Culture.FormatNumber is not implemented for this Island platform yet");
  {$ENDIF}
end;

method Culture.FormatCurrency(aValue: Double): not nullable String;
begin
  {$IF ECHOES}
  result := aValue.ToString("C2", fCulture);
  {$ELSEIF COOPER}
  var lFormat := java.text.NumberFormat.getCurrencyInstance(fLocale);
  result := lFormat.format(aValue);
  {$ELSEIF TOFFEE}
  var lFormatter := NSNumberFormatter.alloc.init;
  lFormatter.locale := fLocale;
  lFormatter.numberStyle := NSNumberFormatterStyle.CurrencyStyle;
  result := lFormatter.stringFromNumber(NSNumber.numberWithDouble(aValue));
  {$ELSE}
  raise new NotImplementedException("Culture.FormatCurrency is not implemented for this Island platform yet");
  {$ENDIF}
end;

method Culture.Compare(aFirst: not nullable String; aSecond: not nullable String; aIgnoreCase: Boolean): Integer;
begin
  {$IF ECHOES}
  var lOptions := System.Globalization.CompareOptions.None;
  if aIgnoreCase then
    lOptions := System.Globalization.CompareOptions.IgnoreCase;
  result := System.String.Compare(aFirst, aSecond, fCulture, lOptions);
  {$ELSEIF COOPER}
  var lCollator := java.text.Collator.getInstance(fLocale);
  if aIgnoreCase then
    lCollator.setStrength(java.text.Collator.PRIMARY);
  result := lCollator.compare(aFirst, aSecond);
  {$ELSEIF TOFFEE}
  var lFirst := NSString.stringWithString(aFirst);
  var lOptions: NSStringCompareOptions := 0;
  if aIgnoreCase then
    lOptions := NSStringCompareOptions.CaseInsensitiveSearch;
  var lResult := lFirst.compare(aSecond) options(lOptions) range(NSMakeRange(0, lFirst.length)) locale(fLocale);
  result := Integer(lResult);
  {$ELSE}
  raise new NotImplementedException("Culture.Compare is not implemented for this Island platform yet");
  {$ENDIF}
end;

end.
