namespace RemObjects.Elements.RTL;

interface

type
  RegexException = public class(RTLException);

  RegexMatch = public class
  private
    fValue: not nullable String;
    fIndex: Integer;
    fGroups: not nullable List<nullable String>;
  assembly
    constructor withValue(aValue: not nullable String) Index(aIndex: Integer) Groups(aGroups: not nullable List<nullable String>);
    begin
      fValue := aValue;
      fIndex := aIndex;
      fGroups := aGroups;
    end;
  public
    property Value: not nullable String read fValue;
    property Index: Integer read fIndex;
    property Groups: not nullable ImmutableList<nullable String> read fGroups; // index 0 = whole match, 1.. = capture groups; nil = group didn't participate

    [ToString]
    method ToString(): String; override;
    begin
      result := fValue;
    end;
  end;

  RegexContinuation = assembly block(aPos: Integer): Boolean;

  // Classic recursive-descent backtracking matcher, implemented via continuation-passing
  // (each node tries to match, then hands off to aCont to match the rest of the pattern;
  // aCont returning false triggers backtracking into the node's remaining options).
  // One instance is used per match attempt so capture-group state never leaks across attempts.
  RegexMatcher = assembly class
  private
    fInput: not nullable String;
    fGroupStarts: array of Integer;
    fGroupEnds: array of Integer;

    method IsWordCharAt(aPos: Integer): Boolean;
    begin
      result := (aPos >= 0) and (aPos < fInput.Length) and (fInput[aPos].IsLetterOrNumber or (fInput[aPos] = '_'));
    end;

    method MatchNode(aNode: not nullable RegexNode; aPos: Integer; aCont: not nullable RegexContinuation): Boolean;
    begin
      case aNode.Kind of
        RegexNodeKind.Empty: result := aCont(aPos);
        RegexNodeKind.Literal: result := (aPos < fInput.Length) and (fInput[aPos] = aNode.LiteralChar) and aCont(aPos + 1);
        RegexNodeKind.AnyChar: result := (aPos < fInput.Length) and (fInput[aPos] <> #10) and aCont(aPos + 1);
        RegexNodeKind.CharClass: result := (aPos < fInput.Length) and aNode.MatchesCharClass(fInput[aPos]) and aCont(aPos + 1);
        RegexNodeKind.StartAnchor: result := (aPos = 0) and aCont(aPos);
        RegexNodeKind.EndAnchor: result := (aPos = fInput.Length) and aCont(aPos);
        RegexNodeKind.WordBoundary: result := (IsWordCharAt(aPos - 1) <> IsWordCharAt(aPos)) and aCont(aPos);
        RegexNodeKind.NotWordBoundary: result := (IsWordCharAt(aPos - 1) = IsWordCharAt(aPos)) and aCont(aPos);
        RegexNodeKind.Concat: result := MatchSeq(aNode.Children, 0, aPos, aCont);
        RegexNodeKind.Alternation: result := MatchAlt(aNode.Children, aPos, aCont);
        RegexNodeKind.Quantifier: result := MatchQuantifier(aNode, 0, aPos, aCont);
        RegexNodeKind.Group: result := MatchGroup(aNode, aPos, aCont);
      end;
    end;

    method MatchSeq(aNodes: not nullable List<RegexNode>; aIndex: Integer; aPos: Integer; aCont: not nullable RegexContinuation): Boolean;
    begin
      if aIndex >= aNodes.Count then
        result := aCont(aPos)
      else
        result := MatchNode(aNodes[aIndex], aPos, method(aNextPos: Integer): Boolean begin
          result := MatchSeq(aNodes, aIndex + 1, aNextPos, aCont);
        end);
    end;

    method MatchAlt(aNodes: not nullable List<RegexNode>; aPos: Integer; aCont: not nullable RegexContinuation): Boolean;
    begin
      result := false;
      for each lAlternative in aNodes do
        if MatchNode(lAlternative, aPos, aCont) then
          exit true;
    end;

    method MatchGroup(aNode: not nullable RegexNode; aPos: Integer; aCont: not nullable RegexContinuation): Boolean;
    begin
      if aNode.GroupIndex < 0 then begin
        result := MatchNode(aNode.Child, aPos, aCont);
        exit;
      end;
      var lGroupIndex := aNode.GroupIndex;
      var lSavedStart := fGroupStarts[lGroupIndex];
      var lSavedEnd := fGroupEnds[lGroupIndex];
      fGroupStarts[lGroupIndex] := aPos;
      result := MatchNode(aNode.Child, aPos, method(aEndPos: Integer): Boolean begin
        var lPreviousEnd := fGroupEnds[lGroupIndex];
        fGroupEnds[lGroupIndex] := aEndPos;
        result := aCont(aEndPos);
        if not result then
          fGroupEnds[lGroupIndex] := lPreviousEnd;
      end);
      if not result then begin
        fGroupStarts[lGroupIndex] := lSavedStart;
        fGroupEnds[lGroupIndex] := lSavedEnd;
      end;
    end;

    method MatchQuantifier(aNode: not nullable RegexNode; aCount: Integer; aPos: Integer; aCont: not nullable RegexContinuation): Boolean;
    begin
      var lChild := aNode.Child;
      var lCanStop := aCount >= aNode.MinRepeat;
      var lCanRepeat := (aNode.MaxRepeat < 0) or (aCount < aNode.MaxRepeat);
      var lRepeatOnce: RegexContinuation := method(aNextPos: Integer): Boolean begin
        if aNextPos = aPos then result := false // guard against an infinite loop on a zero-width repetition
        else result := MatchQuantifier(aNode, aCount + 1, aNextPos, aCont);
      end;
      if aNode.Lazy then begin
        if lCanStop and aCont(aPos) then exit true;
        if lCanRepeat then result := MatchNode(lChild, aPos, lRepeatOnce)
        else result := false;
      end
      else begin
        result := false;
        if lCanRepeat then
          result := MatchNode(lChild, aPos, lRepeatOnce);
        if (not result) and lCanStop then
          result := aCont(aPos);
      end;
    end;

  public
    constructor withInput(aInput: not nullable String) GroupCount(aGroupCount: Integer);
    begin
      fInput := aInput;
      fGroupStarts := new Integer[aGroupCount + 1];
      fGroupEnds := new Integer[aGroupCount + 1];
    end;

    method TryMatchAt(aRoot: not nullable RegexNode; aStart: Integer): nullable RegexMatch;
    begin
      for i: Integer := 0 to length(fGroupStarts) - 1 do begin
        fGroupStarts[i] := -1;
        fGroupEnds[i] := -1;
      end;
      var lEndPos := -1;
      var lMatched := MatchNode(aRoot, aStart, method(aPos: Integer): Boolean begin
        lEndPos := aPos;
        result := true;
      end);
      if not lMatched then exit nil;
      fGroupStarts[0] := aStart;
      fGroupEnds[0] := lEndPos;
      var lValue := fInput.Substring(aStart, lEndPos - aStart);
      var lGroups := new List<nullable String>;
      for i: Integer := 0 to length(fGroupStarts) - 1 do begin
        // NB: assign through a T-typed local, not a bare literal — List<T>.Add(nil)
        // is ambiguous with the Add(sequence/array of T) bulk overloads, which
        // silently no-op on a nil sequence instead of adding one nil element.
        var lGroupValue: nullable String := nil;
        if (fGroupStarts[i] >= 0) and (fGroupEnds[i] >= 0) then
          lGroupValue := fInput.Substring(fGroupStarts[i], fGroupEnds[i] - fGroupStarts[i]);
        lGroups.Add(lGroupValue);
      end;
      result := new RegexMatch withValue(lValue) Index(aStart) Groups(lGroups);
    end;
  end;

  Regex = public class
  private
    fPattern: not nullable String;
    fRoot: not nullable RegexNode;
    fGroupCount: Integer;

    method DoMatch(aInput: not nullable String; aStartAt: Integer): nullable RegexMatch;
    begin
      var lMatcher := new RegexMatcher withInput(aInput) GroupCount(fGroupCount);
      for i: Integer := aStartAt to aInput.Length do begin
        var lMatch := lMatcher.TryMatchAt(fRoot, i);
        if assigned(lMatch) then exit lMatch;
      end;
    end;

    class method ExpandReplacement(aReplacement: not nullable String; aMatch: not nullable RegexMatch): not nullable String;
    begin
      var lSb := new StringBuilder;
      var i := 0;
      while i < aReplacement.Length do begin
        var ch := aReplacement[i];
        if (ch = '$') and (i + 1 < aReplacement.Length) then begin
          var lNext := aReplacement[i + 1];
          if lNext = '$' then begin
            lSb.Append('$');
            inc(i, 2);
            continue;
          end
          else if lNext.IsDigit then begin
            var j := i + 1;
            var lNumStr := "";
            while (j < aReplacement.Length) and aReplacement[j].IsDigit do begin
              lNumStr := lNumStr + aReplacement[j];
              inc(j);
            end;
            var lGroupNum := Convert.ToInt32(lNumStr);
            if lGroupNum < aMatch.Groups.Count then begin
              var lGroupValue := aMatch.Groups[lGroupNum];
              if assigned(lGroupValue) then lSb.Append(lGroupValue);
            end;
            i := j;
            continue;
          end;
        end;
        lSb.Append(ch);
        inc(i);
      end;
      result := lSb.ToString as not nullable;
    end;

  public
    constructor withPattern(aPattern: not nullable String);
    begin
      fPattern := aPattern;
      var lParser := new RegexParser withPattern(aPattern);
      fRoot := lParser.Parse;
      fGroupCount := lParser.GroupCount;
    end;

    // Plain factory alongside the named constructor above, for callers
    // (e.g. Promethium) whose calling convention can't express a labeled
    // constructor call.
    class method FromPattern(aPattern: not nullable String): not nullable Regex;
    begin
      result := new Regex withPattern(aPattern);
    end;

    method IsMatch(aInput: not nullable String): Boolean;
    begin
      result := assigned(Match(aInput));
    end;

    method Match(aInput: not nullable String): nullable RegexMatch;
    begin
      result := DoMatch(aInput, 0);
    end;

    method Match(aInput: not nullable String; aStartAt: Integer): nullable RegexMatch;
    begin
      result := DoMatch(aInput, aStartAt);
    end;

    method Matches(aInput: not nullable String): not nullable List<RegexMatch>;
    begin
      result := new List<RegexMatch>;
      var lStart := 0;
      while lStart <= aInput.Length do begin
        var lMatch := DoMatch(aInput, lStart);
        if not assigned(lMatch) then break;
        result.Add(lMatch);
        if lMatch.Value.Length > 0 then lStart := lMatch.Index + lMatch.Value.Length
        else lStart := lMatch.Index + 1; // avoid looping forever on a zero-length match
      end;
    end;

    method Replace(aInput: not nullable String; aReplacement: not nullable String): String;
    begin
      var lSb := new StringBuilder;
      var lCopiedUpTo := 0;
      var lStart := 0;
      while lStart <= aInput.Length do begin
        var lMatch := DoMatch(aInput, lStart);
        if not assigned(lMatch) then break;
        lSb.Append(aInput.Substring(lCopiedUpTo, lMatch.Index - lCopiedUpTo));
        lSb.Append(ExpandReplacement(aReplacement, lMatch));
        lCopiedUpTo := lMatch.Index + lMatch.Value.Length;
        if lMatch.Value.Length > 0 then lStart := lCopiedUpTo
        else lStart := lMatch.Index + 1;
      end;
      lSb.Append(aInput.Substring(lCopiedUpTo, aInput.Length - lCopiedUpTo));
      result := lSb.ToString;
    end;

    method Split(aInput: not nullable String): not nullable List<String>;
    begin
      result := new List<String>;
      var lCopiedUpTo := 0;
      var lStart := 0;
      while lStart <= aInput.Length do begin
        var lMatch := DoMatch(aInput, lStart);
        if not assigned(lMatch) then break;
        if lMatch.Value.Length = 0 then begin
          lStart := lMatch.Index + 1;
          continue;
        end;
        result.Add(aInput.Substring(lCopiedUpTo, lMatch.Index - lCopiedUpTo));
        lCopiedUpTo := lMatch.Index + lMatch.Value.Length;
        lStart := lCopiedUpTo;
      end;
      result.Add(aInput.Substring(lCopiedUpTo, aInput.Length - lCopiedUpTo));
    end;

    property Pattern: not nullable String read fPattern;
    property GroupCount: Integer read fGroupCount;
  end;

implementation

end.
