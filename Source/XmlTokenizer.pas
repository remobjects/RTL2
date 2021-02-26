namespace RemObjects.Elements.RTL;

interface
type
  XmlTokenizer = public class
  private
    fData: array of Char := nil;
    fPos: Integer;
    fLastRow: Integer;
    fRow: Integer;
    fLastRowStart: Integer;
    fRowStart: Integer;
    fLength: Integer;

    method CharIsIdentifier(C: Char): Boolean; inline;
    method CharIsWhitespace(C: Char): Boolean; inline;
    method CharIsNameStart(C: Char): Boolean; inline;
    method CharIsName(C: Char): Boolean; inline;

    method Parse;

  assembly
    method ParseWhitespace;
    method ParseName;
    method ParseValue;
    method ParseSymbolData;
    method ParseComment;
    method ParseCData;

  public
    constructor (aXml: String);

    method Next: Boolean;

    property Xml: String; readonly;
    property Row: Integer read fLastRow + 1;
    property Column: Integer read fPos - fLastRowStart + 1;
    property Value: String read private write;
    property ErrorMessage: String read private write;
    property Token:XmlTokenKind read private write;
  end;

implementation

uses
{$IF ECHOES}
  System.Globalization,
{$ENDIF}
  RemObjects.Elements
  ;

constructor XmlTokenizer(aXml: String);
begin
  Xml := aXml;
  fData := Xml.ToCharArray;
  Token := XmlTokenKind.BOF;
end;

