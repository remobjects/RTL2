namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  XmlEntities = public class(Test)
  public

    method Parsing;
    begin
      var xml := XmlDocument.FromString('<foo attr="test &amp; test"/>');
      Check.AreEqual(xml.Root.Attribute["attr"].ToString, 'attr="test &amp; test"');
      Check.AreEqual(xml.Root.Attribute["attr"].Value, 'test & test');

      var xml2 := XmlDocument.FromString('<foo attr="test &amp; &bad; & bad test" />');
      Check.AreEqual(xml2.Root.Attribute["attr"].Value, "test & &bad; & bad test");
      Check.AreEqual(xml2.Root.Attribute["attr"].ToString, 'attr="test &amp; &amp;bad; &amp; bad test"');
      Check.AreEqual(xml2.ToString, '<foo attr="test &amp; &amp;bad; &amp; bad test" />');

      var xml3 := XmlDocument.FromString('<Compile Include="$(MSBuildThisFileDirectory)TimeZone.pas"><VirtualFolder>Dates &amp; Co</VirtualFolder></Compile>');
      Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").Value, "Dates & Co");
    end;

    method Numbers;
    begin
      var xml := XmlDocument.FromString('<foo attr="test&#x20;&#32;test"/>');
      Check.AreEqual(xml.Root.Attribute["attr"].Value, 'test  test');
      Check.AreEqual(xml.Root.Attribute["attr"].ToString, 'attr="test  test"');
    end;

    method Encoding;
    begin
      var xml := XmlDocument.FromString('<Test/>');
      xml.Root.SetAttribute("Name", "Dates & Co");
      Check.AreEqual(xml.Root.Attribute["Name"].ToString, 'Name="Dates &amp; Co"');
      xml.Root.SetAttribute("Name", "Dates &amp; Co");
      Check.AreEqual(xml.Root.Attribute["Name"].ToString, 'Name="Dates &amp;amp; Co"'); // do encode the &!

      xml.Root.SetAttribute("Name", "don't you forget about me");
      Check.AreEqual(xml.Root.Attribute["Name"].ToString, 'Name="don''t you forget about me"'); // dont encode the '

      xml.Root.SetAttribute("Name", 'and i said "what about ''breakfast at tiffany''s''?"');
      Check.AreEqual(xml.Root.Attribute["Name"].ToString, 'Name="and i said &quot;what about ''breakfast at tiffany''s''?&quot;"'); // do encode the " but not the '

      var xml3 := XmlDocument.FromString('<Compile ><VirtualFolder>x</VirtualFolder></Compile>');
      xml3.Root.FirstElementWithName("VirtualFolder").Value := "Dates & Co";
      Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").ToString, "<VirtualFolder>Dates &amp; Co</VirtualFolder>");

     xml3.Root.FirstElementWithName("VirtualFolder").Value := "Dates &amp; Co";
     Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").Value, "Dates &amp; Co");
     Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").ToString, "<VirtualFolder>Dates &amp;amp; Co</VirtualFolder>");


      xml3.Root.FirstElementWithName("VirtualFolder").Value := 'and i said "what about ''breakfast at tiffany''s''?"';
      Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").Value, 'and i said "what about ''breakfast at tiffany''s''?"'); // domt encode either quote
      Check.AreEqual(xml3.Root.FirstElementWithName("VirtualFolder").ToString, '<VirtualFolder>and i said "what about ''breakfast at tiffany''s''?"</VirtualFolder>')
    end;

  end;

end.