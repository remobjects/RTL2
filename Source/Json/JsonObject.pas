namespace RemObjects.Elements.RTL;

interface

type
  JsonObject = public class(JsonNode, ISequence<KeyValuePair<String, JsonNode>>)
  private
    fItems: Dictionary<String, JsonNode>;
    method GetItem(aKey: not nullable String): nullable JsonNode;
    method SetItem(aKey: not nullable String; aValue: nullable JsonNode);
    method SetItem(aKey: not nullable String; aValue: nullable String);
    method SetItem(aKey: not nullable String; aValue: Boolean);
    method SetItem(aKey: not nullable String; aValue: Int32);
    method GetKeys: not nullable sequence of String;
    method GetProperties: sequence of KeyValuePair<String, JsonNode>; iterator;

  public
    constructor;
    constructor(aItems: Dictionary<String, JsonNode>);

    method &Add(aKey: not nullable String; aValue: not nullable JsonNode);
    method &Remove(aKey: not nullable String): Boolean;
    method Clear;
    method ContainsKey(aKey: not nullable String): Boolean; // will return false for non-exist-ent keys and for JsonNullValue!
    method ContainsExplicitJsonNullValueForKey(aKey: not nullable String): Boolean; // will return false for non-exist-ent keys and values other than JsonNullValue!

    method ToJson: String; override;

    {$IF COOPER}
    method &iterator: java.util.&Iterator<KeyValuePair<String, JsonNode>>;
    {$ELSEIF ECHOES}
    method GetNonGenericEnumerator: System.Collections.IEnumerator; implements System.Collections.IEnumerable.GetEnumerator;
    method GetEnumerator: System.Collections.Generic.IEnumerator<KeyValuePair<String, JsonNode>>;
    {$ELSEIF ISLAND}
    method GetNonGenericEnumerator(): IEnumerator; implements IEnumerable.GetEnumerator;
    method GetEnumerator(): IEnumerator<KeyValuePair<String,JsonNode>>;
    {$ELSEIF TOFFEE}
    {$HIDE CPW8}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^KeyValuePair<String,JsonNode>) count(len: NSUInteger): NSUInteger;
    {$SHOW CPW8}
    {$ENDIF}

    class method Load(JsonString: String): JsonObject;

    property Count: Integer read fItems.Count; override;
    property Item[aKey: not nullable String]: nullable JsonNode read GetItem write SetItem; default; override;
    property Item[aKey: not nullable String]: nullable String write SetItem; default; override;
    property Item[aKey: not nullable String]: Boolean write SetItem; default; override;
    property Item[aKey: not nullable String]: Int32 write SetItem; default; override;
    property Keys: not nullable sequence of String read GetKeys; override;
    property Properties: sequence of KeyValuePair<String, JsonNode> read GetProperties;
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
  fItems[aKey] := new JsonStringValue(aValue);
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: Boolean);
begin
  fItems[aKey] := new JsonBooleanValue(aValue);
end;

method JsonObject.SetItem(aKey: not nullable String; aValue: Int32);
begin
  fItems[aKey] := new JsonIntegerValue(aValue);
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

method JsonObject.ToJson: String;
begin
  var Serializer := new JsonSerializer(self);
  result := Serializer.Serialize;
end;

method JsonObject.GetProperties: sequence of KeyValuePair<String, JsonNode>;
begin
  for aKey in Keys do
    yield new KeyValuePair<String, JsonNode>(aKey, Item[aKey]);
end;

{$IF COOPER}
method JsonObject.iterator: java.util.&Iterator<KeyValuePair<String, JsonNode>>;
begin
  exit Properties.iterator;
end;
{$ELSEIF ECHOES}
method JsonObject.GetNonGenericEnumerator: System.Collections.IEnumerator;
begin
  exit GetEnumerator;
end;

method JsonObject.GetEnumerator: System.Collections.Generic.IEnumerator<KeyValuePair<String, JsonNode>>;
begin
  var props := GetProperties;
  exit props.GetEnumerator;
end;
{$ELSEIF ISLAND}
method JsonObject.GetNonGenericEnumerator: IEnumerator;
begin
  exit GetEnumerator;
end;

method JsonObject.GetEnumerator: IEnumerator<KeyValuePair<String, JsonNode>>;
begin
  var props := GetProperties;
  exit props.GetEnumerator;
end;
{$ELSEIF TOFFEE}
method JsonObject.countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^KeyValuePair<String,JsonNode>) count(len: NSUInteger): NSUInteger;
begin
  if aState^.state <> 0 then
    exit 0;

  exit GetProperties.countByEnumeratingWithState(aState) objects(stackbuf) count(len);
end;
{$ENDIF}

end.