namespace RemObjects.Elements.RTL.Native;


//
// For now, XmlDocument is implemented as a simple wraopper around NativeXmlElement (Toffee) and System.Xml (Echoes),
// so we can start using it in Fire/Water. The long term plan is to replace this with clean, self-written
// pure-Elements cross-platform imoplementation.
//

interface

uses
  RemObjects.Elements.RTL;
{$IF ECHOES OR (TOFFEE AND MACOS)}

type
  {$IF TOFFEE}
  NativeXmlDocument = NSXMLDocument;
  NativeXmlNode = NSXMLNode;
  NativeXmlElement = NSXMLElement;
  {$ENDIF}
  {$IF ECHOES}
  NativeXmlDocument = XDocument;
  NativeXmlNode = XObject;
  NativeXmlElement = XElement;
  {$ENDIF}

  XmlDocument = public class
  private
    fNativeXmlDocument: NativeXmlDocument;
    constructor (aNativeXmlDocument: NativeXmlDocument);

    fRoot: XmlElement;
    method GetRoot: not nullable XmlElement;
    method GetNamespaces: not nullable sequence of XmlNamespace;
    method GetNamespace(aUrl: Url): nullable XmlNamespace;
    method GetNamespace(aPrefix: String): nullable XmlNamespace;

  public
    class method FromFile(aFileName: not nullable File): nullable XmlDocument;
    class method FromUrl(aUrl: not nullable Url): nullable XmlDocument;
    class method FromString(aString: not nullable String): nullable XmlDocument;
    class method FromBinary(aBinary: not nullable ImmutableBinary): nullable XmlDocument;
    class method WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;
    class method WithRootElement(aName: not nullable String): nullable XmlDocument;

    [ToString]
    method ToString(): String; override;
    method SaveToFile(aFileName: not nullable File);

    property Root: not nullable XmlElement read GetRoot;
    property Namespaces: not nullable sequence of XmlNamespace read GetNamespaces;
    property &Namespace[aUrl: Url]: nullable XmlNamespace read GetNamespace;
    property &Namespace[aPrefix: String]: nullable XmlNamespace read GetNamespace(aPrefix);

    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
  end;

  XmlNode = public class
  unit
    fNativeXmlNode: NativeXmlNode;
    constructor (aNativeXmlNode: NativeXmlNode; aParent: XmlNode := nil);

    fDocument: weak nullable XmlDocument;
    fParent: weak nullable XmlNode;
  public
    property Parent: nullable XmlNode read fParent;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument);
  end;

  XmlElement = public class(XmlNode)
  private
    method GetNamespace: nullable XmlNamespace;
    method GetLocalName: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method GetValue: nullable String;
    method SetValue(aValue: nullable String);
    method GetAttributes: not nullable sequence of XmlAttribute;
    method GetAttribute(aName: not nullable String): nullable XmlAttribute;
    method GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
    method GetElements: not nullable sequence of XmlElement;
    method GetNodes: not nullable sequence of XmlNode;

  public
    property &Namespace: XmlNamespace read GetNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: nullable String read GetValue write SetValue;

    property Attributes: not nullable sequence of XmlAttribute read GetAttributes;
    property Attribute[aName: not nullable String]: nullable XmlAttribute read GetAttribute;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute read GetAttribute;
    property Elements: not nullable sequence of XmlElement read GetElements;
    property Nodes: not nullable sequence of XmlNode read GetNodes;

    method ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;

    method SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
    method RemoveAttribute(aAttribute: not nullable XmlAttribute);
    method RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;

    method AddElement(aElement: not nullable XmlElement);
    method AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
    method RemoveElement(aElement: not nullable XmlElement);
    method RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);

    method ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
    //method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
  end;

  XmlAttribute = public class(XmlNode)
  unit
    constructor (aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
    constructor (aNativeXmlNode: NativeXmlNode; aParent: XmlNode := nil);
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
{$ENDIF}
implementation
{$IF ECHOES OR (TOFFEE AND MACOS)}

{ XmlDocument }

constructor XmlDocument(aNativeXmlDocument: NativeXmlDocument);
begin
  fNativeXmlDocument := aNativeXmlDocument;
end;

class method XmlDocument.FromFile(aFileName: not nullable File): nullable XmlDocument;
begin
  if aFileName.Exists then begin
    {$IF ECHOES}
    var lXml := NativeXmlDocument.Load(aFileName);
    if assigned(lXml.Root) then
      result := new XmlDocument(lXml);
    {$ELSEIF TOFFEE}
    var lError: NSError;
    var lXml := new NativeXmlDocument withContentsOfURL(NSURL.fileURLWithPath(aFileName)) options(0) error(var lError);
    if assigned(lXml) then
      result := new XmlDocument(lXml);
    {$ENDIF}
  end;
end;

class method XmlDocument.FromUrl(aUrl: not nullable Url): nullable XmlDocument;
begin
  {$IF ECHOES}
  if aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := FromFile(aUrl.FilePath)
  else if aUrl.Scheme in ["http", "https"] then
    result := XmlDocument.FromString(Http.GetString(new HttpRequest(aUrl)));
  {$ELSEIF TOFFEE}
  var lError: NSError;
  var lXml := new NativeXmlDocument withContentsOfURL(aUrl) options(0) error(var lError);
  if assigned(lXml) then
    result := new XmlDocument(lXml);
  {$ENDIF}
end;

class method XmlDocument.FromString(aString: not nullable String): nullable XmlDocument;
begin
  {$IF ECHOES}
  var lXml := XDocument.Parse(aString);
  result := new XmlDocument(lXml);
  {$ELSEIF TOFFEE}
  var lError: NSError;
  var lXml := new NativeXmlDocument withXMLString(aString) options(0) error(var lError);
  if assigned(lXml) then
    result := new XmlDocument(lXml);
  {$ENDIF}
end;

class method XmlDocument.FromBinary(aBinary: not nullable ImmutableBinary): nullable XmlDocument;
begin
  {$IF ECHOES}
  {$WARNING Not implemented}
  raise new NotImplementedException("XmlDocument.FromBinary() is not implemented for .NET yet..");
  {$ELSEIF TOFFEE}
  var lError: NSError;
  var lXml := new NativeXmlDocument withData(aBinary) options(0) error(var lError);
  if assigned(lXml) then
    result := new XmlDocument(lXml);
  {$ENDIF}
end;

class method XmlDocument.WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;
begin
  {$IF ECHOES}
  var lXml := new NativeXmlDocument(aElement.fNativeXmlNode as NativeXmlElement);
  result := new XmlDocument(lXml);
  result.fRoot := aElement;
  {$ELSEIF TOFFEE}
  var lXml := new NativeXmlDocument withRootElement(aElement.fNativeXmlNode as NativeXmlElement);
  if assigned(lXml) then begin
    result := new XmlDocument(lXml);
    result.fRoot := aElement;
  end;
  {$ENDIF}
end;

class method XmlDocument.WithRootElement(aName: not nullable String): nullable XmlDocument;
begin
  {$IF ECHOES}
  var lXml := new NativeXmlDocument(new NativeXmlElement(aName));
  result := new XmlDocument(lXml);
  {$ELSEIF TOFFEE}
  var lXml := new NativeXmlDocument withRootElement(new NativeXmlElement withName(aName));
  if assigned(lXml) then begin
    result := new XmlDocument(lXml);
  end;
  {$ENDIF}
end;

method XmlDocument.ToString(): String;
begin
  result := fNativeXmlDocument.ToString();
end;

method XmlDocument.SaveToFile(aFileName: not nullable File);
begin
  {$IF ECHOES}
  fNativeXmlDocument.Save(aFileName);
  {$ELSEIF TOFFEE}
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

method XmlDocument.AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
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
    {$IF ECHOES}
    fRoot := new XmlElement(fNativeXmlDocument.Root);
    {$ELSEIF TOFFEE}
    fRoot := new XmlElement(fNativeXmlDocument.rootElement);
    {$ENDIF}
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

constructor XmlNode(aNativeXmlNode: NativeXmlNode; aParent: XmlNode := nil);
begin
  fNativeXmlNode := aNativeXmlNode;
  fParent := aParent;
end;

{ XmlElement }

method XmlElement.ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as XElement).Elements().Where(c -> c.Name.LocalName = aLocalName).Select(c -> new XmlElement(c, self)) as not nullable;
  {$ELSEIF TOFFEE}
  if assigned(aNamespace) then
    result := (fNativeXmlNode as NativeXmlElement).elementsForLocalName(aLocalName) URI(aNamespace.Url.ToAbsoluteString()).Select(c -> new XmlElement(c, self))
  else
    result := (fNativeXmlNode as NativeXmlElement).elementsForName(aLocalName).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  {$IF ECHOES}
  {$WARNING Not implemented}
  raise new NotImplementedException("XmlDocument.FromBinary() is not imoplemented yet.");
  //result := [];//(fNativeXmlNode as XElement).Elements(aLocalName).Select(c -> new XmlElement(c, self)) as not nullable;
  {$ELSEIF TOFFEE}
  var lURI := aNamespace:Url:ToAbsoluteString;
  result := (fNativeXmlNode as NativeXmlElement).children.Where(c -> c.URI = lURI).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
