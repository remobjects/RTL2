namespace RemObjects.Elements.RTL;

interface

type
  XmlDocument = public class
    constructor;
    constructor (aRoot : not nullable XmlElement);
  assembly
    fXmlParser: XmlParser;
    fFormatOptions: XmlFormattingOptions;
    fSaveFormatted: Boolean := false;
    fLineBreak: String;
    fFormatInsideTags: Boolean := false;
  private
    fNodes: List<XmlNode> := new List<XmlNode>;
    fRoot: /*not nullable*/ XmlElement;

    method GetNodes: ImmutableList<XmlNode>;
    method GetRoot: not nullable XmlElement;
    method SetRoot(aRoot: not nullable XmlElement);

  public
    class method FromFile(aFileName: not nullable File): not nullable XmlDocument;
    class method FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
    class method FromString(aString: not nullable String): nullable XmlDocument;
    class method FromBinary(aBinary: not nullable Binary): nullable XmlDocument;
    class method WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;
    class method WithRootElement(aName: not nullable String): nullable XmlDocument;

    class method TryFromFile(aFileName: not nullable File): nullable XmlDocument;
    class method TryFromUrl(aUrl: not nullable Url): nullable XmlDocument;

    [ToString]
    method ToString(): String; override;
    method SaveToFile(aFileName: not nullable File);
    method SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);


    property Nodes: ImmutableList<XmlNode> read GetNodes;
    property Root: not nullable XmlElement read GetRoot write SetRoot;

    property Version : String;
    property Encoding : String;
    property Standalone : String;
    method AddNode(aNode: not nullable XmlNode);
  end;

  XmlNodeType = public enum(
    Element,
    Attribute,
    Comment,
    CData,
    &Namespace,
    Text,
    ProcessingInstruction,
    Whitespace
    );

  XmlNode = public class
  unit
    fDocument: weak nullable XmlDocument;
    fParent: weak nullable XmlNode;
    fNodeType: XmlNodeType;
    Indent: String;

    method SetDocument(aDoc: XmlDocument);
    method GetNodeType : XmlNodeType;
  protected
    method CharIsWhitespace(C: String): Boolean;
  public
    constructor (aParent: XmlNode := nil);
    property Parent: nullable XmlNode read fParent;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument) write SetDocument;
    property NodeType: XmlNodeType read GetNodeType;
    property StartLine: Integer;
    property StartColumn: Integer;
    property EndLine: Integer;
    property EndColumn: Integer;
    [ToString]
    method ToString(): String; override;
  end;

  XmlElement = public class(XmlNode)
  unit
    fIsEmpty: Boolean := true;
  private
    fLocalName : String;
    fAttributes: List<XmlAttribute> := new List<XmlAttribute>;
    fElements: List<XmlElement> := new List<XmlElement>;
    fNodes: List<XmlNode> := new List<XmlNode>;
    fNamespace : XmlNamespace;
    fNamespaces: List<XmlNamespace> := new List<XmlNamespace>;
    fDefaultNamespace: XmlNamespace;

    method GetNamespace: XmlNamespace;
    method SetNamespace(aNamespace: XmlNamespace);
    method GetLocalName: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method GetValue: nullable String;
    method SetValue(aValue: nullable String);
    method GetAttributes: not nullable sequence of XmlAttribute;
    method GetAttribute(aName: not nullable String): nullable XmlAttribute;
    method GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
    method GetNodes: ImmutableList<XmlNode>;
    method GetElements: not nullable sequence of XmlElement;
    method GetNamespace(aUrl: Url): nullable XmlNamespace;
    method GetNamespace(aPrefix: String): nullable XmlNamespace;
    method GetNamespaces: not nullable sequence of XmlNamespace;
    method GetDefaultNamespace: XmlNamespace;

  public
    constructor (aParent: XmlNode := nil);
    constructor (aParent: XmlNode := nil; aIndent: String := "");

    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property DefinedNamespaces: not nullable sequence of XmlNamespace read GetNamespaces;
    property DefaultNamespace: XmlNamespace read  GetDefaultNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: nullable String read GetValue write SetValue;
    property IsEmpty: Boolean read fIsEmpty;
    property EndTagName: String;

    property Attributes: not nullable sequence of XmlAttribute read GetAttributes;
    property Attribute[aName: not nullable String]: nullable XmlAttribute read GetAttribute;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute read GetAttribute;
    property Elements: not nullable sequence of XmlElement read GetElements;
    property Nodes: ImmutableList<XmlNode> read GetNodes;
    property &Namespace[aUrl: Url]: nullable XmlNamespace read GetNamespace;
    property &Namespace[aPrefix: String]: nullable XmlNamespace read GetNamespace;

    method ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;

    method AddAttribute(aAttribute: not nullable XmlAttribute);
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

    method AddNode(aNode: not nullable XmlNode);
    //method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
    [ToString]
    method ToString(): String; override;
  end;

  XmlAttribute = public class(XmlNode)
  private
    fLocalName: String;
    fValue: String;
    fNamespace:XmlNamespace;
    WSName: String;
    WSValue: String;
    method GetNamespace: XmlNamespace;
    method SetNamespace(aNamespace: not nullable XmlNamespace);
    method GetLocalName: not nullable String;
    method GetValue: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method SetValue(aValue: not nullable String);
  public
    constructor (aParent: XmlNode := nil);
    constructor (aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: not nullable String read GetValue write SetValue;
    [ToString]
    method ToString(): String; override;
  end;

  XmlComment = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Value: String;
  end;

  XmlCData = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Value: String;
  end;

  XmlNamespace = public class(XmlNode)
  private
    method GetPrefix: String;
    method SetPrefix(aPrefix: String);
    fPrefix: String;
    WSName: String;
    WSValue: String;
  public
    constructor(aParent: XmlNode := nil);
    constructor(aPrefix: String; aUrl: not nullable Url);
    property Prefix: String read GetPrefix write SetPrefix;
    property Url: Url;
    [ToString]
    method ToString(): String; override;

  end;

  XmlProcessingInstruction = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Target: String;
    property Data: String;
  end;

  XmlText = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Value: String;
  end;

implementation

{ XmlDocument }

constructor XmlDocument();
begin
end;

constructor XmlDocument(aRoot: not nullable XmlElement);
begin
  fRoot := aRoot;
  fRoot.Document := self;
  AddNode(fRoot);
end;

class method XmlDocument.FromFile(aFileName: not nullable File): not nullable XmlDocument;
begin
  if not aFileName.Exists then
    raise new FileNotFoundException(aFileName);
  var XmlStr:String := aFileName.ReadText();
  var lXmlParser := new XmlParser(XmlStr);
  result := lXmlParser.Parse();
  result.fXmlParser := lXmlParser;
end;

class method XmlDocument.TryFromFile(aFileName: not nullable File): nullable XmlDocument;
begin
  if aFileName.Exists then begin
    try
      result := FromFile(aFileName);
    except
      on E: XmlException do;
    end;
  end;
end;

class method XmlDocument.FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
begin
  if aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := FromFile(aUrl.FilePath)
  {$IF NOT ISLAND}
  else if aUrl.Scheme in ["http", "https"] then
    result := Http.GetXml(new HttpRequest(aUrl))
  {$ENDIF}
  else
    raise new XmlException(String.Format("Cannot load XML from URL '{0}'.", aUrl.ToAbsoluteString()));
end;

class method XmlDocument.TryFromUrl(aUrl: not nullable Url): nullable XmlDocument;
begin
  if aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := TryFromFile(aUrl.FilePath)
  {$IF NOT ISLAND}
  else if aUrl.Scheme in ["http", "https"] then try
    result := Http.GetXml(new HttpRequest(aUrl));
  except
    on E: XmlException do;
    on E: HttpException do;
  end;
  {$ENDIF}
end;

class method XmlDocument.FromString(aString: not nullable String): nullable XmlDocument;
begin
  var lXmlParser := new XmlParser(aString);
  result := lXmlParser.Parse();
  result.fXmlParser := lXmlParser;
end;

class method XmlDocument.FromBinary(aBinary: not nullable Binary): nullable XmlDocument;
begin
  result := XmlDocument.FromString(new String(aBinary.ToArray));
end;

class method XmlDocument.WithRootElement(aElement: not nullable XmlElement): nullable XmlDocument;
begin
  result := new XmlDocument(aElement);
end;

class method XmlDocument.WithRootElement(aName: not nullable String): nullable XmlDocument;
begin
  result := new XmlDocument(new XmlElement(nil, LocalName := aName));
end;

method XmlDocument.ToString(): String;
begin
  result:="";
  if Version <> nil then result := '<?xml version="'+Version+'"';
  if Encoding <> nil then result := result + ' encoding="'+Encoding+'"';
  if Standalone <> nil then result := result + ' standalone="'+Standalone+'"';
  if result <> "" then result := result + "?>";
  if not(fSaveFormatted) or
    (fSaveFormatted and
      (fXmlParser <> nil) and
      (
        (fFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) or
        (
          (fXmlParser.FormatOptions.WhitespaceStyle = fFormatOptions.WhitespaceStyle) and
          (fXmlParser.FormatOptions.NewLineForElements = fFormatOptions.NewLineForElements) and
          (fXmlParser.FormatOptions.Indentation = fFormatOptions.Indentation) and
          (fXmlParser.FormatOptions.NewLineSymbol = fFormatOptions.NewLineSymbol)
        )
      )
     ) then begin
    if fSaveFormatted and (fFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then begin
      fSaveFormatted := false;
      fFormatInsideTags := true;
    end;
    for each aNode in fNodes do
      result := result+aNode.ToString
  end
  else begin
    if (fFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then fFormatInsideTags := true;
    if (Version <> nil) and fFormatOptions.NewLineForElements then result := result + fLineBreak;
      for each aNode in fNodes do begin
        if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
          result := result+aNode.ToString+fLineBreak;
      end;
  end;
end;

method XmlDocument.SaveToFile(aFileName: not nullable File);
begin
  if not(aFileName.Exists) then
    FileUtils.Create(aFileName.FullPath);
  FileUtils.WriteText(aFileName.FullPath, self.ToString);
end;

method XmlDocument.SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);
begin
  fSaveFormatted := true;
  fFormatOptions := aFormatOptions;
  case fFormatOptions.NewLineSymbol of
    XmlNewLineSymbol.PlatformDefault, XmlNewLineSymbol.Preserve: fLineBreak := Environment.LineBreak;
    XmlNewLineSymbol.LF: fLineBreak := #10;
    XmlNewLineSymbol.CRLF: fLineBreak := #13#10;
  end;
  SaveToFile(aFileName);
  fSaveFormatted := false;
end;


method XmlDocument.AddNode(aNode: not nullable XmlNode);
begin
  aNode.Document := self;
  fNodes.Add(aNode);
end;

method XmlDocument.GetRoot: not nullable XmlElement;
begin
  result := fRoot as not nullable;
end;

method XmlDocument.SetRoot(aRoot: not nullable XmlElement);
begin
  if fRoot <> nil then fNodes.Remove(fRoot);
  fRoot := aRoot;
  AddNode(aRoot);
end;

method XmlDocument.GetNodes: ImmutableList<XmlNode>;
begin
  {var aNodes: List<XmlNode> := new List<XmlNode>;
  for each aNode in fNodes do begin
    if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
      aNodes.Add(aNode);
  end;
  result := aNodes as not nullable;}
  result := fNodes;
end;

constructor XmlNode(aParent: XmlNode);
begin
  fParent := aParent;
end;

method XmlNode.SetDocument(aDoc: XmlDocument);
begin
  fDocument := aDoc;
end;

method XmlNode.GetNodeType: XmlNodeType;
begin
  result := fNodeType;
end;

method XmlNode.ToString: String;
begin
  case NodeType of
    XmlNodeType.Text: begin
      result := XmlText(self).Value;
    end;
    XmlNodeType.Comment: begin
      result := "<!--"+XmlComment(self).Value+"-->";
    end;
    XmlNodeType.CData: result := "<![CDATA["+XmlCData(self).Value+"]]>";
    XmlNodeType.ProcessingInstruction: begin
      result := "<?"+XmlProcessingInstruction(self).Target;
      var str := XmlProcessingInstruction(self).Data;
      if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
        result := result + " ";
      result := result + str+"?>";
    end;
  end;
end;

method XmlNode.CharIsWhitespace(C: String): Boolean;
begin
   exit (C = ' ') or (C = #13) or (C = #10) or (C = #9);
end;
{ XmlElement }
constructor XmlElement(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.Element;
end;

constructor XmlElement(aParent: XmlNode; aIndent: String);
begin
  inherited constructor (aParent);
  Indent := aIndent;
  fNodeType := XmlNodeType.Element;
end;

method XmlElement.ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  if aNamespace = nil then
    result := Elements.Where(c -> (c.LocalName = aLocalName)) as not nullable
  else
    result := Elements.Where(c -> (c.LocalName = aLocalName) and (c.Namespace = aNamespace)) as not nullable
end;

method XmlElement.ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  result := Elements.Where(c -> c.Namespace = aNamespace) as not nullable;
end;

method XmlElement.FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
begin
  result := ElementsWithName(aLocalName, aNamespace).FirstOrDefault();
  if (result = nil) then begin
    var lBracePos := aLocalName.IndexOf('{');
    if (lBracePos = 0) and (aLocalName.IndexOf('}') > lBracePos) then begin
      result := ElementsWithName(aLocalName.Substring(aLocalName.IndexOf('}')+1, aLocalName.Length - aLocalName.IndexOf('}')-1 ),
        &Namespace[ Url.UrlWithString(aLocalName.Substring(1, aLocalName.IndexOf('}')-1))]).FirstOrDefault;
    end
    else begin
      var lPrefixPos := aLocalName.IndexOf(':');
    if (lPrefixPos > 0) and (&Namespace[aLocalName.Substring(0, lPrefixPos)] <> nil) then
      result := ElementsWithName(aLocalName.Substring(lPrefixPos+1, aLocalName.Length-lPrefixPos-1), &Namespace[aLocalName.Substring(0, lPrefixPos)]).FirstOrDefault
    end;
  end;
end;

method XmlElement.AddAttribute(aAttribute: not nullable XmlAttribute);
begin
  fAttributes.Add(aAttribute);
end;

method XmlElement.SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
begin
  if assigned(Attributes) then begin
    var lAttribute := GetAttributes.Where(a -> a.LocalName = aName).FirstOrDefault();
    if assigned(lAttribute) then lAttribute.Value := aValue
    else fAttributes.Add(new XmlAttribute(aName, aNamespace, aValue));
  end
  else begin
    fAttributes.Add( new XmlAttribute(aName, aNamespace, aValue));
  end;
end;

method XmlElement.RemoveAttribute(aAttribute: not nullable XmlAttribute);
begin
  fAttributes.Remove(aAttribute);
end;

method XmlElement.RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
begin
  var lAttribute := Attributes.Where(a -> (a.LocalName = aName) and (a.Namespace = aNamespace)).FirstOrDefault;
  if assigned(lAttribute) then
    fAttributes.Remove(lAttribute);
end;

method XmlElement.AddElement(aElement: not nullable XmlElement);
begin
  aElement.fParent := self;
  if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then begin
    if fNodes.Count > 0 then begin
      var LastNodePos := fNodes.Count-1;
      if (fNodes.Item[LastNodePos].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[LastNodePos]).Value = aElement.fParent.Indent) then begin
        fNodes.Insert(LastNodePos,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Insert(LastNodePos+1,aElement);
        fNodes.Insert(LastNodePos+2 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
      end;
     end
     else begin
        fNodes.Add(new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Add(aElement);
        fNodes.Add(new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
     end;
  end
  else fNodes.Add(aElement);
  fElements.Add(aElement);
end;

method XmlElement.AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
begin
  if (fNodes.Count = 0)  and (aIndex = 0) then AddElement(aElement)
  else begin
    fElements.Insert(aIndex, aElement);
    var lFormat := false;
    if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then
      lFormat := true;
    var i,j: Integer;
    for i:=0 to fNodes.Count-1 do begin
      if fNodes.Item[i].NodeType = XmlNodeType.Element then begin
        if aIndex = j then break;
        inc(j);
      end;
    end;
    if lFormat and (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value.StartsWith(aElement.fParent.Indent)) then begin
      fNodes.Insert(i-1,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
      fNodes.Insert(i,aElement);
      fNodes.Insert(i+1 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
    end
    else fNodes.Insert(i,aElement);
  end;
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
begin
  result := new XmlElement(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result);
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
begin
  result := new XmlElement(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result) atIndex(aIndex);
end;

method XmlElement.RemoveElement(aElement: not nullable XmlElement);
begin
  fElements.Remove(aElement);
  if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then begin
    var i := 0;
    var found := false;
    while (i < fNodes.Count) and not(found) do begin
      if fNodes.Item[i] = aElement then found := true;
      inc(i);
    end;
    i:= i-1;
    if found and (i > 0) and (i < fNodes.Count-1)  and
      (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value.StartsWith(self.Document.fXmlParser.FormatOptions.Indentation) and
      (fNodes.Item[i+1].NodeType = XmlNodeType.Text) and (XmlText(fNodes.Item[i+1]).Value.EndsWith(#10))) then begin
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
    end
    else fNodes.Remove(aElement);
  end
  else fNodes.Remove(aElement);
  aElement.fParent := nil;
end;

method XmlElement.RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
begin
  for each e in ElementsWithName(aName, aNamespace).ToList() do
    RemoveElement(e);
end;

method XmlElement.ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
begin
  var i := 0;
  for each elem in Elements do
    if elem.Equals(aExistingElement) then begin
      fElements.ReplaceAt(i, aNewElement);
      break;
    end
    else inc(i) ;
  var j := i;
  for j:=i to Nodes.Count-1 do begin
     if fNodes.Item[j].Equals(aExistingElement) then begin
       fNodes.ReplaceAt(j, aNewElement);
       break;
     end;
  end;
end;

{method XmlElement.MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
begin
end;}

method XmlElement.GetNodes: ImmutableList<XmlNode>;
begin
  {var aNodes: List<XmlNode> := new List<XmlNode>;
  for each aNode in fNodes do begin
    if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
      aNodes.Add(aNode);
  end;
  result := aNodes as not nullable;}
  result := fNodes;
end;

method XmlElement.AddNode(aNode: not nullable XmlNode);
begin
  fIsEmpty := false;
  if (aNode.NodeType = XmlNodeType.Text) and (XmlText(aNode).Value = "") then exit;
  fNodes.Add(aNode);
end;

method XmlElement.GetLocalName: not nullable String;
begin
  //result := fLocalName as not nullable;
  result := fLocalName.Trim as not nullable;
end;

method XmlElement.SetLocalName(aValue: not nullable String);
begin
  fLocalName := aValue;
end;

method XmlElement.GetNamespace: nullable XmlNamespace;
begin
  result := fNamespace;
  result := coalesce(fNamespace, fDefaultNamespace);
  if (result = nil) and (self.Parent <> nil) then result := XmlElement(self.Parent).DefaultNamespace;
end;

method XmlElement.SetNamespace(aNamespace: XmlNamespace);
begin
  fNamespace := aNamespace;
end;

method XmlElement.GetDefaultNamespace: XmlNamespace;
begin
  if Parent = nil then result := fDefaultNamespace
  else result := coalesce(fDefaultNamespace, XmlElement(Parent).DefaultNamespace);
end;

method XmlElement.GetValue: nullable String;
begin
  result := "";
  for each lNode in Nodes do begin
    if result <> "" then result := result+" ";
    if lNode.NodeType = XmlNodeType.Text then result := result+XmlText(lNode).Value
    else if lNode.NodeType = XmlNodeType.Element then result := result+XmlElement(lNode).GetValue;
  end;
end;

method XmlElement.SetValue(aValue: nullable String);
begin
  fNodes.RemoveAll;
  AddNode(new XmlText(self, Value := aValue));
end;

method XmlElement.GetAttributes: not nullable sequence of XmlAttribute;
begin
  result := fAttributes as not nullable;
end;

method XmlElement.GetAttribute(aName: not nullable String): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> a.LocalName = aName).FirstOrDefault;
end;

method XmlElement.GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> (a.LocalName = aName) and (a.Namespace = aNamespace)).FirstOrDefault;
end;

method XmlElement.GetElements: not nullable sequence of XmlElement;
begin
  result := fElements as not nullable;
end;

method XmlElement.GetNamespaces: not nullable sequence of XmlNamespace;
begin
  result := fNamespaces as not nullable;
end;

method XmlElement.GetNamespace(aUrl: Url): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Url = aUrl).FirstOrDefault;
end;

method XmlElement.GetNamespace(aPrefix: String): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
end;

method XmlElement.AddNamespace(aNamespace: not nullable XmlNamespace);
begin
  if GetNamespace(aNamespace.Prefix) = nil then begin
    fNamespaces.Add(aNamespace);
    if (aNamespace.Prefix = nil) or (aNamespace.Prefix = "") then fDefaultNamespace := aNamespace;
  end
  else if aNamespace.Prefix=nil then raise new Exception("Duplicate namespace xmlns")
    else  raise new Exception("Duplicate namespace xmlns:"+aNamespace.Prefix);
end;

method XmlElement.AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
begin
  result := new XmlNamespace(aPrefix, aUrl);
  AddNamespace(result);
end;

method XmlElement.RemoveNamespace(aNamespace: not nullable XmlNamespace);
begin
  fNamespaces.Remove(aNamespace);
end;

method XmlElement.RemoveNamespace(aPrefix: not nullable String);
begin
  var lNamespace := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
  fNamespaces.Remove(lNamespace);
end;

method XmlElement.ToString(): String;
begin
  var str: String;
  result := "<";
  if (&Namespace <> nil) and (&Namespace.Prefix<>"") and (&Namespace.Prefix <> nil) then
    result := result+&Namespace.Prefix+":";
  result := result + fLocalName;
  for each defNS in DefinedNamespaces do begin
    str := defNS.ToString;
    if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
      result := result+" ";
    result := result+str;
  end;
  for each attr in Attributes do begin
    str := attr.ToString;
    if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
      result := result+" ";
    result := result+str;

  end;
  if IsEmpty then begin
    if (Document <> nil) then begin
      if (Document.fFormatInsideTags) then begin
        if (Document.fFormatOptions.EmptyTagSyle <> XmlTagStyle.PreferOpenAndCloseTag) and Document.fFormatOptions.SpaceBeforeSlashInEmptyTags and
          not (CharIsWhitespace(result[result.Length-1])) then
          result := result + " ";
        result := result + "/>"
      end
      else begin
        if (Document.fXmlParser <> nil) and (Document.fXmlParser.FormatOptions.SpaceBeforeSlashInEmptyTags) and
          not (CharIsWhitespace(result[result.Length-1])) then
          result := result+ " ";
        result := result +"/>";
      end;

    end;
  end;
  if fNodes.count > 0 then result := result +">";
  /********/
  var lFormat := false;
  var indent : String := "";
  if Document.fSaveFormatted and (Document.fFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
    if Document.fFormatOptions.NewLineForElements  then lFormat := true;
    var i := 0;
    if lFormat  and (fNodes.count > 0) then begin
      var n := fNodes[0];
      while n.Parent<>nil do begin
        indent := indent+Document.fFormatOptions.Indentation;
        n := n.Parent;
      end;
    end;

    for each aNode in fNodes do begin
      if (aNode.NodeType = XmlNodeType.Text) then
        if (XmlText(aNode).Value.Trim <> "") then begin
          if (i > 0) and (fNodes[i-1].NodeType = XmlNodeType.Text) and (XmlText(fNodes[i-1]).Value.Trim = "") then
            result := result + fNodes[i-1].ToString;
          result := result+ aNode.ToString;
          if (i < fNodes.Count-1) and (fNodes[i+1].NodeType = XmlNodeType.Text) and (XmlText(fNodes[i+1]).Value.Trim = "") then begin
            str := fNodes[i+1].ToString;
            if str.IndexOf(Document.fLineBreak) > -1 then
              str := str.Substring(0, str.LastIndexOf(Document.fLineBreak));
            result := result + str;
          end;
        end;
      if (aNode.NodeType <> XmlNodeType.Text) then
        if lFormat then
          result := result + Document.fLineBreak + indent + aNode.ToString
        else result := result + aNode.tostring;
      inc(i);
    end;
  end
  /******/
  else
    for each aNode in fNodes do
      result := result + aNode.ToString;
  if IsEmpty = false then begin
    if (fNodes.Count = 0) and (Document.fFormatInsideTags) and (Document.fFormatOptions.EmptyTagSyle = XmlTagStyle.PreferSingleTag) then
      if Document.fFormatOptions.SpaceBeforeSlashInEmptyTags and not (CharIsWhitespace(result[result.Length-1])) then
        result := result + " />"
      else
        result := result+"/>"
    else begin
      if fNodes.Count = 0 then result := result + ">";
      if lFormat and (Elements.Count > 0) then begin
        result := result +Document.fLineBreak;
        if Indent.LastIndexOf(Document.fFormatOptions.Indentation) > -1 then result := result+Indent.Substring(0, Indent.LastIndexOf(Document.fFormatOptions.Indentation));
      end;
      result := result+"</";
      if (&Namespace <> nil) and (&Namespace.Prefix <> "") and (&Namespace.Prefix <> nil) then
        result := result+&Namespace.Prefix+':';
      if EndTagName <> nil then result := result+ EndTagName+">"
      else result := result + LocalName+">";
    end;
  end;
end;

{ XmlAttribute }

constructor XmlAttribute(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.Attribute;
end;

constructor XmlAttribute(aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
begin
  fLocalName := aLocalName;
  fNamespace := aNamespace;
  fValue := aValue;
  inherited constructor(nil);
  fNodeType := XmlNodeType.Attribute;
end;

method XmlAttribute.GetLocalName: not nullable String;
begin
  //result := fLocalName as not nullable;
  /*if fLocalName.IndexOf("=") > -1 then begin
    result := fLocalName.Substring(0, fLocalName.IndexOf("="));
  end;*/
  result := fLocalName.Trim as not nullable;
end;

method XmlAttribute.GetNamespace: XmlNamespace;
begin
  result := fNamespace;
end;

method XmlAttribute.SetNamespace(aNamespace: not nullable XmlNamespace);
begin
  fNamespace := aNamespace;
end;

method XmlAttribute.GetValue: not nullable String;
begin
  result := fValue.Trim as not nullable;
  if ((result[0] = '"') and (result[result.Length-1] = '"') or
    (result[0] = '''') and (result[result.Length-1] = '''')) then
    result := result.Substring(1,result.Length-2) as not nullable;
end;

method XmlAttribute.SetLocalName(aValue: not nullable String);
begin
  WSName := nil;
  if aValue.Length <> aValue.Trim.Length then WSName := aValue;
  fLocalName := aValue;
end;

method XmlAttribute.SetValue(aValue: not nullable String);
begin
  fValue := aValue;
  WSValue := nil;
  if aValue.Length <> aValue.Trim.Length then WSValue := aValue;
end;

method XmlAttribute.ToString: String;
begin
  if (Document <> nil) and not(Document.fFormatInsideTags) and (WSName <> nil) then result := result + WSName+"="
  else begin
    if (Document <> nil) and Document.fFormatInsideTags and Document.fFormatOptions.NewLineForAttributes then begin
      var indent :="";
      var n: XmlNode;
      n:=Parent;
      while n <> nil do begin
        indent := indent + Document.fFormatOptions.Indentation;
        n := n.Parent;
      end;
      result := result + Document.fLineBreak+indent;
    end;
      if &Namespace<>nil then result := result+&Namespace.Prefix+":";
      result := result + LocalName+'=';
    end;
  if (Document <> nil) and not(Document.fFormatInsideTags) and (WSValue <> nil) then result := result + WSValue
  else result := result +'"'+Value+'"';
end;

{ XmlNamespace}
constructor XmlNamespace(aParent: XmlNode);
begin
  inherited constructor(aParent);
  fNodeType := XmlNodeType.Namespace;
end;

constructor XmlNamespace(aPrefix: String; aUrl: not nullable Url);
begin
  inherited constructor(nil);
  Prefix := aPrefix;
  Url := aUrl;
  fNodeType := XmlNodeType.Namespace;
end;

method XmlNamespace.GetPrefix: String;
begin
  if fPrefix = nil then exit nil
  else exit fPrefix.Trim;
end;

method XmlNamespace.SetPrefix(aPrefix: String);
begin
  WSName := nil;
  WSValue := nil;
  if aPrefix <> nil then begin
    var AttrSeparator := aPrefix.IndexOf("=");
    if AttrSeparator >-1 then begin
      WSName := aPrefix.Substring(0, AttrSeparator);
      WSValue := aPrefix.Substring(AttrSeparator+1, aPrefix.Length-AttrSeparator-1);
      if WSName.IndexOf("xmlns:") > -1 then fPrefix := WSName.Substring(WSName.IndexOf(":")+1, WSName.Length -WSName.IndexOf(":")-1 )
      else if WSName.IndexOf("xmlns") > -1 then fPrefix := "";
    end
    else fPrefix := aPrefix;
  end;
end;

method XmlNamespace.ToString: String;
begin
  result := "";
  if (Document <> nil) and not(Document.fFormatInsideTags) and (WSName <> nil) then begin
    result := result + WSName+"=";
  end
  else begin
    if (Document <> nil) and Document.fFormatInsideTags and Document.fFormatOptions.NewLineForAttributes then begin
      var indent :="";
      var n: XmlNode;
      n:=Parent;
      while n <> nil do begin
        indent := indent + Document.fFormatOptions.Indentation;
        n := n.Parent;
      end;
      result := result + Document.fLineBreak+Indent;
    end;
    result := result+"xmlns";
    if (Prefix <> "") and (Prefix <> nil) then result := result+':'+Prefix;
    result := result + "=";
  end;
  if (Document <> nil) and not(Document.fFormatInsideTags) and (WSValue <> nil) then result := result + WSValue
  else    result := result +'"'+ Url.ToString+'"';
end;

{XmlComment}
constructor XmlComment(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.Comment;
end;

{XmlCData}
constructor XmlCData(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.CData;
end;

{XmlText}

constructor XmlText(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.Text;
end;

{XmlProcessingInstructions}

constructor XmlProcessingInstruction(aParent: XmlNode);
begin
  inherited constructor (aParent);
  fNodeType := XmlNodeType.ProcessingInstruction;
end;

end.