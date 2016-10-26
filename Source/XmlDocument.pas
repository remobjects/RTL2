namespace Elements.RTL;

interface

type
  XmlDocument = public class
  public
    class method FromFile(aFileName: File): XmlDocument;
    class method FromUrl(aUrl: Url): XmlDocument;
    class method FromString(aString: String): XmlDocument;
    class method WithRootElement(aElement: XmlElement): XmlDocument;

    [ToString]
    method ToString(); override;
    method SaveToFile(aFileName: File); override;
  
    property Root: not nullable XmlElement; readonly;
    property Namespaces: not nullable sequence of XmlNamespace;
    property &Namespace[aUrl: Url]: nullable XmlNamespace;
    property &Namespace[aPrefix: String]: nullable XmlNamespace;

    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: not nullable String; aUrl: not nullable Url): XmlNamespace;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
  end;
  
  XmlNode = public class
  private
    fDocument: nullable XmlDocument;
    fParent: nullable XmlNode;
  public
    property Parent: nullable XmlNode; readonly;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument);
  end;
  
  XmlElement = public class(XmlNode)
  public
    property &Namespace: XmlNamespace;
    property LocalName: String;
    property Value: String;
  
    property Attributes: not nullable sequence of XmlAttribute; readonly;
    property Attribute[aName: not nullable String]: nullable XmlAttribute; readonly;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute; readonly;
    property Elements: not nullable sequence of XmlElement; readonly;
    property Nodes: not nullable sequence of XmlElement; readonly;

    method ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
    
    method AddAttribute(aAttribute: not nullable XmlAttribute);
    method AddAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String): not nullable XmlAttribute;
    method RemoveAttribute(aAttribute: not nullable XmlAttribute);
    method RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
    
    method AddElement(aElement: not nullable XmlElement);
    method AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
    method RemoveElement(aElement: not nullable XmlElement);
    method RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);

    method ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
    method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
  end;
  
  XmlAttribute = public class(XmlNode)
  public
    property &Namespace: XmlNamespace;
    property LocalName: String;
    property Value: String;
  end;
  
  XmlComment = public class(XmlNode)
  public
    property Value: String;
  end;
  
  XmlCData = public class(XmlNode)
  public
    property Value: String;
  end;
  
  XmlNamespace = public class
  public
    property Prefix: String;
    property Url: Url;
  end;

implementation

end.
