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
      Check.IsTrue(lDateTime.Year = 1800);
      Check.IsTrue(lDateTime.Month = 1);
      Check.IsTrue(lDateTime.Day = 5);
      Check.IsTrue(lDateTime.Hour = 9);
      Check.IsTrue(lDateTime.Minute = 5);
      var lOADate: Double := DateTime.ToOADate(lDateTime);
      Check.AreEqual(lToTest.ToString, lOADate.ToString);

      lToTest := 43105.3785891204; // 5 - 1 - 2018 09:05:10 100ns <-- OADate;
      lDateTime := DateTime.FromOADate(lToTest);
      Check.IsTrue(lDateTime.Year = 2018);
      Check.IsTrue(lDateTime.Month = 1);
      Check.IsTrue(lDateTime.Day = 5);
      Check.IsTrue(lDateTime.Hour = 9);
      Check.IsTrue(lDateTime.Minute = 5);
      lOADate := DateTime.ToOADate(lDateTime);
      Check.AreEqual(lToTest.ToString, lOADate.ToString);
    end;
  end;
end.