namespace RemObjects.Elements.RTL;

type
  UnicodeCodePoint = public /*type*/ UInt32;
  UnicodeCharacter = public type String;

  UnicodeException = public class(RTLException)
  end;

  String = public partial class
  public

    constructor(aCodePoints: List<UnicodeCodePoint>);
    begin
      var lBytes := new Byte[aCodePoints.Count*4];
      for each cp in aCodePoints index i do begin
        lBytes[(i*4)+3] := UInt32(cp) and $000000ff;
        lBytes[(i*4)+2] := UInt32(cp) and $0000ff00 shr 8;
        lBytes[(i*4)+1] := UInt32(cp) and $00ff0000 shr 16;
        lBytes[(i*4)+0] := UInt32(cp) and $ff000000 shr 24;
      end;
      result := Encoding.UTF32BE.GetString(lBytes);
    end;

    constructor(aCodePoints: array of UnicodeCodePoint);
    begin
      var lBytes := new Byte[aCodePoints.Count*4];
      for each cp in aCodePoints index i do begin
        lBytes[(i*4)+3] := cp and $000000ff;
        lBytes[(i*4)+2] := cp and $0000ff00 shr 8;
        lBytes[(i*4)+1] := cp and $00ff0000 shr 16;
        lBytes[(i*4)+0] := cp and $ff000000 shr 24;
      end;
      result := Encoding.UTF32BE.GetString(lBytes);
    end;

    method ToHexString: String;
    begin
      result := Convert.ToHexString(Encoding.UTF16BE.GetBytes(self));
    end;

    method IsIndexInsideOfASurrogatePair(aIndex: Integer): Boolean; inline;
    begin
      if (aIndex ≤ 0) or (aIndex ≥ Length) then
        exit false;
      var ch := UInt32(self[aIndex-1]);
      result := IsFirstSurrogatePairChar(ch);
    end;


    method ToUnicodeCodePointIndices: ImmutableList<Integer>;
    begin
      var lResult := new List<Integer> withCapacity(Length);

      var i := 0;
      var len := Length;
      while i < len do begin
        lResult.Add(i);

        var ch := UInt16(self[i]);

        if IsNonSurrogatePairChar(ch) then begin // normal characacter
          inc(i);
          if i ≥ len then break;
        end
        else if IsFirstSurrogatePairChar(ch) then begin // beginning of surrogate pair
          inc(i);

          ch := UInt32(self[i]);
          if IsSecondSurrogatePairChar(ch) then begin
            inc(i);
            if i ≥ len then break;
          end
          else begin
            raise new UnicodeException($"Invalid surrogate pair at index {i}");
          end;

        end
        else begin
          raise new UnicodeException($"Invalid surrogate pair at index {i}");
        end;
      end;

      result := lResult;
    end;

    method ToUnicodeCodePoints: ImmutableList<UnicodeCodePoint>;
    begin
      var lResult := new List<UnicodeCodePoint> withCapacity(Length);

      var i := 0;
      var len := Length;
      while i < len do begin

        var ch := UInt32(self[i]);

        if IsNonSurrogatePairChar(ch) then begin // normal characacter
          lResult.Add(UnicodeCodePoint(ch));
          inc(i);
        end
        else if IsFirstSurrogatePairChar(ch) then begin // beginning of surrogate pair
          var lCurrentSurrogate := ch;
          inc(i);

          ch := UInt32(self[i]);
          if IsSecondSurrogatePairChar(ch) then begin
            lResult.Add(UnicodeCodePoint(UnicodeCodePointFromSurrogatePair(lCurrentSurrogate, ch)));
            inc(i);
          end
          else begin
            raise new UnicodeException($"Invalid surrogate pair at index {i}");
          end;

        end
        else begin
          raise new UnicodeException($"Invalid surrogate pair at index {i}");
        end;
      end;

      result := lResult;
    end;

    method UnicodeCodePointAtIndex(aIndex: Integer): UnicodeCodePoint;
    begin
      if (aIndex < 0) or (aIndex ≥ Length) then
        raise new IndexOutOfRangeException($"Index {aIndex} is out of the valid range ({0}...{Length-1}");

      var ch := UInt16(self[aIndex]);

      if IsNonSurrogatePairChar(ch) then begin
        result := UnicodeCodePoint(ch);
      end
      else if IsFirstSurrogatePairChar(ch) then begin
        if aIndex < Length-1 then begin
          var ch2 := UInt16(self[aIndex+1]);
          if IsSecondSurrogatePairChar(ch2) then
            result := UnicodeCodePointFromSurrogatePair(ch, ch2)
          else
            raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
        end
        else
          raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
      end
      else /* implied: IsSecondSurrogatePairChar */ begin
        if (aIndex > 0) and IsFirstSurrogatePairChar(UInt16(aIndex-1)) then
          raise new UnicodeException($"Index {aIndex} is inside a surrogate pair")
        else
          raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
      end;
    end;

    method UnicodeCodePointBeforeIndex(aIndex: Integer): UnicodeCodePoint;
    begin
      if (aIndex ≤ 0) or (aIndex > Length) then
        raise new IndexOutOfRangeException($"Index {aIndex} is out of the valid range ({1}...{Length}");

      var ch := UInt16(self[aIndex-1]);

      if IsNonSurrogatePairChar(ch) then begin
        result := UnicodeCodePoint(ch);
      end
      else if IsSecondSurrogatePairChar(ch) then begin
        if aIndex > 1 then begin
          var ch2 := UInt16(self[aIndex-2]);
          if IsFirstSurrogatePairChar(ch2) then
            result := UnicodeCodePointFromSurrogatePair(ch2, ch)
          else
            raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
        end
        else
          raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
      end
      else /* implied: IsFirstSurrogatePairChar */ begin
        if (aIndex < Length-1) and IsSecondSurrogatePairChar(UInt16(aIndex)) then
          raise new UnicodeException($"Index {aIndex} is inside a surrogate pair")
        else
          raise new UnicodeException($"Invalid surrogate pair at index {aIndex}");
      end;
    end;

    method IsIndexInsideOfAJoinedUnicodeCharacter(aIndex: Integer): Boolean;
    begin
      if (aIndex < 0) or (aIndex > Length) then
        raise new IndexOutOfRangeException($"Index {aIndex} is out of the valid range ({0}...{Length-1}");
      if (aIndex = 0) or (aIndex = Length) then
        exit false;
      if IsIndexInsideOfASurrogatePair(aIndex) then
        exit IsIndexInsideOfAJoinedUnicodeCharacter(aIndex-1) or IsIndexInsideOfAJoinedUnicodeCharacter(aIndex+1);

      var cp := UnicodeCodePointAtIndex(aIndex);
      if IsModifierUnicodePoint(cp) or IsVariationSelectorsUnicodePoint(cp) or IsJoinerUnicodePoint(cp) then begin
        // todo: maybe check what comes before?
        exit true;
      end;

      var cp2 := UnicodeCodePointBeforeIndex(aIndex);
      if IsRegionalIndicatorUnicodePoint(cp) then begin
        if IsRegionalIndicatorUnicodePoint(cp2) then begin
          var i := aIndex-2; // Regional indicators are always 2 wide
          while i > 0 do begin // count if we're at an even or odd number of regional indicators, as they always work in pairs
            var cp3 := UnicodeCodePointBeforeIndex(i);
            if not IsRegionalIndicatorUnicodePoint(cp3) then
              if ((aIndex-i)/2) mod 2 = 1 then
                exit true
              else
                break;
            dec(i, 2);
          end;
          if ((aIndex-i)/2) mod 2 = 1 then
            exit true;
        end;
      end;

      if IsJoinerUnicodePoint(cp2) then begin
        exit true;
      end;
    end;

    method StartIndexOfJoinedUnicodeCharacterAtIndex(aIndex: Integer): Integer;
    begin
      while aIndex > 0 do begin
        if IsIndexInsideOfASurrogatePair(aIndex) then
          dec(aIndex);
        if not IsIndexInsideOfAJoinedUnicodeCharacter(aIndex) then
          exit aIndex;
        dec(aIndex);
      end;
    end;

    method IndexAfterJoinedUnicodeCharacterCoveringIndex(aIndex: Integer): Integer;
    begin
      var len := Length;
      while aIndex < len do begin
        if IsIndexInsideOfASurrogatePair(aIndex) then
          inc(aIndex);
        if not IsIndexInsideOfAJoinedUnicodeCharacter(aIndex) then
          exit aIndex;
        inc(aIndex);
      end;
    end;

    method ToUnicodeCharacters: ImmutableList<UnicodeCharacter>;
    begin
      var lResult := new List<UnicodeCharacter>;

      var lCurrentChar: array of Char;
      var lCombineWithNext := false;
      var lIsRegionalIndicatorLetter := false;
      for each ch2 in ToUnicodeCodePoints do begin
        var ch := UInt32(ch2);
        if IsModifierUnicodePoint(ch) or IsVariationSelectorsUnicodePoint(ch) then begin
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          continue;
        end;

        if IsRegionalIndicatorUnicodePoint(ch) then begin // Regional Indicator Symbol Letter
          if lIsRegionalIndicatorLetter then begin
            lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
            lIsRegionalIndicatorLetter := false;
            continue;
          end
          else begin
            lIsRegionalIndicatorLetter := true;
          end;
        end;

        if IsJoinerUnicodePoint(ch) then begin // Joiners
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          lCombineWithNext := true;
          continue;
        end;

        if lCombineWithNext then begin
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          lCombineWithNext := false;
        end
        else begin
          if RemObjects.Elements.System.length(lCurrentChar) > 0 then
            lResult.Add(new String(lCurrentChar) as UnicodeCharacter);
          lCurrentChar := UnicodeCodePoint(ch).ToUTF16;
        end;
      end;
      if RemObjects.Elements.System.length(lCurrentChar) > 0 then
        lResult.Add(new String(lCurrentChar) as UnicodeCharacter);
      result := lResult;//ToUnicodeCodePoints.Select(ch -> chr(ch).ToString as UnicodeCharacter).ToList;
    end;

  private

    //
    // Surrogate Helpers
    //

    method IsNonSurrogatePairChar(aChar: UInt16): Boolean; private; inline;
    begin
      result := (aChar ≤ $0D7FF) or (aChar > $00E000)
    end;

    method IsFirstSurrogatePairChar(aChar: UInt16): Boolean; private; inline;
    begin
      result := (aChar ≥ $00D800) and (aChar ≤ $00DBFF);
    end;

    method IsSecondSurrogatePairChar(aChar: UInt16): Boolean; private; inline;
    begin
      result := (aChar ≥ $00DC00) and (aChar < $00DFFF);
    end;

    method UnicodeCodePointFromSurrogatePair(aChar1, aChar2: UInt16): UnicodeCodePoint; private; inline;
    begin
      var lCode := $10000;
      lCode := lCode + ((aChar1 and $03FF) shl 10);
      lCode := lCode + (aChar2 and $03FF);
      result := UnicodeCodePoint(lCode);
    end;

    //method SurrogatePairFromUnicodeCodePoint(aCodePoint: UnicodeCodePoint): tuople of (Char, Char); private; inline;
    //begin
      //var lCode := $10000;
      //lCode := lCode + ((aChar1 and $03FF) shl 10);
      //lCode := lCode + (aChar2 and $03FF);
      //result := UnicodeCodePoint(lCode);
    //end;

    //
    // CodePoint / Joining Helpers
    //

    method IsModifierUnicodePoint(aCodePoint: UInt32): Boolean; private; inline;
    begin
      result := aCodePoint in [$1F3FB..$1F3FF, // skin tone
                               $1F9B0..$1F9B3  // hair color
                              ];
    end;

    method IsVariationSelectorsUnicodePoint(aCodePoint: UnicodeCodePoint): Boolean; private; inline;
    begin
      result := aCodePoint in [$FE00..$FE0F];
    end;

    method IsJoinerUnicodePoint(aCodePoint: UnicodeCodePoint): Boolean; private; inline;
    begin
      //result := aCodePoint in [$200D];
      result := aCodePoint = $200D;
    end;

    method IsRegionalIndicatorUnicodePoint(aCodePoint: UnicodeCodePoint): Boolean; private; inline;
    begin
      result := aCodePoint in [$1F1E6..$1F1FF]
    end;

  end;

extension method UnicodeCodePoint.ToUTF16: array of Char; public;
begin
  if UInt32(self) > $ffff then begin
    result := [chr($D800 + (((UInt32(self) - $10000) shr 10) and $03ff)),
              chr($DC00 + ((UInt32(self) - $10000) and $03ff))];
  end
  else begin
    result := [Char(UInt16(self))];
  end;
end;

extension method UnicodeCodePoint.ToUTF16String: String; public;
begin
  if UInt32(self) > $ffff then begin
    result := chr($D800 + (((UInt32(self) - $10000) shr 10) and $03ff))+
              chr($DC00 + ((UInt32(self) - $10000) and $03ff));
  end
  else begin
    result := chr(UInt16(self));
  end;
end;

end.