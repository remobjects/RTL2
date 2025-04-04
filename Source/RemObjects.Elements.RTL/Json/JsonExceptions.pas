namespace RemObjects.Elements.RTL;

interface

type
  JsonException = public class (RTLException);
  JsonNodeTypeException = public class (JsonException);
  JsonParserException = public class (JsonException);
  JsonUnexpectedTokenException = public class (JsonParserException);
  JsonUnexpectedEndOfFileException = public class (JsonParserException);
  JsonInvalidTokenException = public class (JsonParserException);
  JsonInvalidValueException = public class (JsonParserException);

implementation

end.