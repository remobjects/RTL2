namespace RemObjects.Elements.RTL;

interface

type
  XmlParser = public class
  private
    Tokenizer: XmlTokenizer;
    method Expected(params Values: array of XmlTokenKind);
    method ReadAttribute(aParent: XmlElement; aWS: String := ""; aIndent: String := ""): XmlNode;
    method ReadElement(aParent: XmlElement; aIndent: String := nil): XmlElement;
    method GetNamespaceForPrefix(aPrefix:not nullable String; aParent: XmlElement): XmlNamespace;
    method ReadProcessingInstruction(aParent: XmlElement): XmlProcessingInstruction;
  assembly
    fLineBreak: String;
  public
    constructor (XmlString: String);
    constructor (XmlString: String; aOptions: XmlFormattingOptions);
    method Parse: XmlDocument;
    FormatOptions: XmlFormattingOptions;
  end;

  XmlConsts = assembly static class
  public
    const TAG_DECL_OPEN: String =  "<?xml";
    const TAG_DECL_CLOSE: String = "?>";
  end;

  XmlTokenKind = public enum(
    BOF,
    EOF,
    Whitespace,
    DeclarationStart,
    DeclarationEnd,
    ProcessingInstruction,
    TagOpen,
    TagClose,
    EmptyElementEnd,
    TagElementEnd,
    ElementName,
    AttributeValue,
    SymbolData,
    Comment,
    CData,
    SlashSymbol,
    AttributeSeparator,
    SyntaxError);

  XmlWhitespaceStyle = public enum(
   PreserveAllWhitespace,  // even inside element tags, such as between attributes
   PreserveWhitespaceOutsideElements, // only outside of element tags
   PreserveWhitespaceAroundText); // only for text non-empty nodes

  XmlTagStyle = public enum(
    Preserve,
    PreferOpenAndCloseTag,
    PreferSingleTag);

  XmlNewLineSymbol = public enum(
    Preserve,
    PlatformDefault,
    LF,
    CRLF);

  XmlFormattingOptions = public record
  public
    WhitespaceStyle: XmlWhitespaceStyle := XmlWhitespaceStyle.PreserveAllWhitespace;
    EmptyTagSyle: XmlTagStyle := XmlTagStyle.Preserve;
    SpaceBeforeSlashInEmptyTags: Boolean := false;
    Indentation: String := #9;
    NewLineForElements: Boolean := true;
    NewLineForAttributes: Boolean := false;
    NewLineSymbol: XmlNewLineSymbol  := XmlNewLineSymbol.PlatformDefault;
  end;

implementation

constructor XmlParser( XmlString: String);
begin
  Tokenizer := new XmlTokenizer(XmlString, true);
  FormatOptions := new XmlFormattingOptions;
  case FormatOptions.NewLineSymbol of
    XmlNewLineSymbol.PlatformDefault, XmlNewLineSymbol.Preserve: fLineBreak := Environment.LineBreak;
    XmlNewLineSymbol.LF: fLineBreak := #10;
    XmlNewLineSymbol.CRLF: fLineBreak := #13#10;

  end;
end;

constructor XmlParser(XmlString: String; aOptions: XmlFormattingOptions);
begin
  Tokenizer := new XmlTokenizer(XmlString, true);
  FormatOptions := aOptions;
  case FormatOptions.NewLineSymbol of
    XmlNewLineSymbol.PlatformDefault, XmlNewLineSymbol.Preserve: fLineBreak := Environment.LineBreak;
    XmlNewLineSymbol.LF: fLineBreak := #10;
    XmlNewLineSymbol.CRLF: fLineBreak := #13#10;
  end;

end;

