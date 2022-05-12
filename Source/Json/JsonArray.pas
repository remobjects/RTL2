namespace RemObjects.Elements.RTL;

interface

type
  JsonArray = public class (JsonNode)
  private
    fItems: not nullable List<JsonNode>;
    method GetItem(aIndex: Integer): not nullable JsonNode;
    method SetItem(aIndex: Integer; aValue: not nullable JsonNode);

  public
    constructor;
    constructor(aItems: not nullable ImmutableList<JsonNode>);
    {$IF NOT COOPER}
    constructor(aItems: not nullable ImmutableList<String>);
    {$ENDIF}
    constructor(params aItems: not nullable array of JsonNode);
    constructor(params aItems: not nullable array of String);

    method &Add(aValue: not nullable JsonNode);
    method &Add(aValues: ImmutableList<JsonNode>);
    method &Add(params aValues: array of JsonNode);
    method &Add(aValues: ImmutableList<String>);
    method &Add(params aValues: array of String);
    method Insert(aIndex: Integer; aValue: not nullable JsonNode);
    method Clear;
    method &RemoveAt(aIndex: Integer);

    //method ToStrings: not nullable sequence of String;
    //method ToStringList: not nullable ImmutableList<String>;

    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String; override;

    {$IF NOT TOFFEE}
    [&Sequence]
    method GetSequence: sequence of JsonNode; iterator;
    begin
      yield fItems;
    end;
    {$ENDIF}

    {$IF TOFFEE AND NOT TOFFEEV2}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger;
    {$ENDIF}

    class method Load(JsonString: String): not nullable JsonArray;

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

    operator Implicit(aValue: JsonArray): ImmutableList<JsonNode>;
    begin
      result := aValue.fItems;
    end;

    operator Implicit(aValue: JsonArray): array of JsonNode;
    begin
      result := aValue.fItems.ToArray();
    end;

  end;

implementation

constructor JsonArray;
begin
  fItems := new List<JsonNode>();
end;

constructor JsonArray(aItems: not nullable ImmutableList<JsonNode>);
begin
  fItems := aItems.UniqueMutableCopy;
end;

{$IF NOT COOPER}
constructor JsonArray(aItems: not nullable ImmutableList<String>);
begin
  fItems := new List<JsonNode>();
  for each el in aItems do
    fItems.Add(new JsonStringValue(el));
end;
{$ENDIF}

constructor JsonArray(params aItems: not nullable array of JsonNode);
begin
  fItems := new List<JsonNode>(aItems);
end;

constructor JsonArray(params aItems: not nullable array of String);
begin
  fItems := aItems.Select(v -> new JsonStringValue(v) as JsonNode).ToList as not nullable;
end;

method JsonArray.GetItem(aIndex: Integer): not nullable JsonNode;
begin
  exit fItems[aIndex] as not nullable;
end;

method JsonArray.SetItem(aIndex: Integer; aValue: not nullable JsonNode);
begin
  fItems[aIndex] := aValue;
end;

method JsonArray.Add(aValue: not nullable JsonNode);
begin
  fItems.Add(aValue);
end;

method JsonArray.Add(aValues: ImmutableList<JsonNode>);
begin
  fItems.Add(aValues);
end;

method JsonArray.Add(params aValues: array of JsonNode);
begin
  fItems.Add(aValues);
end;

method JsonArray.Add(aValues: ImmutableList<String>);
begin
  for each el in aValues do begin
    fItems.Add(new JsonStringValue(el));
  end;
end;

method JsonArray.Add(params aValues: array of String);
begin
  fItems.Add(aValues.Select(s -> new JsonStringValue(s) as JsonNode));
end;

method JsonArray.Insert(aIndex: Integer; aValue: not nullable JsonNode);
begin
  fItems.Insert(aIndex, aValue);
end;

method JsonArray.Clear;
begin
  fItems.RemoveAll;
end;

method JsonArray.RemoveAt(aIndex: Integer);
begin
  fItems.RemoveAt(aIndex);
end;

class method JsonArray.Load(JsonString: String): not nullable JsonArray;
begin
  var Serializer := new JsonDeserializer(JsonString);
  var lValue := Serializer.Deserialize;

  if not (lValue is JsonArray) then
    raise new InvalidOperationException("String does not contain a valid Json array");

  result := lValue as JsonArray as not nullable;
end;

method JsonArray.ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
begin
  var Serializer := new JsonSerializer(self, aFormat);
  exit Serializer.Serialize;
end;

{$IF TOFFEE AND NOT TOFFEEV2}
method JsonArray.countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger;
begin
  {$HIDE CPW8}
  exit NSArray(fItems).countByEnumeratingWithState(aState) objects(^id(stackbuf)) count(len);
  {$SHOW CPW8}
end;
{$ENDIF}

//method JsonArray.ToStrings: not nullable sequence of String;
//begin
  //result := fItems.Where(i -> i is JsonStringValue).Select(i -> i.StringValue) as not nullable;
//end;

//method JsonArray.ToStringList: not nullable ImmutableList<String>;
//begin
  //result := ToStrings().ToList() as not nullable;
//end;

end.