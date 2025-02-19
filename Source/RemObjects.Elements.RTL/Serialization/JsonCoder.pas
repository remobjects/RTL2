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
      Json := aJson;
      Hierarchy.Push(Json/*.Root*/ as JsonObject);
    end;


    property Json: JsonDocument;

    [ToString]
    method ToString: String; override;
    begin
      result := Json.ToString;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := Json.ToJsonString(aFormat);
    end;

  end;

end.