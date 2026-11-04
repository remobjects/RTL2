namespace RemObjects.Elements.RTL;

interface

type
  JsonSerializer = assembly class
  private
    Builder: StringBuilder := new StringBuilder();
    JValue: JsonNode;
    Offset: Integer;
    fFormat: JsonFormat;
    fObjectCallback: nullable JsonObjectSerializationCallback;

    method SerializationKeys(aObject: not nullable JsonObject; aPath: not nullable String): not nullable ImmutableList<String>;
    class method CompareOrdinal(aLeft: not nullable String; aRight: not nullable String): Integer;
    class method CompareKeys(aLeft: not nullable String; aRight: not nullable String): Integer;

    method IncOffset;
    method DecOffset;
    method AppendOffset;

    method VisitObject(Value: JsonObject; aPath: not nullable String);
    method VisitArray(Value: JsonArray; aPath: not nullable String);
    method VisitString(Value: JsonStringValue);
    method VisitInteger(Value: JsonIntegerValue);
    method VisitFloat(Value: JsonFloatValue);
    method VisitBoolean(Value: JsonBooleanValue);
    method VisitNull();
    method VisitName(Value: not nullable String);
    method Visit(Value: JsonNode; aPath: not nullable String);
  public
    constructor (Value: not nullable JsonNode; aFormat: JsonFormat; aObjectCallback: nullable JsonObjectSerializationCallback := nil);

    method Serialize: not nullable String;
  end;

implementation

constructor JsonSerializer(Value: not nullable JsonNode; aFormat: JsonFormat; aObjectCallback: nullable JsonObjectSerializationCallback);
begin
  JValue := Value;
  fFormat := aFormat;
  fObjectCallback := aObjectCallback;
end;

method JsonSerializer.Serialize: not nullable String;
begin
  Builder.Clear;
  Offset := 0;
  Visit(JValue, "");
  result := Builder.ToString as not nullable;
end;

method JsonSerializer.VisitObject(Value: JsonObject; aPath: not nullable String);
begin
  var lKeys := SerializationKeys(Value, aPath);
  var lKeyCount := lKeys.Count;
  Builder.Append(JsonConsts.OBJECT_START);
  if lKeyCount = 0 then begin
    Builder.Append(JsonConsts.OBJECT_END);
    exit;
  end;
  if fFormat = JsonFormat.HumanReadable then
    Builder.AppendLine;

  IncOffset;

  var lCount := 0;

  for Key: String in lKeys do begin
    inc(lCount);
    VisitName(Key);
    var lPath := if assigned(fObjectCallback) then aPath+"/"+Key.Replace("~", "~0").Replace("/", "~1") else "";
    Visit(Value[Key], lPath);

    if lCount < lKeyCount then
      Builder.Append(JsonConsts.VALUE_SEPARATOR);
    if fFormat = JsonFormat.HumanReadable then
      Builder.AppendLine
  end;
  DecOffset;
  AppendOffset;
  Builder.Append(JsonConsts.OBJECT_END);
end;

method JsonSerializer.VisitArray(Value: JsonArray; aPath: not nullable String);
begin
  Builder.Append(JsonConsts.ARRAY_START);
  if Value.Count = 0 then begin
    Builder.Append(JsonConsts.ARRAY_END);
    exit;
  end;
  if fFormat = JsonFormat.HumanReadable then
    Builder.AppendLine();
  IncOffset;

  for i: Int32 := 0 to Value.Count-1 do begin
    AppendOffset;
    var lPath := if assigned(fObjectCallback) then aPath+"/"+i.ToString else "";
    Visit(Value[i], lPath);
    if i < Value.Count - 1 then
      Builder.Append(JsonConsts.VALUE_SEPARATOR);
    if fFormat = JsonFormat.HumanReadable then
      Builder.AppendLine;
  end;

  DecOffset;
  AppendOffset;
  Builder.Append(JsonConsts.ARRAY_END);
end;

