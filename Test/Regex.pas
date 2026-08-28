namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  RegexTests = public class(Test)
  public

    method Literals;
    begin
      var lRegex := new Regex withPattern("hello");
      Check.IsTrue(lRegex.IsMatch("say hello world"));
      Check.IsFalse(lRegex.IsMatch("say goodbye world"));
      var lMatch := lRegex.Match("say hello world");
      Check.IsNotNil(lMatch);
      Check.AreEqual(lMatch.Value, "hello");
      Check.AreEqual(lMatch.Index, 4);
    end;

    method AnyCharAndEscaping;
    begin
      Check.IsTrue(new Regex withPattern("h.llo").IsMatch("hello"));
      Check.IsFalse(new Regex withPattern("h.llo").IsMatch("h" + #10 + "llo")); // '.' doesn't match newline
      Check.IsTrue(new Regex withPattern("3\.14").IsMatch("pi is 3.14"));
      Check.IsFalse(new Regex withPattern("3\.14").IsMatch("pi is 3x14"));
    end;

    method CharacterClasses;
    begin
      var lRegex := new Regex withPattern("[a-zA-Z0-9_]+");
      var lMatch := lRegex.Match("  hello_World42!  ");
      Check.IsNotNil(lMatch);
      Check.AreEqual(lMatch.Value, "hello_World42");

      Check.IsTrue(new Regex withPattern("[^0-9]+").IsMatch("abc"));
      Check.IsFalse(new Regex withPattern("^[^0-9]+$").IsMatch("abc123"));

      Check.IsTrue(new Regex withPattern("\d+").IsMatch("room 42"));
      Check.IsFalse(new Regex withPattern("^\d+$").IsMatch("42a"));
      Check.IsTrue(new Regex withPattern("^\w+$").IsMatch("word_123"));
      Check.IsTrue(new Regex withPattern("^\s+$").IsMatch("   " + #9));
    end;

    method QuantifiersGreedy;
    begin
      var lMatch := new Regex withPattern("a.*b").Match("a123b456b");
      Check.IsNotNil(lMatch);
      Check.AreEqual(lMatch.Value, "a123b456b"); // greedy: matches to the LAST b

      Check.IsTrue(new Regex withPattern("ab+c").IsMatch("abbbbc"));
      Check.IsFalse(new Regex withPattern("ab+c").IsMatch("ac"));
      Check.IsTrue(new Regex withPattern("ab?c").IsMatch("ac"));
      Check.IsTrue(new Regex withPattern("ab?c").IsMatch("abc"));
      Check.IsFalse(new Regex withPattern("ab?c").IsMatch("abbc"));

      Check.IsTrue(new Regex withPattern("^a{2,4}$").IsMatch("aaa"));
      Check.IsFalse(new Regex withPattern("^a{2,4}$").IsMatch("a"));
      Check.IsFalse(new Regex withPattern("^a{2,4}$").IsMatch("aaaaa"));
      Check.IsTrue(new Regex withPattern("^a{3}$").IsMatch("aaa"));
      Check.IsTrue(new Regex withPattern("^a{2,}$").IsMatch("aaaaaa"));
    end;

    method QuantifiersLazy;
    begin
      var lMatch := new Regex withPattern("a.*?b").Match("a123b456b");
      Check.IsNotNil(lMatch);
      Check.AreEqual(lMatch.Value, "a123b"); // lazy: stops at the FIRST b

      lMatch := new Regex withPattern("<.+?>").Match("<a><b>");
      Check.AreEqual(lMatch.Value, "<a>");
    end;

    method Alternation;
    begin
      var lRegex := new Regex withPattern("cat|dog|bird");
      Check.IsTrue(lRegex.IsMatch("I have a dog"));
      Check.IsTrue(lRegex.IsMatch("I have a cat"));
      Check.IsFalse(lRegex.IsMatch("I have a fish"));

      Check.IsTrue(new Regex withPattern("^(foo|bar)baz$").IsMatch("foobaz"));
      Check.IsTrue(new Regex withPattern("^(foo|bar)baz$").IsMatch("barbaz"));
      Check.IsFalse(new Regex withPattern("^(foo|bar)baz$").IsMatch("bazbaz"));
    end;

    method CapturingGroups;
    begin
      var lRegex := new Regex withPattern("(\d+)-(\d+)-(\d+)");
      var lMatch := lRegex.Match("date: 2026-08-24 end");
      Check.IsNotNil(lMatch);
      Check.AreEqual(lMatch.Value, "2026-08-24");
      Check.AreEqual(lRegex.GroupCount, 3);
      Check.AreEqual(lMatch.Groups.Count, 4); // whole match + 3 groups
      Check.AreEqual(lMatch.Groups[0], "2026-08-24");
      Check.AreEqual(lMatch.Groups[1], "2026");
      Check.AreEqual(lMatch.Groups[2], "08");
      Check.AreEqual(lMatch.Groups[3], "24");

      // non-capturing group shouldn't add to GroupCount
      var lNonCapturing := new Regex withPattern("(?:\d+)-(\w+)");
      Check.AreEqual(lNonCapturing.GroupCount, 1);
      var lMatch2 := lNonCapturing.Match("12-abc");
      Check.AreEqual(lMatch2.Groups[1], "abc");
    end;

    method Anchors;
    begin
      Check.IsTrue(new Regex withPattern("^abc$").IsMatch("abc"));
      Check.IsFalse(new Regex withPattern("^abc$").IsMatch("xabc"));
      Check.IsFalse(new Regex withPattern("^abc$").IsMatch("abcx"));
      Check.IsTrue(new Regex withPattern("^\bfoo\b$").IsMatch("foo"));
      Check.IsFalse(new Regex withPattern("\bfoo\b").IsMatch("foobar"));
      Check.IsTrue(new Regex withPattern("\bfoo\b").IsMatch("a foo b"));
    end;

    method RealWorldPatterns;
    begin
      // simple email-like pattern
      var lEmail := new Regex withPattern("^[a-zA-Z0-9_.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
      Check.IsTrue(lEmail.IsMatch("marc@askalf.com"));
      Check.IsFalse(lEmail.IsMatch("not an email"));

      // date shape \d+-\d+-\d+
      var lDate := new Regex withPattern("\d{4}-\d{2}-\d{2}");
      Check.IsTrue(lDate.IsMatch("today is 2026-08-24."));
      var lAllDates := lDate.Matches("from 2026-08-24 to 2026-09-01");
      Check.AreEqual(lAllDates.Count, 2);
      Check.AreEqual(lAllDates[0].Value, "2026-08-24");
      Check.AreEqual(lAllDates[1].Value, "2026-09-01");
    end;

    method ReplaceAndSplit;
    begin
      var lRegex := new Regex withPattern("(\w+)@(\w+)");
      Check.AreEqual(lRegex.Replace("contact: marc@askalf", "$2:$1"), "contact: askalf:marc");

      var lParts := new Regex withPattern("\s*,\s*").Split("a, b,c ,  d");
      Check.AreEqual(lParts.Count, 4);
      Check.AreEqual(lParts[0], "a");
      Check.AreEqual(lParts[1], "b");
      Check.AreEqual(lParts[2], "c");
      Check.AreEqual(lParts[3], "d");
    end;

    method EmptyPatternAndInput;
    begin
      var lEmptyPattern := new Regex withPattern("");
      Check.IsTrue(lEmptyPattern.IsMatch(""));
      Check.IsTrue(lEmptyPattern.IsMatch("anything"));
      var lMatch := lEmptyPattern.Match("anything");
      Check.AreEqual(lMatch.Value, "");
      Check.AreEqual(lMatch.Index, 0);

      var lNonEmptyPattern := new Regex withPattern("a+");
      Check.IsFalse(lNonEmptyPattern.IsMatch(""));
      Check.IsNil(lNonEmptyPattern.Match(""));
    end;

    method CaseSensitivity;
    begin
      Check.IsTrue(new Regex withPattern("ABC").IsMatch("ABC"));
      Check.IsFalse(new Regex withPattern("ABC").IsMatch("abc"));
      Check.IsFalse(new Regex withPattern("[A-Z]+").IsMatch("lowercase"));
      Check.IsTrue(new Regex withPattern("[a-z]+").IsMatch("lowercase"));
    end;

    method EscapingMetacharacters;
    begin
      Check.IsTrue(new Regex withPattern("a\*b").IsMatch("a*b"));
      Check.IsFalse(new Regex withPattern("a\*b").IsMatch("aXb"));
      Check.IsTrue(new Regex withPattern("a\+b").IsMatch("a+b"));
      Check.IsTrue(new Regex withPattern("a\?b").IsMatch("a?b"));
      Check.IsTrue(new Regex withPattern("\(a\)").IsMatch("(a)"));
      Check.IsTrue(new Regex withPattern("a\[b\]c").IsMatch("a[b]c"));
      Check.IsTrue(new Regex withPattern("a\{2\}").IsMatch("a{2}"));
      Check.IsTrue(new Regex withPattern("a\|b").IsMatch("a|b"));
      Check.IsFalse(new Regex withPattern("a\|b").IsMatch("a"));
      Check.IsTrue(new Regex withPattern("\^abc\$").IsMatch("^abc$"));
      // an unrecognized escape just means "this char literally"
      Check.IsTrue(new Regex withPattern("a\-b").IsMatch("a-b"));
      Check.IsTrue(new Regex withPattern("a\@b").IsMatch("a@b"));
    end;

    method WhitespaceEscapes;
    begin
      Check.IsTrue(new Regex withPattern("a\nb").IsMatch("a" + #10 + "b"));
      Check.IsTrue(new Regex withPattern("a\rb").IsMatch("a" + #13 + "b"));
      Check.IsTrue(new Regex withPattern("a\tb").IsMatch("a" + #9 + "b"));
      Check.IsFalse(new Regex withPattern("a\nb").IsMatch("a b"));
    end;

    method NegatedCharacterClass;
    begin
      var lRegex := new Regex withPattern("[^aeiou]+");
      Check.AreEqual(lRegex.Match("bcdfg").Value, "bcdfg");
      Check.AreEqual(lRegex.Match("xaeiouy").Value, "x");

      Check.IsTrue(new Regex withPattern("^[^0-9]+$").IsMatch("abcXYZ"));
      Check.IsFalse(new Regex withPattern("^[^0-9]+$").IsMatch("abc1"));
    end;

    method CharacterClassEdgeCases;
    begin
      // a trailing/leading dash inside [] is a literal '-', not a range
      Check.IsTrue(new Regex withPattern("^[a-]+$").IsMatch("a-a--"));
      Check.IsTrue(new Regex withPattern("^[-a]+$").IsMatch("-a-a"));
      Check.IsFalse(new Regex withPattern("^[a-]+$").IsMatch("ab"));

      // a ']' immediately after '[' (or '[^') is a literal ']', not the closing bracket
      Check.IsTrue(new Regex withPattern("^[]a]+$").IsMatch("]a]a]"));
      Check.IsTrue(new Regex withPattern("^[^]a]+$").IsMatch("xyz"));
      Check.IsFalse(new Regex withPattern("^[^]a]+$").IsMatch("xay"));
    end;

    method MixedShorthandInClass;
    begin
      var lRegex := new Regex withPattern("^[\da-f]+$");
      Check.IsTrue(lRegex.IsMatch("0123456789abcdef"));
      Check.IsFalse(lRegex.IsMatch("0123456789ABCDEF"));

      Check.IsTrue(new Regex withPattern("^[\s,;]+$").IsMatch(" ,;  ,"));
    end;

    method ExactAndOpenEndedRepeat;
    begin
      Check.IsTrue(new Regex withPattern("^a{0}b$").IsMatch("b"));
      Check.IsFalse(new Regex withPattern("^a{0}b$").IsMatch("ab"));
      Check.IsTrue(new Regex withPattern("^a{0,0}b$").IsMatch("b"));
      Check.IsTrue(new Regex withPattern("^a{2}$").IsMatch("aa"));
      Check.IsFalse(new Regex withPattern("^a{2}$").IsMatch("aaa"));
      Check.IsFalse(new Regex withPattern("^a{2}$").IsMatch("a"));
      Check.IsTrue(new Regex withPattern("^a{2,}$").IsMatch("aaaaaaaa"));
      Check.IsFalse(new Regex withPattern("^a{2,}$").IsMatch("a"));
    end;

    method QuantifierOnGroup;
    begin
      Check.IsTrue(new Regex withPattern("^(ab){2,3}$").IsMatch("abab"));
      Check.IsTrue(new Regex withPattern("^(ab){2,3}$").IsMatch("ababab"));
      Check.IsFalse(new Regex withPattern("^(ab){2,3}$").IsMatch("ab"));
      Check.IsFalse(new Regex withPattern("^(ab){2,3}$").IsMatch("abababab"));
    end;

    method QuantifierOnCharClass;
    begin
      Check.IsTrue(new Regex withPattern("^[abc]{2,4}$").IsMatch("abca"));
      Check.IsFalse(new Regex withPattern("^[abc]{2,4}$").IsMatch("abcad"));
      Check.IsTrue(new Regex withPattern("^\d{3}-\d{4}$").IsMatch("555-1234"));
    end;

    method ZeroWidthQuantifierGuard;
    begin
      // (a*)* can match its inner group zero-width infinitely; must not hang, and
      // should still find the longest real match.
      Check.IsTrue(new Regex withPattern("(a*)*").IsMatch(""));
      var lMatch := new Regex withPattern("(a*)*").Match("aaa");
      Check.AreEqual(lMatch.Value, "aaa");

      Check.IsTrue(new Regex withPattern("(a?)*b").IsMatch("aaab"));
      Check.IsTrue(new Regex withPattern("(a?)*b").IsMatch("b"));
    end;

    method AlternationWithQuantifiers;
    begin
      Check.IsTrue(new Regex withPattern("^(a|b)*$").IsMatch("abababba"));
      Check.IsTrue(new Regex withPattern("^(a|b)*$").IsMatch(""));
      Check.IsFalse(new Regex withPattern("^(a|b)*$").IsMatch("abc"));

      var lMatch := new Regex withPattern("a(b|c)*d").Match("xxabcbcdxx");
      Check.AreEqual(lMatch.Value, "abcbcd");
    end;

    method NestedGroups;
    begin
      var lRegex := new Regex withPattern("((a)(b))");
      var lMatch := lRegex.Match("ab");
      Check.AreEqual(lRegex.GroupCount, 3);
      Check.AreEqual(lMatch.Groups[1], "ab");
      Check.AreEqual(lMatch.Groups[2], "a");
      Check.AreEqual(lMatch.Groups[3], "b");
    end;

    method RepeatedGroupCapturesLastIteration;
    begin
      var lRegex := new Regex withPattern("(a)+");
      var lMatch := lRegex.Match("aaa");
      Check.AreEqual(lMatch.Value, "aaa");
      Check.AreEqual(lMatch.Groups[1], "a"); // only the LAST iteration's capture survives

      var lCsv := new Regex withPattern("(\w+,)+");
      var lMatch2 := lCsv.Match("aa,bb,cc,");
      Check.AreEqual(lMatch2.Value, "aa,bb,cc,");
      Check.AreEqual(lMatch2.Groups[1], "cc,");
    end;

    method GroupInUntakenAlternativeIsNil;
    begin
      var lRegex := new Regex withPattern("(a)|(b)");
      var lMatch := lRegex.Match("b");
      Check.AreEqual(lMatch.Value, "b");
      Check.IsNil(lMatch.Groups[1]);
      Check.AreEqual(lMatch.Groups[2], "b");

      lMatch := lRegex.Match("a");
      Check.AreEqual(lMatch.Groups[1], "a");
      Check.IsNil(lMatch.Groups[2]);
    end;

    method AnchorsAreStringBoundaryOnly;
    begin
      // ^ and $ only match the true start/end of the whole input (no multiline mode)
      Check.IsFalse(new Regex withPattern("a^b").IsMatch("ab"));
      Check.IsFalse(new Regex withPattern("a$b").IsMatch("ab"));
      Check.IsFalse(new Regex withPattern("^b").IsMatch("a" + #10 + "b"));
      Check.IsTrue(new Regex withPattern("^a").IsMatch("a" + #10 + "b"));
    end;

    method WordBoundaryVariants;
    begin
      Check.IsTrue(new Regex withPattern("\bcat\b").IsMatch("a cat sat"));
      Check.IsFalse(new Regex withPattern("\bcat\b").IsMatch("concatenate"));
      Check.IsTrue(new Regex withPattern("\Bcat\B").IsMatch("concatenate"));
      Check.IsFalse(new Regex withPattern("\Bcat\B").IsMatch("a cat sat"));
      Check.IsTrue(new Regex withPattern("^\bword").IsMatch("word up"));
      Check.IsTrue(new Regex withPattern("word\b$").IsMatch("a word"));
    end;

    method MatchesNonOverlapping;
    begin
      var lMatches := new Regex withPattern("aa").Matches("aaaa");
      Check.AreEqual(lMatches.Count, 2);
      Check.AreEqual(lMatches[0].Index, 0);
      Check.AreEqual(lMatches[1].Index, 2);

      Check.AreEqual(new Regex withPattern("x").Matches("aaaa").Count, 0);
      Check.AreEqual(new Regex withPattern("a").Matches("aaaa").Count, 4);
    end;

    method MatchStartAtOverload;
    begin
      var lRegex := new Regex withPattern("\d+");
      var lFirst := lRegex.Match("12 34 56");
      Check.AreEqual(lFirst.Value, "12");
      var lSecond := lRegex.Match("12 34 56", lFirst.Index + lFirst.Value.Length);
      Check.AreEqual(lSecond.Value, "34");
      Check.IsNil(lRegex.Match("12 34 56", 100));
    end;

    method ReplaceEdgeCases;
    begin
      var lRegex := new Regex withPattern("\d+");
      Check.AreEqual(lRegex.Replace("no numbers here", "#"), "no numbers here");
      Check.AreEqual(lRegex.Replace("a1b22c333", "#"), "a#b#c#");
      Check.AreEqual(lRegex.Replace("a1b22c333", ""), "abc");
      Check.AreEqual(new Regex withPattern("a").Replace("banana", "$$"), "b$n$n$");

      var lGroupRegex := new Regex withPattern("(\w+)=(\w+)");
      Check.AreEqual(lGroupRegex.Replace("x=1, y=2", "$2=$1"), "1=x, 2=y");
      // out-of-range group reference is simply dropped
      Check.AreEqual(lGroupRegex.Replace("x=1", "[$9]"), "[]");
    end;

    method SplitEdgeCases;
    begin
      var lCommaRegex := new Regex withPattern(",");
      var lParts := lCommaRegex.Split("a,b,c");
      Check.AreEqual(lParts.Count, 3);

      // no match at all -> the whole string comes back as a single element
      var lNoMatch := new Regex withPattern("x").Split("abc");
      Check.AreEqual(lNoMatch.Count, 1);
      Check.AreEqual(lNoMatch[0], "abc");

      // delimiter at the very start and very end produces leading/trailing empty pieces
      var lEdges := new Regex withPattern(",").Split(",a,b,");
      Check.AreEqual(lEdges.Count, 4);
      Check.AreEqual(lEdges[0], "");
      Check.AreEqual(lEdges[1], "a");
      Check.AreEqual(lEdges[2], "b");
      Check.AreEqual(lEdges[3], "");
    end;

    method RealWorldPatterns2;
    begin
      var lPhone := new Regex withPattern("\(\d{3}\) \d{3}-\d{4}");
      Check.IsTrue(lPhone.IsMatch("call (555) 123-4567 now"));
      Check.IsFalse(lPhone.IsMatch("call 555-123-4567 now"));

      var lHexColor := new Regex withPattern("^#[0-9a-fA-F]{6}$");
      Check.IsTrue(lHexColor.IsMatch("#1A2b3C"));
      Check.IsFalse(lHexColor.IsMatch("#1A2b3"));
      Check.IsFalse(lHexColor.IsMatch("1A2b3C"));

      var lIpLike := new Regex withPattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$");
      Check.IsTrue(lIpLike.IsMatch("192.168.0.1"));
      Check.IsTrue(lIpLike.IsMatch("1.2.3.4"));
      Check.IsFalse(lIpLike.IsMatch("1.2.3"));

      var lTrimmed := new Regex withPattern("^\s+|\s+$").Replace("   padded text   ", "");
      Check.AreEqual(lTrimmed, "padded text"); // Replace strips every match, so both the leading and trailing runs go
    end;

    method InvalidPatternsThrow;
    begin
      Check.Throws(() -> new Regex withPattern("(unterminated"));
      Check.Throws(() -> new Regex withPattern("[unterminated"));
      Check.Throws(() -> new Regex withPattern("*nothingtorepeat"));
      Check.Throws(() -> new Regex withPattern("+nothingtorepeat"));
      Check.Throws(() -> new Regex withPattern("(?=lookahead)"));
      Check.Throws(() -> new Regex withPattern("(?!lookahead)"));
      Check.Throws(() -> new Regex withPattern("[z-a]")); // invalid range, hi < lo
      Check.Throws(() -> new Regex withPattern("abc)")); // unmatched closing paren
    end;

    method FromPatternFactory;
    begin
      var lRegex := Regex.FromPattern("\d+");
      Check.IsTrue(lRegex.IsMatch("abc123"));
      Check.AreEqual(lRegex.Match("abc123").Value, "123");
    end;

    method PropertiesSanity;
    begin
      var lRegex := new Regex withPattern("(a)(b)(c)");
      Check.AreEqual(lRegex.Pattern, "(a)(b)(c)");
      Check.AreEqual(lRegex.GroupCount, 3);

      var lNoGroups := new Regex withPattern("abc");
      Check.AreEqual(lNoGroups.GroupCount, 0);
    end;

  end;

end.
