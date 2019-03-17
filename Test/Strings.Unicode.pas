namespace Elements.RTL2.Tests.Shared;

interface

uses
  RemObjects.Elements.EUnit,
  RemObjects.Elements.RTL;

extension method ImmutableList<UnicodeCodePoint>.JoinedHexString(aSeparator: String): RemObjects.Elements.RTL.String;

type
  String = public class(Test)
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
    method FirstTest;
    begin

      Check.AreEqual("Hello".ToUnicodeCodePointIndices().JoinedString(","), "0,1,2,3,4");
      Check.AreEqual("🤪🤪🤪".ToUnicodeCodePointIndices().JoinedString(","), "0,2,4");
      Check.AreEqual("Hell🤪 There".ToUnicodeCodePointIndices().JoinedString(","), "0,1,2,3,4,6,7,8,9,10,11");

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
      //Check.AreEqual("🤷🏼‍♀️".ToUnicodeCodePoints().JoinedHexString(","), "129335,127996,8205,9792,65039");

      Check.AreEqual("Hello".ToUnicodeCodePoints().JoinedString(","), "72,101,108,108,111");
      Check.AreEqual("🤪🤪🤪".ToUnicodeCodePoints().JoinedString(","), "129322,129322,129322");
      Check.AreEqual("Hell🤪 There".ToUnicodeCodePoints().JoinedString(","), "72,101,108,108,129322,32,84,104,101,114,101");

      Check.AreEqual("🤷🏼‍♀️".ToUnicodeCodePointIndices().JoinedString(","), "0,2,4,5,6");
      Check.AreEqual("🤷🏼‍♀️".ToUnicodeCodePoints().JoinedString(","), "129335,127996,8205,9792,65039");
      Check.AreEqual("🤷🏼‍♀️".ToHexString(),"D83EDD37D83CDFFC200D2640FE0F");
                                     // "D83E+DD37, D83C+DFFC, 200D, 2640, FE0F");
                                     // 1F937 (Person shrugging)
                                     // 1F3FC (Skin Color)
                                     // 200D (Zero Width Joiner)
                                     // 2640 (Female Sign)
                                     // FE0F Variation Selector-16, An invisible codepoint which specifies that the preceding character should be displayed with emoji presentation. Only required if the preceding character defaults to text presentation.)
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