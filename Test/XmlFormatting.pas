namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  XmlFormatting = public class(Test)
  private
  protected
  public
    method FirstTest;
    begin
      Assert.IsTrue(true);

      var lXmlStyle := new XmlFormattingOptions;
      lXmlStyle.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
      lXmlStyle.NewLineForElements := true;
      lXmlStyle.NewLineForAttributes := true;
      //lXmlStyle.Indentation := #9;

      var xml := XmlDocument.FromString('<foo bar="a" baz="b" />');
      //writeLn(xml.ToString(lXmlStyle));
    end;

  end;

end.