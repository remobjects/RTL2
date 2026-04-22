namespace RemObjects.Elements.RTL.Tests;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  JsonTests = public class(Test)
  public

    method Floats;
    begin
      var f := JsonFloatValue(12.18688);
      Check.AreEqual(f.ToString, "12.18688");
      Check.AreEqual(f.ToJsonString, "12.18688");
      Check.AreNotEqual(f.ToJsonString, "12.187");
    end;

    method TryFromAString;
    begin
      var lJson := JsonDocument.TryFromString("");
      Check.IsNil(lJson);
    end;

    method TryFromStringHandlesIncompleteJsonBasedOnAllowPartial;
    begin
      Check.IsNil(JsonDocument.TryFromString('{"name":"value"'));
      Check.IsNil(JsonDocument.TryFromString('{"name":"value"', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":"value"', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":"value'));
      Check.IsNil(JsonDocument.TryFromString('{"name":"value', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":"value', true));

      Check.IsNil(JsonDocument.TryFromString('{ "name": "long string'));
      Check.IsNil(JsonDocument.TryFromString('{ "name": "long string', false));
      Check.IsNotNil(JsonDocument.TryFromString('{ "name": "long string', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":1}'));
      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":1}', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":{"nested":1}', true));

      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":"value"}'));
      Check.IsNil(JsonDocument.TryFromString('{"name":{"nested":"value"}', false));
      Check.IsNotNil(JsonDocument.TryFromString('{"name":{"nested":"value"}', true));
    end;

    method TryFromStringOutExceptionRejectsIncompleteJson;
    begin
      var lException: Exception;
      var lJson := JsonDocument.TryFromString('{"name":"value"', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":"value', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{ "name": "long string', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
      Check.AreEqual(lException.GetType, typeOf(JsonUnexpectedEndOfFileException));
      Check.AreEqual(lException.Message, "Unexpected end of string at 1/23 for string node started at 1/11.");

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":{"nested":1}', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);

      lException := nil;
      lJson := JsonDocument.TryFromString('{"name":{"nested":"value"}', out lException);
      Check.IsNil(lJson);
      Check.IsNotNil(lException);
    end;

    method StringToYaml;
    begin
      Check.AreEqual(JsonStringValue("yes: null").ToYamlString, '"yes: null"');
      Check.AreEqual(JsonNullValue.Null.ToYamlString, 'null');
      Check.AreEqual(JsonBooleanValue.True.ToYamlString, 'true');
    end;

    method ArrayToYaml;
    begin
      var lBreak := Environment.LineBreak;
      var lJson := new JsonArray(new JsonStringValue("first value"), new JsonObject(), JsonNullValue.Null);

      Check.AreEqual(lJson.ToYamlString,
        '- "first value"'+lBreak+
        '- {}'+lBreak+
        '- null');
    end;

    method ObjectToYaml;
    begin
      var lBreak := Environment.LineBreak;
      var lJson := new JsonObject();
      lJson["items"] := new JsonArray(new JsonStringValue("first"), new JsonArray(), JsonNullValue.Null);

      Check.AreEqual(lJson.ToYamlString,
        '"items":'+lBreak+
        '  - "first"'+lBreak+
        '  - []'+lBreak+
        '  - null');
    end;

    method YamlOptionsAreApplied;
    begin
      var lOptions := new YamlOptions();
      lOptions.Indentation := #9;
      lOptions.NewLine := #10;
      lOptions.AlwaysQuoteKeys := false;
      lOptions.AlwaysQuoteStrings := false;
      lOptions.EmitDocumentMarker := true;

      var lJson := new JsonObject();
      lJson["name"] := new JsonStringValue("plain");
      lJson["items"] := new JsonArray(new JsonStringValue("two words"), new JsonObject());

      Check.AreEqual(lJson.ToYamlString(lOptions),
        '---'#10+
        'name: plain'#10+
        'items:'#10+
        #9'- two words'#10+
        #9'- {}');
    end;

  end;


end.
