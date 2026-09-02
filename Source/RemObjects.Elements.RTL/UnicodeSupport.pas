namespace RemObjects.Elements.RTL;

interface

{$IF COOPER}
uses
  java.text;
{$ELSEIF TOFFEE}
uses
  Foundation;
{$ENDIF}

type
  // Implemented for Echoes, Cooper, and Toffee only — see the Island note
  // below the class declarations for why plain Island is excluded (not a
  // permanent design choice, a currently-blocked one).
  //
  // Matches System.Globalization.UnicodeCategory's own member order/values
  // on Echoes exactly (a direct cast, zero mapping needed there). Cooper's
  // java.lang.Character constants use a different numeric order and are
  // translated explicitly (see GetCategory below). Toffee has no single
  // native "get category" call at all — Foundation only exposes
  // character-set *membership* tests (NSCharacterSet), not a full 30-way
  // classification — so it only distinguishes the categories directly
  // reachable that way and falls back to OtherLetter/OtherSymbol/
  // OtherPunctuation/OtherNotAssigned for anything finer-grained real
  // Unicode data would be needed for. This is a real, documented reduction
  // in granularity on that target, not an oversight.
  UnicodeCategory = public enum (
    UppercaseLetter, LowercaseLetter, TitlecaseLetter, ModifierLetter, OtherLetter,
    NonSpacingMark, SpacingCombiningMark, EnclosingMark,
    DecimalDigitNumber, LetterNumber, OtherNumber,
    SpaceSeparator, LineSeparator, ParagraphSeparator,
    Control, Format, Surrogate, PrivateUse, ConnectorPunctuation,
    DashPunctuation, OpenPunctuation, ClosePunctuation, InitialQuotePunctuation,
    FinalQuotePunctuation, OtherPunctuation, MathSymbol, CurrencySymbol,
    ModifierSymbol, OtherSymbol, OtherNotAssigned);

  UnicodeInfo = public static class
  public
    class method GetCategory(aChar: Char): UnicodeCategory;
    class method GetNumericValue(aChar: Char): Double;
    class method NormalizeNFC(aString: not nullable String): not nullable String;
    class method NormalizeNFD(aString: not nullable String): not nullable String;
  end;

  // Island (every sub-target, Darwin included) is not implemented here —
  // every UnicodeInfo method raises NotImplementedException on Island. Two
  // separate reasons, not one:
  // (1) Island's own native runtime (checked directly in its String.pas
  //     source) has no character-category/normalization API of its own at
  //     all, on any sub-target — so there's nothing to wrap for
  //     Island.Windows/Linux/Android/WebAssembly short of embedding real
  //     Unicode data or wiring up per-OS native APIs, each a genuinely
  //     separate, larger undertaking.
  // (2) Island.Darwin specifically DOES link against Foundation (the same
  //     framework Toffee uses) and the identical NSString/NSCharacterSet
  //     calls that work correctly from Toffee source — but writing that
  //     exact same code in this file (Oxygene source targeting
  //     Island.Darwin) crashes the compiler itself (an internal assertion
  //     failure in GenerateExecutable/VisitResolvedNewExpression during
  //     Island codegen), not a compile-time diagnostic. This reproduced
  //     consistently and appears to be a genuine Island-Darwin-specific
  //     Foundation-interop codegen bug, distinct from (1) —
  //     Island.Darwin's own runtime capability isn't actually the blocker
  //     there, the compiler is.

implementation

