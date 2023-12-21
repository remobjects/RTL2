namespace RemObjects.Elements.RTL;

type
  ByteArrayExtensions = public extension record(array of Byte)
  public

    method IndexOf(aBytes: array of Byte): Integer;
    begin
      result := -1;
      var len := RemObjects.Elements.System.length(aBytes);
      if len = 0 then
        exit;
      if len ≤ RemObjects.Elements.System.length(self) then begin
        lOuterLoop:
          for i: Integer := 0 to Length-len do begin
            if aBytes[0] = self[i] then begin
              for j: Integer := 1 to len-1 do
                if aBytes[j] ≠ self[i+j] then
                  continue lOuterLoop;
              exit i;
            end;
          end;
      end;
    end;

    method IndexOf(aByte: Byte): Integer;
    begin
      result := -1;
      for i: Integer := 0 to RemObjects.Elements.System.length(self)-1 do
        if aByte = self[i] then
          exit i;
    end;

    method &Reverse(aArray: array of Byte);
    begin
      var len := Length;
      for i: Integer := 0 to (len-1) div 2 do begin
        var lSave := self[i];
        self[i] := self[len-1-i];
        self[len-1-i] := lSave;
      end;
    end;

    {$IF TOFFEE}
    constructor withNSData(aData: NSData);
    begin
      result := new Byte[aData.length];
      aData.getBytes(@result[0]) length(aData.length);
    end;

    method AsNSData: NSData;
    begin
      result := NSData.dataWithBytes(@self[0]) length(self.Length);
    end;
    {$ENDIF}

    method ToHexString(aOffset: Integer; aCount: Integer; aSpacer: String := nil; aBytesPerLine: Integer := -1): not nullable String;
    begin
      result := Convert.ToHexString(self, aOffset, aCount, aSpacer, aBytesPerLine);
    end;

    method ToHexString(aSpacer: String := nil; aBytesPerLine: Integer := -1): not nullable String;
    begin
      result := Convert.ToHexString(self, 0, self.Length, aSpacer, aBytesPerLine);
    end;

  end;

  {$IF TOFFEE}
  &Array = public class
  public

    class method &Copy(sourceArray: array of Byte; sourceIndex: Integer; destinationArray: array of Byte; destinationIndex: Integer; length: Integer);
    begin
      memcpy((@destinationArray[0])+destinationIndex, (@sourceArray[0])+sourceIndex, length);
    end;

  end;
  {$ENDIF}

end.