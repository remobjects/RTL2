namespace RemObjects.Elements.RTL;

interface

type
  RegexParser = assembly class
  private
    fPattern: not nullable String;
    fPos: Integer;
    fGroupCount: Integer;

    method AtEnd: Boolean; inline;
    method Peek: Char; inline;
    method PeekAt(aOffset: Integer): Char;
    method Advance: Char; inline;

    method ParseAlternation: not nullable RegexNode;
    method ParseConcat: not nullable RegexNode;
    method ParseQuantified: not nullable RegexNode;
    method ParseAtom: not nullable RegexNode;
    method ParseGroup: not nullable RegexNode;
    method ParseCharClass: not nullable RegexNode;
    method ParseClassEscapeItem: not nullable RegexCharClassItem;
    method ParseEscapeAtom: not nullable RegexNode;
    method TryParseBraceQuantifier(out aMin: Integer; out aMax: Integer): Boolean;
  public
    constructor withPattern(aPattern: not nullable String);
    method Parse: not nullable RegexNode;

    property GroupCount: Integer read fGroupCount;
  end;

implementation

constructor RegexParser withPattern(aPattern: not nullable String);
begin
  fPattern := aPattern;
  fPos := 0;
  fGroupCount := 0;
end;

method RegexParser.AtEnd: Boolean;
begin
  result := fPos >= fPattern.Length;
end;

method RegexParser.Peek: Char;
begin
  if AtEnd then result := #0
  else result := fPattern[fPos];
end;

method RegexParser.PeekAt(aOffset: Integer): Char;
begin
  var i := fPos + aOffset;
  if (i < 0) or (i >= fPattern.Length) then result := #0
  else result := fPattern[i];
end;

method RegexParser.Advance: Char;
begin
  result := Peek;
  inc(fPos);
end;

method RegexParser.Parse: not nullable RegexNode;
begin
  result := ParseAlternation;
  if not AtEnd then
    raise new RegexException("Unexpected character '{0}' at position {1}", [Peek, fPos]);
end;

method RegexParser.ParseAlternation: not nullable RegexNode;
begin
  var lFirst := ParseConcat;
  if Peek <> '|' then
    exit lFirst;
  var lAlternatives := new List<RegexNode>;
  lAlternatives.Add(lFirst);
  while Peek = '|' do begin
    Advance;
    lAlternatives.Add(ParseConcat);
  end;
  result := new RegexNode(Kind := RegexNodeKind.Alternation, Children := lAlternatives);
end;

method RegexParser.ParseConcat: not nullable RegexNode;
begin
  var lChildren := new List<RegexNode>;
  while (not AtEnd) and (Peek <> '|') and (Peek <> ')') do
    lChildren.Add(ParseQuantified);
  if lChildren.Count = 0 then result := new RegexNode(Kind := RegexNodeKind.Empty)
  else if lChildren.Count = 1 then result := lChildren[0] as not nullable
  else result := new RegexNode(Kind := RegexNodeKind.Concat, Children := lChildren);
end;

method RegexParser.ParseQuantified: not nullable RegexNode;
begin
  result := ParseAtom;
  if AtEnd then exit;
  var lMin, lMax: Integer;
  var lHasQuantifier := true;
  case Peek of
    '*': begin Advance; lMin := 0; lMax := -1; end;
    '+': begin Advance; lMin := 1; lMax := -1; end;
    '?': begin Advance; lMin := 0; lMax := 1; end;
    '{': begin
      var lSavedPos := fPos;
      if not TryParseBraceQuantifier(out lMin, out lMax) then begin
        fPos := lSavedPos;
        lHasQuantifier := false;
      end;
    end;
    else lHasQuantifier := false;
  end;
  if not lHasQuantifier then exit;
  var lLazy := false;
  if Peek = '?' then begin
    Advance;
    lLazy := true;
  end;
  result := new RegexNode(Kind := RegexNodeKind.Quantifier, Child := result, MinRepeat := lMin, MaxRepeat := lMax, Lazy := lLazy);
end;

method RegexParser.TryParseBraceQuantifier(out aMin: Integer; out aMax: Integer): Boolean;
begin
  Advance; // consume '{'
  var lMinStr := "";
  while (not AtEnd) and Peek.IsDigit do
    lMinStr := lMinStr + Advance;
  if lMinStr = "" then exit false;
  aMin := Convert.ToInt32(lMinStr);
  if Peek = '}' then begin
    Advance;
    aMax := aMin;
    exit true;
  end;
  if Peek <> ',' then exit false;
  Advance; // consume ','
  var lMaxStr := "";
  while (not AtEnd) and Peek.IsDigit do
    lMaxStr := lMaxStr + Advance;
  if Peek <> '}' then exit false;
  Advance; // consume '}'
  if lMaxStr = "" then aMax := -1
  else aMax := Convert.ToInt32(lMaxStr);
  exit true;
end;

