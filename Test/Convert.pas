namespace Elements.RTL2.Tests.Shared;

uses
  Elements.RTL,
  RemObjects.Elements.EUnit;

type
  ConvertTests = public class(Test)
  private
  protected
  public

    method Integers;
    begin
      Assert.AreEqual(Convert.TryToInt32("-5"), -5);
      Assert.AreEqual(Convert.TryToInt32("5"), 5);
      Assert.AreEqual(Convert.TryToInt32("123456789"), 123456789);
      Assert.IsNil(Convert.TryToInt32("xxx"));
      Assert.IsNil(Convert.TryToInt32("123456789012345"));

      Assert.AreEqual(Convert.TryToInt32("2147483647"), 2147483647);
      Assert.AreEqual(Convert.TryToInt32("-2147483648"), -2147483648);
      Assert.IsNil(Convert.TryToInt32("2147483648"));
      Assert.IsNil(Convert.TryToInt32("-2147483649"));


      Assert.AreEqual(Convert.TryToInt64("-5"), -5);
      Assert.AreEqual(Convert.TryToInt64("5"), 5);
      Assert.AreEqual(Convert.TryToInt64("123456789"), 123456789);
      Assert.IsNil(Convert.TryToInt64("xxx"));
      Assert.AreEqual(Convert.TryToInt64("123456789012345"), 123456789012345);

      // min and max values

      Assert.AreEqual(Convert.TryToInt64("9223372036854775807"), 9223372036854775807);
      Assert.AreEqual(Convert.TryToInt64("-9223372036854775808"), -9223372036854775808);
      Assert.IsNil(Convert.TryToInt64("9223372036854775808"));
      Assert.IsNil(Convert.TryToInt64("-9223372036854775809"));

      //76669: Odd behavior with nil Int32
      //Assert.AreEqual(Convert.TryToInt32("9223372036854775807"), 9223372036854775807); // fails to compile: // E546 Value "9223372036854775807" exceeds the bounds of target type "Int32"
      writeLn(assigned(Convert.TryToInt32("-9223372036854775808")));                     // prints false
      Assert.AreEqual(Convert.TryToInt32("-9223372036854775808"), -9223372036854775808); // why does this succeed
      Assert.AreEqual(nil, -9223372036854775808);                                        // why does this succeed
      Assert.IsNil(Convert.TryToInt32("9223372036854775808"));
      Assert.IsNil(Convert.TryToInt32("-9223372036854775809"));
    end;

  end;

end.
