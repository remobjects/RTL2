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