method XmlParser.Parse: XmlDocument;
begin
  var WS: String :="";
  Tokenizer.Next;
  result := new XmlDocument();
  result.fXmlParser := self;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
      result.AddNode(new XmlText(Value := Tokenizer.Value));
    Tokenizer.Next;
  end;
  Expected(XmlTokenKind.DeclarationStart, XmlTokenKind.ProcessingInstruction, XmlTokenKind.TagOpen);

  {result.Version := "1.0";
  result.Encoding := "utf-8";
  result.Standalone := "no";}
  if Tokenizer.Token = XmlTokenKind.DeclarationStart then begin
    Tokenizer.Next;
    Expected(XmlTokenKind.Whitespace);
    if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
    Tokenizer.Next;
    Expected(XmlTokenKind.ElementName);
    var aXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
    if aXmlAttr.LocalName = "version" then begin
      //check version
      if (aXmlAttr.Value.IndexOf("1.") <> 0) or (aXmlAttr.Value.Length <> 3) or
        ((aXmlAttr.Value.Chars[2] < '0') or (aXmlAttr.Value.Chars[2] > '9')) then
        raise new XmlException ("Unknown XML version", aXmlAttr.EndLine, aXmlAttr.EndColumn);
      result.Version := aXmlAttr.Value;
      Expected(XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName);
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if ((Tokenizer.Value <> "encoding") and (Tokenizer.Value <> "standalone")) then
          raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        aXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
      end;
    end;
    if aXmlAttr.LocalName = "encoding" then begin
      //check encoding
      try
        Encoding.GetEncoding(aXmlAttr.Value);
      except
        raise new XmlException ("Unknown encoding", aXmlAttr.EndLine, aXmlAttr.EndColumn);
      end;
      result.Encoding := aXmlAttr.Value;
      Expected(XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName);
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if (Tokenizer.Value <> "standalone") then raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        aXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
      end;
    end;
    if aXmlAttr.LocalName = "standalone" then begin
      //check yes/no
      if (aXmlAttr.Value.Trim <> "yes") and (aXmlAttr.Value.Trim <>"no") then
        raise new XmlException("Unknown 'standalone' value", aXmlAttr.EndLine, aXmlAttr.EndColumn);
      result.Standalone := aXmlAttr.Value;
    end;
    Expected(XmlTokenKind.DeclarationEnd);
    Tokenizer.Next;

  end;
  Expected(XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction);
  var lFormat := false;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
    lFormat := true;
  if lFormat and (result.Nodes.Count = 0) and (result.Version <> nil) then
    result.AddNode(new XmlText(Value := fLineBreak));
  while Tokenizer.Token <> XmlTokenKind.TagOpen do begin
    Expected(XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction);
    {if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and
      (Tokenizer.Token <> XmlTokenKind.Whitespace) then begin //or ((result.Nodes.count=0) and (result.Version <> nil)) then begin
      result.AddNode(new XmlText(Value := fLineBreak));
    end;}
    case Tokenizer.Token of
      XmlTokenKind.Whitespace: begin
        if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
          result.AddNode(new XmlText(Value := Tokenizer.Value));
        Tokenizer.Next;
      end;
      XmlTokenKind.Comment: begin
        result.AddNode(new XmlComment(Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));
        Tokenizer.Next;
        var lCount := result.Nodes.Count-1;
        result.Nodes[lCount].EndLine := Tokenizer.Row;
        result.Nodes[lCount].EndColumn := Tokenizer.Column-1;
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;//add node
      XmlTokenKind.ProcessingInstruction : begin
        result.AddNode(ReadProcessingInstruction(nil));
        Tokenizer.Next;//add node
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;
    end;
  end;
  Expected(XmlTokenKind.TagOpen);
  var aIndent: String;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
    aIndent := "";
    //result.AddNode(new XmlText(Value := fLineBreak));
  end;

  result.Root := ReadElement(nil,aIndent);
  while Tokenizer.Token <> XmlTokenKind.EOF do begin
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd);
    Tokenizer.Next;
    if (Tokenizer.Token = XmlTokenKind.Whitespace) then Tokenizer.Next;
    Expected(XmlTokenKind.EOF, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction);
    case Tokenizer.Token of
      XmlTokenKind.Comment: result.AddNode(new XmlComment(Value := Tokenizer.Value));
      XmlTokenKind.ProcessingInstruction: result.AddNode(ReadProcessingInstruction(nil));
    end;
    Tokenizer.Next;
  end;
end;

method XmlParser.Expected(params Values: array of XmlTokenKind);
begin
  for Item in Values do
    if Tokenizer.Token = Item then
      exit;
  case Tokenizer.Token of
    XmlTokenKind.SyntaxError: raise new XmlException (Tokenizer.Value, Tokenizer.Row, Tokenizer.Column);
    XmlTokenKind.EOF: raise new XmlException ("Unexpected end of file", Tokenizer.Row,Tokenizer.Column);
    else raise new XmlException('Unexpected token. '+ Values[0].ToString + ' is expected but '+Tokenizer.Token.ToString+" found", Tokenizer.Row, Tokenizer.Column);
  end;
