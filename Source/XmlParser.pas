﻿namespace RemObjects.Elements.RTL;

interface

type
  XmlParser = public class
  private
    Tokenizer: XmlTokenizer;
    method Expected (out aError: XmlErrorInfo; params Values: array of XmlTokenKind): Boolean;
    method ReadAttribute(aParent: XmlElement; aWS: String := ""; aIndent: String := ""; out aError: XmlErrorInfo): XmlNode;
    method ReadElement(aParent: XmlElement; aIndent: String := nil; out aError: XmlErrorInfo): XmlElement;
    method GetNamespaceForPrefix(aPrefix:not nullable String; aParent: XmlElement): XmlNamespace;
    method ReadProcessingInstruction(aParent: XmlElement; out aError: XmlErrorInfo): XmlProcessingInstruction;
    method ReadDocumentType(out aError: XmlErrorInfo): XmlDocumentType;
    method ParseEntities(S: String): nullable String;
    method ResolveEntity(S: not nullable String): nullable String;
  assembly
    fLineBreak: String;
  public
    constructor (aXmlString: String);
    constructor (aXmlString: String; aOptions: XmlFormattingOptions);
    method Parse(): not nullable XmlDocument;
    FormatOptions: XmlFormattingOptions;
  end;

  XmlConsts = assembly static class
  public
    const TAG_DECL_OPEN: String =  "<?xml";
    const TAG_DECL_CLOSE: String = "?>";
    const XML_NAMESPACE_URL: String = "http://www.w3.org/XML/1998/namespace";
  end;

  XmlTokenKind = public enum(
    BOF,
    EOF,
    Whitespace,
    DeclarationStart,
    DeclarationEnd,
    ProcessingInstruction,
    DocumentType,
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
    OpenSquareBracket,
    CloseSquareBracket,
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

  XmlFormattingOptions = public class
  public
    WhitespaceStyle: XmlWhitespaceStyle := XmlWhitespaceStyle.PreserveAllWhitespace;
    EmptyTagSyle: XmlTagStyle := XmlTagStyle.Preserve;
    SpaceBeforeSlashInEmptyTags: Boolean := false;
    Indentation: String := #9;
    NewLineForElements: Boolean := true;
    NewLineForAttributes: Boolean := false;
    NewLineSymbol: XmlNewLineSymbol  := XmlNewLineSymbol.PlatformDefault;
    PreserveExactStringsForUnchnagedValues: Boolean := false;
    WriteNewLineAtEnd: Boolean := false;
    WriteBOM: Boolean := false;
    PreserveLinebreaksForAttributes := false;
    PreserveEmptyLines := false;

    method UniqueCopy: XmlFormattingOptions;
    begin
      result := new XmlFormattingOptions;
      result.WhitespaceStyle := WhitespaceStyle;
      result.EmptyTagSyle := EmptyTagSyle;
      result.SpaceBeforeSlashInEmptyTags := SpaceBeforeSlashInEmptyTags;
      result.Indentation := Indentation;
      result.NewLineForElements := NewLineForElements;
      result.NewLineForAttributes := NewLineForAttributes;
      result.NewLineSymbol := NewLineSymbol;
      result.PreserveExactStringsForUnchnagedValues := PreserveExactStringsForUnchnagedValues;
      result.WriteNewLineAtEnd := WriteNewLineAtEnd;
      result.WriteBOM := WriteBOM;
      result.PreserveLinebreaksForAttributes := PreserveLinebreaksForAttributes;
      result.PreserveEmptyLines := PreserveEmptyLines;
    end;

    class property VisualStudioStyle: XmlFormattingOptions := getVisualStudioStyle; lazy;
    class property StandardReadableStyle: XmlFormattingOptions := getStandardReadableStyle; lazy;

    class method getVisualStudioStyle: XmlFormattingOptions; private;
    begin
      result := new XmlFormattingOptions();
      result.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
      result.EmptyTagSyle := XmlTagStyle.PreferSingleTag;
      result.Indentation := "  ";
      result.NewLineForElements := true;
      result.NewLineForAttributes := false;
      result.NewLineSymbol := XmlNewLineSymbol.CRLF;
      result.SpaceBeforeSlashInEmptyTags := true;
      result.WriteNewLineAtEnd := false;
      result.WriteBOM := true;
    end;

    class method getStandardReadableStyle: XmlFormattingOptions; private;
    begin
      result := new XmlFormattingOptions();
      result.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
      result.EmptyTagSyle := XmlTagStyle.PreferSingleTag;
      result.Indentation := #9;
      result.NewLineForElements := true;
      result.NewLineForAttributes := false;
      result.NewLineSymbol := XmlNewLineSymbol.PlatformDefault;
      result.SpaceBeforeSlashInEmptyTags := false;
      result.PreserveLinebreaksForAttributes := true;
      result.PreserveEmptyLines := true;
    end;

  assembly

    method NewLineString: String;
    begin
      case NewLineSymbol of
        XmlNewLineSymbol.PlatformDefault: result := Environment.LineBreak;
        XmlNewLineSymbol.LF: result := #10;
        XmlNewLineSymbol.CRLF: result := #13#10;
        XmlNewLineSymbol.Preserve: result := nil;
      end;
    end;

  end;

  XmlErrorInfo = public class
  public
    Message: String;
    Suggestion: String;
    Row: Integer;
    Column: Integer;
    method FillErrorInfo(aMsg: String; aSuggestion: String; aRow: Integer; aColumn: Integer; aXmlDoc: XmlDocument := nil);
    begin
      Message := aMsg;
      Suggestion := aSuggestion;
      Row := aRow;
      Column := aColumn;
    end;
  end;

implementation

constructor XmlParser(aXmlString: String);
begin
  Tokenizer := new XmlTokenizer(aXmlString);
  //FormatOptions := new XmlFormattingOptions;
  //fLineBreak := FormatOptions.NewLineString;
  //if fLineBreak = nil then
  if aXmlString.IndexOf(#13#10) > -1 then fLineBreak := #13#10
  else if aXmlString.IndexOf(#10) > -1 then fLineBreak := #10
  else fLineBreak := Environment.LineBreak;
  FormatOptions := new XmlFormattingOptions;
end;

constructor XmlParser(aXmlString: String; aOptions: XmlFormattingOptions);
begin
  Tokenizer := new XmlTokenizer(aXmlString);
  FormatOptions := aOptions;
  fLineBreak := FormatOptions.NewLineString;
  if fLineBreak = nil then
    if aXmlString.IndexOf(#13#10) > -1 then fLineBreak := #13#10
    else if aXmlString.IndexOf(#10) > -1 then fLineBreak := #10
      else fLineBreak := Environment.LineBreak;
end;

method XmlParser.Parse(): not nullable XmlDocument;
begin
  var WS: String :="";
  var lError: XmlErrorInfo;
  Tokenizer.Next;
  result := new XmlDocument();
  result.fXmlParser := self;
  if not Expected(out lError, XmlTokenKind.DeclarationStart, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType, XmlTokenKind.TagOpen, XmlTokenKind.Comment, XmlTokenKind.Whitespace) then begin
    result.Root := new XmlElement withName('[ERROR]');
    result.ErrorInfo := lError;
    exit;
  end;
  if Tokenizer.Token = XmlTokenKind.Comment then begin
    result.AddNode(new XmlComment(Value := Tokenizer.Value, NodeRange := new XmlRange(StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)));
    Tokenizer.Next;
    result.Nodes[result.Nodes.Count-1].NodeRange.EndLine := Tokenizer.Row;
    result.Nodes[result.Nodes.Count-1].NodeRange.EndColumn := Tokenizer.Column;
  end;
  {result.Version := "1.0";
  result.Encoding := "utf-8";
  result.Standalone := "no";}
  if Tokenizer.Token = XmlTokenKind.DeclarationStart then begin
    Tokenizer.Next;
    if not Expected(out lError, XmlTokenKind.Whitespace) then begin
      result.Root := new XmlElement withName('[ERROR]');
      result.ErrorInfo := lError;
      exit;
    end;
    if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
    Tokenizer.Next;
    if not Expected(out lError, XmlTokenKind.ElementName) then begin
      result.Root := new XmlElement withName('[ERROR]');
      result.ErrorInfo := lError;
      exit;
    end;
    var lXmlAttr := XmlAttribute(ReadAttribute(nil, WS, out lError));
    if assigned(lError) then begin
      result.Root := new XmlElement withName('[ERROR]');
      result.ErrorInfo := lError;
      exit;
    end;
    if lXmlAttr.LocalName = "version" then begin
      //check version
      if not(lXmlAttr.Value.StartsWith("1.")) or (lXmlAttr.Value.Length <> 3) or
        ((lXmlAttr.Value.Chars[2] < '0') or (lXmlAttr.Value.Chars[2] > '9')) then begin
        //aError := new XmlErrorInfo;
        //aError.FillErrorInfo(String.Format("Unknown XML version '{0}'", lXmlAttr.Value), "1.0", lXmlAttr.EndLine, lXmlAttr.EndColumn, result);
        result.ErrorInfo := new XmlErrorInfo;
        result.ErrorInfo.FillErrorInfo(String.Format("Unknown XML version '{0}'", lXmlAttr.Value), "1.0", lXmlAttr.NodeRange.EndLine, lXmlAttr.NodeRange.EndColumn, result);
        result.Root := new XmlElement withName('[ERROR]');
        exit;
        //raise new XmlException(String.Format("Unknown XML version '{0}'", lXmlAttr.Value), lXmlAttr.EndLine, lXmlAttr.EndColumn);
      end;
      result.Version := lXmlAttr.Value;
      if not Expected(out lError, XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName) then begin
        result.Root := new XmlElement withName('[ERROR]');
        result.ErrorInfo := lError;
        exit;
      end;
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if ((Tokenizer.Value <> "encoding") and (Tokenizer.Value <> "standalone")) then begin
          //aError := new XmlErrorInfo;
          //aError.FillErrorInfo("Unknown declaration attribute", "encoding", Tokenizer.Row, Tokenizer.Column, result);
          result.ErrorInfo := new XmlErrorInfo;
          result.ErrorInfo.FillErrorInfo("Unknown declaration attribute", "encoding", Tokenizer.Row, Tokenizer.Column, result);
          result.Root := new XmlElement withName('[ERROR]');
          exit;
          //raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        end;
        lXmlAttr := XmlAttribute(ReadAttribute(nil, WS, out lError));
        if assigned(lError) then begin
          result.Root := new XmlElement withName('[ERROR]');
          result.ErrorInfo := lError;
          exit;
        end;
      end;
    end;
    if lXmlAttr.LocalName = "encoding" then begin
      //check encoding
      var lEncoding := Encoding.GetEncoding(lXmlAttr.Value);
      if not assigned(lEncoding) then begin
        //aError := new XmlErrorInfo;
        //aError.FillErrorInfo(String.Format("Unknown encoding '{0}'", lXmlAttr.Value), "utf-8", lXmlAttr.EndLine, lXmlAttr.EndColumn, result);
        result.ErrorInfo := new XmlErrorInfo;
        result.ErrorInfo.FillErrorInfo(String.Format("Unknown encoding '{0}'", lXmlAttr.Value), "utf-8", lXmlAttr.NodeRange.EndLine, lXmlAttr.NodeRange.EndColumn, result);
        result.Root := new XmlElement withName('[ERROR]');
        exit;
        //raise new XmlException(String.Format("Unknown encoding '{0}'", lXmlAttr.Value), lXmlAttr.EndLine, lXmlAttr.EndColumn);
      end;
      result.Encoding := lXmlAttr.Value;
      if not Expected(out lError, XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName) then begin
        result.Root := new XmlElement withName('[ERROR]');
        result.ErrorInfo := lError;
        exit;
      end;
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if (Tokenizer.Value <> "standalone") then begin
          //aError := new XmlErrorInfo;
          //aError.FillErrorInfo("Unknown declaration attribute", "standalone", Tokenizer.Row, Tokenizer.Column, result);
          result.ErrorInfo := new XmlErrorInfo;
          result.ErrorInfo.FillErrorInfo("Unknown declaration attribute", "standalone", Tokenizer.Row, Tokenizer.Column, result);
          result.Root := new XmlElement withName('[ERROR]');
          exit;
          //raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        end;
        lXmlAttr := XmlAttribute(ReadAttribute(nil, WS, out lError));
        if assigned(lError) then begin
          result.Root := new XmlElement withName('[ERROR]');
          result.ErrorInfo := lError;
          exit;
        end;
      end;
    end;
    if lXmlAttr.LocalName = "standalone" then begin
      //check yes/no
      if (lXmlAttr.Value <> "yes") and (lXmlAttr.Value <> "no") then begin
        //aError := new XmlErrorInfo;
        //aError.FillErrorInfo("Unknown 'standalone' value", "no", lXmlAttr.EndLine, lXmlAttr.EndColumn, result);
        result.ErrorInfo := new XmlErrorInfo;
        result.ErrorInfo.FillErrorInfo("Unknown 'standalone' value", "no", lXmlAttr.NodeRange.EndLine, lXmlAttr.NodeRange.EndColumn, result);
        result.Root := new XmlElement withName('[ERROR]');
        exit;
        //raise new XmlException("Unknown 'standalone' value", lXmlAttr.EndLine, lXmlAttr.EndColumn);
      end;
      result.Standalone := lXmlAttr.Value;
    end;
  if not Expected(out lError, XmlTokenKind.DeclarationEnd) then begin
    result.Root := new XmlElement withName('[ERROR]');
    result.ErrorInfo := lError;
    exit;
  end;
    Tokenizer.Next;

  end;
  if not Expected(out lError, XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType) then begin
    result.Root := new XmlElement withName('[ERROR]');
    result.ErrorInfo := lError;
    exit;
  end;
  var lFormat := false;
  var WasDocType := false;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
    lFormat := true;
  if lFormat and (result.Nodes.Count = 0) and (result.Version <> nil) then
    result.AddNode(new XmlText(Value := fLineBreak));
  while Tokenizer.Token <> XmlTokenKind.TagOpen do begin
    if WasDocType then begin
      if not Expected(out lError, XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction) then begin
        result.Root := new XmlElement withName('[ERROR]');
        result.ErrorInfo := lError;
        exit
      end
    end
    else
      if not Expected(out lError, XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType) then begin
        result.Root := new XmlElement withName('[ERROR]');
        result.ErrorInfo := lError;
        exit;
      end;
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
        result.AddNode(new XmlComment(Value := Tokenizer.Value, NodeRange := new XmlRange(StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)));
        Tokenizer.Next;
        var lCount := result.Nodes.Count-1;
        result.Nodes[lCount].NodeRange.EndLine := Tokenizer.Row;
        result.Nodes[lCount].NodeRange.EndColumn := Tokenizer.Column;
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;//add node
      XmlTokenKind.ProcessingInstruction : begin
        var lPI := ReadProcessingInstruction(nil, out lError);
        if assigned(lError) then begin
          result.Root := new XmlElement withName('[ERROR]');
          result.ErrorInfo := lError;
          exit;
        end;
        result.AddNode(lPI);
        Tokenizer.Next;//add node
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;
      XmlTokenKind.DocumentType: begin
        WasDocType := true;
        var lDT := ReadDocumentType(out lError);
        if assigned(lError) then begin
          result.Root := new XmlElement withName('[ERROR]');
          result.ErrorInfo := lError;
          exit;
        end;
        result.AddNode(lDT);
        Tokenizer.Next;
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;
    end;
  end;
  if not Expected(out lError, XmlTokenKind.TagOpen) then begin
    result.Root := new XmlElement withName('[ERROR]');
    result.ErrorInfo := lError;
    exit;
  end;
  var lIndent: String;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
    lIndent := "";
    //result.AddNode(new XmlText(Value := fLineBreak));
  end;
  var lElement := ReadElement(nil, lIndent, out lError);
  if lElement = nil then result.Root := new XmlElement withName('[ERROR]')
  else result.Root := lElement;
  //result.Root := ReadElement(nil,lIndent, out aError);
  if assigned(lError) then begin
    result.ErrorInfo := lError;
    exit;
  end;
  while Tokenizer.Token <> XmlTokenKind.EOF do begin
    if not Expected(out lError, XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd) then exit;
    Tokenizer.Next;
    if (Tokenizer.Token = XmlTokenKind.Whitespace) then Tokenizer.Next;
    if not Expected(out lError, XmlTokenKind.EOF, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction) then begin
      result.ErrorInfo := lError;
      exit;
    end;
    case Tokenizer.Token of
      XmlTokenKind.Comment: result.AddNode(new XmlComment(Value := Tokenizer.Value));
      XmlTokenKind.ProcessingInstruction: begin
        var lPI := ReadProcessingInstruction(nil, out lError);
        if assigned(lError) then exit;
        result.AddNode(lPI);
      end;
    end;
    Tokenizer.Next;
  end;
end;

method XmlParser.Expected(out aError: XmlErrorInfo; params Values: array of XmlTokenKind): Boolean;
begin
  for Item in Values do
    if Tokenizer.Token = Item then
      exit true;
  aError := new XmlErrorInfo;
  case Tokenizer.Token of
    XmlTokenKind.SyntaxError: begin
      aError.FillErrorInfo(Tokenizer.Value, Values[0].toString, Tokenizer.Row, Tokenizer.Column);
      exit false;
    end;
    XmlTokenKind.EOF: begin
      aError.FillErrorInfo("Unexpected end of file", Values[0].ToString, Tokenizer.Row, Tokenizer.Column);
      exit false;
    end;
    else begin
      aError.FillErrorInfo('Unexpected token. '+ Values[0].ToString + ' is expected but '+Tokenizer.Token.ToString+" found", "", Tokenizer.Row, Tokenizer.Column);
      exit false;
    end;
  end;
end;

method XmlParser.ReadAttribute(aParent: XmlElement; aWS: String; aIndent:String; out aError: XmlErrorInfo): XmlNode;
begin
  var lLocalName, lValue: String;
  var lStartRow, lStartCol, lEndRow, lEndCol: Integer;
  var lWSleft, lWSright, linnerWSleft, linnerWSright: String;
  var lValueStartRow, lValueStartCol: Integer;

  lWSleft := aWS;
  if not Expected(out aError, XmlTokenKind.ElementName) then exit;
  lStartRow := Tokenizer.Row;
  lStartCol := Tokenizer.Column;
  lLocalName := Tokenizer.Value;
  var lQuoteChar: Char;
  if (FormatOptions.PreserveLinebreaksForAttributes) then
    if(lWSleft.Contains(fLineBreak)) then begin
      if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (aIndent = nil) then begin
        lWSleft := fLineBreak;
        for i:Integer := 0 to aParent.NodeRange.StartColumn-1 do
          lWSleft := lWSleft + " ";
        lWSleft := lWSleft +FormatOptions.Indentation
      end
      else if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
        lWSleft := fLineBreak+aIndent;
    end;
  if (FormatOptions.NewLineForAttributes) then begin
    if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (aIndent = nil) then
      lWSleft := fLineBreak+aParent.NodeRange.StartColumn+FormatOptions.Indentation
    else
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
        lWSleft := fLineBreak+aIndent;
  end;
  Tokenizer.Next;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then linnerWSleft := Tokenizer.Value;
    Tokenizer.Next;
  end;
  if not Expected(out aError, XmlTokenKind.AttributeSeparator) then goto newattr;//exit;
  lValueStartRow := Tokenizer.Row;
  lValueStartCol := Tokenizer.Column+2;
  Tokenizer.Next;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then linnerWSright := Tokenizer.Value;
    Tokenizer.Next;
    lValueStartRow := Tokenizer.Row;
    lValueStartCol := Tokenizer.Column+1;
  end;
  if assigned(Tokenizer.Value) and ((Tokenizer.Value[0] = '"') or (Tokenizer.Value[0] = "'")) then begin
    lValue := Tokenizer.Value;
    lQuoteChar := lValue[0];
    lValue := lValue.Trim([lQuoteChar]);
  end;
  if not Expected(out aError, XmlTokenKind.AttributeValue) then begin
    Tokenizer.Next;
    aError.Row := Tokenizer.Row;
    aError.Column := Tokenizer.Column;
    goto newattr;
  end;

  /************/
  Tokenizer.Next;
  lEndRow := Tokenizer.Row;
  lEndCol := Tokenizer.Column;
  if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.Whitespace, XmlTokenKind.EmptyElementEnd, XmlTokenKind.DeclarationEnd) then goto newattr;//exit;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then lWSright := Tokenizer.Value
    else if (FormatOptions.PreserveLinebreaksForAttributes) and (Tokenizer.Value.Contains(fLineBreak)) then
      if (aIndent = nil) then begin
        lWSright := fLineBreak;
        for i:Integer := 0 to aParent.NodeRange.StartColumn -1 do
          lWSright := lWSright + " ";
        lWSright := lWSright+ FormatOptions.Indentation;
      end
      else if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
        lWSright := fLineBreak+aIndent;
    Tokenizer.Next;
  end;
  /***********/
  newattr:;
  if ((lLocalName.StartsWith("xmlns:")) or (lLocalName = "xmlns")) then begin
    if lLocalName = "xmlns" then lLocalName:=""
    else
     // lLocalName:=lLocalName.Substring("xmlns:".Length, lLocalName.Length- "xmlns:".Length)
       lLocalName:=lLocalName.Substring(6);
    result := new XmlNamespace withParent(aParent);
    (result as XmlNamespace).Prefix := lLocalName;
    (result as XmlNamespace).Uri := lValue;
    result.NodeRange.FillRange(lStartRow, lStartCol, lEndRow, lEndCol);
    (result as XmlNamespace).WSleft := lWSleft;
    (result as XmlNamespace).innerWSleft := linnerWSleft;
    (result as XmlNamespace).innerWSright := linnerWSright;
    (result as XmlNamespace).WSright := lWSright;
    (result as XmlNamespace).QuoteChar := lQuoteChar
  end
  else begin
    result := new XmlAttribute withParent(aParent);
    result.NodeRange.FillRange(lStartRow, lStartCol, lEndRow, lEndCol);
    XmlAttribute(result).LocalName := lLocalName;
    var lparsedValue := if lValue = nil then "" else ParseEntities(lValue);
    XmlAttribute(result).Value := lparsedValue;
    XmlAttribute(result).ValueRange.FillRange(lValueStartRow, lValueStartCol, lEndRow, lEndCol-1);
    XmlAttribute(result).QuoteChar := lQuoteChar;
    XmlAttribute(result).WSleft := lWSleft;
    XmlAttribute(result).innerWSleft := linnerWSleft;
    XmlAttribute(result).innerWSright := linnerWSright;
    XmlAttribute(result).WSright := lWSright;
  end;
  //Tokenizer.Next;
end;

method XmlParser.ReadElement(aParent: XmlElement; aIndent: String; out aError: XmlErrorInfo):XmlElement;
begin
  var WS := "";
  if not Expected(out aError, XmlTokenKind.TagOpen) then exit;
  result := new XmlElement withParent(aParent) Indent(aIndent);
  if aParent:PreserveSpace then result.PreserveSpace := true;
  if aIndent <> nil then
    aIndent := aIndent + FormatOptions.Indentation;
  result.NodeRange.FillRange(Tokenizer.Row, Tokenizer.Column);
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.ElementName, XmlTokenKind.SyntaxError) then exit;
  if (Tokenizer.Token = XmlTokenKind.SyntaxError) then begin
    aError := new XmlErrorInfo;
    if (Tokenizer.Value.Contains(" ")) then begin
      aError.FillErrorInfo(Tokenizer.Value, "ElementName", Tokenizer.Row, Tokenizer.Column);
      exit;
    end
    else
      aError.FillErrorInfo("Element name expected", "ElementName", Tokenizer.Row, Tokenizer.Column);
  end;
  result.LocalName := Tokenizer.Value;
  var lFormat: Boolean;
  if Tokenizer.Token = XmlTokenKind.ElementName then begin
    Tokenizer.Next;
    if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.Whitespace) then goto checkns;//exit;
    if Tokenizer.Token = XmlTokenKind.Whitespace then begin
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) or ((FormatOptions.PreserveLinebreaksForAttributes) and Tokenizer.Value.Contains(fLineBreak)) then WS := Tokenizer.Value;
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName) then goto checkns;
    end;
    while (Tokenizer.Token = XmlTokenKind.ElementName) do begin
      var lXmlNode := ReadAttribute(result, WS, aIndent, out aError);
      if not assigned(lXmlNode) then exit;
      WS := "";
      if lXmlNode.NodeType = XmlNodeType.Namespace then result.AddNamespace(XmlNamespace(lXmlNode))
      else result.AddAttribute(XmlAttribute(lXmlNode));
      if assigned(aError) then goto checkns;
      if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName) then exit;
    end;
    lFormat := false;
    if (Tokenizer.Token = XmlTokenKind.TagClose) or (Tokenizer.Token = XmlTokenKind.EmptyElementEnd) then begin
      result.OpenTagEndLine := Tokenizer.Row;
      if Tokenizer.Token = XmlTokenKind.EmptyElementEnd then result.OpenTagEndColumn := Tokenizer.Column+2
      else result.OpenTagEndColumn := Tokenizer.Column+1;
    end;
  end;
  checkns:;
  //check prefix for LocalName
  var lNamespace: XmlNamespace := nil;
  var lColonPos := result.LocalName.IndexOf(':');
  var lEmptyName: Boolean;
  if lColonPos = (result.LocalName.Length-1) then
    lEmptyName := true;
  if lColonPos > 0 then begin
    var lPrefix := result.LocalName.Substring(0, lColonPos);
    lNamespace := coalesce(result.Namespace[lPrefix], GetNamespaceForPrefix(lPrefix, aParent));
    if (lNamespace = nil) then begin
      var lSuggestion: String := "";
      var lElement := result;
      while (lSuggestion = "") and (lElement <> nil) do begin
        if assigned(lElement.DefaultNamespace) and (lElement.DefaultNamespace.Prefix <> "") then begin
          lSuggestion := lElement.DefaultNamespace.Prefix;
          break;
        end;
        for each lNmspc in lElement.DefinedNamespaces do
          if lNmspc.Prefix <> "" then begin
            lSuggestion := lNmspc.Prefix;
            break;
          end;
          lElement := lElement.Parent;
      end;
      result.LocalName := '[ERROR]:'+ iif(lEmptyName, "[ERROR]",result.LocalName.Substring(lColonPos+1));
      result.OpenTagEndLine := 0;
      result.OpenTagEndColumn := 0;
      //if assigned (aError) then exit;
      aError := new XmlErrorInfo;
      aError.FillErrorInfo("Unknown prefix '"+lPrefix+":'", lSuggestion, result.NodeRange.StartLine, (result.NodeRange.StartColumn+1));
      exit;
    end;
    result.Namespace := lNamespace;
    result.LocalName := iif(lEmptyName, "[ERROR]", result.LocalName.Substring(lColonPos+1));
  end;
  //check prefix for attributes
  for each lAttribute in result.Attributes do begin
    lColonPos := lAttribute.LocalName.IndexOf(':');
    if lColonPos = (lAttribute.LocalName.Length -1) then
      lEmptyName := true;
    if lColonPos >0 then begin
      var lPrefix := lAttribute.LocalName.Substring(0, lColonPos);
      var lLocalName := iif (lEmptyName, "[ERROR]", lAttribute.LocalName.Substring(lColonPos+1));
      if lPrefix = "xml" then begin
        lNamespace := new XmlNamespace(lPrefix, XmlConsts.XML_NAMESPACE_URL);
        case lLocalName of
          "lang":;
          "space": begin
            if lAttribute.Value = "preserve" then result.PreserveSpace := true
            else if lAttribute.Value = "default" then
              result.PreserveSpace := false
            else begin
              aError := new XmlErrorInfo;
              aError.FillErrorInfo('Unknown value for "xml:space" attribute', "default", lAttribute.ValueRange.StartLine, lAttribute.ValueRange.StartColumn);
            end;
          end;
          "id":;
          "base":;
          else begin
            //raise new XmlException("Unknown attribute name for 'xml:' prefix '"+lLocalName+":'", lAttribute.StartLine, lAttribute.StartColumn+4);
            aError := new XmlErrorInfo;
            aError.FillErrorInfo("Unknown attribute name for 'xml:' prefix '"+lLocalName+":'", "space", lAttribute.NodeRange.StartLine, lAttribute.NodeRange.StartColumn+4);
            lAttribute.Namespace := lNamespace;
            lAttribute.LocalName := '[ERROR]';
            result.OpenTagEndLine := 0;
            result.OpenTagEndColumn := 0;
            exit;
          end;
        end;
      end
      else begin
        lNamespace := coalesce(result.Namespace[lPrefix], GetNamespaceForPrefix(lPrefix, aParent));
        if lNamespace = nil then begin //raise new XmlException("Unknown prefix '"+lPrefix+":'", lAttribute.StartLine, lAttribute.StartColumn);
          aError := new XmlErrorInfo;
          var lSuggestion: String := "";
          var lElement := result;
          while (lSuggestion = "") and (lElement <> nil) do begin
            if assigned(lElement.DefaultNamespace) and (lElement.DefaultNamespace.Prefix <> "") then begin
              lSuggestion := lElement.DefaultNamespace.Prefix;
              break;
            end;
            for each lNmspc in lElement.DefinedNamespaces do
              if lNmspc.Prefix <> "" then begin
                lSuggestion := lNmspc.Prefix;
                break;
              end;
            lElement := lElement.Parent;
          end;
          aError.FillErrorInfo("Unknown prefix '"+lPrefix+":'", lSuggestion, lAttribute.NodeRange.StartLine, lAttribute.NodeRange.StartColumn);
          lAttribute.LocalName := '[ERROR]:'+ lLocalName;
          result.OpenTagEndLine := 0;
          result.OpenTagEndColumn := 0;
          exit;
        end;
      end;
      lAttribute.Namespace := lNamespace;
      lAttribute.LocalName := lLocalName;//lAttribute.LocalName.Substring(lAttribute.LocalName.IndexOf(':')+1, lAttribute.LocalName.Length-lAttribute.LocalName.IndexOf(':')-1);
    end;
  end;
  if assigned(aError) then exit;
  if (Tokenizer.Token = XmlTokenKind.TagClose) then begin
      if WS <> "" then result.WSAfterName := WS;
      Tokenizer.Next;
      var WSValue: String := "";
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and (FormatOptions.NewLineForElements) and not result.PreserveSpace then
        lFormat := true;
      while (Tokenizer.Token <> XmlTokenKind.TagElementEnd) do begin
        if not Expected(out aError, XmlTokenKind.SymbolData, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.CData, XmlTokenKind.ProcessingInstruction, XmlTokenKind.TagOpen, XmlTokenKind.TagElementEnd) then exit;
        if Tokenizer.Token = XmlTokenKind.TagOpen then begin
          if lFormat then begin result.AddNode(new XmlText(result, Value:=fLineBreak));result.AddNode(new XmlText(result, Value:=aIndent)); end;
          var lEl := ReadElement(result, aIndent, out aError);
          if lEl <> nil then result.AddElement(lEl);
          if assigned(aError) then exit;
          WSValue := "";
        end
        else begin
          if lFormat and (Tokenizer.Token not in [XmlTokenKind.Whitespace, XmlTokenKind.SymbolData]) then begin
            result.AddNode(new XmlText(result, Value := fLineBreak));// end;
            result.AddNode(new XmlText(result, Value:=aIndent));
          end;
          case Tokenizer.Token of
            XmlTokenKind.Whitespace: begin
              if result.PreserveSpace or (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
                result.AddNode(new XmlText(result, Value := Tokenizer.Value));
                WSValue := "";
              end
              else
                if ((result.Nodes.Count > 0) and (result.Nodes[result.Nodes.Count-1].NodeType = XmlNodeType.Text) and (XmlText(result.Nodes[result.Nodes.Count-1]).Value.Trim <> "")) then begin
                  WSValue := Tokenizer.Value;
                  {if WSValue.IndexOf(fLineBreak) > -1 then
                    WSValue := WSValue.Substring(0, WSValue.LastIndexOf(fLineBreak));}
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
              var lParsedValue := ParseEntities(Tokenizer.Value);
              result.AddNode(new XmlText(result, Value := {Tokenizer.Value}lParsedValue, originalRawValue := Tokenizer.Value,
                NodeRange := new XmlRange(StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)));//add node;
              WSValue := "";
            end;
            XmlTokenKind.Comment: begin
              result.AddNode(new XmlComment(result, Value := Tokenizer.Value, NodeRange := new XmlRange(StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column))) ;
              WSValue := "";
            end;
            XmlTokenKind.CData: begin
              result.AddNode(new XmlCData(result, Value := Tokenizer.Value, NodeRange := new XmlRange(StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)));
              WSValue := "";
            end;
            XmlTokenKind.ProcessingInstruction: begin
              var lPI := ReadProcessingInstruction(result, out aError);
              if lPI <> nil then result.AddNode(lPI);
              if assigned(aError) then exit;
              WSValue := "";
            end;
          end;
          Tokenizer.Next;
          var lCount := result.Nodes.Count-1;
          if (lCount > 0) and (result.Nodes[lCount].NodeRange.EndLine = 0) then
            result.Nodes[lCount].NodeRange.EndLine := Tokenizer.Row;
          if (lCount > 0) and (result.Nodes[lCount].NodeRange.EndColumn = 0) then
            result.Nodes[lCount].NodeRange.EndColumn := Tokenizer.Column;
        end;
      end;
      if Tokenizer.Token = XmlTokenKind.TagElementEnd then begin
        result.CloseTagRange.StartLine := Tokenizer.Row;
        result.CloseTagRange.StartColumn := Tokenizer.Column;
        if (result.IsEmpty) and (FormatOptions.EmptyTagSyle <> XmlTagStyle.PreferSingleTag) then
          result.AddNode(new XmlText(result,Value := ""));
        Tokenizer.Next;
        if Expected(out aError, XmlTokenKind.ElementName) then begin //exit;
          if (result.FullName.TrimEnd <> Tokenizer.Value) then begin
            result.EndTagName := Tokenizer.Value;
            var lEndTagName := result.EndTagName;
            aError := new XmlErrorInfo;
            var lPos := result.EndTagName.IndexOf(':');
            var lPrefix := "";
            var lPrefixLength := 0;
            if lPos > 0 then begin
              lPrefix := Tokenizer.Value.Substring(0, lPos);
              lPrefixLength := lPrefix.Length;
              lNamespace := coalesce(result.Namespace[lPrefix], GetNamespaceForPrefix(lPrefix, aParent));
              if not assigned(lNamespace) then begin
                aError.FillErrorInfo("Unknown prefix "+lPrefix, "", Tokenizer.Row, Tokenizer.Column-lPrefixLength-1);
                exit;
              end else
                lEndTagName := lEndTagName.Substring(lPos+1);
            end else begin
              if ((result.Namespace:Prefix <> nil) and (result.Namespace.Prefix <> "") and  not result.Namespace.Prefix.StartsWith(Tokenizer.Value)) then begin
                aError.FillErrorInfo("Unknown prefix "+Tokenizer.Value, "", Tokenizer.Row, Tokenizer.Column);
                exit;
              end;
            end;
            var lDotPosStart := result.LocalName.IndexOf('.');
            if lDotPosStart > 0 then begin
              var lStartTagNames := result.LocalName.Split('.');
              //var lDotPosEnd := lEndTagName.IndexOf('.');
              var lEndTagNames := lEndTagName.Split('.');
              for i: Integer := 0 to lStartTagNames.Count-1 do begin
                if (lEndTagNames.Count > i) then
                  if lEndTagNames[i]<> lStartTagNames[i] then
                    if (lStartTagNames[i].StartsWith(lEndTagNames[i])) and (lEndTagNames.Count = i+1) then
                      aError.FillErrorInfo(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), result.LocalName, Tokenizer.Row, Tokenizer.Column+Tokenizer.Value.length)
                    else begin
                      var lErrorColumn := Tokenizer.Column;
                      if lPrefixLength > 0 then lErrorColumn := lErrorColumn +lPrefixLength+1;
                      if i > 0 then
                        for j: Integer := 0 to i-1 do
                          lErrorColumn := lErrorColumn + lEndTagNames[j].Length + 1;
                      aError.FillErrorInfo(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), result.LocalName, Tokenizer.Row, lErrorColumn);
                      exit;
                    end;
              end;
            end;
            if not result.LocalName.StartsWith(lEndTagName) then begin
              aError.FillErrorInfo(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), "", Tokenizer.Row, Tokenizer.Column+length(lPrefix));
              exit;
            end
            else
              aError.FillErrorInfo(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), result.LocalName, Tokenizer.Row, Tokenizer.Column+Tokenizer.Value.length);
          end;
        end;
        if lFormat and (aIndent <> nil) and (result.Elements.Count >0) then begin
          result.AddNode(new XmlText(result, Value := fLineBreak));
          result.AddNode(new XmlText(result, Value := aIndent.Substring(0,aIndent.LastIndexOf(FormatOptions.Indentation))));
        end;

        if Tokenizer.Token = XmlTokenKind.ElementName then begin
          /*if (result.FullName <> Tokenizer.Value) then begin
            if not assigned (aError) then begin
              aError := new XmlErrorInfo;
              aError.FillErrorInfo(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), result.LocalName, Tokenizer.Row, Tokenizer.Column+Tokenizer.Value.length);
            end;
            result.EndTagName := Tokenizer.Value;
            exit;
          end;*/
          Tokenizer.Next;
          if (Tokenizer.Token = XmlTokenKind.Whitespace) then begin
            if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then
              result.EndTagName := result.LocalName+Tokenizer.Value;
            Tokenizer.Next;
          end;
          if not Expected(out aError, XmlTokenKind.TagClose) then exit;
          result.NodeRange.EndLine := Tokenizer.Row;
          result.NodeRange.EndColumn := Tokenizer.Column+1;
          result.CloseTagRange.EndLine := result.NodeRange.EndLine;
          result.CloseTagRange.EndColumn := result.NodeRange.EndColumn;
          if result.Parent = nil then exit(result);
          Tokenizer.Next;
        end;
      end;
    end
    else  if Tokenizer.Token = XmlTokenKind.EmptyElementEnd then begin
      result.NodeRange.EndLine := Tokenizer.Row;
      result.NodeRange.EndColumn := Tokenizer.Column+2;
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
//end;

