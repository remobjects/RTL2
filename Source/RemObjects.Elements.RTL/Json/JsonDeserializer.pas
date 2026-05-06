namespace RemObjects.Elements.RTL;

type
  JsonDeserializer = assembly class
  assembly

    constructor (JsonString: String; aAllowPartialJson: Boolean := false);
    begin
      Tokenizer := new JsonTokenizer(JsonString, true, AllowPartialJson := aAllowPartialJson);
    end;

    method Deserialize: not nullable JsonNode;
    begin
      Tokenizer.Next;
      var lAdvancePastContainerEnd := false;
      //Expected(JsonTokenKind.ObjectStart, JsonTokenKind.ArrayStart);
      case Tokenizer.Token of
        JsonTokenKind.ObjectStart: begin
          result := ReadObject();
          lAdvancePastContainerEnd := Tokenizer.Token <> JsonTokenKind.EOF;
        end;
        JsonTokenKind.ArrayStart: begin
          result := ReadArray();
          lAdvancePastContainerEnd := Tokenizer.Token <> JsonTokenKind.EOF;
        end;
        else begin
          case Tokenizer.Token of
            JsonTokenKind.String: result := ReadValue as not nullable;
            JsonTokenKind.Number: result := ReadValue as not nullable;
            JsonTokenKind.Null: result := ReadValue as not nullable;
            JsonTokenKind.True: result := ReadValue as not nullable;
            JsonTokenKind.False: result := ReadValue as not nullable;
            else raise new JsonUnexpectedTokenException($"Unexpected token at {Tokenizer.Row}/{Tokenizer.Column}.");
          end;
        end;
      end;

      if lAdvancePastContainerEnd then
        Tokenizer.Next;

      if (Tokenizer.Token <> JsonTokenKind.EOF) and not Tokenizer.IsPartialJson then
        raise new JsonUnexpectedTokenException($"Unexpected token at {Tokenizer.Row}/{Tokenizer.Column}.");
    end;

  private

    Tokenizer: JsonTokenizer;

    method TokenKindString(aValue: JsonTokenKind): not nullable String;
    begin
      case aValue of
        JsonTokenKind.BOF: exit "BOF";
        JsonTokenKind.EOF: exit "EOF";
        JsonTokenKind.SyntaxError: exit "SyntaxError";
        JsonTokenKind.Whitespace: exit "Whitespace";
        JsonTokenKind.String: exit "String";
        JsonTokenKind.Number: exit "Number";
        JsonTokenKind.Null: exit "Null";
        JsonTokenKind.True: exit "True";
        JsonTokenKind.False: exit "False";
        JsonTokenKind.Identifier: exit "Identifier";
        JsonTokenKind.ArrayStart: exit "ArrayStart";
        JsonTokenKind.ArrayEnd: exit "ArrayEnd";
        JsonTokenKind.ObjectStart: exit "ObjectStart";
        JsonTokenKind.ObjectEnd: exit "ObjectEnd";
        JsonTokenKind.NameSeperator: exit "NameSeperator";
        JsonTokenKind.ValueSeperator: exit "ValueSeperator";
        else exit aValue.ToString;
      end;
    end;

    method ExpectedTokensString(aValues: array of JsonTokenKind): not nullable String;
    begin
      var lResult := new StringBuilder;
      for i: Integer := 0 to length(aValues)-1 do begin
        if i > 0 then
          lResult.Append(", ");
        lResult.Append(TokenKindString(aValues[i]));
      end;
      exit lResult.ToString;
    end;

    method Expected(params Values: array of JsonTokenKind);
    begin
      for Item in Values do
        if Tokenizer.Token = Item then
          exit;

      {$IF COOPER}
      raise new JsonUnexpectedTokenException($"Unexpected token at {Tokenizer.Row}/{Tokenizer.Column}.");
      {$ELSE}
      raise new JsonUnexpectedTokenException($"Unexpected token at {Tokenizer.Row}/{Tokenizer.Column}; expected '{ExpectedTokensString(Values)}', got '{TokenKindString(Tokenizer.Token)}'.");
      {$ENDIF}
    end;


    method ReadObject: not nullable JsonObject;
    begin
      Expected(JsonTokenKind.ObjectStart);

      result := new JsonObject;
      Tokenizer.Next;

      if Tokenizer.Token = JsonTokenKind.ObjectEnd then
        exit;

      var Properties := ReadProperties;

      if (Tokenizer.Token = JsonTokenKind.EOF) and Tokenizer.AllowPartialJson then
        Tokenizer.IsPartialJson := true
      else if not Tokenizer.IsPartialJson then
        Expected(JsonTokenKind.ObjectEnd);

      for Item in Properties do
        result.Add(Item.Key, Item.Value);
    end;

    method ReadArray: not nullable JsonArray;
    begin
      Expected(JsonTokenKind.ArrayStart);

      result := new JsonArray;
      Tokenizer.Next;

      if Tokenizer.Token = JsonTokenKind.ArrayEnd then
        exit;

      var Values := ReadValues;

      if (Tokenizer.Token = JsonTokenKind.EOF) and Tokenizer.AllowPartialJson then
        Tokenizer.IsPartialJson := true
      else
        Expected(JsonTokenKind.ArrayEnd);

      for Item in Values do
        result.Add(Item);
    end;

    method ReadProperties: sequence of KeyValuePair<String, JsonNode>;
    begin
      var List := new List<KeyValuePair<String, JsonNode>>;

      repeat
        List.Add(ReadPropery);

        if not Tokenizer.IsPartialJson and (Tokenizer.Token = JsonTokenKind.ValueSeperator) then begin
          Tokenizer.Next;
          continue;
        end;
      until Tokenizer.IsPartialJson or (Tokenizer.Token = JsonTokenKind.EOF) or (Tokenizer.Token = JsonTokenKind.ObjectEnd);

      exit List;
    end;

    method ReadPropery: KeyValuePair<String, JsonNode>;
    begin
      var lKey := ReadKey;
      Expected(JsonTokenKind.NameSeperator);
      if Tokenizer.Next then
        result := new KeyValuePair<String,JsonNode>(lKey, ReadValue);
    end;

    method ReadKey: String;
    begin
      Expected(JsonTokenKind.String, JsonTokenKind.Identifier);

      if String.IsNullOrEmpty(Tokenizer.Value) then
        raise new JsonParserException("Invalid propery key. Key can not be empty.");

      result := Tokenizer.Value;
      Tokenizer.Next;
    end;

    method ReadValues: sequence of JsonNode;
    begin
      var List := new List<JsonNode>;

      repeat
        List.Add(ReadValue);

        if Tokenizer.Token = JsonTokenKind.ValueSeperator then begin
          Tokenizer.Next;
          continue;
        end;
      until (Tokenizer.Token = JsonTokenKind.EOF) or (Tokenizer.Token = JsonTokenKind.ArrayEnd);

      exit List;
    end;

    method ReadValue: JsonNode;
    begin
      Expected(JsonTokenKind.String, JsonTokenKind.Number, JsonTokenKind.Null, JsonTokenKind.True, JsonTokenKind.False, JsonTokenKind.ArrayStart, JsonTokenKind.ObjectStart, JsonTokenKind.Identifier);

      case Tokenizer.Token of
        JsonTokenKind.String: result := new JsonStringValue(Tokenizer.Value);
        JsonTokenKind.Number: begin
          var lValue := Convert.ToDoubleInvariant(Tokenizer.Value);
          if Tokenizer.Value.Contains(".") or Tokenizer.Value.Contains("e") or Tokenizer.Value.Contains("E") then
            result := new JsonFloatValue(lValue) // force float of valiue had a decimal point!
          else if Consts.IsInfinity(lValue) or Consts.IsNaN(lValue) then
            result := new JsonFloatValue(lValue)
          else begin
            if lValue > Consts.MaxInt64 then
              result := new JsonFloatValue(lValue)
            else
              result := new JsonIntegerValue(Convert.ToInt64(Tokenizer.Value))
          end;
        end;
        JsonTokenKind.Null: result := JsonNullValue.Null;
        JsonTokenKind.True: result := new JsonBooleanValue(true);
        JsonTokenKind.False: result := new JsonBooleanValue(false);
        JsonTokenKind.ArrayStart: result := ReadArray();
        JsonTokenKind.ObjectStart: result := ReadObject();
        JsonTokenKind.Identifier: result := new JsonStringValue(Tokenizer.Value);
      end;

      Tokenizer.Next;
    end;

  end;

end.
