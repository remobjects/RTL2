namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  XmlNamespaces = public class(Test)
  public

    method Basics;
    begin
      var xml := XmlDocument.FromString('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://default" xmlns:a="http://a" xmlns:b="http://bc"><one/><a:two/><b:three/></root>');

      Assert.IsTrue(xml.Root.LocalName = "root");
      Assert.IsTrue(xml.Root.DefinedNamespaces.Count = 3);
      //Assert.IsTrue(xml.Root.DefaultNamespace.Name = "");
      //Assert.IsTrue(xml.Root.DefaultNamespace.Url.ToAbsoluteString() = "http://default");
      Assert.AreEqual(xml.Root.DefinedNamespaces.ToList()[0].Url.ToAbsoluteString(), Url.UrlWithString("http://default").ToAbsoluteString());
      Assert.AreEqual(xml.Root.DefinedNamespaces.ToList()[1].Url.ToAbsoluteString(), Url.UrlWithString("http://a").ToAbsoluteString());
      Assert.AreEqual(xml.Root.DefinedNamespaces.ToList()[2].Url.ToAbsoluteString(), Url.UrlWithString("http://bc").ToAbsoluteString());

      Assert.IsNotNil(xml.Root.FirstElementWithName("one"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("two"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("three"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("a:two"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("b:three"));
      Assert.IsNotNil(xml.Root.FirstElementWithName("{http://bc}three"));

      //Assert.AreEqual(xml.Root.FirstElementWithName("one").Namespace, xml.Root.DefaultNamespace);
      Assert.AreEqual(xml.Root.FirstElementWithName("one").Namespace, xml.Root.DefinedNamespaces.ToList()[0]);
      Assert.AreEqual(xml.Root.FirstElementWithName("two"):&Namespace, xml.Root.DefinedNamespaces.ToList()[1]);
      Assert.AreEqual(xml.Root.FirstElementWithName("three"):&Namespace, xml.Root.DefinedNamespaces.ToList()[2]);
    end;

    method UserSettingsFile;
    begin
      var _userSettingsXML := XmlDocument.WithRootElement("Project");
      _userSettingsXML.Root.AddNamespace(nil, Url.UrlWithString("http://schemas.microsoft.com/developer/msbuild/2003"));
      Assert.AreEqual(_userSettingsXML.ToString, '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"/>');
    end;

  end;

end.