class method UnicodeInfo.GetCategory(aChar: Char): UnicodeCategory;
begin
  {$IF ECHOES}
  result := UnicodeCategory(System.Globalization.CharUnicodeInfo.GetUnicodeCategory(aChar));
  {$ELSEIF COOPER}
  var lType := java.lang.Character.getType(Integer(aChar));
  case lType of
    1: result := UnicodeCategory.UppercaseLetter;
    2: result := UnicodeCategory.LowercaseLetter;
    3: result := UnicodeCategory.TitlecaseLetter;
    4: result := UnicodeCategory.ModifierLetter;
    5: result := UnicodeCategory.OtherLetter;
    6: result := UnicodeCategory.NonSpacingMark;
    7: result := UnicodeCategory.EnclosingMark;
    8: result := UnicodeCategory.SpacingCombiningMark;
    9: result := UnicodeCategory.DecimalDigitNumber;
    10: result := UnicodeCategory.LetterNumber;
    11: result := UnicodeCategory.OtherNumber;
    12: result := UnicodeCategory.SpaceSeparator;
    13: result := UnicodeCategory.LineSeparator;
    14: result := UnicodeCategory.ParagraphSeparator;
    15: result := UnicodeCategory.Control;
    16: result := UnicodeCategory.Format;
    18: result := UnicodeCategory.PrivateUse;
    19: result := UnicodeCategory.Surrogate;
    20: result := UnicodeCategory.DashPunctuation;
    21: result := UnicodeCategory.OpenPunctuation;
    22: result := UnicodeCategory.ClosePunctuation;
    23: result := UnicodeCategory.ConnectorPunctuation;
    24: result := UnicodeCategory.OtherPunctuation;
    25: result := UnicodeCategory.MathSymbol;
    26: result := UnicodeCategory.CurrencySymbol;
    27: result := UnicodeCategory.ModifierSymbol;
    28: result := UnicodeCategory.OtherSymbol;
    29: result := UnicodeCategory.InitialQuotePunctuation;
    30: result := UnicodeCategory.FinalQuotePunctuation;
  else
    result := UnicodeCategory.OtherNotAssigned;
  end;
  {$ELSEIF TOFFEE}
  var lStr := NSString.stringWithString(String(aChar));
  var lCode: Foundation.unichar := lStr.characterAtIndex(0);
  if NSCharacterSet.uppercaseLetterCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.UppercaseLetter
  else if NSCharacterSet.lowercaseLetterCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.LowercaseLetter
  else if NSCharacterSet.decimalDigitCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.DecimalDigitNumber
  else if NSCharacterSet.letterCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.OtherLetter
  else if NSCharacterSet.whitespaceCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.SpaceSeparator
  else if NSCharacterSet.newlineCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.Control
  else if NSCharacterSet.punctuationCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.OtherPunctuation
  else if NSCharacterSet.symbolCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.OtherSymbol
  else if NSCharacterSet.controlCharacterSet.characterIsMember(lCode) then
    result := UnicodeCategory.Control
  else
    result := UnicodeCategory.OtherNotAssigned;
  {$ELSE}
  raise new NotImplementedException("UnicodeInfo.GetCategory is not implemented for this Island platform yet — no native Unicode category data is available outside Darwin/Echoes/Cooper");
  {$ENDIF}
end;

class method UnicodeInfo.GetNumericValue(aChar: Char): Double;
begin
  {$IF ECHOES}
  result := System.Globalization.CharUnicodeInfo.GetNumericValue(aChar);
  {$ELSEIF COOPER}
  var lValue := java.lang.Character.getNumericValue(Integer(aChar));
  if lValue < 0 then
    result := RemObjects.Elements.RTL.Consts.NaN
  else
    result := lValue;
  {$ELSEIF TOFFEE}
  // Foundation has no direct numeric-value-of-character API; only decimal
  // digits '0'-'9' are handled here (the overwhelmingly common case) —
  // Unicode's other numeric characters (Roman numerals, fractions, other
  // scripts' digits) would need real Unicode data this target doesn't have.
  if (aChar >= '0') and (aChar <= '9') then
    result := Integer(aChar) - Integer('0')
  else
    result := RemObjects.Elements.RTL.Consts.NaN;
  {$ELSE}
  raise new NotImplementedException("UnicodeInfo.GetNumericValue is not implemented for this Island platform yet");
  {$ENDIF}
end;

class method UnicodeInfo.NormalizeNFC(aString: not nullable String): not nullable String;
begin
  {$IF ECHOES}
  result := System.String(aString).Normalize(System.Text.NormalizationForm.FormC);
  {$ELSEIF COOPER}
  result := java.text.Normalizer.normalize(aString, java.text.Normalizer.Form.NFC);
  {$ELSEIF TOFFEE}
  var lStr := NSString.stringWithString(aString);
  result := lStr.precomposedStringWithCanonicalMapping;
  {$ELSE}
  raise new NotImplementedException("UnicodeInfo.NormalizeNFC is not implemented for this Island platform yet");
  {$ENDIF}
end;

class method UnicodeInfo.NormalizeNFD(aString: not nullable String): not nullable String;
begin
  {$IF ECHOES}
  result := System.String(aString).Normalize(System.Text.NormalizationForm.FormD);
  {$ELSEIF COOPER}
  result := java.text.Normalizer.normalize(aString, java.text.Normalizer.Form.NFD);
  {$ELSEIF TOFFEE}
  var lStr := NSString.stringWithString(aString);
  result := lStr.decomposedStringWithCanonicalMapping;
  {$ELSE}
  raise new NotImplementedException("UnicodeInfo.NormalizeNFD is not implemented for this Island platform yet");
  {$ENDIF}
end;

end.