end;

method XmlParser.ReadAttribute(aParent: XmlElement; aWS: String; aIndent:String): XmlNode;
begin
  var aLocalName, aValue, aWSName, aWSValue: String;
  var lStartRow, lStartCol, lEndRow, lEndCol: Integer;
  var WS: String := aWS;
  Expected(XmlTokenKind.ElementName);
  lStartRow := Tokenizer.Row;
  lStartCol := Tokenizer.Column;
  aLocalName := Tokenizer.Value;
  if (FormatOptions.NewLineForAttributes) then begin
    if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (aIndent = nil) then
      WS := fLineBreak+aParent.StartColumn+FormatOptions.Indentation
    else
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
        WS := fLineBreak+aIndent;
  end;
  aWSName := WS+aLocalName;
  Tokenizer.Next;
  WS := "";
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then WS := Tokenizer.Value;
    Tokenizer.Next;
  end;
  aWSName := aWSName+WS;
  Expected(XmlTokenKind.AttributeSeparator);
  Tokenizer.Next;
  WS := "";
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then WS := Tokenizer.Value;
    Tokenizer.Next;
  end;
  Expected(XmlTokenKind.AttributeValue);
  aValue := Tokenizer.Value;
  aWSValue := WS+aValue;
  lEndRow := Tokenizer.Row;
  lEndCol := Tokenizer.Column;
  /************/
  Tokenizer.Next;
  Expected(XmlTokenKind.TagClose, XmlTokenKind.Whitespace, XmlTokenKind.EmptyElementEnd, XmlTokenKind.DeclarationEnd);
  WS := "";
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    WS := Tokenizer.Value;
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then aWSValue := aWSValue + WS;
    Tokenizer.Next;
  end;
  /***********/
  if ((aLocalName.StartsWith("xmlns:")) or (aLocalName = "xmlns")) then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) or FormatOptions.NewLineForAttributes then
      aLocalName := aWSName+"="+aWSValue
    else
      if aLocalName.StartsWith("xmlns:") then
        aLocalName:=aLocalName.Substring("xmlns:".Length, aLocalName.Length- "xmlns:".Length)
      else if aLocalName = "xmlns" then aLocalName:="";
    result := new XmlNamespace(aParent, Prefix := aLocalName, Url := Url.UrlWithString(aValue.Substring(1,aValue.Length-2)), StartLine := lStartRow, StartColumn := lStartCol, EndLine := lEndRow, EndColumn := lEndCol);
  end
  else begin
    result := new XmlAttribute(aParent, StartLine := lStartRow, StartColumn := lStartCol, EndLine := lEndRow, EndColumn := lEndCol);
    XmlAttribute(result).LocalName := aWSName;//aLocalName;
    XmlAttribute(result).Value := aWSValue;//aValue;
  end;
  //Tokenizer.Next;
end;

