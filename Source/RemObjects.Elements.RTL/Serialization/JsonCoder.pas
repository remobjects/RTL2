namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL;

type
  JsonCoder = public partial class(GenericCoder<JsonNode>)
  public

    constructor;
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
      constructor withJson(JsonDocument.CreateObject);
    end;

    {$IF NOT WEBASSEMBLY}
    constructor withFile(aFileName: String);
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
      constructor withJson(JsonDocument.FromFile(aFileName));
    end;
    {$ENDIF}

    constructor withJson(aJson: JsonDocument);
    begin
      {$IF NOT SERIALIZATION}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
      fJson := aJson;
      Hierarchy.Push(fJson/*.Root*/ as JsonObject);
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := fJson.ToString;
    end;

    method ToJson: JsonNode;
    begin
      result := fJson;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := fJson.ToJsonString(aFormat);
    end;

  private

    var fJson: JsonDocument;

  end;

end.