begin
  result := ElementsWithName(aLocalName, aNamespace).FirstOrDefault();
end;

method XmlElement.SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
begin
  {$IF ECHOES}
  //var lXName := XName.Get(aName, aNamespace:Url:ToAbsoluteString());
  var lAttribute := (fNativeXmlNode as NativeXmlElement).Attributes().Where(a -> a.Name.LocalName = aName).FirstOrDefault();
  if assigned(lAttribute) then begin
    lAttribute.Value := aValue;
  end
  else begin
    (fNativeXmlNode as NativeXmlElement).Add(new XAttribute(aName, aValue));
  end;
  {$ELSEIF TOFFEE}
  var lAttribute := if assigned(aNamespace) then
                      (fNativeXmlNode as NativeXmlElement).attributeForLocalName(aName) URI(aNamespace.Url.ToAbsoluteString())
                    else
                      (fNativeXmlNode as NativeXmlElement).attributeForName(aName);
  if assigned(lAttribute) then begin
    lAttribute.stringValue := aValue;
  end
  else begin
    if assigned(aNamespace) then
      (fNativeXmlNode as NativeXmlElement).addAttribute(NativeXmlNode.attributeWithName(aName) URI(aNamespace.Url.ToAbsoluteString()) stringValue(aValue))
    else
      (fNativeXmlNode as NativeXmlElement).addAttribute(NativeXmlNode.attributeWithName(aName) stringValue(aValue));
  end;
  {$ENDIF}
