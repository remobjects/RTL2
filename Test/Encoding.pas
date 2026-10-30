namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  EncodingTests = public class(Test)
  public

    method TryGetStringReturnsDecodedString;
    begin
      var lBytes := Encoding.UTF8.GetBytes("hello");

      Check.AreEqual("hello", Encoding.UTF8.TryGetString(lBytes));
      Check.AreEqual("ell", Encoding.UTF8.TryGetString(lBytes, 1, 3));
      Check.AreEqual("llo", Encoding.UTF8.TryGetString(lBytes, 2));
      Check.AreEqual("hello", Encoding.UTF8.TryGetString(new ImmutableBinary(lBytes)));
    end;

    // A stream may split a UTF-8 character at any byte. Failed partial
    // decoding must return nil so the caller can retain bytes without throwing.
    method TryGetStringRetainsSplitUTF8Characters;
    begin
      {$IF TOFFEE}
      for each lText in ["café", "a€b", "a😀b"] do begin
        var lBytes := Encoding.UTF8.GetBytes(lText);
        for lSplit: Integer := 1 to length(lBytes)-1 do begin
          var lPending := new Binary;
          lPending.Write(lBytes, lSplit);
          var lPrefix := Encoding.UTF8.TryGetString(lPending);
          var lDecoded := "";
          if assigned(lPrefix) then begin
            lDecoded := lPrefix;
            lPending.Clear;
          end;
          lPending.Write(lBytes, lSplit, length(lBytes)-lSplit);
          var lTail := Encoding.UTF8.TryGetString(lPending);
          Check.IsNotNil(lTail);
          Check.AreEqual(lText, lDecoded+lTail);
        end;
      end;
      {$ENDIF}
    end;

    method TryGetStringReturnsNilForInvalidCocoaData;
    begin
      {$IF TOFFEE}
      var lInvalidUtf8: array of Byte := [$C3, $28];

      Check.IsNil(Encoding.UTF8.TryGetString(lInvalidUtf8));
      Check.IsNil(Encoding.UTF8.TryGetString(new ImmutableBinary(lInvalidUtf8)));
      {$ENDIF}
    end;

  end;

end.
