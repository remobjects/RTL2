namespace RemObjects.Elements.RTL;

interface

type
  JsonObject = public class(JsonNode)
  private
    fItems: Dictionary<String, JsonNode>;
    method GetItem(aKey: not nullable String): nullable JsonNode;
    method SetItem(aKey: not nullable String; aValue: nullable JsonNode);
    method SetItem(aKey: not nullable String; aValue: nullable String);
    method SetItem(aKey: not nullable String; aValue: Boolean);
    method SetItem(aKey: not nullable String; aValue: Int32);
    method SetItem(aKey: not nullable String; aValue: Double);
    method GetKeys: not nullable sequence of String;
    method GetProperties: sequence of tuple of (String,JsonNode); iterator;

  public
    constructor;
    constructor(aItems: Dictionary<String, JsonNode>);

    method &Add(aKey: not nullable String; aValue: not nullable JsonNode);
    method &Remove(aKey: not nullable String): Boolean;
    method Clear;
    method ContainsKey(aKey: not nullable String): Boolean; // will return false for non-exist-ent keys and for JsonNullValue!
    method ContainsExplicitJsonNullValueForKey(aKey: not nullable String): Boolean; // will return false for non-exist-ent keys and values other than JsonNullValue!

    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;

    {$IF NOT TOFFEE}[&Sequence]{$ENDIF}
    method GetSequence: sequence of tuple of (String, JsonNode); iterator;
    begin
      for each kv in fItems do
        yield (kv.Key, kv.Value);
    end;

    {$IF TOFFEE AND NOT TOFFEEV2}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^tuple of (String,JsonNode)) count(len: NSUInteger): NSUInteger;
    {$ENDIF}

    class method Load(JsonString: String): JsonObject;

    property Count: Integer read fItems.Count; override;
    property Item[aKey: not nullable String]: nullable JsonNode read GetItem write SetItem; default; override;
    property Item[aKey: not nullable String]: nullable String write SetItem; default; override;
    property Item[aKey: not nullable String]: Boolean write SetItem; default; override;
    property Item[aKey: not nullable String]: Int32 write SetItem; default; override;
    property Item[aKey: not nullable String]: Double write SetItem; default; override;
    property Keys: not nullable sequence of String read GetKeys; override;
    property Properties: sequence of tuple of (String,JsonNode) read GetProperties;
  end;

implementation

constructor JsonObject;
begin
  fItems := new Dictionary<String, JsonNode>();
end;

constructor JsonObject(aItems: Dictionary<String,JsonNode>);
begin
  fItems := aItems;
end;

method JsonObject.GetItem(aKey: not nullable String): nullable JsonNode;
begin
  if fItems.ContainsKey(aKey) then begin
    result := fItems[aKey];
    if result is JsonNullValue then
      result := nil;
  end;
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: nullable JsonNode);
begin
  fItems[aKey] := aValue;
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: nullable String);
begin
  fItems[aKey] := JsonStringValue.Create(aValue);
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: Boolean);
begin
  fItems[aKey] := new JsonBooleanValue(aValue);
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: Int32);
begin
  fItems[aKey] := new JsonIntegerValue(aValue);
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: Double);
begin
  fItems[aKey] := new JsonFloatValue(aValue);
end;

method JsonObject.Add(aKey: not nullable String; aValue: not nullable JsonNode);
begin
  fItems[aKey] := aValue;
end;

method JsonObject.Clear;
begin
  fItems.RemoveAll;
end;

method JsonObject.ContainsKey(aKey: not nullable String): Boolean;
begin
  var lValue := fItems[aKey];
  exit assigned(lValue) and (lValue is not JsonNullValue);
end;

method JsonObject.ContainsExplicitJsonNullValueForKey(aKey: not nullable String): Boolean;
begin
  exit fItems[aKey] is JsonNullValue;
end;

method JsonObject.Remove(aKey: not nullable String): Boolean;
begin
  exit fItems.Remove(aKey);
end;

class method JsonObject.Load(JsonString: String): JsonObject;
begin
  var Serializer := new JsonDeserializer(JsonString);
  var lValue := Serializer.Deserialize;

  if not (lValue is JsonObject) then
    raise new JsonParserException("String does not contains valid Json object");

  result := lValue as JsonObject;
end;

method JsonObject.GetKeys: not nullable sequence of String;
begin
  exit fItems.Keys as not nullable;
end;

method JsonObject.ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
begin
  var Serializer := new JsonSerializer(self, aFormat);
  result := Serializer.Serialize;
end;

method JsonObject.GetProperties: sequence of tuple of (String,JsonNode);
begin
  for aKey in Keys do
    yield (aKey, Item[aKey]);
end;

{$IF TOFFEE AND NOT TOFFEEV2}
method JsonObject.countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^tuple of (String,JsonNode)) count(len: NSUInteger): NSUInteger;
begin
  if aState^.state <> 0 then
    exit 0;

  exit GetProperties.countByEnumeratingWithState(aState) objects(stackbuf) count(len);
end;
{$ENDIF}

end.