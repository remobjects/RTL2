namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  Xml = public class(Test)
  public

    method FindingElements;
    begin
      var xml := XmlDocument.FromString('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://default" xmlns:a="http://a" xmlns:b="http://bc"><one/><a:two><nested x="a" y="b" /></a:two><b:three/></root>');

      Check.IsTrue(xml.Root.LocalName = "root");

      Check.IsNotNil(xml.Root.FirstElementWithName("one"));
      Check.IsNotNil(xml.Root.FirstElementWithName("two"));
      Check.IsNotNil(xml.Root.FirstElementWithName("three"));
      Check.IsNotNil(xml.Root.FirstElementWithName("a:two"));
      Check.IsNotNil(xml.Root.FirstElementWithName("b:three"));
      Check.IsNotNil(xml.Root.FirstElementWithName("{http://bc}three"));

      Check.IsNotNil(xml.Root.FirstElementWithName("two").FirstElementWithName("nested"));
      Check.AreEqual(xml.Root.FirstElementWithName("two").FirstElementWithName("nested").Attribute["x"].Value, "a");
      Check.IsNil(xml.Root.FirstElementWithName("two").FirstElementWithName("nested").Attribute["z"]);

      var four := xml.Root.AddElement("four", nil, "F4or");
      Check.IsNotNil(xml.Root.FirstElementWithName("four"));
      Check.AreEqual(xml.Root.FirstElementWithName("four").Value, "F4or");
      Check.AreEqual(four.ToString(), "<four>F4or</four>");
    end;

  end;

end.