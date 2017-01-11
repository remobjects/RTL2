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

    method CharIsIdentifier(C: Char): Boolean;
    method CharIsWhitespace(C: Char): Boolean;
    method CharIsNameStart(C: Char): Boolean;
    method CharIsName(C: Char): Boolean;
    method IsValidSpecSymbol(S: String): Boolean;

    method Parse;

    method ParseWhitespace;
    method ParseName;
    method ParseValue;
    method ParseSpecSymbol(lPosition: Integer): Boolean;
    method ParseSymbolData;
    method ParseComment;
    method ParseCData;

  public
    constructor (aXml: String);
    constructor (aXml: String; SkipWhitespaces: Boolean);

    method Next: Boolean;
    
    property Xml: String; readonly;
    property Row: Integer read fLastRow + 1;
    property Column: Integer read fPos - fLastRowStart + 1;
    property Value: String read private write;
    property Token:XmlTokenKind read private write;
    property IgnoreWhitespaces: Boolean read write; readonly;
  end;

implementation

{$IF ECHOES}
uses System.Globalization;
{$ENDIF}

constructor XmlTokenizer(aXml: String);
begin
  constructor(aXml, true);
end;

constructor XmlTokenizer(aXml: String; SkipWhitespaces: Boolean);
begin
  Xml := aXml;
  //SugarArgumentNullException.RaiseIfNil(XML, "Xml");
  self.IgnoreWhitespaces := SkipWhitespaces;
  var CharData := Xml.ToCharArray;
  fData := new Char[CharData.Length + 4];
  {$IF COOPER}
  System.arraycopy(CharData, 0, fData, 0, CharData.Length);
  {$ELSEIF ECHOES}
  Array.Copy(CharData, 0, fData, 0, CharData.Length);
  {$ELSEIF TOFFEE}
  rtl.memset(@fData[0], 0, fData.length);
  memcpy(@fData[0], @CharData[0], sizeOf(Char) * CharData.Length);
  {$ENDIF} 
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
  {$IF ECHOES}
    var category := CharUnicodeInfo.GetUnicodeCategory(C);
    exit (category = UnicodeCategory.UppercaseLetter) or (category = UnicodeCategory.LowercaseLetter) or (category = UnicodeCategory.TitlecaseLetter) 
    or (category = UnicodeCategory.OtherLetter) or (category = UnicodeCategory.LetterNumber) or (C = '_') or (C = ':');
  {$ELSE}
    exit (((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or (C = '_') or (C = ':'));
  {$ENDIF}
end;

method XmlTokenizer.CharIsName(C: Char): Boolean;
begin
  exit CharIsNameStart(C) or ((C >='0') and (C <= '9')) or (C = '-')
  {exit (((C >= 'a') and (C<='z')) or ((C >= 'A') and (C <= 'Z')) or
   (C = '_') or (C = ':') or (C = '-') or ((C >='0') and (C <= '9'))); }
end;

method XmlTokenizer.IsValidSpecSymbol(S: String): Boolean;
begin
  exit ((S = "&lt;") or (S = "&gt;") or (S = "&amp;") or (S = "&apos;") or (S = "&quot;"))
end;

method XmlTokenizer.Parse;
begin
  if (fPos>0) and 
    ((fData[fPos-1] = '>') or ((fPos > (fPos-fLength-1)) and (Token = XmlTokenKind.Whitespace) and (fData[fPos-fLength-1] = '>'))) 
    and (fData[fPos] <> #0) and (not(CharIsWhitespace(fData[fPos]))) and (fData[fPos] <> '<') then ParseSymbolData()
  else
    if CharIsNameStart(fData[fPos]) then ParseName
    else 
      if (fData.Length >= fPos+XmlConsts.TAG_DECL_CLOSE.Length) and (new String(fData,fPos,XmlConsts.TAG_DECL_CLOSE.Length) = XmlConsts.TAG_DECL_CLOSE) then begin
        fLength := XmlConsts.TAG_DECL_CLOSE.Length;
        Value:=nil;
        Token := XmlTokenKind.DeclarationEnd;
      end
      else
        case fData[fPos] of 
          ' ', #9, #13, #10: ParseWhitespace;
          '=' : begin
            fLength := 1;
            Value := nil;
            Token := XmlTokenKind.AttributeSeparator;
          end;
          '"' : ParseValue;
          '''' : ParseValue;
          '<': if (fData.Length >= fPos+1) then
            case fData[fPos+1] of 
              '/': begin
                fLength := 2;
                Value := nil;
                Token := XmlTokenKind.TagElementEnd;
              end;
              '!': if (fData.Length>fPos+4) and (fData[fPos+2] = '-') and (fData[fPos+3] = '-') then ParseComment//comment
                else if (fData.Length>fPos+9)and (new String(fData,fPos+2,7) = "[CDATA[") then ParseCData
                  else begin
                    Token := XmlTokenKind.SyntaxError;
                    fPos := fPos+1;
                    Value := "Unknown token";
                  end;
              '?': begin
                if (fData.Length >= fPos+XmlConsts.TAG_DECL_OPEN.Length) and 
                  (new String(fData,fPos,XmlConsts.TAG_DECL_OPEN.Length)  = XmlConsts.TAG_DECL_OPEN) and (CharIsWhitespace(fData[fPos+XmlConsts.TAG_DECL_OPEN.Length])) then begin
                  if fPos = 0 then begin Token := XmlTokenKind.DeclarationStart; 
                    fLength:= XmlConsts.TAG_DECL_OPEN.Length;
                    Value := nil; 
                  end
                  else begin
                    Token := XmlTokenKind.SyntaxError;
                    Value := "No information or whitespaces before the declaration are allowed";
                    //raise new Exception('No information or whitespaces before the declaration are allowed');
                  end
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
            end;
            '>': begin
              fLength := 1;
              Value := nil;
              Token := XmlTokenKind.TagClose;
            end;
            '/': if (fData.Length >= (fPos+1)) and (fData[fPos+1] = '>') then begin
              fLength := 2;
              Value := nil;
              Token := XmlTokenKind.EmptyElementEnd;
              end
              else Token := XmlTokenKind.SlashSymbol;  
            #0 : Token := XmlTokenKind.EOF;
            else begin 
              fLength := 0;
              Value := "Unexpected token "+fData[fPos];
              Token := XmlTokenKind.SyntaxError;
            end;
          end;
end;

method XmlTokenizer.Next: Boolean;
begin
  if Token = XmlTokenKind.EOF then
    exit false;
  while true do begin
    fPos := fPos + fLength;
    fLastRow := fRow;
    fLastRowStart := fRowStart;
    Parse;
    if (Token = XmlTokenKind.EOF) or (Token = XmlTokenKind.SyntaxError) then
      exit false;
    //if IgnoreWhitespaces and (Token = XMLTokenKind.Whitespace) then
    //  continue;
    exit true;
  end;
end;

method XmlTokenizer.ParseWhitespace;
begin
  if not CharIsWhitespace(fData[fPos]) then
    exit;

  var lPosition := fPos;

  while CharIsWhitespace(fData[lPosition]) do begin
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
  while CharIsName(fData[lPosition]) do begin
    if fData[lPosition] = ':' then begin
      inc(colonSymbol);
        if (fData.Length < (lPosition+1)) then begin
          fPos := lPosition+1;
          Token := XmlTokenKind.SyntaxError;
          Value := "Name expected";
          exit;
        end
        else if (CharIsNameStart(fData[lPosition+1]) = false) then begin
          fPos := lPosition+1;
          Token := XmlTokenKind.SyntaxError;
          Value := "Name could't begin from "+fData[lPosition+1]+" symbol";
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
  //var quoteSymbol := fData[fPos];
  //if (quoteSymbol <> '"') and (quoteSymbol <> "'") then exit;
  if (fData[fPos] <> '"') and (fData[fPos] <> "'") then exit;
  //Value := '';
  Value := fData[fPos];
  inc(fPos);
   
  while fData[fPos] <> Value.Substring(0,1){quoteSymbol} do begin
    case fData[fPos] of
      '>' :  Value := Value+'&gt;';
      //'"' : Value := Value + '&quot;';
      //'''' : Value := Value + '&apos;';
      '&' :  if ParseSpecSymbol(fPos) then fPos := fPos + fLength
        else exit;
      #13 : begin 
        if (fData.Length > fPos+1) and (fData[fPos + 1] = #10) then inc(fPos);
        fRowStart := fPos + 1;
        inc(fRow);
        Value := Value+fData[fPos-1]+fData[fPos];
      end;
      #10: begin
        fRowStart := fPos + 1;
        inc(fRow);
        Value := Value+fData[fPos];
      end;
      '<' : begin 
        Token := XmlTokenKind.SyntaxError;
        Value := "Syntax error. Symbol '<' is not allowed in attribute value";
        exit;
        //raise new Exception("Syntax error at "+Row+"/"+Column+"Symbol '<' is not allowed in attribute value");
      end;
      #0: begin 
        Token := XmlTokenKind.EOF;
        exit;
      end;
      else Value := Value+ fData[fPos];
    end;
    inc(fPos);
  end;
  Value := Value + fData[fPos];
  fLength := 1;
  Token := XmlTokenKind.AttributeValue;
end;

method XmlTokenizer.ParseSpecSymbol(lPosition: Integer): Boolean;
begin
  if (fData[lPosition] <> '&') or (fData.Length = lPosition+1)  then exit(false);
  var lPos := lPosition;
  inc(lPos);// := fPos+1;
  var specSymbol := "&";
  while fData[lPos] <> ';' do begin 
    if fData[lPos] =  #0 then begin
      fPos := lPos;
      Token := XmlTokenKind.EOF;
      exit(false);
    end;
    if fData[lPos] = '<' then begin
      fPos := lPos;
      Token := XmlTokenKind.SyntaxError;
      Value := "';' expected but '<' found";
      exit(false);
    end;
    specSymbol := specSymbol+fData[lPos];
    inc(lPos);
  end;
  specSymbol := specSymbol+fData[lPos];
  if IsValidSpecSymbol(specSymbol) then Value := Value + specSymbol
  else begin
    Token := XmlTokenKind.SyntaxError;
    fPos := lPosition;
    Value := "Symbol "+specSymbol+" is unknown";
    exit(false);
  end;
  fLength := lPos - lPosition;
  //fPos := lPosition;
  result := true;
end;

method XmlTokenizer.ParseSymbolData;
begin
  Value := "";
  var lPosition := fPos; 
  var lPos: Integer;
  while ((fData[lPosition] <> '<') and (fData[lPosition] <> #0)) do begin
    case fData[lPosition] of
      '>' :  Value := Value+'&gt;';
      '&' :  if ParseSpecSymbol(lPosition) then lPosition := lPosition + fLength
        else exit;
      #13 : begin 
        if (fData.length<lPosition+1) then begin
          Token := XmlTokenKind.EOF;
          fPos  := lPosition +1;
          exit;
        end
        else if fData[lPosition + 1] = #10 then 
          inc(lPosition);  
          lPos := lPosition+1;
          while CharIsWhitespace(fData[lPos]) do inc(lPos); 
          if (fData[lPos] <> '<') and (fData[lPos] <> #0) then begin 
            fRowStart := lPosition + 1;
            inc(fRow);
            Value := Value+fData[lPosition-1]+fData[lPosition];
          end
      end;
      #10: begin
        lPos := lPosition+1;
          while CharIsWhitespace(fData[lPos]) do inc(lPos); 
          if (fData[lPos] <> '<') and (fData[lPos] <> #0) then begin 
            fRowStart := lPosition + 1;
            inc(fRow);
            Value := Value+fData[lPosition];
          end
      end;
    else Value := Value+ fData[lPosition];
    end;
    inc(lPosition);
  end;
  //fLength := lPosition-fPos;
  //if CharIsWhitespace(fData[lPosition-1]) then begin
    while CharIsWhitespace(fData[lPosition-1]) do
      lPosition := lPosition -1;
    fLength := lPosition - fPos; //Value.Trim.Length;
    Value := Value.Trim;
  //end;
  {if fData[lPosition-1] = #10 then  fLength := fLength-1;
  if fData[lPosition-2] = #13 then fLength := fLength-1;}
  Token := XmlTokenKind.SymbolData;
end;

method XmlTokenizer.ParseComment;
begin
  var lPosition := fPos+4;
  var Comment := true;
  while Comment do begin
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
      #0: begin
        Token :=XmlTokenKind.EOF;
        fPos := lPosition;
        exit;
      end
    end;
    inc(lPosition);
  end;
  if (fData.Length > lPosition+1) and (fData[lPosition+1] <> '>') then begin
    Token := XmlTokenKind.SyntaxError;
    fPos := lPosition;
    Value := "Comment couldn't contain '--'";
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
      #0: begin
        Token := XmlTokenKind.EOF;
        fPos := lPosition;
        exit;
      end
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