namespace Elements.RTL;

{$IF TOFFEE and MACOS}

//
// For now, XmlDocument is implemented as a simple wraopper around NSXMLElement (Toffee) and System.Xml (Echoes),
// so we can start using it in Fire/Water. The long term plan is to replace this with clean, self-written
// pure-Elements cross-platform imoplementation.
//

interface

type
  XmlDocument = public class
  private
    {$IF TOFFEE}
    fNativeXmlDocument: NSXMLDocument;
    constructor (aNativeXmlDocument: NSXMLDocument);
    {$ENDIF}
    
    fRoot: XmlElement;
    method GetRoot: not nullable XmlElement;
    method GetNamespaces: not nullable sequence of XmlNamespace;
    method GetNamespace(aUrl: Url): nullable XmlNamespace;
    method GetNamespace(aPrefix: String): nullable XmlNamespace;
  
  public
    class method FromFile(aFileName: not nullable File): nullable XmlDocument;
    class method FromUrl(aUrl: not nullable Url): nullable XmlDocument;
    class method FromString(aString: not nullable String): nullable XmlDocument;
    class method WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;

    [ToString]
    method ToString(): String; override;
    method SaveToFile(aFileName: not nullable File);
  
    property Root: not nullable XmlElement read GetRoot;
    property Namespaces: not nullable sequence of XmlNamespace read GetNamespaces;
    property &Namespace[aUrl: Url]: nullable XmlNamespace read GetNamespace;
    property &Namespace[aPrefix: String]: nullable XmlNamespace read GetNamespace(aPrefix);

    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: not nullable String; aUrl: not nullable Url): XmlNamespace;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
  end;
  
  XmlNode = public class
  unit
    {$IF TOFFEE}
    fNativeXmlNode: NSXMLNode;
    constructor (aNativeXmlNode: NSXMLNode; aParent: XmlNode := nil);
    {$ENDIF}
    
    fDocument: weak nullable XmlDocument;
    fParent: weak nullable XmlNode;
  public
    property Parent: nullable XmlNode read fParent;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument);
  end;
  
  XmlElement = public class(XmlNode)
  private
    method GetNamespace: XmlNamespace;
    method GetLocalName: not nullable String;
    method GetValue: not nullable String;
    method SetValue(aValue: not nullable String);    
    method GetAttributes: not nullable sequence of XmlAttribute;
    method GetAttribute(aName: not nullable String): nullable XmlAttribute;
    method GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
    method GetElements: not nullable sequence of XmlElement;
    method GetNodes: not nullable sequence of XmlNode;
    
  public
    property &Namespace: XmlNamespace read GetNamespace;
    property LocalName: not nullable String read GetLocalName;
    property Value: not nullable String read GetValue write SetValue;
  
    property Attributes: not nullable sequence of XmlAttribute read GetAttributes;
    property Attribute[aName: not nullable String]: nullable XmlAttribute read GetAttribute;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute read GetAttribute;
    property Elements: not nullable sequence of XmlElement read GetElements;
    property Nodes: not nullable sequence of XmlNode read GetNodes;

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
    //method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
  end;
  
  XmlAttribute = public class(XmlNode)
  unit
    constructor(aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
  private
    method GetNamespace: XmlNamespace;
    method GetLocalName: not nullable String;
    method GetValue: not nullable String;
    method SetValue(aValue: not nullable String);
  public
    property &Namespace: XmlNamespace read GetNamespace;
    property LocalName: not nullable String read GetLocalName;
    property Value: not nullable String read GetValue write SetValue;
  end;
  
  XmlComment = public class(XmlNode)
  public
    property Value: String;
  end;
  
  XmlCData = public class(XmlNode)
  public
    property Value: String;
  end;
  
  XmlNamespace = public class(XmlNode)
  public
    property Prefix: String;
    property Url: Url;
  end;

implementation

{ XmlDocument }

{$IF TOFFEE}
constructor XmlDocument(aNativeXmlDocument: NSXMLDocument);
begin
  fNativeXmlDocument := aNativeXmlDocument;
end;
{$ENDIF}

class method XmlDocument.FromFile(aFileName: not nullable File): nullable XmlDocument;
begin
  if aFileName.Exists then begin
    {$IF TOFFEE}
    var lError: NSError;
    var lXml := new NSXMLDocument withContentsOfURL(NSURL.fileURLWithPath(aFileName)) options(0) error(var lError);
    if assigned(lXml) then
      result := new XmlDocument(lXml);
    {$ENDIF}
  end;
end;

class method XmlDocument.FromUrl(aUrl: not nullable Url): nullable XmlDocument;
begin
  {$IF TOFFEE}
  var lError: NSError;
  var lXml := new NSXMLDocument withContentsOfURL(aUrl) options(0) error(var lError);
  if assigned(lXml) then
    result := new XmlDocument(lXml);
  {$ENDIF}
end;

class method XmlDocument.FromString(aString: not nullable String): nullable XmlDocument;
begin
  {$IF TOFFEE}
  var lError: NSError;
  var lXml := new NSXMLDocument withXMLString(aString) options(0) error(var lError);
  if assigned(lXml) then
    result := new XmlDocument(lXml);
  {$ENDIF}
end;

class method XmlDocument.WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;
begin
  {$IF TOFFEE}
  var lXml := new NSXMLDocument withRootElement(aElement.fNativeXmlNode as NSXMLElement);
  if assigned(lXml) then begin
    result := new XmlDocument(lXml);
    result.fRoot := aElement;
  end;
  {$ENDIF}
end;

method XmlDocument.ToString(): String;
begin
  {$IF TOFFEE}
  result := fNativeXmlDocument.ToString();
  {$ENDIF}
end;

method XmlDocument.SaveToFile(aFileName: not nullable File);
begin
  {$IF TOFFEE}
  var lError: NSError;
  var lOptions := NSXMLNodeOptions.NSXMLNodePreserveAttributeOrder or
                  NSXMLNodeOptions.NSXMLNodePreserveNamespaceOrder or
                  NSXMLNodeOptions.NSXMLNodePreserveWhitespace or
                /*NSXMLNodeOptions.NSXMLNodePreserveEmptyElements or*/
                  NSXMLNodeOptions.NSXMLNodeCompactEmptyElement or
                  NSXMLNodeOptions.NSXMLNodePrettyPrint;
  var lResult := fNativeXmlDocument.XMLDataWithOptions(lOptions):writeToURL(NSURL.fileURLWithPath(aFileName))
                                                                 options(NSDataWritingOptions.NSDataWritingAtomic)
                                                                 error(var lError);
  if not lResult then
    raise new RTLException withError(lError)
  {$ENDIF}
end;


method XmlDocument.AddNamespace(aNamespace: not nullable XmlNamespace);
begin
  {$HINT Not Implemented yet}
end;

method XmlDocument.AddNamespace(aPrefix: not nullable String; aUrl: not nullable Url): XmlNamespace;
begin
  {$HINT Not Implemented yet}
end;

method XmlDocument.RemoveNamespace(aNamespace: not nullable XmlNamespace);
begin
  {$HINT Not Implemented yet}
end;

method XmlDocument.RemoveNamespace(aPrefix: not nullable String);
begin
  {$HINT Not Implemented yet}
end;

method XmlDocument.GetRoot: not nullable XmlElement;
begin
  if not assigned(fRoot) then begin
    fRoot := new XmlElement(fNativeXmlDocument.rootElement);
    fRoot.fDocument := self;
  end;
  result := fRoot as not nullable;
end;

method XmlDocument.GetNamespaces: not nullable sequence of XmlNamespace;
begin
  {$HINT Not Implemented yet}
  result := [];
end;

method XmlDocument.GetNamespace(aUrl: Url): nullable XmlNamespace;
begin
  {$HINT Not Implemented yet}
end;

method XmlDocument.GetNamespace(aPrefix: String): nullable XmlNamespace;
begin
  {$HINT Not Implemented yet}
end;

{ XmlNode }

{$IF TOFFEE}
constructor XmlNode(aNativeXmlNode: NSXMLNode; aParent: XmlNode := nil);
begin
  fNativeXmlNode := aNativeXmlNode;
  fParent := aParent;
end;
{$ENDIF}

{ XmlElement }

method XmlElement.ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  {$IF TOFFEE}
  if assigned(aNamespace) then
    result := (fNativeXmlNode as NSXMLElement).elementsForLocalName(aLocalName) URI(aNamespace.Url.ToAbsoluteString()).Select(c -> new XmlElement(c, self))
  else
    result := (fNativeXmlNode as NSXMLElement).elementsForName(aLocalName).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  {$IF TOFFEE}
  var lURI := aNameSpace:Url:ToAbsoluteString;
  result := (fNativeXmlNode as NSXMLElement).children.Where(c -> c.URI = lURI).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
begin
  result := ElementsWithName(aLocalName, aNamespace).FirstOrDefault();
end;

method XmlElement.AddAttribute(aAttribute: not nullable XmlAttribute);
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).addAttribute(aAttribute.fNativeXmlNode);
  aAttribute.fParent := self;
  {$ENDIF}
