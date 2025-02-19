namespace RemObjects.Elements.RTL;

type
  JsonArray = public class (JsonNode{$IF NOT TOFFEEV2}, sequence of JsonNode{$ENDIF})
  public

    property NodeKind: JsonNodeKind read JsonNodeKind.Array; override;

    constructor;
    begin
      fItems := new List<JsonNode>();
    end;

    constructor withCapacity(aCapacity: Integer);
    begin
      fItems := new List<JsonNode> withCapacity(aCapacity);
    end;

    constructor(aItems: not nullable ImmutableList<JsonNode>);
    begin
      fItems := aItems.UniqueMutableCopy;
    end;

    {$IF NOT COOPER}
    constructor(aItems: not nullable ImmutableList<String>);
    begin
      fItems := new List<JsonNode>();
      for each el in aItems do
        fItems.Add(new JsonStringValue(el));
    end;
    {$ENDIF}

    constructor(params aItems: not nullable array of JsonNode);
    begin
      fItems := new List<JsonNode>(aItems);
    end;

    constructor(aItems: not nullable sequence of JsonNode);
    begin
      fItems := new List<JsonNode>(aItems);
    end;

    //constructor(aItems: not nullable sequence of JsonObject);
    //begin
      //fItems := new List<JsonNode>(aItems.Ca`st<JsonNode>());
    //end;

    constructor(params aItems: not nullable array of String);
    begin
      fItems := aItems.Select(v -> new JsonStringValue(v) as JsonNode).ToList as not nullable;
    end;

    constructor(aItems: not nullable sequence of String);
    begin
      fItems := aItems.Select(v -> new JsonStringValue(v) as JsonNode).ToList as not nullable;
    end;

    method UniqueCopy: InstanceType; override;
    begin
      var lValues := new List<JsonNode> withCapacity(fItems.Count);
      for i := 0 to fItems.Count-1 do
        lValues.Add(fItems[i].UniqueCopy);
      result := new JsonArray(lValues);
    end;

    //

    method &Add(aValue: not nullable JsonNode);
    begin
      fItems.Add(aValue);
    end;

    // allowing sequence of JsonNode here causes conflict with allowing adding JsonArrays to an array,
    // as JsonArray is BOTH a JsonNode *and* a sequence of JsonNodes, so it wuld be logically (and technically) ambiguous
    method &Add(aValues: nullable ImmutableList<JsonNode>);
    begin
      fItems.Add(aValues);
    end;

    //method &Add(params aValues: array of JsonNode);
    //begin
      //fItems.Add(aValues);
    //end;

    {$IF TOFFEE}
    // Toffee does not support sequence & params
    method &Add(aValues: sequence of String);
    begin
      for each el in aValues do begin
        fItems.Add(new JsonStringValue(el));
      end;
    end;

    {$ELSE}
    method &Add(params aValues: sequence of String);
    begin
      for each el in aValues do begin
        fItems.Add(new JsonStringValue(el));
      end;
    end;
    {$ENDIF}

    //method &Add(params aValues: sequence of String);
    //begin
      //fItems.Add(aValues.Select(s -> new JsonStringValue(s) as JsonNode));
    //end;

    method Insert(aIndex: Integer; aValue: not nullable JsonNode);
    begin
      fItems.Insert(aIndex, aValue);
    end;

    method Clear;
    begin
      fItems.RemoveAll;
    end;

    method &RemoveAt(aIndex: Integer);
    begin
      fItems.RemoveAt(aIndex);
    end;

    //

    method ToStrings: not nullable sequence of String;
    begin
      result := fItems.Where(i -> i is JsonStringValue).Select(i -> i.StringValue) as not nullable;
    end;

    method ToStringList: not nullable ImmutableList<String>;
    begin
      result := ToStrings().ToList() as not nullable;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): not nullable String; override;
    begin
      var Serializer := new JsonSerializer(self, aFormat);
      exit Serializer.Serialize;
    end;

    {$IF NOT TOFFEE}[&Sequence]{$ENDIF}
    method GetSequence: sequence of JsonNode; iterator; override; public;
    begin
      yield fItems;
    end;

    {$IF TOFFEE}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger; override;
    begin
      {$HIDE CPW8}
      exit NSArray(fItems).countByEnumeratingWithState(aState) objects(^id(stackbuf)) count(len);
      {$SHOW CPW8}
    end;
    {$ENDIF}

    class method Load(JsonString: String): not nullable JsonArray;
    begin
      var Serializer := new JsonDeserializer(JsonString);
      var lValue := Serializer.Deserialize;

      if not (lValue is JsonArray) then
        raise new InvalidOperationException("String does not contain a valid Json array");

      result := lValue as JsonArray as not nullable;
    end;

    property Count: Integer read fItems.Count; override;
    property Item[aIndex: Integer]: not nullable JsonNode read GetItem write SetItem; default; override;
    property Items: not nullable ImmutableList<JsonNode> read fItems;

    operator Implicit(aValue: ImmutableList<String>): JsonArray;
    begin
      result := new JsonArray(aValue.ToArray);
    end;

    operator Implicit(aValue: array of String): JsonArray;
    begin
      result := new JsonArray(aValue);
    end;

    operator Implicit(aValue: ImmutableList<JsonNode>): JsonArray;
    begin
      result := new JsonArray(aValue.ToArray);
    end;

    operator Implicit(aValue: array of JsonNode): JsonArray;
    begin
      result := new JsonArray(aValue);
    end;

    operator Explicit(aValue: JsonArray): ImmutableList<JsonNode>;
    begin
      result := aValue.fItems;
    end;

    operator Explicit(aValue: JsonArray): array of JsonNode;
    begin
      result := aValue.fItems.ToArray();
    end;

    operator &Equal(lhs: JsonArray; rhs: JsonArray): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;

      if lhs:Count ≠ rhs:Count then
        exit false;
      for i := 0 to lhs:Count-1 do
        if lhs[i] ≠ rhs[i] then
          exit false;

      result := true;
    end;

    operator &Equal(lhs: JsonArray; rhs: array of String): Boolean;
    begin
      {$IF NOT TOFFEE}
      if Object(lhs) = Object(rhs) then
        exit true;
      {$ELSE}
      if not assigned(lhs) and not assigned(rhs) then
        exit true;
      {$ENDIF}

      if lhs:Count ≠ rhs:Count then
        exit false;
      for i := 0 to lhs:Count-1 do
        if lhs[i]:StringValue ≠ rhs[i] then
          exit false;

      result := true;
    end;

    operator &Equal(lhs: array of String; rhs: JsonArray): Boolean;
    begin
      {$IF NOT TOFFEE}
      if Object(lhs) = Object(rhs) then
        exit true;
      {$ELSE}
      if not assigned(lhs) and not assigned(rhs) then
        exit true;
      {$ENDIF}

      if lhs:Count ≠ rhs:Count then
        exit false;
      for i := 0 to lhs:Count-1 do
        if lhs[i] ≠ rhs[i]:StringValue then
          exit false;

      result := true;
    end;

    //operator NotEqual(lhs: JsonArray; rhs: JsonArray): Boolean;
    //begin
      //result := not (lhs = rhs);
    //end;

    method Any(aName: not nullable String): sequence of JsonNode; override; iterator;
    begin
      for each j in self do
        yield j.Any(aName);
    end;

    method Replace(aOldValue: JsonNode; aNewValue: JsonNode);
    begin
      for i := 0 to fItems.Count-1 do
        if fItems[i] = aOldValue then
          fItems[i] := aNewValue;
    end;

    method Replace(aOldValue: String; aNewValue: String);
    begin
      for i := 0 to fItems.Count-1 do
        if fItems[i] = aOldValue then
          fItems[i] := new JsonStringValue(aNewValue);
    end;

  private

    fItems: not nullable List<JsonNode>;
    method GetItem(aIndex: Integer): not nullable JsonNode;
    begin
      exit fItems[aIndex] as not nullable;
    end;

    method SetItem(aIndex: Integer; aValue: not nullable JsonNode);
    begin
      fItems[aIndex] := aValue;
    end;

  end;

end.