method XmlTokenizer.CharIsIdentifier(C: Char): Boolean;
begin
  exit (((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or (C = '_'));
end;

method XmlTokenizer.CharIsWhitespace(C: Char): Boolean;
begin
  exit (C = ' ') or (C = #13) or (C = #10) or (C = #9);
end;

method XmlTokenizer.CharIsNameStart(C: Char): Boolean;
begin
  result := ((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or ((C>=#192) and (C<=#214)) or ((C>=#216) and (C<=#246)) or ((C>=#248) and (C<=#767)) or
    ((C>=#880) and (C<=#893)) or ((C>=#895) and (C<=#8191)) or (C=#8204) or (C=#8205) or ((C>=#8304) and (C<=#8591)) or ((C>=#11264) and (C<=#12271)) or ((C>=#12289) and (C<=#55295)) or
    ((C>=#63744) and (C<=#64975)) or ((C>=#65008) and (C<=#65533)){ or ((C>=#65536) and (C<=#983039))} or (C = '_') or (C = ':');
end;

method XmlTokenizer.CharIsName(C: Char): Boolean;
begin
  result := CharIsNameStart(C) or ((C >='0') and (C <= '9')) or (C = '-') or (C = '.')
end;

method XmlTokenizer.Parse;
begin
  if (fPos >= fData.length) then begin
    Token := XmlTokenKind.EOF;
    exit;
  end;
  if (fPos>0) and
    ((fData[fPos-1] = '>') or (((fPos-fLength) > 0) and (Token = XmlTokenKind.Whitespace) and (fData[fPos-fLength-1] = '>')))
    and (fPos < fData.length) and (not(CharIsWhitespace(fData[fPos]))) and (fData[fPos] <> '<') then ParseSymbolData()
  else
    if CharIsNameStart(fData[fPos]) then ParseName
    else if (fData.Length >= fPos+2{XmlConsts.TAG_DECL_CLOSE.Length}) and (new String(fData,fPos,2{XmlConsts.TAG_DECL_CLOSE.Length}) = XmlConsts.TAG_DECL_CLOSE) then begin
      fLength := 2;//XmlConsts.TAG_DECL_CLOSE.Length;
      Value:=nil;
      Token := XmlTokenKind.DeclarationEnd;
    end
    else case fData[fPos] of
      ' ', #9, #13, #10: ParseWhitespace;
      '=' : begin
        fLength := 1;
        Value := nil;
        Token := XmlTokenKind.AttributeSeparator;
      end;
      '"' : ParseValue;
      '''' : ParseValue;
      '<': if (fData.Length > fPos+1) then
        case fData[fPos+1] of
          '/': begin
              fLength := 2;
              Value := nil;
              Token := XmlTokenKind.TagElementEnd;
            end;
          '!':
            if (fData.Length > fPos+4) and (fData[fPos+2] = '-') and (fData[fPos+3] = '-') then
              ParseComment//comment
            else if (fData.Length > fPos+9) then
              if (new String(fData,fPos+2,7) = "[CDATA[") then ParseCData
              else
                if (new String(fData, fPos+2, 7) = "DOCTYPE" ) then begin
                  Token := XmlTokenKind.DocumentType;
                  fLength := 9;
                  Value := "";
                end
                else begin
                  Token := XmlTokenKind.SyntaxError;
                  fPos := fPos+1;
                  Value := "Unknown token";
                end;
          '?': begin
            if (fData.Length >= fPos+5{XmlConsts.TAG_DECL_OPEN.Length}) and
              (new String(fData,fPos,5{XmlConsts.TAG_DECL_OPEN.Length})  = XmlConsts.TAG_DECL_OPEN) and (CharIsWhitespace(fData[fPos+5{XmlConsts.TAG_DECL_OPEN.Length}])) then begin
              //if fPos = 0 then begin 
              Token := XmlTokenKind.DeclarationStart;
              fLength:= 5;//XmlConsts.TAG_DECL_OPEN.Length;
              Value := nil;
              {end
              else begin
                Token := XmlTokenKind.SyntaxError;
                Value := "No information or whitespaces before the declaration are allowed";
                //raise new Exception('No information or whitespaces before the declaration are allowed');
              end}
            end
            else begin
              Token := XmlTokenKind.ProcessingInstruction;
              fLength := 2;
              Value :="";
            end;
          end;
          else begin
            fLength := 1;
            Value := nil;
            Token := XmlTokenKind.TagOpen;
          end;
        end
      else begin
        fLength := 1;
        Value := nil;
        Token := XmlTokenKind.TagOpen;
      end;
      '>': begin
        fLength := 1;
        Value := nil;
        Token := XmlTokenKind.TagClose;
        end;
      '/': begin
        if (fData.Length >= (fPos+1)) and (fData[fPos+1] = '>') then begin
          fLength := 2;
          Value := nil;
          Token := XmlTokenKind.EmptyElementEnd;
        end
        else Token := XmlTokenKind.SlashSymbol;
        end;
      //#0: Token := XmlTokenKind.EOF;
      '[': begin
        Token := XmlTokenKind.OpenSquareBracket;
        Value := nil;
        fLength := 1;
        end;
      ']': begin
        Token := XmlTokenKind.CloseSquareBracket;
        Value := nil;
        fLength := 1;
        end;
        else begin
          fLength := 0;
          Value := "Unexpected token "+fData[fPos];
          Token := XmlTokenKind.SyntaxError;
        end;
      end;
end;

method XmlTokenizer.Next: Boolean;
begin
  //if Token = XmlTokenKind.EOF then
  //  exit false;
  while true do begin
    fPos := fPos + fLength;
    fLastRow := fRow;
    fLastRowStart := fRowStart;
    if Token = XmlTokenKind.EOF then
      exit false;
    if fPos < fData.Length then Parse
    else begin
      Token := XmlTokenKind.EOF;
      Value := "";
    end;
    if (Token = XmlTokenKind.EOF) or (Token = XmlTokenKind.SyntaxError) then
      exit false;
    exit true;
  end;
end;

method XmlTokenizer.ParseWhitespace;
begin
  if not CharIsWhitespace(fData[fPos]) then
    exit;

  var lPosition := fPos;

  while (lPosition < fData.length) and CharIsWhitespace(fData[lPosition])  do begin
    if fData[lPosition] = #13 then begin
      if fData[lPosition + 1] = #10 then
        inc(lPosition);

      fRowStart := lPosition + 1;
      inc(fRow);
    end
    else if fData[lPosition] = #10 then begin
      fRowStart := lPosition + 1;
      inc(fRow);
    end;

    inc(lPosition);
  end;

  fLength := lPosition - fPos;
  //Value := nil;
  Value := new String(fData, fPos, fLength);
  Token := XmlTokenKind.Whitespace;
end;

method XmlTokenizer.ParseName;
begin
  var lPosition := fPos + 1;
  var colonSymbol := 0;
  while (lPosition < fData.length) do begin
    var ch := fData[lPosition];
    if not CharIsName(ch) then break;
    if ch = ':' then begin
      inc(colonSymbol);
      if (fData.Length <= (lPosition+1)) then begin
        //fPos := lPosition+1;
        lPosition := lPosition + 1;
        break;
        {Token := XmlTokenKind.SyntaxError;
        Value := new String(fData, fPos, lPosition+1 - fPos);
        fPos := lPosition+1;}
        //Value := "Name expected";
        //exit;
      end
      else if (CharIsNameStart(fData[lPosition+1]) = false) then begin
        Token := XmlTokenKind.SyntaxError;
        //Value := "Name could't begin from "+fData[lPosition+1]+" symbol";
        Value := new String(fData, fPos, lPosition+1 - fPos);
        fPos := lPosition+1;
        exit;
      end;
    end;
    if colonSymbol > 1 then begin
      Value := ':';
      fPos := lPosition;
      Token := XmlTokenKind.SyntaxError;
      Value := "Unexpected token ':'";
      exit;
    end;
    inc(lPosition);
  end;

  fLength := lPosition - fPos;
  Value := new String(fData, fPos, fLength);
  Token := XmlTokenKind.ElementName;
end;

method XmlTokenizer.ParseValue;
begin
  var lQuoteChar := fData[fPos];
  if (lQuoteChar ≠ '"') and (lQuoteChar ≠ '''') then exit;
  var lPosition := fPos;
  inc(lPosition);
  loop begin
    if (lPosition >= fData.length) then begin
      Value := new String(fData, fPos, lPosition-fPos);
      ErrorMessage := "Attribute value expected but EOF found";
      fLength := lPosition - fPos+1;
      Token := XmlTokenKind.EOF; exit;
      //break;
    end;
    var ch := fData[lPosition];
    if ch = lQuoteChar then break;
    case ch of
      #13: begin
        if (fData.Length > lPosition+1) and (fData[lPosition + 1] = #10) then inc(lPosition);
        fRowStart := lPosition + 1;
        inc(fRow);
      end;
      #10: begin
        fRowStart := lPosition + 1;
        inc(fRow);
      end;
      {'<' : begin
        Token := XmlTokenKind.SyntaxError;
        ErrorMessage := "Syntax error. Symbol '<' is not allowed in attribute value";
        fLength := lPosition - fPos;
        Value :=  new String(fData, fPos, lPosition-fPos);
        exit;
      end;}
    end;
    inc(lPosition);
  end;

  Value := new String(fData, fPos, lPosition-fPos+1);
  fLength := lPosition - fPos+1;
  Token := XmlTokenKind.AttributeValue;
end;

method XmlTokenizer.ParseSymbolData;
begin
  var lPosition := fPos;
  var lStart := fPos;
  var lPos: Integer;
  while (lPosition < fData.length) and (fData[lPosition] <> '<') do begin
    case fData[lPosition] of
      #13 : begin
          if (fData.length<lPosition+1) then begin
            Token := XmlTokenKind.EOF;
            fPos  := lPosition +1;
            exit;
          end
          else if fData[lPosition + 1] = #10 then
            inc(lPosition);
            lPos := lPosition+1;
            while (lPos < fData.length) and CharIsWhitespace(fData[lPos]) do inc(lPos);
            if (fData[lPos] <> '<') {and (fData[lPos] <> #0)} then begin
              fRowStart := lPosition + 1;
              inc(fRow);
            end
        end;
      #10: begin
        lPos := lPosition+1;
          while (lPos < fData.length) and CharIsWhitespace(fData[lPos]) do inc(lPos);
          if (fData[lPos] <> '<'){ and (fData[lPos] <> #0)} then begin
            fRowStart := lPosition + 1;
            inc(fRow);
          end
      end;
    end;
    inc(lPosition);
  end;
  while CharIsWhitespace(fData[lPosition-1]) do
    lPosition := lPosition-1;
  fLength := lPosition - fPos;
  Value := new String(fData, lStart, lPosition-lStart);
  Token := XmlTokenKind.SymbolData;
end;

method XmlTokenizer.ParseComment;
begin
  var lPosition := fPos+4;
  var Comment := true;
  while Comment do begin
    if (lPosition >= fData.length) then begin
      Token := XmlTokenKind.EOF;
      fPos := lPosition;
      exit;
    end;
    case fData[lPosition] of
      #13: begin
        if (fData.Length > lPosition+1) and (fData[lPosition + 1] = #10) then inc(lPosition);
        fRowStart := lPosition + 1;
        inc(fRow);
      end;
      #10: begin
        fRowStart := lPosition+1;
        inc(fRow);
      end;
      '-': if (fData.Length > lPosition+1) and (fData[lPosition+1] = '-') then Comment := false;
    end;
    inc(lPosition);
  end;
  if (fData.Length > lPosition+1) and (fData[lPosition+1] <> '>') then begin
    Token := XmlTokenKind.SyntaxError;
    fPos := lPosition;
    Value := "For compatibility, ""--"" must not occur within comments.";
  end
  else begin
    fLength := lPosition - fPos+2;
    Value := new String(fData,fPos+4,fLength-7);
    Token := XmlTokenKind.Comment;
  end;
end;

method XmlTokenizer.ParseCData;
begin
  var lPosition := fPos+9;
  var CData := true;
  while CData do begin
    if (lPosition >= fData.length) then begin
      Token := XmlTokenKind.EOF;
      fPos := lPosition;
      exit;
    end;
    case fData[lPosition] of
      #13: begin
        if (fData.Length > lPosition+1) and (fData[lPosition + 1] = #10) then inc(lPosition);
        fRowStart := lPosition + 1;
        inc(fRow);
      end;
      #10: begin
        fRowStart := lPosition+1;
        inc(fRow);
      end;
      ']': if (fData.Length > lPosition+1) and (fData[lPosition+1] = ']') then CData := false;
    end;
    inc(lPosition);
  end;
  if (fData.Length > lPosition+1) and (fData[lPosition+1] <> '>') then begin
    Token := XmlTokenKind.SyntaxError;
    fPos := lPosition;
    Value := "CData section couldn't contain ']]' ";
  end
  else begin
    fLength := lPosition - fPos+2;
    Value := new String(fData,fPos+9,fLength-12);
    Token := XmlTokenKind.CData;
  end;
end;

end.