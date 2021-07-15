namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  String_Formatter = public class(Test)
  public
    method NumericValuesTests;
    begin
      Assert.AreEqual(String.Format("{0:d3}", 10), '010');
      Assert.AreEqual(String.Format("{0,10:d3}", 10), '       010');
      Assert.AreEqual(String.Format("{0,-10:d3}", 10), '010       ');

      Assert.AreEqual(String.Format("{0:P}", 0.2468013), '24' + Locale.Current.NumberFormat.DecimalSeparator + '68');

      Assert.AreEqual(String.Format("{0:F}", 17843), '17843' + Locale.Current.NumberFormat.DecimalSeparator + '00');
      Assert.AreEqual(String.Format("{0:F3}", -29541), '-29541' + Locale.Current.NumberFormat.DecimalSeparator + '000');
      Assert.AreEqual(String.Format("{0:F}", 18934.1879), '18934' + Locale.Current.NumberFormat.DecimalSeparator + '19');
      Assert.AreEqual(String.Format("{0:F0}", 18934.1879), '18934');
      Assert.AreEqual(String.Format("{0:F1}", 18934.1879), '18934' + Locale.Current.NumberFormat.DecimalSeparator + '2');

      Assert.AreEqual(String.Format("{0:X}", 123456789), '75BCD15');
      Assert.AreEqual(String.Format("{0:X2}", 123456789), '75BCD15');

      Assert.AreEqual(String.Format("{0:N}", -12445.6789), '-12' + Locale.Current.NumberFormat.ThousandsSeparator + '445' + Locale.Current.NumberFormat.DecimalSeparator + '68');
      Assert.AreEqual(String.Format("{0:N}", -445.6789), '-445' + Locale.Current.NumberFormat.DecimalSeparator + '68');
    end;
  end;

end.