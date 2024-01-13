namespace RemObjects.Elements.RTL;

type
  JsonObject = public class(JsonNode)
  public

    constructor;
    begin
      fItems := new Dictionary<String, JsonNode>;
    end;

    constructor(aItems: Dictionary<String, JsonNode>);
    begin
      fItems := aItems;
    end;

    method UniqueCopy: InstanceType; override;
    begin
      var lValues := new Dictionary<String, JsonNode> withCapacity(fItems.Count);
      for each k in fItems.Keys do
        lValues[k] := fItems[k].UniqueCopy;
      result := new JsonObject(lValues);
    end;

    //

    method &Add(aKey: not nullable String; aValue: not nullable JsonNode);
    begin
      fItems[aKey] := aValue;
    end;

    method &Remove(aKey: not nullable String): Boolean;
    begin
      exit fItems.Remove(aKey);
    end;

    method Clear;
    begin
      fItems.RemoveAll;
    end;

    // will return false for non-existent keys and for JsonNullValue!
    method ContainsKey(aKey: not nullable String): Boolean;
    begin
      var lValue := fItems[aKey];
      exit assigned(lValue) and (lValue is not JsonNullValue);
    end;

    // will return false for non-existent keys and values other than JsonNullValue!
    method ContainsExplicitJsonNullValueForKey(aKey: not nullable String): Boolean;
    begin
      exit fItems[aKey] is JsonNullValue;
    end;

    //

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): not nullable String; override;
    begin
      var Serializer := new JsonSerializer(self, aFormat);
      result := Serializer.Serialize;
    end;

    {$IF NOT TOFFEE}[&Sequence]{$ENDIF}
    method GetSequence: sequence of tuple of (String, JsonNode); iterator;
    begin
      for each kv in fItems do
        yield (kv.Key, kv.Value);
    end;

    //{$IF TOFFEE AND NOT TOFFEEV2}
    //method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^tuple of (String,JsonNode)) count(len: NSUInteger): NSUInteger;
    //begin
      //if aState^.state <> 0 then
        //exit 0;
      //exit GetProperties.countByEnumeratingWithState(aState) objects(stackbuf) count(len);
    //end;
    //{$ENDIF}

    class method Load(JsonString: String): JsonObject;
    begin
      var Serializer := new JsonDeserializer(JsonString);
      var lValue := Serializer.Deserialize;

      if not (lValue is JsonObject) then
        raise new JsonParserException("String does not contains valid Json object");

      result := lValue as JsonObject;
    end;

    property Count: Integer read fItems.Count; override;
    property Item[aKey: not nullable String]: nullable JsonNode read GetItem write SetItem; default; override;
    property Item[aKey: not nullable String]: nullable String write SetItem; default; override;
    property Item[aKey: not nullable String]: Boolean write SetItem; default; override;
    property Item[aKey: not nullable String]: Int32 write SetItem; default; override;
    property Item[aKey: not nullable String]: Double write SetItem; default; override;
    property Keys: not nullable sequence of String read GetKeys; override;
    property Properties: sequence of tuple of (String,JsonNode) read GetProperties;

    operator &Equal(lhs: JsonObject; rhs: JsonObject): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;

      if lhs.Keys.Count ≠ rhs.Keys.Count then
        exit false;
      for each k in lhs.Keys do
        if lhs[k] ≠ rhs[k] then
          exit false;

      result := true;
    end;

  private

    fItems: Dictionary<String, JsonNode>;

    method GetItem(aKey: not nullable String): nullable JsonNode;
    begin
      if fItems.ContainsKey(aKey) then begin
        result := fItems[aKey];
        if result is JsonNullValue then
          result := nil;
      end;
    end;

    method SetItem(aKey: not nullable String; aValue: nullable JsonNode);
    begin
      fItems[aKey] := aValue;
    end;

    method SetItem(aKey: not nullable String; aValue: nullable String);
    begin
      fItems[aKey] := JsonStringValue.Create(aValue);
    end;

    method SetItem(aKey: not nullable String; aValue: Boolean);
    begin
      fItems[aKey] := new JsonBooleanValue(aValue);
    end;

    method SetItem(aKey: not nullable String; aValue: Int32);
    begin
      fItems[aKey] := new JsonIntegerValue(aValue);
    end;

    method SetItem(aKey: not nullable String; aValue: Double);
    begin
      fItems[aKey] := new JsonFloatValue(aValue);
    end;

    method GetKeys: not nullable sequence of String;
    begin
      exit fItems.Keys as not nullable;
    end;

    method GetProperties: sequence of tuple of (String,JsonNode); iterator;
    begin
      for aKey in Keys do
        yield (aKey, Item[aKey]);
    end;

  end;

end.