end;

method XmlElement.AddAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String): not nullable XmlAttribute;
begin
  result := new XmlAttribute(aName, aNamespace, aValue);
  AddAttribute(result);
end;

method XmlElement.RemoveAttribute(aAttribute: not nullable XmlAttribute);
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).removeAttributeForName(aAttribute.LocalName);
  aAttribute.fParent := nil;
  {$ENDIF}
end;

method XmlElement.RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).removeAttributeForName(aName); {$HINT doesn't honor namespace?}
  {$ENDIF}
end;

method XmlElement.AddElement(aElement: not nullable XmlElement);
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).addChild(aElement.fNativeXmlNode);
  aElement.fParent := self;
  {$ENDIF}
end;

method XmlElement.AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).insertChild(aElement.fNativeXmlNode) atIndex(aIndex);
  aElement.fParent := self;
  {$ENDIF}
end;

method XmlElement.RemoveElement(aElement: not nullable XmlElement);
begin
  {$IF TOFFEE}
  (fNativeXmlNode as NSXMLElement).removeChildAtIndex(aElement.fNativeXmlNode.index);
  aElement.fParent := nil;
  {$ENDIF}
end;

method XmlElement.RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
begin
  {$IF TOFFEE}
  for each e in ElementsWithName(aName, aNamespace) do
    (fNativeXmlNode as NSXMLElement).removeChildAtIndex(e.fNativeXmlNode.index);
  {$ENDIF}
