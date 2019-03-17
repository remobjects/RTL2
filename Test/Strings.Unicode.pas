namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.EUnit;

type
  String = public class(Test)
  protected

  public
    method FirstTest;
    begin

      Check.AreEqual("Hello".ToCharacterIndices().JoinedString(","), "0,1,2,3,4");
      Check.AreEqual("🤪🤪🤪".ToCharacterIndices().JoinedString(","), "0,2,4");
      Check.AreEqual("Hell🤪 There".ToCharacterIndices().JoinedString(","), "0,1,2,3,4,6,7,8,9,10,11");

      Check.AreEqual("你好".Length, 2);
      Check.AreEqual("你好".ToCharacterIndices().JoinedString(","), "0,1");
      //Check.AreEqual("你好".ToHexString(),
                     //"");

      Check.AreEqual("Hello".ToUnicodeCharacters().JoinedString(","), "72,101,108,108,111");
      Check.AreEqual("🤪🤪🤪".ToUnicodeCharacters().JoinedString(","), "129322,129322,129322");
      Check.AreEqual("Hell🤪 There".ToUnicodeCharacters().JoinedString(","), "72,101,108,108,129322,32,84,104,101,114,101");

    end;

  end;

end.