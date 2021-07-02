﻿//
// Stringformatter.pas
//
// This file is ported from the Mono project
//
// Original File:
//   PlatformString.cs
// Original Mono Authors:
//   Patrik Torstensson
//   Jeffrey Stedfast (fejj@ximian.com)
//   Dan Lewis (dihlewis@yahoo.co.uk)
//   Sebastien Pouliot  <sebastien@ximian.com>
//   Marek Safar (marek.safar@seznam.cz)
//   Andreas Nahr (Classdevelopment@A-SoftTech.com)
//
// (C) 2001 Ximian, Inc.  http://www.ximian.com
// Copyright (C) 2004-2005 Novell (http://www.novell.com)
// Copyright (c) 2012 Xamarin, Inc (http://www.xamarin.com)
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

namespace RemObjects.Elements.RTL;

interface

type
  StringFormatter = public static class
  private
    class method ParseDecimal(aString: String; var ptr: Int32): Int32;
    class method ParseFormatSpecifier(aString: String; var ptr: Int32; out n: Int32; out width: Int32; out left_align: Boolean; out aFormat: String);
    class method ProcessFormat(aFormat: String; aArg: Object; aLocale: Locale): String;
    class method ProcessStandardNumericFormat(aFormat: String; aArg: Object; aLocale: Locale): String;
  public
    class method FormatString(aFormat: String; params args: array of Object): not nullable String;
    class method FormatString(aLocale: Locale; aFormat: String; params args: array of Object): not nullable String;
  end;

implementation

class method StringFormatter.FormatString(aLocale: Locale; aFormat: String; params args: array of Object): not nullable String;
begin
  if aFormat = nil then raise new ArgumentNullException('aFormat');
  if args = nil then raise new ArgumentNullException('args');
  var sb := new StringBuilder();
  var ptr: Int32 := 0;
  var start: Int32 := ptr;
  while ptr < aFormat.Length do begin
    var c := aFormat[ptr];
    inc(ptr);
    if c = '{' then begin
      sb.Append(aFormat, start, ptr - start - 1);
      // check for escaped open bracket
      if aFormat[ptr] = '{' then begin
        start := ptr;
        inc(ptr);
        continue;
      end;
      // parse specifier
      var n: Int32;
      var width: Int32;
      var left_align: Boolean;
      var arg_format: String;
      ParseFormatSpecifier(aFormat, var ptr, out n, out width, out left_align, out arg_format);

      if n ≥ length(args) then
        raise new FormatException('Placeholder index ({0}) must be greater than or equal to zero and less than the size of the argument list ({1}).', n, length(args));

      // format argument
      var arg := args[n];
      var str := if not assigned(arg) then '' else if arg_format ≠ '' then ProcessFormat(arg_format, arg, aLocale) else {$IF TOFFEE}arg.description{$ELSE}arg.ToString{$ENDIF};

      // pad formatted string and append to sb
      if width > length(str) then begin
        var padlen := width - length(str);
        if left_align then begin
          sb.Append(str);
          sb.Append(' ', padlen)
        end
        else begin
          sb.Append(' ', padlen);
          sb.Append(str)
        end
      end
      else begin
        sb.Append(str)
      end;
      start := ptr
    end
    else if ((c = '}') and (ptr < aFormat.Length) and (aFormat[ptr] = '}')) then begin
        sb.Append(aFormat, start, ptr - start - 1);
        start := ptr;
        inc(ptr);
    end
    else if c = '}' then begin
      raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
    end;
  end;
  if start < aFormat.Length then sb.Append(aFormat, start, aFormat.Length - start);
  exit sb.ToString() as not nullable;
end;

class method StringFormatter.FormatString(aFormat: String; params args: array of Object): not nullable String;
begin
  exit FormatString(Locale.Current, aFormat, args);
end;