method XmlParser.GetNamespaceForPrefix(aPrefix: not nullable String; aParent: XmlElement): XmlNamespace;
begin
  while assigned(aParent) do begin
    result := aParent.Namespace[aPrefix];
    if assigned(result) then
      exit;
    aParent := XmlElement(aParent.Parent);
  end;
end;

method XmlParser.ReadProcessingInstruction(aParent: XmlElement; out aError: XmlErrorInfo):  XmlProcessingInstruction;
begin
  var WS := "";
  if not Expected(out aError, XmlTokenKind.ProcessingInstruction) then exit;
  result := new XmlProcessingInstruction(aParent);
  result.NodeRange.FillRange(Tokenizer.Row, Tokenizer.Column);
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.ElementName) then exit;
  result.Target := Tokenizer.Value;
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.Whitespace) then exit;
  if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
  Tokenizer.Next;

  if not Expected(out aError, XmlTokenKind.ElementName) then exit;
  while Tokenizer.Token = XmlTokenKind.ElementName do begin
    var lXmlAttr := XmlAttribute(ReadAttribute(nil, WS, out aError));
    result.Data := result.Data+lXmlAttr.ToString;//aXmlAttr.LocalName+'="'+aXmlAttr.Value;
    WS:="";
    //Tokenizer.Next;
  end;
  if not Expected(out aError, XmlTokenKind.DeclarationEnd) then exit;
  result.NodeRange.EndLine := Tokenizer.Row;
  result.NodeRange.EndColumn := Tokenizer.Column+2;
  //Tokenizer.Next;
