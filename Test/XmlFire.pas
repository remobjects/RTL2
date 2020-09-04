namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
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
      Check.AreEqual(xml.ToString, '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"/>');
    end;

    method PreserveHeaders;
    begin
      var sXML := '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project/>';
      var xml := XmlDocument.FromString(sXML);
      Check.AreEqual(xml.ToString, sXML);
    end;

    method PreserveSpaces;
    begin
      var sXML := '<?xml version="1.0" encoding="utf-8" standalone="yes"?><Project    '#13'Test= "foo"   '#13#13#10#9'  Bar  ="b  " >'#13'   '#13#9#19#13'  <Tag2   name=  "fo  "   />  '#9#13#10'</Project  >';
      var xml := XmlDocument.FromString(sXML);
      Check.AreEqual(xml.ToString, sXML);
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
      //Check.AreEqual(xml.ToString, sXML);

      var sXML2 := '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'#10'<Project>'#10#9'<ItemGroup>'#10#9#9'<Compile Include="foo" />'#10#9#9'<Compile Include="Bar.pas" />'#10#9'</ItemGroup>'#10'</Project>';
      var lCompile := xml.Root.FirstElementWithName("ItemGroup").AddElement("Compile");
      lCompile.SetAttribute("Include", "Bar.pas");
      Check.AreEqual(xml.ToString, sXML2);
    end;

    method AddDefaultPlatform;
    begin
      var lXml := XmlDocument.WithRootElement("Test");
      lXml.Root.SetAttribute("Condition","'$(Platform)' == ''");
      Check.AreEqual(lXml.Root.Attribute["Condition"].Value, "'$(Platform)' == ''");
      Check.AreEqual(lXml.Root.Attribute["Condition"].ToString, 'Condition="''$(Platform)'' == ''''"');
      Check.AreEqual(lXml.ToString, '<Test Condition="''$(Platform)'' == ''''"/>');
    end;

    method DeleteHintPath;
    begin
      var lXml := XmlDocument.FromString('<ItemGroup>'#13#10#9'<Reference Include="atk">'#13#10#9#9'<HintPath>C:\Program Files (x86)\RemObjects Software\Elements\Island\Reference Libraries\Linux\x86_64\atk.fx</HintPath>'#13#10#9'</Reference>#13#10</ItemGroup>');
      var r := lXml.Root.FirstElementWithName("Reference");
      r.RemoveElement(r.FirstElementWithName("HintPath"));

      var XmlStyleVisualStudio := new XmlFormattingOptions();
      XmlStyleVisualStudio.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
      XmlStyleVisualStudio.EmptyTagSyle := XmlTagStyle.PreferSingleTag;
      XmlStyleVisualStudio.Indentation := '  ';
      XmlStyleVisualStudio.NewLineForElements := true;
      XmlStyleVisualStudio.NewLineForAttributes := false;
      XmlStyleVisualStudio.NewLineSymbol := XmlNewLineSymbol.CRLF;
      XmlStyleVisualStudio.SpaceBeforeSlashInEmptyTags := true;
      XmlStyleVisualStudio.WriteNewLineAtEnd := false;
      XmlStyleVisualStudio.WriteBOM := true;
      Check.AreEqual(lXml.ToString(),'<ItemGroup>'#13#10#9'<Reference Include="atk">'#13#10#9#9#13#10#9'</Reference>#13#10</ItemGroup>');
      Check.AreEqual(lXml.ToString(XmlStyleVisualStudio), '<ItemGroup>'#13#10#9'<Reference Include="atk" />#13#10</ItemGroup>');
    end;
  end;

end.