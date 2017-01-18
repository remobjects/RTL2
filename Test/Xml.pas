namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  Xml = public class(Test)
  public

    method FindingElements;
    begin
      var xml := XmlDocument.FromString('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://default" xmlns:a="http://a" xmlns:b="http://bc"><one/><a:two><nested x="a" y="b" /></a:two><b:three/></root>');

      Assert.IsTrue(xml.Root.LocalName = "root");

      Assert.IsNotNil(xml.Root.FirstElementWithName("one"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("two"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("three"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("a:two"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("b:three"));      Assert.IsNotNil(xml.Root.FirstElementWithName("{http://bc}three"));

      Assert.IsNotNil(xml.Root.FirstElementWithName("two").FirstElementWithName("nested"));
      Assert.AreEqual(xml.Root.FirstElementWithName("two").FirstElementWithName("nested").Attribute["x"].Value, "a");
      Assert.IsNil(xml.Root.FirstElementWithName("two").FirstElementWithName("nested").Attribute["z"]);

      var four := xml.Root.AddElement("four", nil, "F4or");
      Assert.IsNotNil(xml.Root.FirstElementWithName("four"));
      Assert.AreEqual(xml.Root.FirstElementWithName("four").Value, "F4or");
      Assert.AreEqual(four.ToString(), "<four>F4or</four>");
    end;

  end;

end.