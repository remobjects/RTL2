namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  XmlEntities = public class(Test)
  public

    method Parsing;
    begin
      var xml := XmlDocument.FromString('<foo attr="test &amp; test"/>');
      Assert.AreEqual(xml.Root.Attribute["attr"].ToString, 'attr="test &amp; test"');
      Assert.AreEqual(xml.Root.Attribute["attr"].Value, 'test & test');

      var xml2 := XmlDocument.FromString('<foo attr="test &amp; &bad; & bad test" />');
      Assert.AreEqual(xml2.Root.Attribute["attr"].Value, "test & &bad; & bad test");
      Assert.AreEqual(xml2.Root.Attribute["attr"].ToString, 'attr="test &amp; &amp;bad; &amp; bad test"');
      Assert.AreEqual(xml2, '<foo attr="test &amp; &amp;bad; &amp; bad test" />');
    end;

  end;

end.