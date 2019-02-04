namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  XmlNamespaces = public class(Test)
  public

    method Basics;
    begin
      var xml := XmlDocument.FromString('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root xmlns="http://default" xmlns:a="http://a" xmlns:b="http://bc"><one/><a:two/><b:three/></root>');

      Check.IsTrue(xml.Root.LocalName = "root");
      Check.IsTrue(xml.Root.DefinedNamespaces.Count = 3);
      //Check.IsTrue(xml.Root.DefaultNamespace.Name = "");
      //Check.IsTrue(xml.Root.DefaultNamespace.Url.ToAbsoluteString() = "http://default");
      Check.AreEqual(xml.Root.DefinedNamespaces.ToList()[0].Uri.ToString, Uri.UriWithString("http://default").ToString());
      Check.AreEqual(xml.Root.DefinedNamespaces.ToList()[1].Uri.ToString, Uri.UriWithString("http://a").ToString());
      Check.AreEqual(xml.Root.DefinedNamespaces.ToList()[2].Uri.ToString, Uri.UriWithString("http://bc").ToString());

      Check.IsNotNil(xml.Root.FirstElementWithName("one"));
      Check.IsNotNil(xml.Root.FirstElementWithName("two"));
      Check.IsNotNil(xml.Root.FirstElementWithName("three"));
      Check.IsNotNil(xml.Root.FirstElementWithName("a:two"));
      Check.IsNotNil(xml.Root.FirstElementWithName("b:three"));
      Check.IsNotNil(xml.Root.FirstElementWithName("{http://bc}three"));

      //Check.AreEqual(xml.Root.FirstElementWithName("one").Namespace, xml.Root.DefaultNamespace);
      Check.AreEqual(xml.Root.FirstElementWithName("one").Namespace, xml.Root.DefinedNamespaces.ToList()[0]);
      Check.AreEqual(xml.Root.FirstElementWithName("two"):&Namespace, xml.Root.DefinedNamespaces.ToList()[1]);
      Check.AreEqual(xml.Root.FirstElementWithName("three"):&Namespace, xml.Root.DefinedNamespaces.ToList()[2]);
    end;

    method UserSettingsFile;
    begin
      var _userSettingsXML := XmlDocument.WithRootElement("Project");
      _userSettingsXML.Root.AddNamespace(nil, Url.UrlWithString("http://schemas.microsoft.com/developer/msbuild/2003"));
      Check.AreEqual(_userSettingsXML.ToString, '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"/>');
    end;

  end;

end.