method RegexParser.ParseAtom: not nullable RegexNode;
begin
  if AtEnd then
    raise new RegexException("Unexpected end of pattern");
  case Peek of
    '(': result := ParseGroup;
    '[': result := ParseCharClass;
    '.': begin Advance; result := new RegexNode(Kind := RegexNodeKind.AnyChar); end;
    '^': begin Advance; result := new RegexNode(Kind := RegexNodeKind.StartAnchor); end;
    '$': begin Advance; result := new RegexNode(Kind := RegexNodeKind.EndAnchor); end;
    '\': begin Advance; result := ParseEscapeAtom; end;
    '*', '+', '?': raise new RegexException("Quantifier '{0}' without preceding atom at position {1}", [Peek, fPos]);
    else result := new RegexNode(Kind := RegexNodeKind.Literal, LiteralChar := Advance);
  end;
end;

method RegexParser.ParseGroup: not nullable RegexNode;
begin
  Advance; // consume '('
  var lGroupIndex := -1;
  if Peek = '?' then begin
    Advance;
    if Peek = ':' then
      Advance
    else
      raise new RegexException("Unsupported group syntax '(?{0}' — lookaround and named groups are not supported", [Peek]);
  end
  else begin
    inc(fGroupCount);
    lGroupIndex := fGroupCount;
  end;
  var lInner := ParseAlternation;
  if Peek <> ')' then
    raise new RegexException("Expected ')' at position {0}", [fPos]);
  Advance; // consume ')'
  result := new RegexNode(Kind := RegexNodeKind.Group, GroupIndex := lGroupIndex, Child := lInner);
end;

method RegexParser.ParseEscapeAtom: not nullable RegexNode;
begin
  if AtEnd then
    raise new RegexException("Dangling escape at end of pattern");
  var ch := Advance;
  case ch of
    'd': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.Digit)]));
    'D': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotDigit)]));
    'w': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.Word)]));
    'W': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotWord)]));
    's': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.Space)]));
    'S': result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := new List<RegexCharClassItem>([RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotSpace)]));
    'b': result := new RegexNode(Kind := RegexNodeKind.WordBoundary);
    'B': result := new RegexNode(Kind := RegexNodeKind.NotWordBoundary);
    'n': result := new RegexNode(Kind := RegexNodeKind.Literal, LiteralChar := #10);
    'r': result := new RegexNode(Kind := RegexNodeKind.Literal, LiteralChar := #13);
    't': result := new RegexNode(Kind := RegexNodeKind.Literal, LiteralChar := #9);
    else result := new RegexNode(Kind := RegexNodeKind.Literal, LiteralChar := ch);
  end;
end;

method RegexParser.ParseCharClass: not nullable RegexNode;
begin
  Advance; // consume '['
  var lNegated := false;
  if Peek = '^' then begin
    Advance;
    lNegated := true;
  end;
  var lItems := new List<RegexCharClassItem>;
  var lFirst := true;
  while (not AtEnd) and ((Peek <> ']') or lFirst) do begin
    lFirst := false;
    var lLo: Char;
    if Peek = '\' then begin
      Advance;
      var lItem := ParseClassEscapeItem;
      if lItem.Kind <> RegexCharClassItemKind.Range then begin
        lItems.Add(lItem);
        continue;
      end;
      lLo := lItem.LoChar;
    end
    else
      lLo := Advance;
    if (Peek = '-') and (PeekAt(1) <> ']') and (PeekAt(1) <> #0) then begin
      Advance; // consume '-'
      var lHi: Char;
      if Peek = '\' then begin
        Advance;
        var lHiItem := ParseClassEscapeItem;
        if lHiItem.Kind <> RegexCharClassItemKind.Range then
          raise new RegexException("Invalid character range in character class");
        lHi := lHiItem.LoChar;
      end
      else
        lHi := Advance;
      if ord(lHi) < ord(lLo) then
        raise new RegexException("Invalid character range '{0}-{1}'", [lLo, lHi]);
      lItems.Add(RegexCharClassItem.Range(lLo, lHi));
    end
    else
      lItems.Add(RegexCharClassItem.Range(lLo, lLo));
  end;
  if AtEnd then
    raise new RegexException("Unterminated character class");
  Advance; // consume ']'
  result := new RegexNode(Kind := RegexNodeKind.CharClass, CharClassItems := lItems, CharClassNegated := lNegated);
end;

method RegexParser.ParseClassEscapeItem: not nullable RegexCharClassItem;
begin
  if AtEnd then
    raise new RegexException("Dangling escape in character class");
  var ch := Advance;
  case ch of
    'd': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.Digit);
    'D': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotDigit);
    'w': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.Word);
    'W': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotWord);
    's': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.Space);
    'S': result := RegexCharClassItem.Shorthand(RegexCharClassItemKind.NotSpace);
    'n': result := RegexCharClassItem.Range(#10, #10);
    'r': result := RegexCharClassItem.Range(#13, #13);
    't': result := RegexCharClassItem.Range(#9, #9);
    else result := RegexCharClassItem.Range(ch, ch);
  end;
end;

end.