method JsonSerializer.SerializationKeys(aObject: not nullable JsonObject; aPath: not nullable String): not nullable ImmutableList<String>;
begin
  var lKeys := aObject.Keys.ToList.UniqueCopy;
  if not assigned(fObjectCallback) then
    exit lKeys;

  var lContext := new JsonObjectSerializationContext(aObject, aPath, lKeys);
  fObjectCallback(lContext);
  case lContext.Order of
    JsonKeyOrder.AsIs: exit lKeys;
    JsonKeyOrder.Alpha: exit lKeys.ToSortedList((a, b) -> CompareKeys(a, b));
    JsonKeyOrder.Custom: begin
      var lCustomKeys := lContext.CustomKeys;
      if not assigned(lCustomKeys) then
        raise new JsonSerializationException($"Invalid custom JSON key order at '{aPath}': CustomKeys is required.");
      if lCustomKeys.Count ≠ lKeys.Count then
        raise new JsonSerializationException($"Invalid custom JSON key order at '{aPath}': expected {lKeys.Count} keys, got {lCustomKeys.Count}.");

      var lRemaining := new Dictionary<String, Boolean>;
      for lKey in lKeys do
        lRemaining[lKey] := true;
      for lKey in lCustomKeys do begin
        if not assigned(lKey) then
          raise new JsonSerializationException($"Invalid custom JSON key order at '{aPath}': null key.");
        if not lRemaining.Remove(lKey) then
          raise new JsonSerializationException($"Invalid custom JSON key order at '{aPath}': unknown or duplicate key '{lKey}'.");
      end;
      exit lCustomKeys.UniqueCopy;
    end;
    else raise new JsonSerializationException($"Invalid JSON key order at '{aPath}': {lContext.Order}.");
  end;
end;

class method JsonSerializer.CompareOrdinal(aLeft: not nullable String; aRight: not nullable String): Integer;
begin
  var lCount := if aLeft.Length < aRight.Length then aLeft.Length else aRight.Length;
  for i: Integer := 0 to lCount-1 do begin
    if aLeft[i] < aRight[i] then
      exit -1;
    if aLeft[i] > aRight[i] then
      exit 1;
  end;
  result := aLeft.Length-aRight.Length;
end;

class method JsonSerializer.CompareKeys(aLeft: not nullable String; aRight: not nullable String): Integer;
begin
  result := CompareOrdinal(aLeft.ToLowerInvariant, aRight.ToLowerInvariant);
  if result = 0 then
    result := CompareOrdinal(aLeft, aRight);
end;

method JsonSerializer.VisitString(Value: JsonStringValue);
begin
  Builder.Append(Value.ToJsonString);
end;

method JsonSerializer.VisitInteger(Value: JsonIntegerValue);
begin
  Builder.Append(Value.ToJsonString);
end;

method JsonSerializer.VisitFloat(Value: JsonFloatValue);
begin
  Builder.Append(Value.ToJsonString);
end;

method JsonSerializer.VisitBoolean(Value: JsonBooleanValue);
begin
  Builder.Append(Value.ToJsonString);
end;

method JsonSerializer.VisitNull();
begin
  Builder.Append(JsonConsts.NULL_VALUE);
end;

method JsonSerializer.VisitName(Value: not nullable String);
begin
  AppendOffset;
  Builder.Append(JsonStringValue.RenderString(Value));
  Builder.Append(JsonConsts.NAME_SEPARATOR);
  if fFormat = JsonFormat.HumanReadable then
    Builder.Append(" ");
end;

method JsonSerializer.Visit(Value: JsonNode; aPath: not nullable String);
begin
  if assigned(Value) then begin
    case Value type of
      JsonStringValue: VisitString(Value as JsonStringValue);
      JsonIntegerValue: VisitInteger(Value as JsonIntegerValue);
      JsonFloatValue: VisitFloat(Value as JsonFloatValue);
      JsonBooleanValue: VisitBoolean(Value as JsonBooleanValue);
      JsonNullValue: VisitNull();
      JsonArray: VisitArray(Value as JsonArray, aPath);
      JsonObject: VisitObject(Value as JsonObject, aPath);
    end;
  end
  else
    VisitNull();
end;

method JsonSerializer.IncOffset;
begin
  Offset := Offset + 2;
end;

method JsonSerializer.DecOffset;
begin
  Offset := Offset - 2;
end;

method JsonSerializer.AppendOffset;
begin
  if fFormat = JsonFormat.HumanReadable then
    Builder.Append(' ', Offset);
end;

end.
