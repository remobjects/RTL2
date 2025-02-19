﻿namespace RemObjects.Elements.RTL;

interface

type
  Range = public record {$IF TOFFEE}mapped to Foundation.NSRange{$ENDIF}
  public
    constructor(aLocation, aLength: Integer);
    {$IFNDEF TOFFEE}
    property Location: Integer;
    property Length: Integer;
    {$ELSE}
    property Location: Integer read mapped.location write mapped.location;
    property Length: Integer read mapped.length write mapped.length;
    {$ENDIF}
    property &End: Integer read Location+Length;

    method OverlappingSubRange(aRange: Range): nullable Range;
    begin
      if (aRange.Location ≥ &End) then
        exit nil;
      if (aRange.End ≤ Location) then
        exit nil;
      var lNewStart := Math.Max(&Location, aRange.Location);
      var lNewEnd := Math.Min(&End, aRange.End);
      result := new Range(lNewStart, lNewEnd-lNewStart);
    end;

  end;

  RangeHelper = public static class
  public
    method Validate(aRange: Range; BufferSize: Integer);
  end;

implementation

{ Range }

constructor Range(aLocation, aLength: Integer);
begin
  {$IF TOFFEE}
  result := NSMakeRange(aLocation, aLength);
  {$ELSE}
  Location := aLocation;
  Length := aLength;
  {$ENDIF}
end;

{ RangeHelper }

class method RangeHelper.Validate(aRange: Range; BufferSize: Integer);
begin
  if aRange.Location < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Location");

  if aRange.Length < 0 then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.NEGATIVE_VALUE_ERROR, "Length");

  if aRange.Location >= BufferSize then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "Location");

  if aRange.Length > BufferSize then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.ARG_OUT_OF_RANGE_ERROR, "Length");

  if aRange.Location + aRange.Length > BufferSize then
    raise new ArgumentOutOfRangeException(RTLErrorMessages.OUT_OF_RANGE_ERROR, aRange.Location, aRange.Length, BufferSize);
end;

end.