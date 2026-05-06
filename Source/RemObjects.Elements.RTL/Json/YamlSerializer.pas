namespace RemObjects.Elements.RTL;

interface

type
  YamlOptions = public class
  public
    Indentation: not nullable String := "  ";
    NewLine: String := nil;
    AlwaysQuoteStrings: Boolean := true;
    AlwaysQuoteKeys: Boolean := true;
    EmitDocumentMarker: Boolean := false;
    EmitInlineEmptyCollections: Boolean := true;

    method UniqueCopy: not nullable YamlOptions;
    begin
      result := new YamlOptions();
      result.Indentation := Indentation;
      result.NewLine := NewLine;
      result.AlwaysQuoteStrings := AlwaysQuoteStrings;
      result.AlwaysQuoteKeys := AlwaysQuoteKeys;
      result.EmitDocumentMarker := EmitDocumentMarker;
      result.EmitInlineEmptyCollections := EmitInlineEmptyCollections;
    end;

  assembly
    method NewLineString: not nullable String;
    begin
      result := coalesce(NewLine, Environment.LineBreak) as not nullable;
    end;
  end;

  YamlSerializer = assembly class
  private
    Builder: StringBuilder := new StringBuilder();
    JValue: JsonNode;
    fOptions: not nullable YamlOptions;

    method AppendIndent(aLevel: Integer);
    method AppendNewLine;
    method IsInlineValue(aValue: JsonNode): Boolean;
    method Visit(Value: JsonNode; aLevel: Integer);
    method VisitObject(Value: JsonObject; aLevel: Integer);
    method VisitArray(Value: JsonArray; aLevel: Integer);
    method VisitScalar(Value: JsonNode);

  public
    class method CanEmitPlainScalar(aValue: not nullable String): Boolean; assembly;
    class method RenderString(aValue: not nullable String; aAlwaysQuote: Boolean): not nullable String; assembly;

    constructor(Value: not nullable JsonNode; aOptions: YamlOptions := nil);

    method Serialize: not nullable String;
  end;

implementation

constructor YamlSerializer(Value: not nullable JsonNode; aOptions: YamlOptions := nil);
begin
  JValue := Value;
  if assigned(aOptions) then
    fOptions := aOptions.UniqueCopy
  else
    fOptions := new YamlOptions();
end;

method YamlSerializer.Serialize: not nullable String;
begin
  Builder.Clear;
  if fOptions.EmitDocumentMarker then begin
    Builder.Append("---");
    AppendNewLine;
  end;
  Visit(JValue, 0);
  result := Builder.ToString as not nullable;
end;

class method YamlSerializer.CanEmitPlainScalar(aValue: not nullable String): Boolean;
begin
  if length(aValue) = 0 then
    exit false;

  if aValue.Trim ≠ aValue then
    exit false;

  if aValue.Contains(#10) or aValue.Contains(#13) or aValue.Contains(#9) then
    exit false;

  case aValue[0] of
    '0'..'9', '-', '+', ':', '?', ',', '[', ']', '{', '}', '#', '&', '*', '!', '|', '>', '@', '`', '"', '''', '%':
      exit false;
  end;

  var lLower := aValue.ToLowerInvariant;
  case lLower of
    "null", "~", "true", "false", "yes", "no", "on", "off", ".nan", ".inf", "-.inf", "+.inf":
      exit false;
  end;

  for each c in aValue do
    case c of
      'a'..'z', 'A'..'Z', '0'..'9', ' ', '_', '-', '.', '/':
        ;
      else
        exit false;
    end;

  exit true;
end;

class method YamlSerializer.RenderString(aValue: not nullable String; aAlwaysQuote: Boolean): not nullable String;
begin
  if aAlwaysQuote or not CanEmitPlainScalar(aValue) then
    exit new JsonStringValue(aValue).ToJsonString as not nullable;

  exit aValue;
end;

method YamlSerializer.AppendIndent(aLevel: Integer);
begin
  for i: Integer := 0 to aLevel-1 do
    Builder.Append(fOptions.Indentation);
end;

method YamlSerializer.AppendNewLine;
begin
  Builder.Append(fOptions.NewLineString);
end;

method YamlSerializer.IsInlineValue(aValue: JsonNode): Boolean;
begin
  if not assigned(aValue) then
    exit true;

  case aValue type of
    JsonObject: exit fOptions.EmitInlineEmptyCollections and ((aValue as JsonObject).Count = 0);
    JsonArray: exit fOptions.EmitInlineEmptyCollections and ((aValue as JsonArray).Count = 0);
    else exit true;
  end;
end;

method YamlSerializer.Visit(Value: JsonNode; aLevel: Integer);
begin
  if not assigned(Value) then begin
    Builder.Append(JsonConsts.NULL_VALUE);
    exit;
  end;

  case Value type of
    JsonObject: VisitObject(Value as JsonObject, aLevel);
    JsonArray: VisitArray(Value as JsonArray, aLevel);
    else VisitScalar(Value);
  end;
end;

method YamlSerializer.VisitObject(Value: JsonObject; aLevel: Integer);
begin
  if Value.Count = 0 then begin
    if (aLevel > 0) and not fOptions.EmitInlineEmptyCollections then
      AppendIndent(aLevel);
    Builder.Append("{}");
    exit;
  end;

  var lCount := 0;
  for each lKey in Value.Keys do begin
    inc(lCount);
    AppendIndent(aLevel);
    Builder.Append(RenderString(lKey, fOptions.AlwaysQuoteKeys));

    var lChild := Value[lKey];
    if IsInlineValue(lChild) then begin
      Builder.Append(": ");
      Visit(lChild, aLevel + 1);
    end
    else begin
      Builder.Append(":");
      AppendNewLine;
      Visit(lChild, aLevel + 1);
    end;

    if lCount < Value.Count then
      AppendNewLine;
  end;
end;

method YamlSerializer.VisitArray(Value: JsonArray; aLevel: Integer);
begin
  if Value.Count = 0 then begin
    if (aLevel > 0) and not fOptions.EmitInlineEmptyCollections then
      AppendIndent(aLevel);
    Builder.Append("[]");
    exit;
  end;

  for i: Int32 := 0 to Value.Count - 1 do begin
    AppendIndent(aLevel);
    Builder.Append("-");

    var lChild := Value[i];
    if IsInlineValue(lChild) then begin
      Builder.Append(" ");
      Visit(lChild, aLevel + 1);
    end
    else begin
      AppendNewLine;
      Visit(lChild, aLevel + 1);
    end;

    if i < Value.Count - 1 then
      AppendNewLine;
  end;
end;

method YamlSerializer.VisitScalar(Value: JsonNode);
begin
  Builder.Append(Value.ToYamlString(fOptions));
end;

end.
