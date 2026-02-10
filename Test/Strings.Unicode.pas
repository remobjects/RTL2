namespace Elements.RTL2.Tests.Shared;

interface

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

extension method ImmutableList<UnicodeCodePoint>.JoinedHexString(aSeparator: String): RemObjects.Elements.RTL.String;

type
  String_Unicode = public class(Test)
  protected

    method JoinedHexString(aList: ImmutableList<UnicodeCodePoint>): RemObjects.Elements.RTL.String;
    begin
      result := "";
      for each c in aList index i do begin
        if i > 0 then
          result := ",";
        result := Convert.ToString(UInt32(c), 16);
      end;
    end;

  public

    method DummyTest;
    begin
      //raise new Exception;
    end;

    method FirstTest;
    begin

      Check.AreEqual("Hello".ToUnicodeCodePointIndices().JoinedString(","), "0,1,2,3,4");
      Check.AreEqual("🤪🤪🤪".ToUnicodeCodePointIndices().JoinedString(","), "0,2,4");
      Check.AreEqual("Hell🤪 There".ToUnicodeCodePointIndices().JoinedString(","), "0,1,2,3,4,6,7,8,9,10,11");

      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(0), 72);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(1), 101);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(2), 108);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(3), 108);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(4), 129322);
      //Check.Throws(() -> "Hell🤪 There".UnicodeCodePointAtIndex(5));
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(6), 32);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointAtIndex(7), 84);

      //Check.Throws(() -> "Hell🤪 There".UnicodeCodePointBeforeIndex(0));
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(1), 72);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(2), 101);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(3), 108);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(4), 108);
      //Check.Throws(() -> "Hell🤪 There".UnicodeCodePointBeforeIndex(5));
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(6), 129322);
      Check.AreEqual("Hell🤪 There".UnicodeCodePointBeforeIndex(7), 32);

      //writeLn("a🤪🤷🏼‍♀️b".ToUnicodeCodePointIndices().JoinedString(","));
      //writeLn("a🤪🤷🏼‍♀️b".ToUnicodeCodePoints().JoinedString(","));
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(0), false);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(1), false);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(3), false); // before "🤷🏼‍♀️"
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(5), true); // after 129335
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(7), true); // after 127996
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(8), true); // after 8205
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(8), true); // after 9792
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(10), false); // after of "🤷🏼‍♀️"
      Check.AreEqual("a🤪🤷🏼‍♀️b".IsIndexInsideOfAJoinedUnicodeCharacter(11), false);

      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(3), 3); // start of "🤷🏼‍♀️"
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(4), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(5), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(6), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(7), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(8), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(9), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".StartIndexOfJoinedUnicodeCharacterAtIndex(10), 10); // start of "b"

      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(3), 3);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(4), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(5), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(6), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(7), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(8), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(9), 10);
      Check.AreEqual("a🤪🤷🏼‍♀️b".IndexAfterJoinedUnicodeCharacterCoveringIndex(10), 10);

      //writeLn("👁️‍🗨️ Eye".ToUnicodeCodePointIndices().JoinedString(","));
      //writeLn("👁️‍🗨️ Eye".ToUnicodeCodePoints().JoinedString(","));
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(0), false);
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(2), true);
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(3), true);
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(4), true);
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(6), true);
      Check.AreEqual("👁️‍🗨️ Eye".IsIndexInsideOfAJoinedUnicodeCharacter(7), false);

      //writeLn("🇨🇼🇨🇼".ToUnicodeCodePointIndices().JoinedString(","));
      //writeLn("🇨🇼🇨🇼".ToUnicodeCodePoints().JoinedString(","));
      Check.AreEqual("🇨🇼🇨🇼".IsIndexInsideOfAJoinedUnicodeCharacter(0), false);
      Check.AreEqual("🇨🇼🇨🇼".IsIndexInsideOfAJoinedUnicodeCharacter(2), true);
      Check.AreEqual("🇨🇼🇨🇼".IsIndexInsideOfAJoinedUnicodeCharacter(4), false);
      Check.AreEqual("🇨🇼🇨🇼".IsIndexInsideOfAJoinedUnicodeCharacter(6), true);
      Check.AreEqual("🇨🇼🇨🇼".IsIndexInsideOfAJoinedUnicodeCharacter(8), false);

      Check.AreEqual("🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(0), 0);
      Check.AreEqual("🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(2), 0);
      Check.AreEqual("🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(4), 4);
      Check.AreEqual("🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(6), 4);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(0), 0);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(1), 1);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(3), 1);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(5), 5);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(7), 5);
      Check.AreEqual("a🇨🇼🇨🇼".StartIndexOfJoinedUnicodeCharacterAtIndex(9), 9);
      //1F9B8 1F3FB 200D 2640 FE0F 79

      var lCPs: array of UnicodeCodePoint := [UnicodeCodePoint(2640)];
      var x := new String(lCPs);
      Check.AreEqual(ord(x[0]), 2640);

      Check.AreEqual("🇨🇼🇨🇼".IndexAfterJoinedUnicodeCharacterCoveringIndex(0), 0);
      Check.AreEqual("🇨🇼🇨🇼".IndexAfterJoinedUnicodeCharacterCoveringIndex(2), 4);
      Check.AreEqual("🇨🇼🇨🇼".IndexAfterJoinedUnicodeCharacterCoveringIndex(4), 4);
      Check.AreEqual("🇨🇼🇨🇼".IndexAfterJoinedUnicodeCharacterCoveringIndex(6), 8);

      Check.AreEqual("你好".Length, 2);
      Check.AreEqual("你好".ToUnicodeCodePointIndices().JoinedString(","), "0,1");
      Check.AreEqual("你好".ToHexString(), "4F60597D");

      //Check.AreEqual(JoinedHexString("Hello".ToUnicodeCodePoints), "72,101,108,108,111");
      //Check.AreEqual(JoinedHexString("🤪🤪🤪".ToUnicodeCodePoints), "129322,129322,129322");
      //Check.AreEqual(JoinedHexString("Hell🤪 There".ToUnicodeCodePoints), "72,101,108,108,129322,32,84,104,101,114,101");
      //Check.AreEqual(JoinedHexString("🤷🏼‍♀️".ToUnicodeCodePoints), "129335,127996,8205,9792,65039");

      //Check.AreEqual("Hello".ToUnicodeCodePoints().JoinedHexString(","), "72,101,108,108,111");
      //Check.AreEqual("🤪🤪🤪".ToUnicodeCodePoints().JoinedHexString(","), "129322,129322,129322");
      //Check.AreEqual("Hell🤪 There".ToUnicodeCodePoints().JoinedHexString(","), "72,101,108,108,129322,32,84,104,101,114,101");
      //Check.AreEqual("🤷🏼‍♀️🤷🏼‍♀️".ToUnicodeCodePoints().JoinedHexString(","), "129335,127996,8205,9792,65039");

      Check.AreEqual("Hello".ToUnicodeCodePoints().JoinedString(","), "72,101,108,108,111");
      Check.AreEqual("🤪🤪🤪".ToUnicodeCodePoints().JoinedString(","), "129322,129322,129322");
      Check.AreEqual("Hell🤪 There".ToUnicodeCodePoints().JoinedString(","), "72,101,108,108,129322,32,84,104,101,114,101");

      Check.AreEqual("👨‍👨‍👧‍👧".ToUnicodeCodePointIndices().JoinedString(","), "0,2,3,5,6,8,9");
      Check.AreEqual("👨‍👨‍👧‍👧".ToUnicodeCodePoints().JoinedString(","), "128104,8205,128104,8205,128103,8205,128103");
      //Check.AreEqual("👨‍👨‍👧‍👧".ToUnicodeCharacterIndices().JoinedString(","), "0");
      Check.AreEqual("👨‍👨‍👧‍👧".ToUnicodeCharacters().JoinedString(","), "👨‍👨‍👧‍👧");
      Check.AreEqual("👨‍👨‍👧‍👧".ToHexString(),"D83DDC68200DD83DDC68200DD83DDC67200DD83DDC67");

      Check.AreEqual("👩🏽‍🤝‍👩🏼".ToUnicodeCodePointIndices().JoinedString(","), "0,2,4,5,7,8,10");
      Check.AreEqual("🏴‍☠️".ToUnicodeCodePointIndices().JoinedString(","), "0,2,3,4");

      Check.AreEqual("🤷🏼‍♀️".ToUnicodeCodePointIndices().JoinedString(","), "0,2,4,5,6");
      Check.AreEqual("🤷🏼‍♀️".ToUnicodeCodePoints().JoinedString(","), "129335,127996,8205,9792,65039");
      //Check.AreEqual("🤷🏼‍♀️".ToUnicodeCharacterIndices().JoinedString(","), "0");
      Check.AreEqual("🤷🏼‍♀️".ToUnicodeCharacters().JoinedString(","), "🤷🏼‍♀️");
      Check.AreEqual("🤷🏼‍♀️".ToHexString(),"D83EDD37D83CDFFC200D2640FE0F");
                                     // "D83E+DD37, D83C+DFFC, 200D, 2640, FE0F");
                                     // 1F937 (Person shrugging)
                                     // 1F3FC (Skin Color)
                                     // 200D (Zero Width Joiner)
                                     // 2640 (Female Sign)
                                     // FE0F Variation Selector-16, An invisible codepoint which specifies that the preceding character should be displayed with emoji presentation. Only required if the preceding character defaults to text presentation.)

      Check.AreEqual("🤪🤷🏼‍♀️🤷".ToUnicodeCharacters().JoinedString(","), "🤪,🤷🏼‍♀️,🤷");
      Check.AreEqual("👁️‍🗨️ Eye in Speech Bubble".ToUnicodeCharacters().JoinedString(","), "👁️‍🗨️, ,E,y,e, ,i,n, ,S,p,e,e,c,h, ,B,u,b,b,l,e");
      Check.AreEqual("🇨🇼 Flag: Curaçao".ToUnicodeCharacters().JoinedString(","), "🇨🇼, ,F,l,a,g,:, ,C,u,r,a,ç,a,o");
    end;

  end;

implementation

extension method ImmutableList<UnicodeCodePoint>.JoinedHexString(aSeparator: String): RemObjects.Elements.RTL.String;
begin
  result := "";
  for each c in self index i do begin
    if i > 0 then
      result := ",";
    result := Convert.ToString(UInt32(c), 16);
  end;
end;


end.