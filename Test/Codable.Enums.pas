namespace Elements.RTL2.Tests.Shared;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit,
  RemObjects.Elements.Serialization;

type
  CodableEnumState = public enum (
    Cancelled = -1,
    Pending = 1,
    Running = 5,
    Finished = 9
  );

  [Codable]
  CodableEnumPayload = public class
  public
    property State: CodableEnumState;
  end;

  CodableEnumTests = public class(Test)
  private
    method EncodePayload(aState: CodableEnumState): JsonObject;
    begin
      var lCoder := new JsonCoder;
      lCoder.Encode(new CodableEnumPayload(State := aState));
      result := lCoder.ToJson as JsonObject;
    end;

    method RoundtripPayload(aJson: String): JsonObject;
    begin
      var lDecoder := new JsonCoder withJson(JsonDocument.FromString(aJson));
      var lValue := new CodableEnumPayload;
      lDecoder.Decode(lValue);

      var lEncoder := new JsonCoder;
      lEncoder.Encode(lValue);
      result := lEncoder.ToJson as JsonObject;
    end;

    method EncodeXmlPayload(aState: CodableEnumState): XmlElement;
    begin
      var lCoder := new XmlCoder;
      lCoder.Encode(new CodableEnumPayload(State := aState));
      result := lCoder.ToXml;
    end;

    method RoundtripXmlPayload(aXml: String): XmlElement;
    begin
      var lDecoder := new XmlCoder withXml(XmlDocument.FromString(aXml).Root);
      var lValue := new CodableEnumPayload;
      lDecoder.Decode(lValue);

      var lEncoder := new XmlCoder;
      lEncoder.Encode(lValue);
      result := lEncoder.ToXml;
    end;

    method XmlPayload(aStateValue: String): String;
    begin
      result := $"<Payload><State>{aStateValue}</State></Payload>";
    end;

  public
    method EncodeKnownEnumValueAsString;
    begin
      var lJson := EncodePayload(CodableEnumState.Running);

      Check.AreEqual(lJson["State"]:NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson["State"]:StringValue, "Running");
    end;

    method DecodeKnownStringEnumValue;
    begin
      var lJson := RoundtripPayload('{"State":"Finished"}');

      Check.AreEqual(lJson["State"]:NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson["State"]:StringValue, "Finished");
    end;

    method DecodeKnownIntegerEnumValue;
    begin
      var lJson := RoundtripPayload('{"State":5}');

      Check.AreEqual(lJson["State"]:NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson["State"]:StringValue, "Running");
    end;

    method DecodeNegativeIntegerEnumValue;
    begin
      var lJson := RoundtripPayload('{"State":-1}');

      Check.AreEqual(lJson["State"]:NodeKind, JsonNodeKind.String);
      Check.AreEqual(lJson["State"]:StringValue, "Cancelled");
    end;

    method DecodeUnknownIntegerEnumValue;
    begin
      var lJson := RoundtripPayload('{"State":42}');

      Check.AreEqual(lJson["State"]:NodeKind, JsonNodeKind.Integer);
      Check.AreEqual(lJson["State"]:IntegerValue, 42);
    end;

    method EncodeKnownEnumValueAsXmlString;
    begin
      var lXml := EncodeXmlPayload(CodableEnumState.Running);
      var lState := lXml.FirstElementWithName("State");

      Check.IsNotNil(lState);
      Check.AreEqual(lState.Value, "Running");
    end;

    method DecodeKnownXmlIntegerEnumValue;
    begin
      var lXml := RoundtripXmlPayload(XmlPayload("5"));
      var lState := lXml.FirstElementWithName("State");

      Check.IsNotNil(lState);
      Check.AreEqual(lState.Value, "Running");
    end;

    method DecodeNegativeXmlIntegerEnumValue;
    begin
      var lXml := RoundtripXmlPayload(XmlPayload("-1"));
      var lState := lXml.FirstElementWithName("State");

      Check.IsNotNil(lState);
      Check.AreEqual(lState.Value, "Cancelled");
    end;

    method RoundtripKnownEnumValueThroughXmlCoder;
    begin
      var lEncodedXml := XmlDocument.WithRootElement(EncodeXmlPayload(CodableEnumState.Finished)).ToString();
      var lXml := RoundtripXmlPayload(lEncodedXml);
      var lState := lXml.FirstElementWithName("State");

      Check.IsNotNil(lState);
      Check.AreEqual(lState.Value, "Finished");
    end;
  end;

end.