end;

method XmlElement.RemoveAttribute(aAttribute: not nullable XmlAttribute);
begin
  {$IF ECHOES}
  (aAttribute.fNativeXmlNode as XAttribute).Remove();
  {$ELSEIF TOFFEE}
  (fNativeXmlNode as NativeXmlElement).removeAttributeForName(aAttribute.LocalName);
  aAttribute.fParent := nil;
  {$ENDIF}
end;

method XmlElement.RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
begin
  {$IF ECHOES}
  //var lXName := XName.Get(aName, aNamespace:Url:ToAbsoluteString());
  var lAttribute := (fNativeXmlNode as NativeXmlElement).Attributes().Where(a -> a.Name.LocalName = aName).FirstOrDefault();
  if assigned(lAttribute) then
    lAttribute.Remove();
  {$ELSEIF TOFFEE}
  var lAttribute := if assigned(aNamespace) then
    (fNativeXmlNode as NativeXmlElement).attributeForLocalName(aName) URI(aNamespace.Url.ToAbsoluteString())
                    else
                      (fNativeXmlNode as NativeXmlElement).attributeForName(aName);
  if assigned(lAttribute) then
    (fNativeXmlNode as NativeXmlElement).removeChildAtIndex(lAttribute.index);
  {$ENDIF}
end;

method XmlElement.AddElement(aElement: not nullable XmlElement);
begin
  {$IF ECHOES}
  (fNativeXmlNode as NativeXmlElement).Add(aElement.fNativeXmlNode);
  {$ELSEIF TOFFEE}
  (fNativeXmlNode as NativeXmlElement).addChild(aElement.fNativeXmlNode);
  {$ENDIF}
  aElement.fParent := self;
end;

