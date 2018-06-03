namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DateTimeTests = public class(Test)
  private
  protected
  public
    method TestOADate;
    begin
      var lToTest: Double := -36518.3785891204; // 5 - 1 - 1800 09:05:10 100ns <-- OADate;
      var lDateTime := DateTime.FromOADate(lToTest); 
      Assert.IsTrue(lDateTime.Year = 1800);
      Assert.IsTrue(lDateTime.Month = 1);
      Assert.IsTrue(lDateTime.Day = 5);
      Assert.IsTrue(lDateTime.Hour = 9);
      Assert.IsTrue(lDateTime.Minute = 5);
      var lOADate: Double := DateTime.ToOADate(lDateTime);
      Assert.AreEqual(lToTest.ToString, lOADate.ToString);

      lToTest := 43105.3785891204; // 5 - 1 - 2018 09:05:10 100ns <-- OADate;
      lDateTime := DateTime.FromOADate(lToTest); 
      Assert.IsTrue(lDateTime.Year = 2018);
      Assert.IsTrue(lDateTime.Month = 1);
      Assert.IsTrue(lDateTime.Day = 5);
      Assert.IsTrue(lDateTime.Hour = 9);
      Assert.IsTrue(lDateTime.Minute = 5);
      lOADate := DateTime.ToOADate(lDateTime);
      Assert.AreEqual(lToTest.ToString, lOADate.ToString);
    end;
  end;
end.