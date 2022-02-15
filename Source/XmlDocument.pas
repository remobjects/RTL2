namespace RemObjects.Elements.RTL;

interface

type
  XmlDocument = public class
    constructor;
    constructor (aRoot : not nullable XmlElement);
  assembly
    fXmlParser: XmlParser;
    //fFormatOptions: XmlFormattingOptions;
    fLineBreak: String;
  private
    fNodes: List<XmlNode> := new List<XmlNode>;
    fRoot: /*not nullable*/ XmlElement;
    fDefaultVersion := "1.0";
    fWasDocType: Boolean;

    method GetNodes: ImmutableList<XmlNode>;
    method GetRoot: not nullable XmlElement;
    method SetRoot(aRoot: not nullable XmlElement);
    method GetCurrentIdentifier(aColumn: Integer; aStart: Integer; aPrefixLength:Integer; aName: String): String;

  public
    {$IF NOT WEBASSEMBLY}
    class method FromFile(aFileName: not nullable File): not nullable XmlDocument;
    {$ENDIF}
    class method FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
    class method FromString(aString: not nullable String): not nullable XmlDocument;
    class method FromBinary(aBinary: not nullable ImmutableBinary): not nullable XmlDocument;
    class method WithRootElement(aElement: not nullable XmlElement): not nullable XmlDocument;
    class method WithRootElement(aName: not nullable String): not nullable XmlDocument;

    {$IF NOT WEBASSEMBLY}
    class method TryFromFile(aFileName: not nullable File): nullable XmlDocument; inline;
    {$ENDIF}
    class method TryFromUrl(aUrl: not nullable Url): nullable XmlDocument; inline;
    class method TryFromString(aString: not nullable String): nullable XmlDocument; inline;
    class method TryFromBinary(aBinary: not nullable ImmutableBinary): nullable XmlDocument; inline;
    {$IF NOT WEBASSEMBLY}
    class method TryFromFile(aFileName: not nullable File; aAllowBrokenDocument: Boolean): nullable XmlDocument;
    {$ENDIF}
    class method TryFromUrl(aUrl: not nullable Url; aAllowBrokenDocument: Boolean): nullable XmlDocument;
    class method TryFromString(aString: not nullable String; aAllowBrokenDocument: Boolean): nullable XmlDocument;
    class method TryFromBinary(aBinary: not nullable ImmutableBinary; aAllowBrokenDocument: Boolean): nullable XmlDocument; inline;

    [ToString]
    method ToString(): String; override;
    method ToString(aFormatOptions: XmlFormattingOptions): String;
    method ToString(aSaveFormatted: Boolean; aFormatOptions: XmlFormattingOptions): String;

    {$IF NOT WEBASSEMBLY}
    method SaveToFile(aFileName: not nullable File);
    method SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);
    {$ENDIF}

    property Nodes: ImmutableList<XmlNode> read GetNodes;
    property Root: not nullable XmlElement read GetRoot write SetRoot;

    property Version : String;
    property Encoding : String;
    property Standalone : String;
    property ErrorInfo: XmlErrorInfo;
    method AddNode(aNode: not nullable XmlNode);
    method NearestOpenTag(aRow: Integer; aColumn: Integer; out aCursorPosition: XmlPositionKind): XmlElement;
    method GetCurrentCursorPosition(aRow: Integer; aColumn: Integer): XmlDocCurrentPosition;
  end;

  XmlNodeType = public enum(
    Element,
    Attribute,
    Comment,
    CData,
    &Namespace,
    Text,
    ProcessingInstruction,
    DocumentType
    );

  XmlNode = public class
  unit
    fDocument: weak nullable XmlDocument;
    fParent: weak nullable XmlElement;
    fNodeType: XmlNodeType;
    Indent: String;

    method SetDocument(aDoc: XmlDocument);
    method GetNodeType : XmlNodeType;
    constructor withParent(aParent: XmlElement := nil);
  protected
    method CheckName(aName: String): Boolean;
    method CharIsWhitespace(C: String): Boolean;
    method ConvertEntity(S: String; C: nullable Char): String;
  public
    constructor; empty;
    property Parent: nullable XmlElement read fParent;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument) write SetDocument;
    property NodeType: XmlNodeType read GetNodeType;
    property NodeRange: XmlRange := new XmlRange;

    [ToString]
    method ToString(): String; override;
    method ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions := new XmlFormattingOptions): String; virtual;

    method UniqueCopy: not nullable XmlNode; virtual;
  end;

  XmlElement = public class(XmlNode)
  private
    fLocalName : String := "";
    fElements: List<XmlElement> := new List<XmlElement>;
    fNodes: List<XmlNode> := new List<XmlNode>;
    fNamespace : XmlNamespace;
    fDefaultNamespace: XmlNamespace;

    fAttributesAndNamespaces: List<XmlNode> := new List<XmlNode>;
    fChildIndex: Integer;
    fPreserveSpace: Boolean;

    method GetNamespace: nullable XmlNamespace;
    method SetNamespace(aNamespace: XmlNamespace);
    method GetLocalName: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method GetFullName: not nullable String;
    //method GetValue: nullable String;
    method SetValue(aValue: nullable String);
    method GetAttributes: not nullable sequence of XmlAttribute;
    method GetAttribute(aName: not nullable String): nullable XmlAttribute;
    method GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
    method GetNodes: ImmutableList<XmlNode>;
    method GetElements: not nullable sequence of XmlElement;
    method GetNamespaceByUri(aUri: String): nullable XmlNamespace;
    method GetNamespace(aPrefix: String): nullable XmlNamespace;
    method GetNamespaces: not nullable sequence of XmlNamespace;
    method GetDefaultNamespace: XmlNamespace;
    method SetPreserveSpace(aPreserveSpace:Boolean);
    method GetNamespaceFromName(var aName: String): nullable XmlNamespace;
  assembly
    //fIsEmpty: Boolean := true;
    constructor withParent(aParent: XmlElement := nil);
    constructor withParent(aParent: XmlElement) Indent(aIndent: String := "");
    WSAfterName: String;

  public
    constructor withName(aLocalName: not nullable String);
    constructor withName(aLocalName: not nullable String) Value(aValue: not nullable String);

    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property DefinedNamespaces: not nullable sequence of XmlNamespace read GetNamespaces;
    property DefaultNamespace: XmlNamespace read  GetDefaultNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: nullable String read GetValue(true) write SetValue;
    property IsEmpty: Boolean read Nodes.Count = 0;//fIsEmpty;
    property EndTagName: String;
    property OpenTagEndLine: Integer;
    property OpenTagEndColumn: Integer;

    property CloseTagRange: XmlRange := new XmlRange;
    property Attributes: not nullable sequence of XmlAttribute read GetAttributes;
    property Attribute[aName: not nullable String]: nullable XmlAttribute read GetAttribute;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute read GetAttribute;
    property Elements: not nullable sequence of XmlElement read GetElements;
    property Nodes: ImmutableList<XmlNode> read GetNodes;
    [Obsolete]property &Namespace[aUri: Uri]: nullable XmlNamespace read &NamespaceByUri[aUri.ToString];
    property &NamespaceByUri[aUri: String]: nullable XmlNamespace read GetNamespaceByUri;
    property &Namespace[aPrefix: String]: nullable XmlNamespace read GetNamespace;
    property FullName: not nullable String read GetFullName;
    property ChildIndex: Integer read fChildIndex;
    property PreserveSpace: Boolean read fPreserveSpace  write SetPreserveSpace;

    method GetValue (aWithNested: Boolean): nullable String;
    method ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;

    method AddAttribute(aAttribute: not nullable XmlAttribute);
    method SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
    method RemoveAttribute(aAttribute: not nullable XmlAttribute);
    method RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;

    method &Add(aData: not nullable sequence of Object);
    method &Add(aData: not nullable sequence of XmlElement);
    method &Add(aElement: not nullable XmlElement);
    method &Add(aCData: not nullable XmlCData);
    method &Add(aComment: not nullable XmlComment);
    method &Add(aAttribute: not nullable XmlAttribute);
    method &Add(aString: not nullable String);
    //method &Add(aInteger: not nullable Integer);
    //method &Add(aFloat: not nullable Double);
    method &Add(aDateTime: not nullable DateTime);

    method AddElement(aElement: not nullable XmlElement);
    method AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
    method AddElements(aElements: not nullable sequence of XmlElement);
    method RemoveElement(aElement: not nullable XmlElement);
    method RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
    method RemoveAllElements;

    method ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);

    method AddNode(aNode: not nullable XmlNode);
    //method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: nullable String; aUri: not nullable String): XmlNamespace;
    [Obsolete]method AddNamespace(aPrefix: nullable String; aUri: not nullable Uri): XmlNamespace;
    begin
      result := AddNamespace(aPrefix, aUri.ToString);
    end;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
    [ToString]
    method ToString(): String; override;
    method ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions := new XmlFormattingOptions): String; override;

    method UniqueCopy: not nullable XmlNode; override;
  end;

  XmlAttribute = public class(XmlNode)
  assembly
    WSleft, WSright: String;
    innerWSleft, innerWSright: String;
    QuoteChar: Char := '"';
    originalRawValue: String;
  private
    fLocalName: String;
    fValue: String;
    fNamespace:XmlNamespace;
    method GetNamespace: XmlNamespace;
    method SetNamespace(aNamespace: not nullable XmlNamespace);
    method GetLocalName: not nullable String;
    method GetValue: not nullable String;
    method GetFullName: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method SetValue(aValue: not nullable String);
  public
    constructor withParent(aParent: XmlElement := nil);
    constructor (aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: not nullable String read GetValue write SetValue;
    property FullName: not nullable String read GetFullName;
    property ValueRange: XmlRange := new XmlRange;
    [ToString]
    method ToString(): String; override;
    method ToString(aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions := new XmlFormattingOptions{aPreserveExactStringsForUnchnagedValues: Boolean := false}): String;
    method UniqueCopy: not nullable XmlNode; override;
  end;

  XmlComment = public class(XmlNode)
  public
    constructor (aParent: XmlElement := nil);
    property Value: String;
  end;

  XmlCData = public class(XmlNode)
  public
    constructor (aParent: XmlElement := nil);
    property Value: String;
  end;

  XmlNamespace = public class(XmlNode)
  private
    method GetPrefix: String;
    method SetPrefix(aPrefix: String);
    fPrefix: String;
  assembly
    WSleft, WSright: String;
    innerWSleft, innerWSright: String;
    QuoteChar: Char := '"';
    constructor withParent(aParent: XmlElement := nil);
  public
    constructor(aPrefix: String; aUri: not nullable String);
    [Obsolete]constructor(aPrefix: String; aUri: not nullable Uri);
    begin
      constructor (aPrefix , aUri.ToString);
    end;
    property Prefix: String read GetPrefix write SetPrefix;
    property Uri: String;
    [ToString]
    method ToString(): String; override;
    method ToString(aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions): String;

    method UniqueCopy: not nullable XmlNode; override;
  end;

  XmlProcessingInstruction = public class(XmlNode)
  public
    constructor (aParent: XmlElement := nil);
    property Target: String;
    property Data: String;
  end;

  XmlText = public class(XmlNode)
  private
    fValue: String;
    method GetValue: String;
    method SetValue(aValue: String);
  assembly
    originalRawValue: String;
  public
    constructor (aParent: XmlElement := nil);
    property Value: String read GetValue write SetValue;
    property IsWhitespaceValue: Boolean read String.IsNullOrWhiteSpace(fValue);
  end;

  XmlDocumentType = public class(XmlNode)
  public
    constructor ();
    property Name: String;
    property SystemId: String;
    property PublicId: String;
    property Declaration: String;
  end;

  XmlRange = public class
  public
    property StartLine: Integer;
    property StartColumn: Integer;
    property EndLine: Integer;
    property EndColumn: Integer;
    method FillRange(aStartLine, aStartColumn: Integer; aEndLine: Integer := 0; aEndColumn: Integer := 0);
    begin
      StartLine := aStartLine;
      StartColumn := aStartColumn;
      EndLine := aEndLine;
      EndColumn := aEndColumn;
    end;
  end;

  XmlError = public class(XmlNode)
  public
    property Attribute: Boolean;
  end;

  XmlDocCurrentPosition = public class
  public
    property CurrentPosition: XmlPositionKind;
    property ParentTag: XmlElement;
    property CurrentTag: XmlElement;
    property CurrentTagIndex: Integer; //0-based number of current tag in the parent tag
    property CurrentAttribute: XmlAttribute; //could be empty
    property CurrentNamespace: XmlNamespace; //could be nil if no namespace
    property CurrentIdentifier: String;
  end;

  XmlPositionKind = public enum(
    None,
    StartTag,
    SingleTag,
    InsideTag,
    InsideXmlns,
    BetweenTags,
    EndTag,
    AttributeValue
  );

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

{$IF NOT WEBASSEMBLY}
class method XmlDocument.FromFile(aFileName: not nullable File): not nullable XmlDocument;
begin
  if not aFileName.Exists then
    raise new FileNotFoundException(String(aFileName));
  var lXMl := TryFromFile(aFileName, true);
  if assigned(lXMl:ErrorInfo) then
    if lXMl.ErrorInfo.Row = -1 then
      raise new XmlException(lXMl.ErrorInfo.Message)
    else
      raise new XmlException(lXMl.ErrorInfo.Message, lXMl.ErrorInfo.Row, lXMl.ErrorInfo.Column);
  result := lXMl as not nullable;
end;

class method XmlDocument.TryFromFile(aFileName: not nullable File): nullable XmlDocument;
begin
  result := TryFromFile(aFileName, false);
end;

class method XmlDocument.TryFromFile(aFileName: not nullable File; aAllowBrokenDocument: Boolean): nullable XmlDocument;
begin
  try
    if aFileName.Exists then begin
      var XmlStr:String := aFileName.ReadText();
      var lXmlParser := new XmlParser(XmlStr);
      result := lXmlParser.Parse();
      result.fXmlParser := lXmlParser;
      if (not aAllowBrokenDocument) and assigned(result.ErrorInfo) then result := nil;
    end;
  except
    on E: Exception do
      if aAllowBrokenDocument then begin
        if not assigned(result) then
          result := new XmlDocument;
        if not assigned(result.ErrorInfo) then
          result.ErrorInfo := new XmlErrorInfo(Message := E.Message, Row := -1);
      end;
  end;
end;
{$ENDIF}

{$IF WEBASSEMBLY}[Warning("Not Implemented for WebAssembly")]{$ENDIF}
class method XmlDocument.FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  {$HINT Fix Below} // 78937: `defined()` doesnt seem to work (and adds extra warning)
  raise new NotImplementedException("Not implemented for WebAssemlbly yet");
  {$ELSE}
  if {not defined("WEBASSEMBLY") and} aUrl.IsFileUrl and aUrl.FilePath.FileExists then begin
    result := FromFile(File(aUrl.FilePath));
    if assigned(result:ErrorInfo) then
      if result.ErrorInfo.Row = -1 then
        raise new XmlException(result.ErrorInfo.Message)
      else
        raise new XmlException(result.ErrorInfo.Message, result.ErrorInfo.Row, result.ErrorInfo.Column);
  end
  else if (aUrl.Scheme = "http") or (aUrl.Scheme = "https") then begin
    result := Http.GetXml(new HttpRequest(aUrl))
  end
  else
    raise new XmlException(String.Format("Cannot load XML from URL '{0}'.", aUrl.ToAbsoluteString()));
  {$ENDIF}
end;

class method XmlDocument.TryFromUrl(aUrl: not nullable Url): nullable XmlDocument;
begin
  result := TryFromUrl(aUrl, false);
end;

class method XmlDocument.TryFromUrl(aUrl: not nullable Url; aAllowBrokenDocument: Boolean): nullable XmlDocument;
begin
  {$IF WEBASSEMBLY}
  {$HINT Fix Below} // 78937: `defined()` doesnt seem to work (and adds extra warning)
  {$ELSE}
    try
  if {not defined("WEBASSEMBLY") and} aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := TryFromFile(File(aUrl.FilePath), aAllowBrokenDocument)
  else if aUrl.Scheme in ["http", "https"] then //try
    {$IFDEF ISLAND}
    raise new NotImplementedException;
    {$ELSE}
    result := Http.GetXml(new HttpRequest(aUrl));
    {$ENDIF}
  except
    on E: Exception do begin
      if aAllowBrokenDocument then begin
        if not assigned(result) then
          result := new XmlDocument;
        if not assigned(result.ErrorInfo) then
          result.ErrorInfo := new XmlErrorInfo(Message := E.Message, Row := -1);
      end;
    {on E: XmlException do;
    on E: HttpException do;}
    end;
  end;

  {$ENDIF}
end;

class method XmlDocument.FromString(aString: not nullable String): not nullable XmlDocument;
begin
  var lResult := TryFromString(aString, true);
  if (lResult.ErrorInfo <> nil) then
    if lResult.ErrorInfo.Row = -1 then
      raise new XmlException(lResult.ErrorInfo.Message)
    else
      raise new XmlException(lResult.ErrorInfo.Message, lResult.ErrorInfo.Row, lResult.ErrorInfo.Column);
  result := lResult as not nullable;
end;

class method XmlDocument.TryFromString(aString: not nullable String): nullable XmlDocument;
begin
  result := TryFromString(aString, false);
end;

class method XmlDocument.TryFromString(aString: not nullable String; aAllowBrokenDocument: Boolean): nullable XmlDocument;
begin
  try
    var lXmlParser := new XmlParser(aString);
    result := lXmlParser.Parse();
    result.fXmlParser := lXmlParser;
    if (not aAllowBrokenDocument) and assigned(result.ErrorInfo) then result := nil;
  except
    on E: Exception do
      if aAllowBrokenDocument then begin
        if not assigned(result) then
          result := new XmlDocument;
        if not assigned(result.ErrorInfo) then
          result.ErrorInfo := new XmlErrorInfo(Message := E.Message);
      end;
  end;
end;

class method XmlDocument.FromBinary(aBinary: not nullable ImmutableBinary): not nullable XmlDocument;
begin
  result := XmlDocument.FromString(new String(aBinary.ToArray));
end;

class method XmlDocument.TryFromBinary(aBinary: not nullable ImmutableBinary): nullable XmlDocument;
begin
  result := XmlDocument.TryFromString(new String(aBinary.ToArray), false);
end;

class method XmlDocument.TryFromBinary(aBinary: not nullable ImmutableBinary; aAllowBrokenDocument: Boolean): nullable XmlDocument;
begin
  result := XmlDocument.TryFromString(new String(aBinary.ToArray), aAllowBrokenDocument);
end;

class method XmlDocument.WithRootElement(aElement: not nullable XmlElement): not nullable XmlDocument;
begin
  result := new XmlDocument(aElement);
end;

class method XmlDocument.WithRootElement(aName: not nullable String): not nullable XmlDocument;
begin
  result := new XmlDocument(new XmlElement withName(aName));
end;

method XmlDocument.ToString(): String;
begin
  result := ToString(false, new XmlFormattingOptions());
end;

method XmlDocument.ToString(aFormatOptions: XmlFormattingOptions): String;
begin
  result := ToString(true, aFormatOptions);
end;

method XmlDocument.ToString(aSaveFormatted: Boolean; aFormatOptions: XmlFormattingOptions): String;
begin
  fLineBreak := aFormatOptions.NewLineString;
  if (fLineBreak = nil) and (fXmlParser <> nil) then fLineBreak := fXmlParser.fLineBreak;
  var Sb := new StringBuilder;
  result:="";
  var lFormatInsideTags := false;
  if Version <> nil then begin
    Sb.Append('<?xml version="');
    Sb.Append(Version);
    Sb.Append('"');
  end;
  if (Encoding <> nil) then begin
    if Sb.Length = 0 then begin
      Sb.Append('<?xml version="');
      Sb.Append(fDefaultVersion);
      Sb.Append('"');
    end;
    Sb.Append(' encoding="');
    Sb.Append(Encoding);
    Sb.Append('"');
  end;
  if Standalone <> nil then begin
    if Sb.Length = 0 then begin
      Sb.Append('<?xml version="');
      Sb.Append(fDefaultVersion);
      Sb.Append('"');
    end;
    Sb.Append(' standalone="');
    Sb.Append(Standalone);
    Sb.Append('"');
  end;
  if Sb.Length > 0 then Sb.Append("?>");
  if not(aSaveFormatted) or
    (aSaveFormatted and
      (fXmlParser <> nil) and
      (
        (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) or
        (
          (fXmlParser.FormatOptions.WhitespaceStyle = aFormatOptions.WhitespaceStyle) and
          (fXmlParser.FormatOptions.NewLineForElements = aFormatOptions.NewLineForElements) and
          (fXmlParser.FormatOptions.Indentation = aFormatOptions.Indentation) and
          (fXmlParser.FormatOptions.NewLineSymbol = aFormatOptions.NewLineSymbol)
        )
      )
     ) then begin
    if aSaveFormatted and (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then begin
      aSaveFormatted := false;
      lFormatInsideTags := true;
    end;
    for each aNode in fNodes do
      Sb.Append(aNode.ToString(aSaveFormatted, lFormatInsideTags, aFormatOptions));
  end
  else begin
    if (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then lFormatInsideTags := true;
    if (Version <> nil) or (Encoding <> nil) or (Standalone <> nil) and aFormatOptions.NewLineForElements then Sb.Append(fLineBreak);
    for each aNode in fNodes do
      if (aNode.NodeType <> XmlNodeType.Text) or (length(XmlText(aNode).Value:Trim) >  0) then begin
        Sb.Append(aNode.ToString(aSaveFormatted, lFormatInsideTags, aFormatOptions));
        Sb.Append(fLineBreak);
      end;
  end;
  result := Sb.ToString;
  if not aFormatOptions.WriteNewLineAtEnd then
    result := result.TrimEnd();
end;

{$IF NOT WEBASSEMBLY}
method XmlDocument.SaveToFile(aFileName: not nullable File);
begin
  var lEncoding: String;
  if Encoding = nil then lEncoding := "utf-8"
  else lEncoding := Encoding;
  File.WriteText(aFileName.FullPath, self.ToString(false, new XmlFormattingOptions), RemObjects.Elements.RTL.Encoding.GetEncoding(lEncoding));
end;

method XmlDocument.SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);
begin
  var lStringValue := self.ToString(true, aFormatOptions);
  var lEncoding := coalesce(if assigned(Encoding) then RemObjects.Elements.RTL.Encoding.GetEncoding(Encoding), RemObjects.Elements.RTL.Encoding.UTF8);
  var lBytes := lEncoding.GetBytes(lStringValue) includeBOM(aFormatOptions.WriteBOM);
  File.WriteBytes(aFileName.FullPath, lBytes);
end;
{$ENDIF}

method XmlDocument.AddNode(aNode: not nullable XmlNode);
begin
  aNode.Document := self;
  if aNode.NodeType = XmlNodeType.DocumentType then
    if fWasDocType then
      raise new XmlException("Only one DOCTYPE node could be added")
    else begin
      fNodes.Insert(0, aNode);
      fWasDocType := true;
    end
  else
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

method XmlDocument.NearestOpenTag(aRow: Integer; aColumn: Integer; out aCursorPosition: XmlPositionKind): XmlElement;
begin
  if ((aRow < Root.NodeRange.StartLine) or ((aRow = Root.NodeRange.StartLine) and (aColumn <= Root.NodeRange.StartColumn))) or
  ((Root.NodeRange.EndLine <> 0) and ((aRow > Root.NodeRange.EndLine) or ((aRow = Root.NodeRange.EndLine) and (aColumn >= Root.NodeRange.EndColumn)))) or
   (assigned(ErrorInfo) and ((aRow > ErrorInfo.Row) or ((aRow = ErrorInfo.Row) and (aColumn > ErrorInfo.Column)))) then exit nil;
  result := Root;
//if (Root.StartLine <= aRow) and (Root.StartColumn <= aColumn) then result := Root;
  var lElement: XmlElement;
  while not (result.Elements.Count = 0) and (lElement <> result) do begin
    lElement := result;
    for each el in lElement.Elements do begin
      if (el.NodeRange.StartLine > aRow) or ((el.NodeRange.StartLine = aRow) and (el.NodeRange.StartColumn >= aColumn)) then
        break
      else
        result := el
    end;
    if (result.NodeRange.EndLine <> 0) and ((result.NodeRange.EndLine < aRow) or ((result.NodeRange.EndLine = aRow) and (result.NodeRange.EndColumn <= aColumn))) or
      ((result.IsEmpty) and (result.OpenTagEndLine <> 0) and ((result.OpenTagEndLine < aRow) or ((result.OpenTagEndLine = aRow) and (result.OpenTagEndColumn <= aColumn)))) then begin
      result := result.Parent;
      break;
    end;
  end;

  if (result.OpenTagEndLine = 0) or (aRow < result.OpenTagEndLine) or (aRow = result.OpenTagEndLine) and (aColumn < result.OpenTagEndColumn) then begin
    if result.IsEmpty then aCursorPosition := XmlPositionKind.SingleTag
    else aCursorPosition := XmlPositionKind.StartTag;
    exit;
  end;
  if (aRow > result.CloseTagRange.StartLine) or (aRow = result.CloseTagRange.StartLine) and (aColumn > result.CloseTagRange.StartColumn) then begin
      aCursorPosition := XmlPositionKind.EndTag;
      exit;
  end;
  aCursorPosition := XmlPositionKind.BetweenTags;
end;

method XmlDocument.GetCurrentIdentifier(aColumn: Integer; aStart: Integer; aPrefixLength: Integer; aName: String): String;
begin
      var lPos := aName.IndexOf('.');
      var lPosNext := lPos;
      while (lPosNext > 0) do begin
        if (aColumn > aStart+lPosNext) then begin
          lPos := lPosNext;
          lPosNext := aName.IndexOf('.', lPos+1)
        end
        else break;
      end;
      if lPos <> lPosNext then
        result := aName.Substring(aPrefixLength, lPos - aPrefixLength);
end;

method XmlDocument.GetCurrentCursorPosition(aRow: Integer; aColumn: Integer): XmlDocCurrentPosition;
begin
  var lPosition: XmlPositionKind;
  var lElement := NearestOpenTag(aRow, aColumn, out lPosition);
  result := new XmlDocCurrentPosition;
  if lElement = nil then exit;
  result.CurrentTagIndex := lElement.ChildIndex;
  if lElement.LocalName = "" then  begin
    result.CurrentTag := nil;
  end
  else begin
    result.CurrentTag := lElement;
  end;
  result.ParentTag := lElement.Parent;
  result.CurrentPosition := lPosition;
  if (lElement <> nil) and (lPosition in [XmlPositionKind.StartTag, XmlPositionKind.SingleTag, XmlPositionKind.EndTag]) then begin
    var lStart: Integer;
    if lPosition = XmlPositionKind.EndTag then lStart := lElement.CloseTagRange.StartColumn+2
    else lStart := lElement.NodeRange.StartColumn+1;
    var lPrefixLength: Integer := 0;
    if length(lElement.Namespace:Prefix) > 0 then begin
      lPrefixLength := length(lElement.Namespace.Prefix)+1;
      if (aColumn >= lStart + lPrefixLength) and ((lElement.LocalName = "") or (aColumn <= lStart+length(lElement.FullName))) then begin
        result.CurrentNamespace := lElement.Namespace;
        //exit;
      end;
    end;
    if lElement.LocalName.Contains('.') and (aColumn <= lStart+length(lElement.FullName)) then begin
      result.CurrentIdentifier := GetCurrentIdentifier(aColumn, lStart, lPrefixLength, lElement.FullName);
      exit;
    end;
    if result.CurrentNamespace <> nil then exit;
    if (lPosition = XmlPositionKind.EndTag) then exit result;
    if (aRow > lElement.NodeRange.StartLine) or (aColumn > lStart+lElement.FullName.Length) then result.CurrentPosition := XmlPositionKind.InsideTag;
    if (lElement.Attributes.Count > 0) then begin
      for each lAttr in lElement.attributes do begin
        if (aRow >= lAttr.NodeRange.StartLine) and (aColumn >=lAttr.NodeRange.StartColumn) and ((lAttr.NodeRange.EndLine = 0) or ((aRow <= lAttr.NodeRange.EndLine) and (aColumn <= lAttr.NodeRange.EndColumn))) then begin
          lStart := lAttr.NodeRange.StartColumn;
          if length(lAttr.Namespace:Prefix) > 0 then begin
            lPrefixLength := length(lAttr.Namespace.Prefix)+1;
            if (aColumn >= lStart + lPrefixLength) and ((lAttr.NodeRange.EndLine = 0) or (aColumn <= lStart+length(lAttr.FullName))) then
              result.CurrentNamespace := lAttr.Namespace;
          end;

          if lAttr.LocalName.Contains('.') and (aColumn <= lStart+length(lAttr.FullName)) then begin
            result.CurrentIdentifier := GetCurrentIdentifier(aColumn, lStart, lPrefixLength, lAttr.FullName);
            exit;
          end;
          if (lAttr.ValueRange.StartLine = lAttr.ValueRange.EndLine) then begin
            if (aRow = lAttr.ValueRange.StartLine) and (aColumn >= lAttr.ValueRange.StartColumn) and (aColumn <= lAttr.ValueRange.EndColumn) then begin
              result.CurrentPosition := XmlPositionKind.AttributeValue;
              result.CurrentAttribute := lAttr;
            end;
          end
          else begin
            if ((aRow = lAttr.ValueRange.StartLine) and (aColumn >= lAttr.ValueRange.StartColumn)) or
              ((aRow > lAttr.ValueRange.StartLine) and ((aRow < lAttr.ValueRange.EndLine) or ((aRow = lAttr.ValueRange.EndLine) and (aColumn <= lAttr.ValueRange.EndColumn)))) then begin
              result.CurrentPosition := XmlPositionKind.AttributeValue;
              result.CurrentAttribute := lAttr;
            end;
          end;
        end;

      end;
    end;
    if lElement.DefinedNamespaces.Count > 0 then begin
      for each lN in lElement.definedNamespaces do begin
        if ((aRow = lN.NodeRange.StartLine) and (aColumn >= lN.NodeRange.StartColumn+6) and (aColumn < lN.NodeRange.EndColumn)) or
          ((aRow > lN.NodeRange.StartLine) and ((aRow < lN.NodeRange.EndLine) or ((aRow = lN.NodeRange.EndLine) and (aColumn < lN.NodeRange.EndColumn)))) then
          result.CurrentPosition := XmlPositionKind.InsideXmlns;
      end;
    end;
  end;
end;

method XmlNode.CheckName(aName: String): Boolean;
begin
  if aName = "" then exit false;
  var t := new XmlTokenizer(aName);
  t.ParseName;
  if t.Value = aName then exit true;
end;

constructor XmlNode withParent(aParent: XmlElement);
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
  result := ToString(false, false);
end;

method XmlNode.ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions := new XmlFormattingOptions): String;
begin
  result := "";
  var Sb := new StringBuilder();
  var aPreserveExactStringsForUnchnagedValues := aFormatOptions.PreserveExactStringsForUnchnagedValues;
  case NodeType of
    XmlNodeType.Text: begin
      if (XmlText(self).originalRawValue <> nil) and aPreserveExactStringsForUnchnagedValues then Sb.Append(XmlText(self).originalRawValue)
      else Sb.Append(ConvertEntity(XmlText(self).Value, nil));
    end;
    XmlNodeType.Comment: begin
      Sb.Append("<!--");
      Sb.Append(XmlComment(self).Value);
      Sb.Append("-->");
    end;
    XmlNodeType.CData: begin
      Sb.Append("<![CDATA[");
      Sb.Append(XmlCData(self).Value);
      Sb.Append("]]>");
    end;
    XmlNodeType.ProcessingInstruction: begin
      Sb.Append("<?");
      Sb.Append(XmlProcessingInstruction(self).Target);
      var str := XmlProcessingInstruction(self).Data;
      if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
        Sb.Append(' ');
      Sb.Append(str);
      Sb.Append("?>");
    end;
    XmlNodeType.Element: Sb.Append( XmlElement(self).ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
    XmlNodeType.DocumentType: begin
      Sb.Append("<!DOCTYPE ");
      if XmlDocumentType(self).Name <> nil then Sb.Append(XmlDocumentType(self).Name);
      if XmlDocumentType(self).PublicId <> nil then begin
        Sb.Append(" PUBLIC ");
        var lAddQuotes := (XmlDocumentType(self).PublicId[0] <> "'") and (XmlDocumentType(self).PublicId[0] <> '"');
        if lAddQuotes then Sb.Append('"');
        Sb.Append(XmlDocumentType(self).PublicId);
        if lAddQuotes then Sb.Append('"');
        Sb.Append(' ');
        lAddQuotes := (XmlDocumentType(self).SystemId[0] <> "'") and (XmlDocumentType(self).SystemId[0] <> '"');
        if lAddQuotes then Sb.Append('"');
        Sb.Append(XmlDocumentType(self).SystemId);
        if lAddQuotes then Sb.Append('"');
      end
      else if XmlDocumentType(self).SystemId <> nil then begin
        Sb.Append(" SYSTEM ");
        var lAddQuotes := (XmlDocumentType(self).SystemId[0] <> "'") and (XmlDocumentType(self).SystemId[0] <> '"');
        if lAddQuotes then Sb.Append('"');
        Sb.Append(XmlDocumentType(self).SystemId);
        if lAddQuotes then Sb.Append('"');
      end;
      if XmlDocumentType(self).Declaration <> nil then begin
        Sb.Append(" [");
        Sb.Append(XmlDocumentType(self).Declaration);
        Sb.Append(']');
      end;
      Sb.Append('>');
    end;
  end;
  result := Sb.ToString();
end;

method XmlNode.UniqueCopy: not nullable XmlNode;
begin
   exit self;
end;

method XmlNode.CharIsWhitespace(C: String): Boolean;
begin
   exit (C = ' ') or (C = #13) or (C = #10) or (C = #9);
end;

method XmlNode.ConvertEntity(S: String; C: nullable Char): String;
begin
  if S = nil then exit nil;
  result := S.Replace('&',"&amp;");
  if (C = '''') then result := result.Replace('''',"&apos");
  if (C = '"') then result := result.Replace('"',"&quot;");
  if not(self is XmlAttribute) then begin
    result := result.Replace('>',"&gt;");
    result := result.Replace('<',"&lt;");
  end;

end;

{ XmlElement }

constructor XmlElement withParent(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Element;
end;

constructor XmlElement withParent(aParent: XmlElement) Indent(aIndent: String);
begin
  inherited constructor withParent(aParent);
  Indent := aIndent;
  fNodeType := XmlNodeType.Element;
end;

constructor XmlElement withName(aLocalName: not nullable String);
begin
  constructor withParent(nil);
  LocalName := aLocalName;
end;

constructor XmlElement withName(aLocalName: not nullable String) Value(aValue: not nullable String);
begin
  constructor withParent(nil);
  LocalName := aLocalName;
  Value := aValue;
end;


method XmlElement.ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  if aNamespace = nil then begin
    aNamespace := GetNamespaceFromName(var aLocalName);
    if assigned(aNamespace) then
      result := Elements.Where(c -> (c.LocalName = aLocalName) and (c.Namespace = aNamespace)) as not nullable
    else
      result := Elements.Where(c -> (c.LocalName = aLocalName) or (c.FullName = aLocalName)) as not nullable
  end
  else
    result := Elements.Where(c -> (c.LocalName = aLocalName) and (c.Namespace = aNamespace)) as not nullable
end;

method XmlElement.ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  result := Elements.Where(c -> c.Namespace = aNamespace) as not nullable;
end;

method XmlElement.FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
begin
  if assigned(aNamespace) then begin
    for each e in fElements do
      if (e.LocalName = aLocalName) and (e.Namespace = aNamespace) then
        exit e;
  end
  else begin
    for each e in fElements do
      if (e.LocalName = aLocalName) or (e.FullName = aLocalName) then
        exit e;

    aNamespace := GetNamespaceFromName( var aLocalName);
    if assigned(aNamespace) then
      result := FirstElementWithName(aLocalName, aNamespace);
  end;
end;

method XmlElement.AddAttribute(aAttribute: not nullable XmlAttribute);
begin
  //fAttributes.Add(aAttribute);
  fAttributesAndNamespaces.Add(aAttribute);
  aAttribute.fParent := self;
end;

method XmlElement.SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
begin
  if assigned(Attributes) then begin
    var lAttribute := GetAttributes.Where(a -> a.LocalName = aName).FirstOrDefault();
    if assigned(lAttribute) then lAttribute.Value := aValue
    else fAttributesAndNamespaces.Add(new XmlAttribute(aName, aNamespace, aValue, fParent := self));
  end
  else begin
    fAttributesAndNamespaces.Add( new XmlAttribute(aName, aNamespace, aValue, fParent := self));
  end;
end;

method XmlElement.RemoveAttribute(aAttribute: not nullable XmlAttribute);
begin
  //fAttributes.Remove(aAttribute);
  fAttributesAndNamespaces.Remove(aAttribute);
end;

method XmlElement.RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
begin
  var lAttribute := Attributes.Where(a -> (a.LocalName = aName) and (a.Namespace = aNamespace)).FirstOrDefault;
    if assigned(lAttribute) then begin
      //fAttributes.Remove(lAttribute);
      fAttributesAndNamespaces.Remove(lAttribute);
    end;
end;

method XmlElement.&Add(aData: not nullable sequence of Object);
begin
  for each lData in aData do begin
    case typeOf(lData) of
      XmlElement: AddElement(lData as XmlElement);
      XmlCData: &Add(lData as XmlCData);
      XmlComment: &Add(lData as XmlComment);
      XmlAttribute: AddAttribute(lData as XmlAttribute);
      String: &Add(lData as String);
      //Integer: &Add(lData as Integer);
      //Double: &Add(lData as Double);
      DateTime: &Add(lData as DateTime)
      else
        raise new Exception("Can not add data to XML element");
    end;
  end;
end;

method XmlElement.&Add(aData: not nullable sequence of XmlElement);
begin
  for each lData in aData do
    AddElement(lData);
end;

method XmlElement.Add(aElement: not nullable XmlElement);
begin
  AddElement(aElement);
end;

method XmlElement.&Add(aCData: not nullable XmlCData);
begin
  AddNode(aCData);
end;

method XmlElement.&Add(aComment: not nullable XmlComment);
begin
  AddNode(aComment);
end;

method XmlElement.&Add(aAttribute: not nullable XmlAttribute);
begin
  AddAttribute(aAttribute);
end;

method XmlElement.&Add(aString: not nullable String);
begin
  Value := Value + aString;
end;

//method XmlElement.&Add(aInteger: not nullable Integer);
//begin
  //Value := Value + aInteger.ToString;
//end;

//method XmlElement.&Add(aFloat: not nullable Double);
//begin
  //Value := Value + aFloat.ToString;
//end;

method XmlElement.&Add(aDateTime: not nullable DateTime);
begin
  Value := Value + aDateTime.ToString;
end;

method XmlElement.AddElement(aElement: not nullable XmlElement);
begin
  aElement.fParent := self;
  aElement.Document := Document;
  aElement.fChildIndex := Elements.Count;
  if self.PreserveSpace then aElement.PreserveSpace := true;
  if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then begin
    if fNodes.Count > 0 then begin
      var LastNodePos := fNodes.Count-1;
      if XmlText(fNodes.Item[LastNodePos]):Value = aElement.fParent.Indent then begin
        //It doesn't work on Island
        {fNodes.Insert(LastNodePos,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Insert(LastNodePos+1,aElement);
        fNodes.Insert(LastNodePos+2 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));}
        fNodes.Add(new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Add(aElement);
        fNodes.Add(new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
        fNodes.Add(new XmlText(self, Value := aElement.fParent.Indent));
        fNodes.RemoveAt(LastNodePos);
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
  //fIsEmpty := false;
end;

method XmlElement.AddElements(aElements: not nullable sequence of XmlElement);
begin
  for each e in aElements do
    AddElement(e);
end;

method XmlElement.AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
begin
  aElement.fChildIndex := aIndex;
  if (fNodes.Count = 0)  and (aIndex = 0) then AddElement(aElement)
  else begin
    aElement.fParent := self;
    aElement.Document := Document;
    if PreserveSpace then aElement.PreserveSpace := true;
    fElements.Insert(aIndex, aElement);
    for i: Integer := aIndex+1 to fElements.Count -1 do
      fElements[i].FChildIndex := fElements[i].fChildIndex +1;
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
    if lFormat and (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value:StartsWith(aElement.fParent.Indent)) then begin
      fNodes.Insert(i-1,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
      fNodes.Insert(i,aElement);
      fNodes.Insert(i+1 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
    end
    else fNodes.Insert(i,aElement);
  end;
  //fIsEmpty := false;
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
begin
  result := new XmlElement withParent(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result);
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
begin
  result := new XmlElement withParent(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result) atIndex(aIndex);
end;

method XmlElement.RemoveElement(aElement: not nullable XmlElement);
begin
  for i: Integer := aElement.ChildIndex+1 to fElements.count -1 do
    fElements[i].fChildIndex := fElements[i].fChildIndex-1;
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
      (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value:StartsWith(self.Document.fXmlParser.FormatOptions.Indentation) and
      (fNodes.Item[i+1].NodeType = XmlNodeType.Text) and (XmlText(fNodes.Item[i+1]).Value:EndsWith(#10))) then begin
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
    end
    else fNodes.Remove(aElement);
  end
  else fNodes.Remove(aElement);
 // if fNodes.count = 0 then fIsEmpty := true;
  aElement.fParent := nil;
end;

method XmlElement.RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
begin
  for each e in ElementsWithName(aName, aNamespace).ToList() do
    RemoveElement(e);
end;

method XmlElement.RemoveAllElements;
begin
  for each e in Elements.ToList() do
    RemoveElement(e);
end;

method XmlElement.ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
begin
  var i := 0;
  aNewElement.fChildIndex := aExistingElement.ChildIndex;
  aNewElement.fParent := self;
  aNewElement.Document := Document;
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
  //fIsEmpty := false;
  //if (aNode.NodeType = XmlNodeType.Text) and (XmlText(aNode).Value = "") then exit;
  fNodes.Add(aNode);
end;

method XmlElement.GetLocalName: not nullable String;
begin
  result := fLocalName as not nullable;
  //result := fLocalName.Trim as not nullable;
end;

method XmlElement.GetFullName: not nullable String;
begin
  result := "";
  if length(&Namespace:Prefix) > 0 then result := &Namespace.Prefix+':';
  result := result + LocalName;
end;

method XmlElement.SetLocalName(aValue: not nullable String);
begin
  if (not CheckName(aValue) and not(aValue.Contains("[ERROR]"))) then
    raise new Exception('"{0}" is not valid XmlElement name', aValue);
  fLocalName := aValue;
  EndTagName := nil;
  WSAfterName := nil;
end;

method XmlElement.GetNamespace: nullable XmlNamespace;
begin
  result := fNamespace;
  result := coalesce(fNamespace, fDefaultNamespace);
  if (result = nil) and (self.Parent <> nil) then result := XmlElement(self.Parent).DefaultNamespace;
end;

method XmlElement.SetNamespace(aNamespace: XmlNamespace);
begin
  if assigned(fNamespace) then fAttributesAndNamespaces.Remove(fNamespace);
  if assigned(aNamespace) then begin
    var elem := self;
    var lAdd := true;
    while assigned(elem) do begin
      if elem.fAttributesAndNamespaces.Contains(aNamespace) then begin
        lAdd := false;
        break;
      end;
      elem := elem.Parent;
    end;
    //aNamespace.Parent := self;
    if lAdd then  fAttributesAndNamespaces.Add(aNamespace);
  end;
  fNamespace := aNamespace;
end;

method XmlElement.GetDefaultNamespace: XmlNamespace;
begin
  if Parent = nil then result := fDefaultNamespace
  else result := coalesce(fDefaultNamespace, XmlElement(Parent).DefaultNamespace);
end;

{method XmlElement.GetValue: nullable String;
begin
  result := "";
  for each lNode in Nodes do begin
    if result <> "" then result := result+" ";
    if lNode.NodeType = XmlNodeType.Text then result := result+XmlText(lNode).Value
    else if lNode.NodeType = XmlNodeType.Element then result := result+XmlElement(lNode).GetValue;
  end;
end;}

method XmlElement.GetValue(aWithNested: Boolean): nullable String;
begin
  result := "";
  for each lNode in Nodes do begin
    if (lNode.NodeType = XmlNodeType.Text) and ((PreserveSpace) or (length(XmlText(lNode).Value:Trim) > 0)) then begin
      if (result <> "") and not result[result.length-1].IsWhitespace and (length(XmlText(lNode).Value) > 0) and not XmlText(lNode).Value[0].IsWhitespace then
        result := result+" ";
      result := result+XmlText(lNode).Value
    end
    else if lNode.NodeType = XmlNodeType.Element then begin
      if aWithNested then begin
        var lValue := XmlElement(lNode).GetValue(true);
        if (result <> "") and not result[result.length-1].IsWhitespace and (length(lValue) > 0) and not lValue[0].IsWhitespace then
          result := result+" ";
        result := result+lValue;
      end;
    end;
  end
end;

method XmlElement.SetValue(aValue: nullable String);
begin
  fNodes.RemoveAll;
  AddNode(new XmlText(self, Value := aValue));
end;

method XmlElement.SetPreserveSpace(aPreserveSpace: Boolean);
begin
  fPreserveSpace := aPreserveSpace;
  var lPreserveSpaceAttr := GetAttribute("xml:space");
  if aPreserveSpace then begin
    if assigned(lPreserveSpaceAttr) then
      lPreserveSpaceAttr.Value := "preserve"
    else if not assigned(Parent) or not Parent.PreserveSpace then begin
      lPreserveSpaceAttr := new XmlAttribute withParent(self);
      lPreserveSpaceAttr.LocalName := "space";
      lPreserveSpaceAttr.Namespace := new XmlNamespace("xml", XmlConsts.XML_NAMESPACE_URL);
      lPreserveSpaceAttr.Value := "preserve";
      lPreserveSpaceAttr.Document := Document;
      AddAttribute(lPreserveSpaceAttr)
    end
  end
  else if assigned(lPreserveSpaceAttr) and (lPreserveSpaceAttr.Value = "preserve") then
    RemoveAttribute(lPreserveSpaceAttr);
end;

method XmlElement.GetAttributes: not nullable sequence of XmlAttribute;
begin
  {$IF TOFFEEV2}
  raise new NotImplementedException("Not implemented for ToffeV2 right now");
  {$ELSE}
  result := fAttributesAndNamespaces.Where(a -> a.NodeType = XmlNodeType.Attribute).Select(x -> x as XmlAttribute) as not nullable;
  {$ENDIF}
end;

method XmlElement.GetAttribute(aName: not nullable String): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> a.LocalName = aName).FirstOrDefault;
  if result = nil then begin
    var lPrefixPos := aName.IndexOf(':');
    if (lPrefixPos > 0) then begin
      var lNamespaceString := aName.Substring(0, lPrefixPos);

      var lNamespace: XmlNamespace;
      if lNamespaceString = "xml" then
        lNamespace := new XmlNamespace("xml", XmlConsts.XML_NAMESPACE_URL);
      var lElement := self;
      while (lNamespace = nil) and (lElement <> nil) do begin
        lNamespace:= lElement.&Namespace[lNamespaceString];
        lElement := XmlElement(lElement.Parent);
      end;
      if assigned(lNamespace) then
        result := GetAttribute(aName.Substring(lPrefixPos+1, aName.Length-lPrefixPos-1), lNamespace);
    end;
  end;
end;

method XmlElement.GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> (a.LocalName = aName) and
    (((aNamespace = nil) and (a.Namespace = nil)) or
      ((aNamespace <> nil) and (a.Namespace.Prefix = aNamespace.Prefix) and (a.Namespace.Uri = aNamespace.Uri)))).FirstOrDefault;
end;

method XmlElement.GetElements: not nullable sequence of XmlElement;
begin
  result := fElements as not nullable;
end;

method XmlElement.GetNamespaces: not nullable sequence of XmlNamespace;
begin
  {$IF TOFFEEV2}
  raise new NotImplementedException("Not implemented for ToffeV2 right now");
  {$ELSE}
  result := fAttributesAndNamespaces.Where(a -> a.NodeType = XmlNodeType.Namespace).Select(x -> x as XmlNamespace) as not nullable;
  {$ENDIF}
end;

method XmlElement.GetNamespaceByUri(aUri: String): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Uri = aUri).FirstOrDefault;
end;

method XmlElement.GetNamespace(aPrefix: String): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
end;

method XmlElement.AddNamespace(aNamespace: not nullable XmlNamespace);
begin
  if GetNamespace(aNamespace.Prefix) = nil then begin
    //fNamespaces.Add(aNamespace);
    aNamespace.fParent := self;
    fAttributesAndNamespaces.Add(aNamespace);
    if (aNamespace.Prefix = nil) or (aNamespace.Prefix = "") then fDefaultNamespace := aNamespace;
  end
  else if aNamespace.Prefix=nil then raise new Exception("Duplicate namespace xmlns")
    else  raise new Exception("Duplicate namespace xmlns:"+aNamespace.Prefix);
end;

method XmlElement.AddNamespace(aPrefix: nullable String; aUri: not nullable String): XmlNamespace;
begin
  result := new XmlNamespace(aPrefix, aUri, fParent := self);
  AddNamespace(result);
end;

method XmlElement.RemoveNamespace(aNamespace: not nullable XmlNamespace);
begin
  //fNamespaces.Remove(aNamespace);
  fAttributesAndNamespaces.Remove(aNamespace);
end;

method XmlElement.RemoveNamespace(aPrefix: not nullable String);
begin
  var lNamespace := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
  //fNamespaces.Remove(lNamespace);
  fAttributesAndNamespaces.Remove(lNamespace);
end;

method xmlElement.ToString(): String;
begin
  result := ToString(false, false);
end;

method XmlElement.ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions): String;
method GetEmptyLines (aWS: String; aLineBreak: String): String;
begin
  result := "";
  if not assigned(aWS) then exit result;
  var pos := aWS.IndexOf(coalesce(Document:fLineBreak, Environment.LineBreak), 0);
  while (pos > -1) and (pos < length(aWS)-1) do begin
    pos := aWS.IndexOf(coalesce(Document:fLineBreak, Environment.LineBreak), pos+1);
    if (pos > -1) then result := result + aLineBreak;//Document.fLineBreak;
  end;
end;
begin
  var strSb := new StringBuilder();
  var Sb := new StringBuilder("<");
  Sb.Append(FullName);
  if assigned(WSAfterName) then Sb.Append(WSAfterName);
  var lLineBreak := coalesce(aFormatOptions.NewLineString, Document:fLineBreak, Environment.LineBreak);
  var lFormat := false;
  var indent : String := nil;
  var startStr: String := "";
  if aSaveFormatted and (aFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and not PreserveSpace then begin
    if aFormatOptions.NewLineForElements  then lFormat := true;
    if lFormat then begin
      var n := self;
      var indentSb := new StringBuilder();
      while (n.Parent <> nil) do begin
        indentSb.Append(aFormatOptions.Indentation);
        n := n.Parent;
      end;
      indent := indentSb.ToString();
    end;
  end;
  if (aFormatInsideTags and (aFormatOptions.PreserveLinebreaksForAttributes or aFormatOptions.NewLineForAttributes)) then begin
    var startStrSb := new StringBuilder();
    for i:Integer := 0 to NodeRange.StartColumn-1 do
      startStrSb.Append(' ');
    startStr := StartStrSb.ToString();
  end;
  for each attr in fAttributesAndNamespaces do begin
    var lWSleft: String := nil;
    var lWSright: String := nil;

    if attr.NodeType = XmlNodeType.Attribute then begin
      lWSleft := XmlAttribute(attr).WSleft;
      lWSright := XmlAttribute(attr).WSright;
    end else if attr.NodeType = XmlNodeType.Namespace then begin
      lWSleft := XmlNamespace(attr).WSleft;
      lWSright := XmlNamespace(attr).WSright;
    end;
    strSb.Clear();// := "";
    var lEmptyLinesleft := "";
    var lEmptyLinesright := "";
    if (aFormatInsideTags) and (aFormatOptions.PreserveEmptyLines) then begin
      if aFormatOptions.PreserveEmptyLines then begin
        lEmptyLinesleft := GetEmptyLines(lWSleft, lLineBreak);
        lEmptyLinesright := GetEmptyLines(lWSright, lLineBreak);
      end;
    end;
    if not(aFormatInsideTags) and (lWSleft <> nil) then strSb.Append(lWSleft);
    if (aFormatInsideTags and ((aFormatOptions.PreserveEmptyLines and (lEmptyLinesleft <> "")) or (aFormatOptions.PreserveLinebreaksForAttributes) and (lWSleft <> nil) and lWSleft.Contains(lLineBreak)) or (aFormatOptions.NewLineForAttributes))  then
      if (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (indent = nil) then begin
        strSb.Append(lLineBreak);
        strSb.Append(lEmptyLinesleft);
        strSb.append(startStr);
        strSb.Append(aFormatOptions.Indentation);
      end
      else if (aFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
        strSb.Append(lLineBreak);
        strSb.Append(lEmptyLinesleft);
        strSb.Append(indent);
        strSb.Append(aFormatOptions.Indentation);
      end;
    if attr.NodeType = XmlNodeType.Attribute then
      strSb.Append(XmlAttribute(attr).ToString(aFormatInsideTags, aFormatOptions))
    else
      strSb.Append(XmlNamespace(attr).ToString(aFormatInsideTags, aFormatOptions));
    if not (aFormatInsideTags) and (lWSright <> nil) then strSb.Append(lWSright);
    if (aFormatInsideTags and (((aFormatOptions.PreserveLinebreaksForAttributes) and (lWSright <> nil) and lWSright.Contains(lLineBreak))) or (aFormatOptions.PreserveEmptyLines and (lEmptyLinesright <> ""))) then
      if (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (indent = nil) then begin
        strSb.Append(lLineBreak);
        strSb.Append(lEmptyLinesright);
        strSb.Append(startStr);
        strSb.Append(aFormatOptions.Indentation);
      end
      else if (aFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
        strSb.Append(lLineBreak);
        strSb.Append(lEmptyLinesright);
        strSb.Append(indent);
        strSb.Append(aFormatOptions.Indentation);
      end;
    var str := strSb.ToString();
    if not(CharIsWhitespace(Sb.Substring(Sb.Length-1,1))) and not(CharIsWhitespace(str[0])) then
      Sb.Append(' ');
    Sb.Append(str);
  end;
  var lOnlyWhitespaceInside := fNodes.Where(a -> (a.NodeType =NodeType.Text) and (XmlText(a).IsWhitespaceValue)).Count = fNodes.Count;
  if IsEmpty or (aFormatInsideTags and lOnlyWhitespaceInside) then begin
    if (Document <> nil) then begin
      if (aFormatInsideTags) then begin
        if (aFormatOptions.EmptyTagSyle <> XmlTagStyle.PreferOpenAndCloseTag) and aFormatOptions.SpaceBeforeSlashInEmptyTags and
          not (CharIsWhitespace(Sb.Substring(Sb.Length-1, 1))) then
            Sb.Append(' ');
        Sb.Append("/>");
      end
      else begin
        if (Document.fXmlParser <> nil) and (Document.fXmlParser.FormatOptions.SpaceBeforeSlashInEmptyTags) and
          not (CharIsWhitespace(Sb.Substring(Sb.Length-1,1))) then
            Sb.Append(' ');
        Sb.Append("/>");
      end;
    end else
      Sb.Append("/>");
  end else
    {if fNodes.count > 0 then }Sb.Append('>');
  /********/
  var CloseTagIndent := false;
  var lEmptyLines := "";
  if aSaveFormatted and (aFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText)  and not PreserveSpace then begin
    var WSValue: String := "";
    var WasText := false;
    var AddNewLine := lFormat;
    for each aNode in fNodes do begin
      if (aNode.NodeType = XmlNodeType.Text) then
        if (length(XmlText(aNode).Value:Trim) > 0) then begin
          AddNewLine := lFormat;
          lEmptyLines := "";
          if (aFormatInsideTags and aFormatOptions.NewLineForAttributes) then begin
            Sb.Append(lLineBreak);
            Sb.Append(indent);
            Sb.Append(aFormatOptions.Indentation);
            Sb.Append(aNode.toString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
            Sb.Append(lLineBreak);
            Sb.Append(indent);
          end
          else begin
            WasText := true;
            AddNewLine := lFormat;
            Sb.Append(WSValue);
            Sb.Append(aNode.ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
            WSValue := "";
          end;
        end
        else begin
          AddNewLine := lFormat;
          WSValue := XmlText(aNode).Value;
          if aFormatOptions.PreserveEmptyLines and not WasText then begin
            lEmptyLines := GetEmptyLines(WSValue, lLineBreak);
          end;
          {var lEmptyLines := "";
          if aFormatOptions.PreserveEmptyLines then begin
            lEmptyLines := GetEmptyLines(XmlText(aNode).Value);
          end;}
          if not aFormatOptions.NewLineForElements then Sb.Append(aNode.ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions))
          else if WasText then begin
            Sb.Append(WSValue);
            if WSValue.IndexOf(lLineBreak) > -1 then AddNewLine := false;
          end;
        end;
      if (aNode.NodeType <> XmlNodeType.Text) then begin
        WasText := false;
        if lFormat then begin
          CloseTagIndent := true;
          Sb.Append(lEmptyLines);
          if AddNewLine then begin
            Sb.Append(lLineBreak);
            Sb.Append(indent);
            Sb.append(aFormatOptions.Indentation);
          end;
          Sb.Append(aNode.ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
        end
        else Sb.Append(aNode.ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
        lEmptyLines := "";
        AddNewLine := lFormat;
      end;
    end;
  end
  /******/
  else
    for each aNode in fNodes do
      Sb.Append(aNode.ToString(aSaveFormatted, aFormatInsideTags, aFormatOptions));
  if (IsEmpty = false) and (not aFormatInsideTags or (aFormatInsideTags and not lOnlyWhitespaceInside)) then begin
    if (fNodes.Count = 0) and (aFormatInsideTags) and (aFormatOptions.EmptyTagSyle = XmlTagStyle.PreferSingleTag) then
      if aFormatOptions.SpaceBeforeSlashInEmptyTags and not (CharIsWhitespace(Sb.Substring(Sb.Length-1,1))) then
        Sb.Append(" />")
      else
        Sb.Append('>')
    else begin
      if fNodes.Count = 0 then Sb.Append('>');
      if lFormat and aFormatOptions.PreserveEmptyLines then
        Sb.Append(lEmptyLines);
      if lFormat and (CloseTagIndent or (lEmptyLines <> "")) then begin
        Sb.Append(lLineBreak);
        Sb.Append(indent);
      end;
      Sb.Append("</");
      if EndTagName <> nil then begin
        Sb.Append(EndTagName);
        Sb.Append('>');
      end
      else begin
        if (&Namespace <> nil) and (&Namespace.Prefix <> "") and (&Namespace.Prefix <> nil) then begin
          Sb.Append(&Namespace.Prefix);
          Sb.Append(':');
        end;
        Sb.Append(LocalName);
        Sb.Append('>');
      end;
    end;
  end;
  result := Sb.ToString();
end;

method XmlElement.GetNamespaceFromName(var aName: String): nullable XmlNamespace;
begin
  var lNamespace: XmlNamespace;
  var lBracePos := aName.IndexOf('{');
  if (lBracePos = 0) then begin
    var lClosingBracePos := aName.IndexOf('}');
    if lClosingBracePos > lBracePos then begin
      lNamespace := &Namespace[aName.Substring(1, lClosingBracePos-1)];
      if assigned(lNamespace) then
        aName := aName.Substring(lClosingBracePos+1, aName.Length-lClosingBracePos-1)
    end;
  end;
  exit lNamespace;
end;

method XmlElement.UniqueCopy: not nullable XmlNode;
begin
  var res := new XmlElement withName(LocalName) as not nullable;
  res.Namespace := &Namespace;
  for each a in fAttributesAndNamespaces do begin
    var uc := a.UniqueCopy();
    uc.fParent := res;
    res.fAttributesAndNamespaces.Add(uc);
  end;
  for each n in Nodes do begin
    var uc := n.UniqueCopy;
    uc.fParent := res;
    res.fNodes.Add(uc);
    if n.NodeType = XmlNodeType.Element then
        res.fElements.Add(uc as XmlElement);
  end;
  res.EndTagName := EndTagName;
  res.fDefaultNamespace := DefaultNamespace;
  res.fChildIndex := ChildIndex;
  res.PreserveSpace  := PreserveSpace;
  exit res;
end;

{ XmlAttribute }

constructor XmlAttribute withParent(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Attribute;
end;

constructor XmlAttribute(aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
begin
  inherited constructor;
  LocalName := aLocalName;
  fNamespace := aNamespace;
  setValue(aValue);
  fNodeType := XmlNodeType.Attribute;
end;

method XmlAttribute.GetLocalName: not nullable String;
begin
  //result := fLocalName as not nullable;
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
  result := fValue as not nullable;
end;

method XmlAttribute.GetFullName: not nullable String;
begin
  result := "";
  if length(&Namespace:Prefix) > 0 then result := &Namespace.Prefix+':';
  result := result + LocalName;
end;

method XmlAttribute.SetLocalName(aValue: not nullable String);
begin
  if not CheckName(aValue) and not(aValue.Contains("[ERROR]")) then
    raise new Exception('"{0}" is not a valid XMLAttribute name', aValue);
  fLocalName := aValue;
end;

method XmlAttribute.SetValue(aValue: not nullable String);
begin
  originalRawValue := nil;
  fValue := aValue;
end;

method XmlAttribute.ToString(): String;
begin
  result := ToString(false);
end;

method XmlAttribute.ToString(aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions := new XmlFormattingOptions): String;
begin
  result := "";
  var Sb := new StringBuilder();
  var aPreserveExactStringsForUnchnagedValues := aFormatOptions.PreserveExactStringsForUnchnagedValues;
  if &Namespace<>nil then begin
    Sb.Append(&Namespace.Prefix);
    Sb.Append(':');
  end;
  Sb.Append(LocalName);
  if not(aFormatInsideTags) and (innerWSleft <> nil) then Sb.Append(innerWSleft);
  Sb.Append('=');
  if not(aFormatInsideTags) and (innerWSright <> nil) then Sb.Append(innerWSright);
  Sb.Append(QuoteChar);
  if (originalRawValue <> nil) and (aPreserveExactStringsForUnchnagedValues) then Sb.Append(originalRawValue)
  else Sb.Append(ConvertEntity(Value, QuoteChar));
  Sb.Append(QuoteChar);
  result := Sb.ToString();
end;

method XmlAttribute.UniqueCopy: not nullable XmlNode;
begin
  result := new XmlAttribute(LocalName, &Namespace, Value,
    innerWSleft := innerWSleft, innerWSright := innerWSright, QuoteChar := QuoteChar, originalRawValue := originalRawValue, WSleft := WSleft, WSright := WSright, Indent := Indent);
end;

{ XmlNamespace}
constructor XmlNamespace withParent(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Namespace;
end;

constructor XmlNamespace(aPrefix: String; aUri: not nullable String);
begin
  inherited constructor;
  Prefix := aPrefix;
  Uri := aUri;
  fNodeType := XmlNodeType.Namespace;
end;

method XmlNamespace.GetPrefix: String;
begin
  if fPrefix = nil then exit nil
  else exit fPrefix.Trim;
end;

method XmlNamespace.SetPrefix(aPrefix: String);
begin
  fPrefix := aPrefix;
end;


method XmlNamespace.ToString(): String;
begin
  result := ToString(false, new XmlFormattingOptions);
end;

method XmlNamespace.ToString(aFormatInsideTags: Boolean; aFormatOptions: XmlFormattingOptions): String;
begin
  var Sb := new StringBuilder("xmlns");
  if (Prefix <> "") and (Prefix <> nil) then begin
    Sb.Append(':');
    Sb.Append(Prefix);
  end;
  if not(aFormatInsideTags) and (innerWSleft <> nil) then Sb.Append(innerWSleft);
  Sb.Append('=');
  if not(aFormatInsideTags) and (innerWSright <> nil) then Sb.Append(innerWSright);
  Sb.Append(QuoteChar);
  if assigned(Uri) then Sb.Append(Uri);
  Sb.Append(QuoteChar);
  result := Sb.ToString();
end;

method XmlNamespace.UniqueCopy: not nullable XmlNode;
begin
  result := self;
  //new XmlNamespace(Prefix, Uri, innerWSleft := innerWSleft, innerWSright := innerWSright, QuoteChar := QuoteChar, Indent := Indent);
end;

{XmlComment}
constructor XmlComment(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Comment;
end;

{XmlCData}
constructor XmlCData(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.CData;
end;

{XmlText}

constructor XmlText(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Text;
end;

method XmlText.GetValue: String;
begin
  result := fValue;
end;

method XmlText.SetValue(aValue: String);
begin
  originalRawValue := nil;
  fValue := aValue;
end;

{XmlProcessingInstructions}

constructor XmlProcessingInstruction(aParent: XmlElement);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.ProcessingInstruction;
end;

constructor XmlDocumentType();
begin
  fNodeType := XmlNodeType.DocumentType;
end;

end.