method XmlElement.AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
begin
  {$IF ECHOES}
  {$WARNING Not implemented}
  raise new NotImplementedException("XmlElement.AddElement() atIndex() is not implemented for .NET yet.");
  {$ELSEIF TOFFEE}
  (fNativeXmlNode as NativeXmlElement).insertChild(aElement.fNativeXmlNode) atIndex(aIndex);
  aElement.fParent := self;
  {$ENDIF}
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
begin
  {$IF ECHOES}
  //result := new XmlElement(new NativeXmlElement(XName.Get(aName, aNamespace:Url:ToAbsoluteString())));
  result := new XmlElement(new NativeXmlElement(aName));
  {$ELSEIF TOFFEE}
  if assigned(aNamespace) then
    result := new XmlElement(new NativeXmlElement withName(aName) URI(aNamespace.Url.ToAbsoluteString()))
  else
    result := new XmlElement(new NativeXmlElement withName(aName));
  {$ENDIF}
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result);
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
begin
  {$IF ECHOES}
  result := new XmlElement(new XElement(XName.Get(aName, aNamespace:Url:ToAbsoluteString())));
  {$ELSEIF TOFFEE}
  if assigned(aNamespace) then
    result := new XmlElement(new NativeXmlElement withName(aName) URI(aNamespace.Url.ToAbsoluteString()))
  else
    result := new XmlElement(new NativeXmlElement withName(aName));
  {$ENDIF}
  result.Value := aValue;
  AddElement(result) atIndex(aIndex);
end;

method XmlElement.RemoveElement(aElement: not nullable XmlElement);
begin
  {$IF ECHOES}
  (aElement.fNativeXmlNode as NativeXmlElement).Remove();
  {$ELSEIF TOFFEE}
  (fNativeXmlNode as NativeXmlElement).removeChildAtIndex(aElement.fNativeXmlNode.index);
  {$ENDIF}
  aElement.fParent := nil;
end;

method XmlElement.RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
begin
  for each e in ElementsWithName(aName, aNamespace).ToList() do
    RemoveElement(e);
end;

method XmlElement.ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
begin
  {$IF ECHOES}
  {$WARNING Not implemented}
  raise new NotImplementedException("XmlElement.ReplaceElement() withElement() is not implemented for .NET yet.");
  {$ELSEIF TOFFEE}
  var lIndex := aExistingElement.fNativeXmlNode.index;
  (fNativeXmlNode as NativeXmlElement).removeChildAtIndex(lIndex);
  (fNativeXmlNode as NativeXmlElement).insertChild(aNewElement.fNativeXmlNode) atIndex(lIndex);
  aExistingElement.fParent := nil;
  aNewElement.fParent := self;
  {$ENDIF}
end;

{method XmlElement.MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
begin
end;}

method XmlElement.GetLocalName: not nullable String;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as XElement).Name.LocalName as not nullable;
  {$ELSEIF TOFFEE}
  result := fNativeXmlNode.name as not nullable;
  {$ENDIF}
end;

method XmlElement.SetLocalName(aValue: not nullable String);
begin
  {$IF ECHOES}
  (fNativeXmlNode as XElement).Name := aValue;
  {$ELSEIF TOFFEE}
  fNativeXmlNode.name := aValue;
  {$ENDIF}
end;

method XmlElement.GetNamespace: nullable XmlNamespace;
begin
  {$IF ECHOES}
  var lURI := (fNativeXmlNode as XElement).Name.NamespaceName;
  {$ELSEIF TOFFEE}
  var lURI := fNativeXmlNode.URI;
  {$ENDIF}
  if length(lURI) > 0 then
    result := Document.Namespace[Url.UrlWithString(lURI)];
end;

method XmlElement.GetValue: nullable String;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as XElement).Value;
  {$ELSEIF TOFFEE}
  result := fNativeXmlNode.stringValue;
  {$ENDIF}
end;

method XmlElement.SetValue(aValue: nullable String);
begin
  {$IF ECHOES}
  (fNativeXmlNode as XElement).Value := aValue;
  {$ELSEIF TOFFEE}
  fNativeXmlNode.stringValue := aValue;
  {$ENDIF}
end;