end;

method XmlElement.ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
begin
  {$IF TOFFEE}
  var lIndex := aExistingElement.fNativeXmlNode.index;
  (fNativeXmlNode as NSXMLElement).removeChildAtIndex(lIndex);
  (fNativeXmlNode as NSXMLElement).insertChild(aNewElement.fNativeXmlNode) atIndex(lIndex);
  aExistingElement.fParent := nil;
  aNewElement.fParent := self;
  {$ENDIF}
end;

{method XmlElement.MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
begin
end;}

method XmlElement.GetLocalName: not nullable String;
begin
  {$IF TOFFEE}
  result := fNativeXmlNode.name as not nullable;
  {$ENDIF}
end;

method XmlElement.GetNamespace: nullable XmlNamespace;
begin
  {$IF TOFFEE}
  if length(fNativeXmlNode.URI) > 0 then
    result := Document.Namespace[Url.UrlWithString(fNativeXmlNode.URI)];
  {$ENDIF}
end;

method XmlElement.GetValue: not nullable String;
begin
  {$IF TOFFEE}
  result := fNativeXmlNode.stringValue as not nullable;
  {$ENDIF}
end;

method XmlElement.SetValue(aValue: not nullable String);
begin
  {$IF TOFFEE}
  fNativeXmlNode.stringValue := aValue;
  {$ENDIF}
end;

method XmlElement.GetAttributes: not nullable sequence of XmlAttribute;
begin
  {$IF TOFFEE}
  result := (fNativeXmlNode as NSXMLElement).attributes.Select(a -> new XmlAttribute(a, self));
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: not nullable String): nullable XmlAttribute;
begin
  {$IF TOFFEE}
  var lAttribute := (fNativeXmlNode as NSXMLElement).attributeForName(aName);
  if assigned(lAttribute) then
    result := new XmlAttribute(lAttribute, self);
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
begin
  {$IF TOFFEE}
  var lAttribute := if assigned(aNamespace) then
                      (fNativeXmlNode as NSXMLElement).attributeForLocalName(aName) URI(aNamespace.Url.ToAbsoluteString)
                    else
                      (fNativeXmlNode as NSXMLElement).attributeForName(aName);
  if assigned(lAttribute) then
    result := new XmlAttribute(lAttribute, self);
  {$ENDIF}
end;

method XmlElement.GetElements: not nullable sequence of XmlElement;
begin
  {$IF TOFFEE}
  result := (fNativeXmlNode as NSXMLElement).children.Where(c -> c is NSXMLElement).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.GetNodes: not nullable sequence of XmlNode;
begin
  {$IF TOFFEE}
  result := (fNativeXmlNode as NSXMLElement).children.Select(c -> begin
    if c is NSXMLElement then
      result := new XmlElement(c, self)
    else case (c as NSXMLNode).kind of
      NSXMLNodeKind.XMLAttributeKind: result := new XmlAttribute(c, self);
      NSXMLNodeKind.XMLCommentKind: result := new XmlComment(c, self);
      NSXMLNodeKind.XMLNamespaceKind: result := new XmlNamespace(c, self);
      else result := new XmlNode(c, self);
    end;
  end);
  {$ENDIF}
end;

{ XmlAttribute }

constructor XmlAttribute(aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
begin
  {$IF TOFFEE}
  if assigned(aNamespace) then
    fNativeXmlNode := NSXMLNode.attributeWithName(aLocalName) URI(aNamespace.Url.ToAbsoluteString()) stringValue(aValue)
  else
    fNativeXmlNode := NSXMLNode.attributeWithName(aLocalName) stringValue(aValue);
  {$ENDIF}
end;

method XmlAttribute.GetLocalName: not nullable String;
begin
  {$IF TOFFEE}
  result := fNativeXmlNode.name as not nullable;
  {$ENDIF}
end;

method XmlAttribute.GetNamespace: XmlNamespace;
begin
  {$IF TOFFEE}
  if length(fNativeXmlNode.URI) > 0 then
    result := Document.Namespace[Url.UrlWithString(fNativeXmlNode.URI)];
  {$ENDIF}
end;

method XmlAttribute.GetValue: not nullable String;
begin
  {$IF TOFFEE}
  result := fNativeXmlNode.stringValue as not nullable;
  {$ENDIF}
end;

method XmlAttribute.SetValue(aValue: not nullable String);
begin
  {$IF TOFFEE}
  fNativeXmlNode.stringValue := aValue;
  {$ENDIF}
end;

{$ENDIF}

end.