method XmlParser.ReadElement(aParent: XmlElement; aIndent: String):XmlElement;
begin
  var WS := "";
  Expected(XmlTokenKind.TagOpen);
  result := new XmlElement(aParent, aIndent);
  if aIndent <> nil then
    aIndent := aIndent + FormatOptions.Indentation;
  result.StartLine := Tokenizer.Row;
  result.StartColumn := Tokenizer.Column;
  Tokenizer.Next;
  Expected(XmlTokenKind.ElementName);
  result.LocalName := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.Whitespace);
  if Tokenizer.Token <> XmlTokenKind.Whitespace then
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd)
  else begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then WS := Tokenizer.Value;
    Tokenizer.Next;
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName);
  end;
  while (Tokenizer.Token = XmlTokenKind.ElementName) do begin
    var aXmlNode := ReadAttribute(result, WS, aIndent);
    WS := "";
    if aXmlNode.NodeType = XmlNodeType.Namespace then result.AddNamespace(XmlNamespace(aXmlNode))
      else result.AddAttribute(XmlAttribute(aXmlNode));
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName);
  end;
  var lFormat := false;
  if (Tokenizer.Token = XmlTokenKind.TagClose) or (Tokenizer.Token = XmlTokenKind.EmptyElementEnd) then begin
    //check prefix for LocalName
    var aNamespace: XmlNamespace := nil;
    if result.LocalName.IndexOf(':')>0 then begin
      var lPrefix := result.LocalName.Substring(0, result.LocalName.IndexOf(':'));
      aNamespace := coalesce(result.Namespace[lPrefix], GetNamespaceForPrefix(lPrefix, aParent));
      if (aNamespace = nil) then raise new XmlException("Unknown prefix '"+lPrefix+":'", result.StartLine, (result.StartColumn+1));
      result.Namespace := aNamespace;
      result.LocalName := result.LocalName.Substring(result.LocalName.IndexOf(':')+1, result.LocalName.Length-result.LocalName.IndexOf(':')-1);
    end;
    //check prefix for attributes
    for each lAttribute in result.Attributes do begin
      if lAttribute.LocalName.IndexOf(':') >0 then begin
        var lPrefix := lAttribute.LocalName.Substring(0, lAttribute.LocalName.IndexOf(':'));
        aNamespace := coalesce(result.Namespace[lPrefix] , GetNamespaceForPrefix(lPrefix, aParent));
        if aNamespace = nil then raise new XmlException("Unknown prefix '"+lPrefix+":'", lAttribute.StartLine, lAttribute.StartColumn);
        lAttribute.Namespace := aNamespace;
        lAttribute.LocalName := lAttribute.LocalName.Substring(lAttribute.LocalName.IndexOf(':')+1, lAttribute.LocalName.Length-lAttribute.LocalName.IndexOf(':')-1);
      end;
    end;
    if (Tokenizer.Token = XmlTokenKind.TagClose) then begin
      if WS <> "" then result.LocalName := result.LocalName + WS;
      Tokenizer.Next;
      var WSValue: String := "";
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and (FormatOptions.NewLineForElements) then
        lFormat := true;
      while (Tokenizer.Token <> XmlTokenKind.TagElementEnd) do begin
        Expected(XmlTokenKind.SymbolData, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.CData, XmlTokenKind.ProcessingInstruction, XmlTokenKind.TagOpen, XmlTokenKind.TagElementEnd);
        if Tokenizer.Token = XmlTokenKind.TagOpen then begin
          if lFormat then begin result.AddNode(new XmlText(result, Value:=fLineBreak));result.AddNode(new XmlText(result, Value:=aIndent)); end;
          result.AddElement(ReadElement(result, aIndent));
          WSValue := "";
        end
        else begin
          if lFormat and (Tokenizer.Token not in [XmlTokenKind.Whitespace, XmlTokenKind.SymbolData]) then begin
            result.AddNode(new XmlText(result, Value := fLineBreak));// end;
            result.AddNode(new XmlText(result, Value:=aIndent));
          end;
          case Tokenizer.Token of
            XmlTokenKind.Whitespace: begin
              if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
                result.AddNode(new XmlText(result, Value := Tokenizer.Value));
                WSValue := "";
              end
              else
                if ((result.Nodes.Count > 0) and (result.Nodes[result.Nodes.Count-1].NodeType = XmlNodeType.Text) and (XmlText(result.Nodes[result.Nodes.Count-1]).Value.Trim <> "")) then begin
                  WSValue := Tokenizer.Value;
                  if WSValue.IndexOf(fLineBreak) > -1 then
                    WSValue := WSValue.Substring(0, WSValue.LastIndexOf(fLineBreak));
                  result.AddNode(new XmlText(result, Value := WSValue));
                  WSValue := "";
                end
                else WSValue := Tokenizer.Value;
            end;
            XmlTokenKind.SymbolData: begin
              if Tokenizer.Value.Trim <> "" then
                if (WSValue <>"") then begin
                  result.AddNode(new XmlText(result, Value := WSValue));
                end;
              result.AddNode(new XmlText(result, Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));//add node;
              WSValue := "";
            end;
            XmlTokenKind.Comment: begin
              result.AddNode(new XmlComment(result, Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)) ;
              WSValue := "";
            end;
            XmlTokenKind.CData: begin
              result.AddNode(new XmlCData(result, Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));
              WSValue := "";
            end;
            XmlTokenKind.ProcessingInstruction: begin
              result.AddNode(ReadProcessingInstruction(result));
              WSValue := "";
            end;
          end;
          Tokenizer.Next;
          var lCount := result.Nodes.Count-1;
          if (lCount > 0) and (result.Nodes[lCount].EndLine = 0) then
            result.Nodes[lCount].EndLine := Tokenizer.Row;
          if (lCount > 0) and (result.Nodes[lCount].EndColumn = 0) then
            result.Nodes[lCount].EndColumn := Tokenizer.Column-1;
        end;
      end;
      if Tokenizer.Token = XmlTokenKind.TagElementEnd then begin
        Tokenizer.Next;
        Expected(XmlTokenKind.ElementName);
        if (Tokenizer.Value.IndexOf(':') > 0) and ((result.Namespace = nil) or (result.Namespace.Prefix = nil) or
          (Tokenizer.Value <> result.Namespace.Prefix+':'+result.LocalName)) then
          raise new XmlException(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), Tokenizer.Row, Tokenizer.Column );
        if (Tokenizer.Value.IndexOf(':') <= 0) and (Tokenizer.Value <> result.LocalName) then
          raise new XmlException(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), Tokenizer.Row, Tokenizer.Column );

        if lFormat and (aIndent <> nil) and (result.Elements.Count >0) then begin
          result.AddNode(new XmlText(result, Value := fLineBreak));
          result.AddNode(new XmlText(result, Value := aIndent.Substring(0,aIndent.LastIndexOf(FormatOptions.Indentation))));
        end;
        if (result.IsEmpty) and (FormatOptions.EmptyTagSyle <> XmlTagStyle.PreferSingleTag) then
          result.AddNode(new XmlText(result,Value := ""));
        Tokenizer.Next;
        if (Tokenizer.Token = XmlTokenKind.Whitespace) then begin
          if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then
            result.EndTagName := result.LocalName+Tokenizer.Value;
            Tokenizer.Next;
        end;
        Expected(XmlTokenKind.TagClose);
        result.EndLine := Tokenizer.Row;
        result.EndColumn := Tokenizer.Column;
        if result.Parent = nil then exit(result);
        Tokenizer.Next;
      end;
    end
    else  if Tokenizer.Token = XmlTokenKind.EmptyElementEnd then begin
      result.EndLine := Tokenizer.Row;
      result.EndColumn := Tokenizer.Column+1;
      if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then
        if (FormatOptions.EmptyTagSyle = XmlTagStyle.PreferOpenAndCloseTag) then
          result.AddNode(new XmlText(result,Value := ""))
        else if (FormatOptions.SpaceBeforeSlashInEmptyTags) then begin
        end;
      if result.Parent = nil then exit(result);
      Tokenizer.Next;
      if lFormat and (Tokenizer.Token not in [XmlTokenKind.Whitespace, XmlTokenKind.SymbolData]) then
        result.AddNode(new XmlText(result, Value:=fLineBreak));
    end;
  end;