method XmlElement.GetAttributes: not nullable sequence of XmlAttribute;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as NativeXmlElement).Attributes.Select(a -> new XmlAttribute(a, self)) as not nullable;
  {$ELSEIF TOFFEE}
  result := (fNativeXmlNode as NativeXmlElement).attributes.Select(a -> new XmlAttribute(a, self));
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: not nullable String): nullable XmlAttribute;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as NativeXmlElement).Attributes().Where(a -> a.Name.LocalName = aName).Select(a -> new XmlAttribute(a, self)).FirstOrDefault;
  {$ELSEIF TOFFEE}
  var lAttribute := (fNativeXmlNode as NativeXmlElement).attributeForName(aName);
  if assigned(lAttribute) then
    result := new XmlAttribute(lAttribute, self);
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as NativeXmlElement).Attributes(XName.Get(aName, aNamespace:Url:ToAbsoluteString())).Select(a -> new XmlAttribute(a, self)).FirstOrDefault;
  {$ELSEIF TOFFEE}
  var lAttribute := if assigned(aNamespace) then
                      (fNativeXmlNode as NativeXmlElement).attributeForLocalName(aName) URI(aNamespace.Url.ToAbsoluteString)
                    else
                      (fNativeXmlNode as NativeXmlElement).attributeForName(aName);
  if assigned(lAttribute) then
    result := new XmlAttribute(lAttribute, self);
  {$ENDIF}
end;

method XmlElement.GetElements: not nullable sequence of XmlElement;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as NativeXmlElement).Elements().Select(c -> new XmlElement(c, self)) as not nullable;
  {$ELSEIF TOFFEE}
  result := (fNativeXmlNode as NativeXmlElement).children.Where(c -> c is NativeXmlElement).Select(c -> new XmlElement(c, self));
  {$ENDIF}
end;

method XmlElement.GetNodes: not nullable sequence of XmlNode;
begin
  {$IF ECHOES}
  {$WARNING Not implemented}
  raise new NotImplementedException("XmlElement.GetNodes() is not implemented for .NET yet.");
  {$ELSEIF TOFFEE}
  result := (fNativeXmlNode as NativeXmlElement).children.Select(c -> begin
    if c is NativeXmlElement then
      result := new XmlElement(c, self)
    else case (c as NativeXmlNode).kind of
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
  var lNativeNode: NativeXmlNode;
  {$IF ECHOES}
  lNativeNode := new XAttribute(XName.Get(aLocalName, aNamespace:Url:ToAbsoluteString()), aValue);
  {$ELSEIF TOFFEE}
  if assigned(aNamespace) then
    lNativeNode := NativeXmlNode.attributeWithName(aLocalName) URI(aNamespace.Url.ToAbsoluteString()) stringValue(aValue)
  else
    lNativeNode := NativeXmlNode.attributeWithName(aLocalName) stringValue(aValue);
  {$ENDIF}
  inherited constructor(lNativeNode);
end;

constructor XmlAttribute(aNativeXmlNode: NativeXmlNode; aParent: XmlNode := nil);
begin
  inherited constructor(aNativeXmlNode, aParent);
end;

method XmlAttribute.GetLocalName: not nullable String;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as XAttribute).Name.LocalName as not nullable;
  {$ELSEIF TOFFEE}
  result := fNativeXmlNode.name as not nullable;
  {$ENDIF}
end;

method XmlAttribute.GetNamespace: XmlNamespace;
begin
  {$IF ECHOES}
  var lURI := (fNativeXmlNode as XAttribute).Name.NamespaceName;
  {$ELSEIF TOFFEE}
  var lURI := fNativeXmlNode.URI;
  {$ENDIF}
  if length(lURI) > 0 then
    result := Document.Namespace[Url.UrlWithString(lURI)];
end;

method XmlAttribute.GetValue: not nullable String;
begin
  {$IF ECHOES}
  result := (fNativeXmlNode as XAttribute).Value as not nullable;
  {$ELSEIF TOFFEE}
  result := fNativeXmlNode.stringValue as not nullable;
  {$ENDIF}
end;

method XmlAttribute.SetValue(aValue: not nullable String);
begin
  {$IF ECHOES}
  (fNativeXmlNode as XAttribute).Value := aValue;
  {$ELSEIF TOFFEE}
  fNativeXmlNode.stringValue := aValue;
  {$ENDIF}
end;

{$ENDIF}

end.