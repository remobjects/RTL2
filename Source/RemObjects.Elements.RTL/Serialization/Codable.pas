namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL;

type
  Codable = public class
  public

    {$IF SERIALIZATION}
    constructor; empty;

    constructor withJson(aJson: JsonDocument);
    begin
      var lCoder := new JsonCoder withJson(aJson);
      (self as IDecodable).Decode(lCoder);
    end;

    constructor withDecoder(aCoder: Coder);
    begin
      (self as IDecodable).Decode(aCoder);
    end;

    method ToJson: JsonObject;
    begin
      var lCoder := new JsonCoder;
      lCoder.Encode(self);
      result := lCoder.Json as JsonObject;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := ToJson.ToJsonString(aFormat);
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := ToJson.ToString;
    end;
    {$ENDIF}

  end;
end.