namespace RemObjects.Elements.Serialization;

type
  //EncodeMemberAttribute = public class(System.Attribute)
  //public

    //constructor(aMemberName: String); empty;

  //end;

  EncodeAttribute = public class(System.Attribute)
  public

    constructor(aName: String); empty;
    constructor(aShouldEncode: Boolean); empty;

  end;

end.