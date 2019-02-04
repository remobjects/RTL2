namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  ConvertTests = public class(Test)
  private
  protected
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

  end;

end.