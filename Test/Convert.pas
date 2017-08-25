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
      Assert.AreEqual(Convert.TryToInt32("-5"), -5);
      Assert.AreEqual(Convert.TryToInt32( "5"),  5);
      Assert.AreEqual(Convert.TryToInt32("+5"),  5);
      Assert.AreEqual(Convert.TryToInt32("123456789"), 123456789);

      Assert.IsNil(Convert.TryToInt32("xxx"));
      Assert.IsNil(Convert.TryToInt32("5x"));
      Assert.IsNil(Convert.TryToInt32("5.0"));
      Assert.IsNil(Convert.TryToInt32("5."));
      Assert.IsNil(Convert.TryToInt32(" 5"));
      Assert.IsNil(Convert.TryToInt32("5 "));
      Assert.IsNil(Convert.TryToInt32("123456789012345"));

      Assert.AreEqual(Convert.TryToInt32( "2147483647"), 2147483647);
      Assert.AreEqual(Convert.TryToInt32("-2147483648"), -2147483648);
      Assert.IsNotNil(Convert.TryToInt32( "2147483647"));
      Assert.IsNotNil(Convert.TryToInt32("-2147483648"));
      Assert.IsNil   (Convert.TryToInt32( "2147483648")); // out of bounds for Int32
      Assert.IsNil   (Convert.TryToInt32("-2147483649")); // out of bounds for Int32
    end;

    method TestInt64;
    begin
      Assert.AreEqual(Convert.TryToInt64("-5"), -5);
      Assert.AreEqual(Convert.TryToInt64("5"), 5);
      Assert.AreEqual(Convert.TryToInt64("123456789"), 123456789);
      Assert.IsNil   (Convert.TryToInt64("xxx"));
      Assert.AreEqual(Convert.TryToInt64("123456789012345"), 123456789012345);

      Assert.AreEqual(Convert.TryToInt64( "9223372036854775807"), 9223372036854775807);
      Assert.AreEqual(Convert.TryToInt64("-9223372036854775808"), -9223372036854775808);
      Assert.IsNotNil(Convert.TryToInt64( "9223372036854775807"));
      Assert.IsNotNil(Convert.TryToInt64("-9223372036854775808"));
      Assert.IsNil   (Convert.TryToInt64( "9223372036854775808")); // out of bounds for Int64
      Assert.IsNil   (Convert.TryToInt64("-9223372036854775809")); // out of bounds for Int32
    end;

    method TestDouble;
    begin
      Assert.AreEqual(Convert.ToDouble('1.0', Locale.Invariant), 1.0);
      Assert.AreEqual(Convert.ToDouble('-1.0', Locale.Invariant), -1.0);
      //Assert.AreEqual(Double.parseDouble('+1.0'); // ok
      Assert.AreEqual(Convert.ToDouble('+1.0', Locale.Invariant), 1.0);
    end;

    //76669: Odd behavior with nil Int32
    method TestCallsWrongAssert;
    begin
      Assert.AreNotEqual(nil, -9223372036854775808); // this one callls the correct one on Echoesd and Cooper. It calls *String* assert on Cocoa and fails!
      Assert.AreNotEqual(Convert.TryToInt32("-9223372036854775808"), -9223372036854775808);   // calls wroong Assert 0/0 and fails.
      // at least it consistently fails on Echoes, Cocoa and Java

      //Assert.AreEqual(Convert.TryToInt32("9223372036854775807"), 9223372036854775807);      // fails to compile: // E546 Value "9223372036854775807" exceeds the bounds of target type "Int32"
    end;

  end;

end.