namespace RemObjects.Elements.RTL;

interface

type
  JsonSerializer = assembly class
  private
    Builder: StringBuilder := new StringBuilder();
    JValue: JsonNode;
    Offset: Integer;
    fFormat: JsonFormat;

    method IncOffset;
    method DecOffset;
    method AppendOffset;

    method VisitObject(Value: JsonObject);
    method VisitArray(Value: JsonArray);
    method VisitString(Value: JsonStringValue);
    method VisitInteger(Value: JsonIntegerValue);
    method VisitFloat(Value: JsonFloatValue);
    method VisitBoolean(Value: JsonBooleanValue);
    method VisitNull();
    method VisitName(Value: not nullable String);
    method Visit(Value: JsonNode);
  public
    constructor (Value: not nullable JsonNode; aFormat: JsonFormat);

    method Serialize: String;
  end;

implementation

constructor JsonSerializer(Value: not nullable JsonNode; aFormat: JsonFormat);
begin
  JValue := Value;
  fFormat := aFormat;
end;

method JsonSerializer.Serialize: String;
begin
  Builder.Clear;
  Offset := 0;
  Visit(JValue);
  result := Builder.ToString;
end;

method JsonSerializer.VisitObject(Value: JsonObject);
begin
  Builder.Append(JsonConsts.OBJECT_START);
  if fFormat = JsonFormat.HumanReadable then
    Builder.AppendLine;

  IncOffset;

  var lCount := 0;

  for Key: String in Value.Keys do begin
    inc(lCount);
    VisitName(Key);
    Visit(Value[Key]);

    if lCount < Value.Count then
      Builder.Append(JsonConsts.VALUE_SEPARATOR);
    if fFormat = JsonFormat.HumanReadable then
      Builder.AppendLine
  end;
  DecOffset;
  AppendOffset;
  Builder.Append(JsonConsts.OBJECT_END);
end;

method JsonSerializer.VisitArray(Value: JsonArray);
begin
  Builder.Append(JsonConsts.ARRAY_START);
  if fFormat = JsonFormat.HumanReadable then
    Builder.AppendLine();
  IncOffset;

  for i: Int32 := 0 to Value.Count-1 do begin
    AppendOffset;
    Visit(Value[i]);
    if i < Value.Count - 1 then
      Builder.Append(JsonConsts.VALUE_SEPARATOR);
    if fFormat = JsonFormat.HumanReadable then
      Builder.AppendLine;
  end;

  DecOffset;
  AppendOffset;
  Builder.Append(JsonConsts.ARRAY_END);
end;

method JsonSerializer.VisitString(Value: JsonStringValue);
begin
  Builder.Append(Value.ToJson);
end;

method JsonSerializer.VisitInteger(Value: JsonIntegerValue);
begin
  Builder.Append(Value.ToJson);
end;

method JsonSerializer.VisitFloat(Value: JsonFloatValue);
begin
  Builder.Append(Value.ToJson);
end;

method JsonSerializer.VisitBoolean(Value: JsonBooleanValue);
begin
  Builder.Append(Value.ToJson);
end;

method JsonSerializer.VisitNull();
begin
  Builder.Append(JsonConsts.NULL_VALUE);
end;

method JsonSerializer.VisitName(Value: not nullable String);
begin
  AppendOffset;
  VisitString(Value);
  Builder.Append(JsonConsts.NAME_SEPARATOR);
  if fFormat = JsonFormat.HumanReadable then
    Builder.Append(" ");
end;

method JsonSerializer.Visit(Value: JsonNode);
begin
  if assigned(Value) then begin
    case Value type of
      JsonStringValue: VisitString(Value as JsonStringValue);
      JsonIntegerValue: VisitInteger(Value as JsonIntegerValue);
      JsonFloatValue: VisitFloat(Value as JsonFloatValue);
      JsonBooleanValue: VisitBoolean(Value as JsonBooleanValue);
      JsonNullValue: VisitNull();
      JsonArray: VisitArray(Value as JsonArray);
      JsonObject: VisitObject(Value as JsonObject);
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