end;

method XmlParser.ReadDocumentType(out aError: XmlErrorInfo): XmlDocumentType;
begin
  if not Expected(out aError, XmlTokenKind.DocumentType) then exit;
  result := new XmlDocumentType();
  result.NodeRange.FillRange(Tokenizer.Row, Tokenizer.Column);
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.Whitespace) then exit;
  //if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.ElementName) then exit;
  result.Name := Tokenizer.Value;
  Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.Whitespace, XmlTokenKind.TagClose) then exit;
  if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.ElementName, XmlTokenKind.OpenSquareBracket) then exit;
  if Tokenizer.Token = XmlTokenKind.ElementName then begin
    if Tokenizer.Value = "SYSTEM" then begin
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.Whitespace) then exit;
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.AttributeValue) then exit;
      result.SystemId := Tokenizer.Value;
      Tokenizer.Next;
    end
    else if Tokenizer.Value = "PUBLIC" then begin
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.Whitespace) then exit;
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.AttributeValue) then exit;
      result.PublicId := Tokenizer.Value;
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.Whitespace) then exit;
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.AttributeValue) then exit;
      result.SystemId := Tokenizer.Value;
      Tokenizer.Next;
    end
    else begin//raise new XmlException("SYSTEM, PUBLIC or square brackets expected", Tokenizer.Row, Tokenizer.Column);
      aError := new XmlErrorInfo;
      aError.FillErrorInfo("SYSTEM, PUBLIC or square brackets expected", "SYSTEM", Tokenizer.Row, Tokenizer.Column);
      result.PublicId := '[ERROR]';
      //result
      exit;
    end;
    if not Expected(out aError, XmlTokenKind.Whitespace, XmlTokenKind.TagClose) then exit;
    if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  end;
  if Tokenizer.Token = XmlTokenKind.OpenSquareBracket then begin
    //that's only for now, need to be parsed
    Tokenizer.Next;
    if not Expected(out aError, XmlTokenKind.ElementName) then exit;
    result.Declaration := Tokenizer.Value;
    Tokenizer.Next;
    if not Expected(out aError, XmlTokenKind.CloseSquareBracket, XmlTokenKind.Whitespace) then exit;
    if Tokenizer.Token = XmlTokenKind.Whitespace then begin
      Tokenizer.Next;
      if not Expected(out aError, XmlTokenKind.CloseSquareBracket) then exit;
    end;
    if Tokenizer.Token = XmlTokenKind.CloseSquareBracket then Tokenizer.Next;
    if not Expected(out aError, XmlTokenKind.TagClose, XmlTokenKind.Whitespace) then exit;
    if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  end;
  if not Expected(out aError, XmlTokenKind.TagClose) then exit;
  result.NodeRange.EndLine := Tokenizer.Row;
  result.NodeRange.EndColumn := Tokenizer.Column+1;