class method StringFormatter.ParseFormatSpecifier(aString: String; var ptr: Int32; out n: Int32; out width: Int32; out left_align: Boolean; out aFormat: String);
begin
  var max := aString.Length;
  // parses format specifier of form:
  //   N,[\ +[-]M][:F]}
  //
  // where:
  // N = argument number (non-negative integer)
  n := ParseDecimal(aString, var ptr);
  if n < 0 then raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
  // M = width (non-negative integer)
  if (ptr < max) and (aString[ptr] = ',') then begin
    // White space between ',' and number or sign.
    inc(ptr);
    while (ptr < max) and (String.CharacterIsWhiteSpace(aString[ptr])) do inc(ptr);
    var start := ptr;
    aFormat := aString.Substring(start, ptr - start);
    left_align := ((ptr < max) and (aString[ptr] = '-'));
    if left_align then inc(ptr);
    width := ParseDecimal(aString, var ptr);
    if width < 0 then raise new FormatException(RTLErrorMessages.FORMAT_ERROR)
  end
  else begin
    width := 0;
    left_align := false;
    aFormat := "";
  end;

  // F = argument format (string)
  if (ptr < max) and (aString[ptr] = ':') then begin
    var start := ptr;
    inc(ptr);
    while (ptr < max) and (aString[ptr] ≠ '}') do inc(ptr);
    aFormat := aFormat + aString.Substring(start, ptr - start);
  end
  else begin
    aFormat := nil;
  end;
  if ((ptr >= max)) or (aString[ptr] ≠ '}') then
    raise new FormatException(RTLErrorMessages.FORMAT_ERROR);
  inc(ptr);
end;

class method StringFormatter.ParseDecimal(aString: String; var ptr: Int32): Int32;
begin
  var p:= ptr;
  var n: Int32 := 0;
  var max := aString.Length;
  while p < max do begin
    var c := aString[p];
    if (c < '0') or ('9' < c) then break;
    n := (n * 10) + ord(c) - ord('0');
    inc(p);
  end;
  if (p = ptr) or (p = max) then  exit -1;
  ptr := p;
  exit n;
end;

class method StringFormatter.ProcessFormat(aFormat: String; aArg: Object; aLocale: Locale): String;
begin
  case aFormat[0] of
    'c','C', 'd', 'D', 'e', 'E', 'f', 'F', 'g', 'G', 'n', 'N', 'p', 'P', 'r', 'R', 'x', 'X': begin
      if (aFormat.Length = 1) or ((aFormat.Length > 1) and (aFormat[1].IsNumber)) then
        exit ProcessStandardNumericFormat(aFormat, aArg, aLocale);
    end;

  end;

  exit {$IF TOFFEE}aArg.description{$ELSE}aArg.ToString{$ENDIF};
end;

class method StringFormatter.ProcessStandardNumericFormat(aFormat: String; aArg: Object; aLocale: Locale): String;
begin
  var lDigits := 0;
  if aFormat.Length > 1 then begin
    var lNumber := Convert.TryToInt32(aFormat.Substring(1));
    if (lNumber = nil) then
      raise new FormatException(RTLErrorMessages.FORMAT_ERROR)
    else
      lDigits := lNumber;
  end;

  case aFormat[0] of
    'd', 'D': begin
      if not (typeOf(aArg) in [Integer, Int64, UInt32, UInt64, Byte, SByte, Int16, UInt16, NativeInt, NativeUInt]) then
        new FormatException(RTLErrorMessages.FORMAT_ERROR);

      var lStr := Convert.ToString(aArg);
      if (lDigits > 0) and (lDigits > lStr.Length) then
        lStr := lStr.PadStart(lDigits - lStr.Length, '0');
      exit lStr;
    end;

    'x', 'X': begin
      if not (typeOf(aArg) in [Integer, Int64, UInt32, UInt64, Byte, SByte, Int16, UInt16, NativeInt, NativeUInt]) then
        new FormatException(RTLErrorMessages.FORMAT_ERROR);
      var lStr := Convert.ToHexString(UInt64(aArg), lDigits);
      exit lStr;
    end;

    'p', 'P': begin
      var lType := typeOf(aArg);
      if not (lType in [Integer, Int64, UInt32, UInt64, Byte, SByte, Int16, UInt16, NativeInt, NativeUInt, Double, Single]) then
        new FormatException(RTLErrorMessages.FORMAT_ERROR);
      var lStr: String;
      var lTotal := if lDigits > 0 then lDigits else 2;
      if lType in [Double, Single] then begin
        var lDouble := Double(aArg) * 100;
        lStr := Convert.ToString(lDouble, lTotal, 0, aLocale);
      end
      else begin
        var lInt := Int64(aArg) * 100;
        lStr := Convert.ToString(lInt);
        lStr := lStr + aLocale.NumberFormat.DecimalSeparator;
        lStr := lStr.PadEnd(lTotal, '0');
      end;
      lStr := lStr + ' %';
      exit lStr;
    end;

    'f', 'F': begin

    end;
  end;
end;

end.