end;

method XmlParser.GetNamespaceForPrefix(aPrefix:not nullable String; aParent: XmlElement): XmlNamespace;
begin
  var ParentElem := aParent;
  while (ParentElem <> nil) and (result = nil) do begin
    if ParentElem.Namespace[aPrefix] <> nil
    then result := ParentElem.Namespace[aPrefix]
    else ParentElem := XmlElement(ParentElem.Parent);
  end;
end;

method XmlParser.ReadProcessingInstruction(aParent: XmlElement):  XmlProcessingInstruction;
begin
  var WS := "";
  Expected(XmlTokenKind.ProcessingInstruction);
  result := new XmlProcessingInstruction(aParent);
  result.StartLine := Tokenizer.Row;
  result.StartColumn := Tokenizer.Column;
  Tokenizer.Next;
  Expected(XmlTokenKind.ElementName);
  result.Target := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.Whitespace);
  if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
  Tokenizer.Next;

  Expected(XmlTokenKind.ElementName);
  while Tokenizer.Token = XmlTokenKind.ElementName do begin
    var aXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
    result.Data := result.Data+aXmlAttr.ToString;//aXmlAttr.LocalName+'="'+aXmlAttr.Value;
    WS:="";
    //Tokenizer.Next;
  end;
  Expected(XmlTokenKind.DeclarationEnd);
  result.EndLine := Tokenizer.Row;
  result.EndColumn := Tokenizer.Column+1;
  //Tokenizer.Next;
end;

end.