end;

method XmlParser.ParseEntities(S: String): nullable String;
begin
  var i := 0;
   var Sb := new StringBuilder(S);
  var len := Sb.Length;
  while i < len do begin
    if Sb[i] = '&' then begin
      var lStart := i;
      var lEntity: String;
      inc(i);
      while i < Sb.Length do begin
        var ch := Sb[i];
        if ch = ';' then begin
          inc(i);
          lEntity := Sb.Substring(lStart, i-lStart);
          break;
        end
        else if ch in ['a'..'z','A'..'Z','0'..'9','#'] then begin
          inc(i);
        end
        else begin
          break;
        end;
      end;
      if assigned(lEntity) then begin
        var lResolvedEntity := ResolveEntity(lEntity);
        if assigned(lResolvedEntity) then begin
          Sb := Sb.Replace(lStart, length(lEntity), lResolvedEntity);
          var diff := (length(lEntity)-length(lResolvedEntity));
          i := i-diff;
          len := len-diff
        end;
      end;
    end
    else
      inc(i);
  end;
  result := Sb.ToString;
end;

method XmlParser.ResolveEntity(S: not nullable String): nullable String;
begin
  if S.StartsWith("&#x") then begin
    var lHex := S.Substring(3, length(S)-4);
    try
      var lValue := Convert.HexStringToUInt32(lHex);
      result := chr(lValue);
    except
    end;
  end
  else if S.StartsWith("&#") then begin
    var lDec := S.Substring(2, length(S)-3);
    var lValue := Convert.TryToInt32(lDec);
    if assigned(lValue) then result := chr(lValue);
  end
  else case S of
    "&lt;": result := "<";
    "&gt;": result := ">";
    "&amp;": result := "&";
    "&apos;": result := "'";
    "&quot;": result := """";
  end;
end;

end.