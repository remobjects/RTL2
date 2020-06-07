namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  ConvertTests = public class(Test)
  private
  protected
    // Copy from Convert.... because in Convert it is private and inline
    method internTrimLeadingZeros(aValue: not nullable String): not nullable String;
    begin
      for i: Int32 := 0 to length(aValue)-1 do
        if aValue[i] ≠ '0' then exit aValue.Substring(i);
      exit "";
    end;

  public

    method TestInt32;
    begin
      Check.AreEqual(Convert.TryToInt32("-5"), -5);
      Check.AreEqual(Convert.TryToInt32( "5"),  5);
      Check.AreEqual(Convert.TryToInt32("+5"),  5);
      Check.AreEqual(Convert.TryToInt32("123456789"), 123456789);

      Check.IsNil(Convert.TryToInt32("xxx"));
      Check.IsNil(Convert.TryToInt32("5x"));
      Check.IsNil(Convert.TryToInt32("5.0"));
      Check.IsNil(Convert.TryToInt32("5."));
      Check.IsNil(Convert.TryToInt32(" 5"));
      Check.IsNil(Convert.TryToInt32("5 "));
      Check.IsNil(Convert.TryToInt32("123456789012345"));

      Check.AreEqual(Convert.TryToInt32( "2147483647"), 2147483647);
      Check.AreEqual(Convert.TryToInt32("-2147483648"), -2147483648);
      Check.IsNotNil(Convert.TryToInt32( "2147483647"));
      Check.IsNotNil(Convert.TryToInt32("-2147483648"));
      Check.IsNil   (Convert.TryToInt32( "2147483648")); // out of bounds for Int32
      Check.IsNil   (Convert.TryToInt32("-2147483649")); // out of bounds for Int32
    end;

    method TestInt64;
    begin
      Check.AreEqual(Convert.TryToInt64("-5"), -5);
      Check.AreEqual(Convert.TryToInt64("5"), 5);
      Check.AreEqual(Convert.TryToInt64("123456789"), 123456789);
      Check.IsNil   (Convert.TryToInt64("xxx"));
      Check.AreEqual(Convert.TryToInt64("123456789012345"), 123456789012345);

      Check.AreEqual(Convert.TryToInt64( "9223372036854775807"), 9223372036854775807);
      Check.AreEqual(Convert.TryToInt64("-9223372036854775808"), -9223372036854775808);
      Check.IsNotNil(Convert.TryToInt64( "9223372036854775807"));
      Check.IsNotNil(Convert.TryToInt64("-9223372036854775808"));
      Check.IsNil   (Convert.TryToInt64( "9223372036854775808")); // out of bounds for Int64
      Check.IsNil   (Convert.TryToInt64("-9223372036854775809")); // out of bounds for Int32
    end;

    method TestDouble;
    begin
      Check.AreEqual(Convert.ToDouble('1.0', Locale.Invariant), 1.0);
      Check.AreEqual(Convert.ToDouble('-1.0', Locale.Invariant), -1.0);
      //Check.AreEqual(Double.parseDouble('+1.0'); // ok
      Check.AreEqual(Convert.ToDouble('+1.0', Locale.Invariant), 1.0);
    end;

    //76669: Odd behavior with nil Int32
    method TestCallsWrongAssert;
    begin
      Check.AreNotEqual(nil, -9223372036854775808); // this one calls the correct one on Echoesd and Cooper. It calls *String* Check on Cocoa and fails!
      Check.AreNotEqual(Convert.TryToInt32("-9223372036854775808"), -9223372036854775808);   // calls wroong Check 0/0 and fails.
      // at least it consistently fails on Echoes, Cocoa and Java

      //writeLn(Convert.TryToInt32("9223372036854775807"));
      //Check.AreEqual(Convert.TryToInt32("9223372036854775807"), 9223372036854775807);      // fails to compile: // E546 Value "9223372036854775807" exceeds the bounds of target type "Int32"
    end;


    method TestHex;
    begin
      Assert.AreEqual(Convert.ToHexString(10,0), "A");
    end;

    method TestBinary;
    begin
      Check.AreEqual(Convert.TryBinaryStringToUInt64("1x"), nil);
      Check.AreEqual(Convert.TryBinaryStringToUInt64("1"), 1);
      Check.AreEqual(Convert.TryBinaryStringToUInt64("10"), 2);
      Check.AreEqual(Convert.TryBinaryStringToUInt64("100"), 4);
      Check.AreEqual(Convert.TryBinaryStringToUInt64("1001"), 9);
    end;


    method TrimLeadingZeros;
    begin
      var res : String;
      var aValue :=  "000000000000000A";
      res := internTrimLeadingZeros(aValue);
       Assert.AreEqual(res, "A");
      aValue :=  "00000000000000A0B";
      res := internTrimLeadingZeros(aValue);
      Assert.AreEqual(res, "A0B");

      aValue :=  "0000000000000000";
      res := internTrimLeadingZeros(aValue);
      Assert.AreEqual(res, "");

    end;

  end;

end.