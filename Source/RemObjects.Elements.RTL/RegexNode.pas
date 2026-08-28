namespace RemObjects.Elements.RTL;

interface

type
  RegexNodeKind = assembly enum(
    Empty,
    Literal,
    AnyChar,
    CharClass,
    StartAnchor,
    EndAnchor,
    WordBoundary,
    NotWordBoundary,
    Group,
    Alternation,
    Concat,
    Quantifier
    );

  RegexCharClassItemKind = assembly enum(
    Range,
    Digit,
    NotDigit,
    Word,
    NotWord,
    Space,
    NotSpace
    );

  RegexCharClassItem = assembly class
  public
    Kind: RegexCharClassItemKind;
    LoChar: Char;
    HiChar: Char;

    class method Range(aLo: Char; aHi: Char): not nullable RegexCharClassItem;
    begin
      result := new RegexCharClassItem;
      result.Kind := RegexCharClassItemKind.Range;
      result.LoChar := aLo;
      result.HiChar := aHi;
    end;

    class method Shorthand(aKind: RegexCharClassItemKind): not nullable RegexCharClassItem;
    begin
      result := new RegexCharClassItem;
      result.Kind := aKind;
    end;

    method Matches(aChar: Char): Boolean;
    begin
      case Kind of
        RegexCharClassItemKind.Range: result := (aChar >= LoChar) and (aChar <= HiChar);
        RegexCharClassItemKind.Digit: result := aChar.IsDigit;
        RegexCharClassItemKind.NotDigit: result := not aChar.IsDigit;
        RegexCharClassItemKind.Word: result := aChar.IsLetterOrNumber or (aChar = '_');
        RegexCharClassItemKind.NotWord: result := not (aChar.IsLetterOrNumber or (aChar = '_'));
        RegexCharClassItemKind.Space: result := aChar.IsWhitespace;
        RegexCharClassItemKind.NotSpace: result := not aChar.IsWhitespace;
      end;
    end;
  end;

  // Plain-data AST node: a single class covers every regex construct rather than a
  // subclass per kind, since most fields (Child/Children) are shared across kinds
  // and the tree is only ever consumed by the matcher in Regex.pas.
  RegexNode = assembly class
  public
    Kind: RegexNodeKind;

    LiteralChar: Char;

    CharClassItems: List<RegexCharClassItem>;
    CharClassNegated: Boolean;

    Child: RegexNode; // Group, Quantifier
    Children: List<RegexNode>; // Alternation, Concat

    GroupIndex: Integer := -1; // Group; -1 = non-capturing

    MinRepeat: Integer; // Quantifier
    MaxRepeat: Integer; // Quantifier; -1 = unbounded
    Lazy: Boolean; // Quantifier

    constructor; empty;

    method MatchesCharClass(aChar: Char): Boolean;
    begin
      result := false;
      for each item in CharClassItems do
        if item.Matches(aChar) then begin
          result := true;
          break;
        end;
      if CharClassNegated then
        result := not result;
    end;
  end;

implementation

end.
