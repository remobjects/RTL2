namespace RemObjects.Elements.RTL;

type
  UnicodeCodePoint = public type UInt32;
  UnicodeCharacter = public type String;

  String = public partial class
  private
  protected
  public

    method ToHexString: String;
    begin
      result := Convert.ToHexString(Encoding.UTF16BE.GetBytes(self));
    end;

    method IsIndexInsideOfASurrogatePair(aIndex: Integer): Boolean; inline;
    begin
      if (aIndex ≤ 0) or (aIndex ≥ Length-1) then
        exit false;
      var ch := UInt32(self[aIndex-1]);
      result := (ch ≥ $00D800) and (ch ≤ $00DBFF);
    end;

    method ToUnicodeCodePointIndices: ImmutableList<Integer>;
    begin
      var lResult := new List<Integer> withCapacity(Length);

      var i := 0;
      var len := Length;
      while i < len do begin
        lResult.Add(i);

        var ch := UInt32(self[i]);

        if (ch ≤ $0D7FF) or (ch > $00E000) then begin // normal characacter
          inc(i);
          if i ≥ len then break;
        end
        else if (ch ≥ $00D800) and (ch ≤ $00DBFF) then begin // beginning of surrogate pair
          var lCurrentSurrogate := ch;
          inc(i);

          ch := UInt32(self[i]);
          if (ch ≥ $00DC00) and (ch < $00DFFF) then begin

            var lCode := $10000;
            lCode := lCode + ((lCurrentSurrogate and $03FF) shl 10);
            lCode := lCode + (ch and $03FF);
            //var lNewChar := UInt32(lCode);

            inc(i);
            if i ≥ len then break;

          end
          else begin
            raise new Exception($"Invalid surrogate pair at index {i}");
          end;

        end
        else begin
          raise new Exception($"Invalid surrogate pair at index {i}");
        end;
      end;

      result := lResult;
    end;

    {$IF NOT COOPER}
    method ToUnicodeCodePoints: ImmutableList<UnicodeCodePoint>;
    begin
      var lResult := new List<UnicodeCodePoint> withCapacity(Length);

      var i := 0;
      var len := Length;
      while i < len do begin

        var ch := UInt32(self[i]);

        if (ch ≤ $0D7FF) or (ch > $00E000) then begin // normal characacter
          lResult.Add(UnicodeCodePoint(ch));
          inc(i);
          //if i ≥ len then break;
        end
        else if (ch ≥ $00D800) and (ch ≤ $00DBFF) then begin // beginning of surrogate pair
          var lCurrentSurrogate := ch;
          inc(i);

          ch := UInt32(self[i]);
          if (ch ≥ $00DC00) and (ch < $00DFFF) then begin

            var lCode := $10000;
            lCode := lCode + ((lCurrentSurrogate and $03FF) shl 10);
            lCode := lCode + (ch and $03FF);
            lResult.Add(UnicodeCodePoint(lCode));

            inc(i);
            //if i ≥ len then break;

          end
          else begin
            raise new Exception($"Invalid surrogate pair at index {i}");
          end;

        end
        else begin
          raise new Exception($"Invalid surrogate pair at index {i}");
        end;
      end;

      result := lResult;
    end;
    {$ENDIF}

    {$IF ECHOES}
    method ToUnicodeCharacters: ImmutableList<UnicodeCharacter>;
    begin
      var lResult := new List<UnicodeCharacter>;

      var lCurrentChar := "";
      var lCombineWithNext := false;
      var lIsRegionalIndicatorLetter := false;
      for each ch: UInt32 in ToUnicodeCodePoints do begin
        if ch in [$1F3FB..$1F3FF, // skin tone
                  $1F9B0..$1F9B3  // hair color
                  ] then begin
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          continue;
        end;
        if ch in [$FE00..$FE0F] then begin // Variation Selectors
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          continue;
        end;

        if ch in [$1F1E6..$1F1FF] then begin // Regional Indicator Symbol Letter
          if lIsRegionalIndicatorLetter then begin
            lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
            lIsRegionalIndicatorLetter := false;
            continue;
          end
          else begin
            lIsRegionalIndicatorLetter := true;
          end;
        end;

        if ch in [$200D] then begin // Joiners
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          lCombineWithNext := true;
          continue;
        end;

        if lCombineWithNext then begin
          lCurrentChar := lCurrentChar+UnicodeCodePoint(ch).ToUTF16;
          lCombineWithNext := false;
        end
        else begin
          if lCurrentChar.Length > 0 then
            lResult.Add(lCurrentChar as UnicodeCharacter);
          lCurrentChar := UnicodeCodePoint(ch).ToUTF16;
        end;
      end;
      if lCurrentChar.Length > 0 then
        lResult.Add(lCurrentChar as UnicodeCharacter);
      result := lResult;//ToUnicodeCodePoints.Select(ch -> chr(ch).ToString as UnicodeCharacter).ToList;
    end;
    {$ENDIF}

  end;

{$IF ECHOES}
extension method UnicodeCodePoint.ToUTF16: String; public;
begin
  if UInt32(self) > $ffff then begin
    result := chr($D800 + (((UInt32(self) - $10000) shr 10) and $03ff))+
              chr($DC00 + ((UInt32(self) - $10000) and $03ff));
  end
  else begin
    result := chr(UInt16(self));
  end;
end;
{$ENDIF}

end.