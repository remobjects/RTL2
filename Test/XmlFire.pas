namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  XmlFire = public class(Test)
  public

    method AddNamespaces;
    begin
      var xml := XmlDocument.WithRootElement("Project");
      xml.Root.AddNamespace(nil, Url.UrlWithString("http://schemas.microsoft.com/developer/msbuild/2003"));
      xml.Version := "1.0";
      //xml.Encoding := Encoding.UTF8;
      //xml.Standalone := true;
      xml.Encoding := "utf-8";
      xml.Standalone := "yes";
      Assert.AreEqual(xml.ToString, '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"/>');
    end;

    method PreserveHeaders;
    begin
      var sXML := '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project/>';
      var xml := XmlDocument.FromString(sXML);
      Assert.AreEqual(xml.ToString, sXML);
    end;

    method PreserveSpaces;
    begin
      var sXML := '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project    '#13'Test= "foo"   '#13#13#10#9'  Bar  ="b  " >'#13'   '#13#9#19#13'  <Tag2   name=  "fo  "   />  '#9#13#10'</Project  >';
      var xml := XmlDocument.FromString(sXML);
      Assert.AreEqual(xml.ToString, sXML);
    end;

    method AddFile;
    begin
      var sXML := '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'#10'<Project>'#10#9'<ItemGroup>'#10#9#9'<Compile Include="foo" />'#10#9'</ItemGroup>'#10'</Project>';
      var lXmlFormatOptions := new XmlFormattingOptions;
      lXmlFormatOptions.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
      lXmlFormatOptions.NewLineForElements := true;
      lXmlFormatOptions.NewLineForAttributes := false;
      lXmlFormatOptions.NewLineSymbol := XmlNewLineSymbol.LF;
      lXmlFormatOptions.SpaceBeforeSlashInEmptyTags := true;
      var lxmlParser := new XmlParser(sXML, lXmlFormatOptions);
      var xml := lxmlParser.Parse();
      //var xml := XmlDocument.FromString(sXML);
      //Assert.AreEqual(xml.ToString, sXML);

      var sXML2 := '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'#10'<Project>'#10#9'<ItemGroup>'#10#9#9'<Compile Include="foo" />'#10#9#9'<Compile Include="Bar.pas" />'#10#9'</ItemGroup>'#10'</Project>';
      var lCompile := xml.Root.FirstElementWithName("ItemGroup").AddElement("Compile");
      lCompile.SetAttribute("Include", "Bar.pas");
      Assert.AreEqual(xml.ToString, sXML2);
    end;

    method AddDefaultPlatform;
    begin
      var lXml := XmlDocument.WithRootElement("Test");
      lXml.Root.SetAttribute("Condition","'$(Platform)' == ''");
      Assert.AreEqual(lXml.Root.Attribute["Condition"].Value, "'$(Platform)' == ''");
      Assert.AreEqual(lXml.Root.Attribute["Condition"].ToString, 'Condition="''$(Platform)'' == ''''"');
      Assert.AreEqual(lXml.ToString, '<Test Condition="''$(Platform)'' == ''''"/>');
    end;

  end;

end.