namespace RemObjects.Elements.RTL;

type
  /// A syntax or evaluation error in the supported jq query subset.
  JsonQueryException = public class(JsonException)
  public

    constructor(aMessage: String; aPosition: Integer := -1);
    begin
      inherited constructor(if aPosition ≥ 0 then $"{aMessage} at offset {aPosition}." else aMessage);
      Position := aPosition;
    end;

    property Position: Integer read private write;

  end;

  /// Limits are copied when evaluation starts. Limits must be positive.
  JsonQueryOptions = public class
  public

    property MaxSteps: Integer := 1000000;
    property MaxValues: Integer := 100000;
    property MaxDepth: Integer := 64;
    property MaxStringLength: Integer := 1048576;
    property IsCancelled: nullable block: Boolean;

  end;

  /// A compiled, reusable jq-style query. Evaluation never modifies its input.
  JsonQuery = public class
  private

    field fExpression: JsonQueryExpression;

  public

    constructor(aQuery: not nullable String);
    begin
      fExpression := new JsonQueryParser(aQuery).Parse;
    end;

    /// Returns the result stream. An empty stream differs from one JSON null result.
    /// Selected nodes can share storage with the input; callers must not mutate them concurrently.
    method Evaluate(aInput: nullable JsonNode; aOptions: nullable JsonQueryOptions := nil): not nullable ImmutableList<JsonNode>;
    begin
      exit new JsonQueryEvaluation(aOptions).Evaluate(fExpression, coalesce(aInput, JsonNullValue.Null), 0);
    end;

  end;

  JsonQueryExpression = assembly class
  public

    property Kind: String;
    property Text: String;
    property Position: Integer;
    property Value: JsonNode;
    property Left: JsonQueryExpression;
    property Right: JsonQueryExpression;
    property Children := new List<JsonQueryExpression>;
    property Names := new List<String>;

  end;

  JsonQueryParser = assembly class
  private

    field fSource: String;
    field fOffset: Integer;
    field fStart: Integer;
    field fToken: String;
    field fKind: String;
    field fDepth: Integer;

    method Fail(aMessage: String);
    begin
      raise new JsonQueryException(aMessage, fStart);
    end;

    method IsLetter(aChar: Char): Boolean;
    begin
      exit (aChar ≥ 'a') and (aChar ≤ 'z') or (aChar ≥ 'A') and (aChar ≤ 'Z') or (aChar = '_');
    end;

    method Next;
    begin
      while (fOffset < fSource.Length) and (fSource[fOffset] in [#9, #10, #13, ' ']) do
        inc(fOffset);
      fStart := fOffset;
      fKind := "symbol";
      if fOffset = fSource.Length then begin
        fToken := "";
        exit;
      end;
      var lChar := fSource[fOffset];
      inc(fOffset);
      if lChar = '"' then begin
        fKind := "string";
        var lClosed := false;
        while fOffset < fSource.Length do begin
          var lNextChar := fSource[fOffset];
          inc(fOffset);
          if lNextChar = '"' then begin
            lClosed := true;
            break;
          end;
          if lNextChar = '\' then
            inc(fOffset);
        end;
        if not lClosed then
          Fail("Unterminated string");
      end
      else if IsLetter(lChar) then begin
        fKind := "name";
        while (fOffset < fSource.Length) and (IsLetter(fSource[fOffset]) or (fSource[fOffset] in ['0'..'9'])) do
          inc(fOffset);
      end
      else if (lChar in ['0'..'9']) or (lChar = '-') then begin
        fKind := "number";
        while (fOffset < fSource.Length) and (fSource[fOffset] in ['0'..'9', '.', 'e', 'E', '+', '-']) do
          inc(fOffset);
      end
      else if (lChar in ['=', '!', '<', '>']) and (fOffset < fSource.Length) and (fSource[fOffset] = '=') then begin
        inc(fOffset);
      end;
      fToken := fSource.Substring(fStart, fOffset-fStart);
    end;

    method Take(aToken: String): Boolean;
    begin
      result := fToken = aToken;
      if result then
        Next;
    end;

    method Expect(aToken: String);
    begin
      if not Take(aToken) then
        Fail($"Expected '{aToken}'");
    end;

    method Node(aKind: String; aLeft: JsonQueryExpression := nil; aRight: JsonQueryExpression := nil): JsonQueryExpression;
    begin
      exit new JsonQueryExpression(Kind := aKind, Left := aLeft, Right := aRight, Position := fStart);
    end;

    method Literal: JsonNode;
    begin
      try
        result := JsonDocument.FromString(fToken, true);
      except
        on E: JsonParserException do
          Fail("Invalid JSON literal");
      end;
      Next;
    end;

    method Expression(aComma: Boolean := true): JsonQueryExpression;
    begin
      inc(fDepth);
      if fDepth > 64 then
        Fail("Query nesting limit exceeded");
      try
        result := Comma(aComma);
        while Take("|") do
          result := Node("pipe", result, Comma(aComma));
      finally
        dec(fDepth);
      end;
    end;

    method Comma(aAllowed: Boolean): JsonQueryExpression;
    begin
      result := LogicalOr;
      while aAllowed and Take(",") do
        result := Node("comma", result, LogicalOr);
    end;

    method LogicalOr: JsonQueryExpression;
    begin
      result := LogicalAnd;
      while Take("or") do
        result := Node("or", result, LogicalAnd);
    end;

    method LogicalAnd: JsonQueryExpression;
    begin
      result := Comparison;
      while Take("and") do
        result := Node("and", result, Comparison);
    end;

    method Comparison: JsonQueryExpression;
    begin
      result := Primary;
      while fToken in ["==", "!=", "<", "<=", ">", ">="] do begin
        var lOperator := fToken;
        Next;
        result := Node(lOperator, result, Primary);
      end;
    end;

    method Primary: JsonQueryExpression;
    begin
      var lPosition := fStart;
      if Take(".") then begin
        result := Node("identity");
        if ((fKind = "name") and ((fStart = lPosition+1) or not (fToken in ["and", "or"]))) or (fKind = "string") then
          result := Member(result);
      end
      else if Take("(") then begin
        result := Expression;
        Expect(")");
      end
      else if Take("[") then begin
        result := Node("array");
        if not Take("]") then begin
          result.Left := Expression;
          Expect("]");
        end;
      end
      else if Take("{") then begin
        result := Node("object");
        if not Take("}") then begin
          repeat
            if (fKind ≠ "name") and (fKind ≠ "string") then
              Fail("Expected object member name");
            var lName: String;
            if fKind = "string" then begin
              lName := Literal.StringValue;
            end
            else begin
              lName := fToken;
              Next;
            end;
            result.Names.Add(lName);
            if Take(":") then begin
              result.Children.Add(Expression(false));
            end
            else begin
              result.Children.Add(new JsonQueryExpression(Kind := "field", Left := Node("identity"), Text := lName, Position := lPosition));
            end;
          until not Take(",");
          Expect("}");
        end;
      end
      else if (fKind = "string") or (fKind = "number") or (fToken in ["true", "false", "null"]) then begin
        result := Node("literal");
        result.Value := Literal;
      end
      else if fKind = "name" then begin
        var lName := fToken;
        Next;
        result := Node("function");
        result.Text := lName;
        if lName in ["select", "map", "sort_by", "group_by"] then begin
          Expect("(");
          result.Left := Expression;
          Expect(")");
        end
        else if not (lName in ["keys", "length", "type", "empty", "not", "unique", "sort", "add", "min", "max", "flatten"]) then begin
          raise new JsonQueryException($"Unsupported function '{lName}'", lPosition);
        end;
      end
      else begin
        Fail($"Expected query expression; found '{fToken}'");
      end;
      result.Position := lPosition;
      while (fToken = ".") or (fToken = "[") do begin
        if Take(".") then begin
          result := Member(result);
        end
        else begin
          Expect("[");
          if Take("]") then begin
            result := Node("iterate", result);
          end
          else begin
            var lIndex := Node("index", result);
            if (fKind ≠ "string") and (fKind ≠ "number") then
              Fail("Only literal string and integer indexes are supported");
            lIndex.Value := Literal;
            if (lIndex.Value is not JsonStringValue) and (lIndex.Value is not JsonIntegerValue) then
              Fail("Expected string or integer index");
            Expect("]");
            result := lIndex;
          end;
        end;
      end;
    end;

    method Member(aInput: JsonQueryExpression): JsonQueryExpression;
    begin
      result := Node("field", aInput);
      if fKind = "string" then begin
        result.Text := Literal.StringValue;
      end
      else if fKind = "name" then begin
        result.Text := fToken;
        Next;
      end
      else begin
        Fail("Expected member name after '.'");
      end;
    end;

  public

    constructor(aSource: String);
    begin
      if not assigned(aSource) or (aSource.Length > 65536) then
        raise new JsonQueryException("Query must contain at most 65536 characters");
      fSource := aSource;
      Next;
    end;

    method Parse: JsonQueryExpression;
    begin
      result := Expression;
      if length(fToken) > 0 then
        Fail($"Unsupported or unexpected token '{fToken}'");
    end;

  end;

  JsonQuerySortItem = assembly class
  public
    property Value: JsonNode;
    property Key: JsonNode;
  end;

  JsonQueryEvaluation = assembly class
  private

    field fSteps: Integer;
    field fValues: Integer;
    field fMaxSteps: Integer;
    field fMaxValues: Integer;
    field fMaxDepth: Integer;
    field fMaxStringLength: Integer;
    field fIsCancelled: nullable block: Boolean;

    method Check(aDepth: Integer := 0);
    begin
      if assigned(fIsCancelled) and fIsCancelled() then
        raise new JsonQueryException("Query cancelled");
      if aDepth > fMaxDepth then
        raise new JsonQueryException("Evaluation nesting limit exceeded");
      if fSteps ≥ fMaxSteps then
        raise new JsonQueryException("Evaluation step limit exceeded");
      inc(fSteps);
    end;

    method Value(aValue: JsonNode): JsonNode;
    begin
      Check;
      if fValues ≥ fMaxValues then
        raise new JsonQueryException("Generated value limit exceeded");
      inc(fValues);
      if (aValue is JsonStringValue) and (aValue.StringValue.Length > fMaxStringLength) then
        raise new JsonQueryException("String length limit exceeded");
      if (aValue is JsonFloatValue) and (Consts.IsNaN(aValue.FloatValue) or Consts.IsInfinity(aValue.FloatValue)) then
        raise new JsonQueryException("Non-finite numbers are unsupported");
      exit coalesce(aValue, JsonNullValue.Null);
    end;

    method Truth(aValue: JsonNode): Boolean;
    begin
      exit (aValue is not JsonNullValue) and ((aValue is not JsonBooleanValue) or aValue.BooleanValue);
    end;

    method Rank(aValue: JsonNode): Integer;
    begin
      if aValue is JsonNullValue then
        exit 0;
      if aValue is JsonBooleanValue then
        exit if aValue.BooleanValue then 2 else 1;
      if (aValue is JsonIntegerValue) or (aValue is JsonFloatValue) then
        exit 3;
      if aValue is JsonStringValue then
        exit 4;
      if aValue is JsonArray then
        exit 5;
      exit 6;
    end;

    method CodePoint(aText: String; var aOffset: Integer): Integer;
    begin
      result := Integer(aText[aOffset]);
      inc(aOffset);
      if (result ≥ $d800) and (result ≤ $dbff) and (aOffset < aText.Length) then begin
        var lLow := Integer(aText[aOffset]);
        if (lLow ≥ $dc00) and (lLow ≤ $dfff) then begin
          result := $10000 + (result-$d800)*$400 + lLow-$dc00;
          inc(aOffset);
        end;
      end;
    end;

    method CompareText(aLeft: String; aRight: String): Integer;
    begin
      var lLeft := 0;
      var lRight := 0;
      while (lLeft < aLeft.Length) and (lRight < aRight.Length) do begin
        Check;
        var lComparison := CodePoint(aLeft, var lLeft)-CodePoint(aRight, var lRight);
        if lComparison ≠ 0 then
          exit lComparison;
      end;
      exit (aLeft.Length-lLeft)-(aRight.Length-lRight);
    end;

    method Keys(aObject: JsonObject): List<String>;
    begin
      var lItems := new List<JsonQuerySortItem>;
      for lKey in aObject.Keys do begin
        var lValue := Value(new JsonStringValue(lKey));
        lItems.Add(new JsonQuerySortItem(Value := lValue, Key := lValue));
      end;
      result := new List<String>;
      for lItem in Sort(lItems) do
        result.Add(lItem.Value.StringValue);
    end;

    method CompareIntegerFloat(aInteger: Int64; aFloat: Double): Integer;
    begin
      // Check the exclusive upper bound before conversion: Int64.Max rounds upward as Double.
      if aFloat ≥ 9223372036854775808.0 then
        exit -1;
      if aFloat < -9223372036854775808.0 then
        exit 1;
      var lInteger := Int64(aFloat);
      if aInteger < lInteger then
        exit -1;
      if aInteger > lInteger then
        exit 1;
      exit if Double(lInteger) < aFloat then -1 else if Double(lInteger) > aFloat then 1 else 0;
    end;

    method Compare(aLeft: JsonNode; aRight: JsonNode; aDepth: Integer := 0): Integer;
    begin
      Check(aDepth);
      aLeft := coalesce(aLeft, JsonNullValue.Null);
      aRight := coalesce(aRight, JsonNullValue.Null);
      var lRank := Rank(aLeft);
      result := lRank-Rank(aRight);
      if result ≠ 0 then
        exit;
      case lRank of
        0, 1, 2: exit 0;
        3: begin
          if (aLeft is JsonIntegerValue) and (aRight is JsonIntegerValue) then
            exit if aLeft.IntegerValue < aRight.IntegerValue then -1 else if aLeft.IntegerValue > aRight.IntegerValue then 1 else 0;
          if aLeft is JsonIntegerValue then
            exit CompareIntegerFloat(aLeft.IntegerValue, aRight.FloatValue);
          if aRight is JsonIntegerValue then
            exit -CompareIntegerFloat(aRight.IntegerValue, aLeft.FloatValue);
          var lLeft := aLeft.FloatValue;
          var lRight := aRight.FloatValue;
          exit if lLeft < lRight then -1 else if lLeft > lRight then 1 else 0;
        end;
        4: exit CompareText(aLeft.StringValue, aRight.StringValue);
        5: begin
          var lLeft := aLeft as JsonArray;
          var lRight := aRight as JsonArray;
          for i: Integer := 0 to Math.Min(lLeft.Count, lRight.Count)-1 do begin
            result := Compare(lLeft[i], lRight[i], aDepth+1);
            if result ≠ 0 then
              exit;
          end;
          exit lLeft.Count-lRight.Count;
        end;
        6: begin
          var lLeft := aLeft as JsonObject;
          var lRight := aRight as JsonObject;
          var lLeftKeys := Keys(lLeft);
          var lRightKeys := Keys(lRight);
          for i: Integer := 0 to Math.Min(lLeftKeys.Count, lRightKeys.Count)-1 do begin
            result := CompareText(lLeftKeys[i], lRightKeys[i]);
            if result ≠ 0 then
              exit;
          end;
          result := lLeftKeys.Count-lRightKeys.Count;
          if result ≠ 0 then
            exit;
          for lKey in lLeftKeys do begin
            result := Compare(lLeft[lKey], lRight[lKey], aDepth+1);
            if result ≠ 0 then
              exit;
          end;
        end;
      end;
    end;

    method Items(aInput: JsonNode): List<JsonNode>;
    begin
      result := new List<JsonNode>;
      if aInput is JsonArray then begin
        var lArray := aInput as JsonArray;
        for i: Integer := 0 to lArray.Count-1 do
          result.Add(Value(lArray[i]));
      end
      else if aInput is JsonObject then begin
        var lObject := aInput as JsonObject;
        for lKey in lObject.Keys do
          result.Add(Value(lObject[lKey]));
      end
      else begin
        raise new JsonQueryException("Iteration requires an array or object");
      end;
    end;

    method CopyObject(aInput: JsonObject): JsonObject;
    begin
      result := new JsonObject;
      Value(result);
      for lKey in aInput.Keys do
        result[lKey] := Value(aInput[lKey]);
    end;

    method Flatten(aInput: JsonArray; aOutput: JsonArray; aDepth: Integer);
    begin
      Check(aDepth);
      for i: Integer := 0 to aInput.Count-1 do begin
        var lItem := aInput[i];
        if lItem is JsonArray then
          Flatten(lItem as JsonArray, aOutput, aDepth+1)
        else
          aOutput.Add(Value(lItem));
      end;
    end;

    method Add(aLeft: JsonNode; aRight: JsonNode): JsonNode;
    begin
      Check;
      if aLeft is JsonNullValue then
        exit aRight;
      if aRight is JsonNullValue then
        exit aLeft;
      if (Rank(aLeft) = 3) and (Rank(aRight) = 3) then begin
        if (aLeft is JsonIntegerValue) and (aRight is JsonIntegerValue) then begin
          var lLeft := aLeft.IntegerValue;
          var lRight := aRight.IntegerValue;
          if ((lRight > 0) and (lLeft > high(Int64)-lRight)) or ((lRight < 0) and (lLeft < low(Int64)-lRight)) then
            raise new JsonQueryException("Integer addition overflow");
          exit Value(new JsonIntegerValue(lLeft+lRight));
        end;
        exit Value(new JsonFloatValue(aLeft.FloatValue+aRight.FloatValue));
      end;
      if (aLeft is JsonStringValue) and (aRight is JsonStringValue) then begin
        if aLeft.StringValue.Length > fMaxStringLength-aRight.StringValue.Length then
          raise new JsonQueryException("String length limit exceeded");
        exit Value(new JsonStringValue(aLeft.StringValue+aRight.StringValue));
      end;
      if (aLeft is JsonArray) and (aRight is JsonArray) then begin
        var lResult := new JsonArray;
        for lItem in Items(aLeft) do
          lResult.Add(lItem);
        for lItem in Items(aRight) do
          lResult.Add(lItem);
        exit Value(lResult);
      end;
      if (aLeft is JsonObject) and (aRight is JsonObject) then begin
        var lResult := CopyObject(aLeft as JsonObject);
        var lRight := aRight as JsonObject;
        for lKey in lRight.Keys do
          lResult[lKey] := Value(lRight[lKey]);
        exit lResult;
      end;
      raise new JsonQueryException("Cannot add these JSON types");
    end;

    method EvaluateFunction(aExpression: JsonQueryExpression; aInput: JsonNode; aDepth: Integer): List<JsonNode>;
    begin
      result := new List<JsonNode>;
      var lName := aExpression.Text;
      case lName of
        "empty": exit;
        "not": result.Add(Value(new JsonBooleanValue(not Truth(aInput))));
        "type": begin
          var lType := case Rank(aInput) of 0: "null"; 1,2: "boolean"; 3: "number"; 4: "string"; 5: "array"; else "object"; end;
          result.Add(Value(new JsonStringValue(lType)));
        end;
        "select": begin
          for lPredicate in Evaluate(aExpression.Left, aInput, aDepth+1) do
            if Truth(lPredicate) then
              result.Add(Value(aInput));
        end;
        "map": begin
          var lArray := new JsonArray;
          for lItem in Items(aInput) do
            for lResult in Evaluate(aExpression.Left, lItem, aDepth+1) do
              lArray.Add(Value(lResult));
          result.Add(Value(lArray));
        end;
        "keys": begin
          var lArray := new JsonArray;
          if aInput is JsonObject then begin
            for lKey in Keys(aInput as JsonObject) do
              lArray.Add(Value(new JsonStringValue(lKey)));
          end
          else if aInput is JsonArray then begin
            for i: Integer := 0 to aInput.Count-1 do
              lArray.Add(Value(new JsonIntegerValue(i)));
          end
          else
            raise new JsonQueryException("keys requires an array or object");
          result.Add(Value(lArray));
        end;
        "length": begin
          var lLength: Int64 := 0;
          if aInput is JsonStringValue then begin
            var lText := aInput.StringValue;
            var lOffset := 0;
            while lOffset < lText.Length do begin
              Check;
              CodePoint(lText, var lOffset);
              inc(lLength);
            end;
          end
          else if (aInput is JsonArray) or (aInput is JsonObject) then
            lLength := aInput.Count
          else if aInput is JsonIntegerValue then begin
            lLength := aInput.IntegerValue;
            if lLength = low(Int64) then
              raise new JsonQueryException("Integer absolute value overflow");
            if lLength < 0 then
              lLength := -lLength;
          end
          else if aInput is JsonFloatValue then begin
            result.Add(Value(new JsonFloatValue(Math.Abs(aInput.FloatValue))));
            exit;
          end
          else if aInput is not JsonNullValue then
            raise new JsonQueryException("length is undefined for booleans");
          result.Add(Value(new JsonIntegerValue(lLength)));
        end;
        else begin
          if aInput is not JsonArray then
            raise new JsonQueryException($"{lName} requires an array");
          var lInput := aInput as JsonArray;
          if lName = "flatten" then begin
            var lArray := new JsonArray;
            Flatten(lInput, lArray, aDepth+1);
            result.Add(Value(lArray));
          end
          else if lName in ["add", "min", "max"] then begin
            var lValue: JsonNode := JsonNullValue.Null;
            for i: Integer := 0 to lInput.Count-1 do begin
              var lItem := coalesce(lInput[i], JsonNullValue.Null);
              if lName = "add" then
                lValue := Add(lValue, lItem)
              else if (i = 0) or ((lName = "min") and (Compare(lItem, lValue) < 0)) or ((lName = "max") and (Compare(lItem, lValue) > 0)) then
                lValue := lItem;
            end;
            result.Add(Value(lValue));
          end
          else begin
            var lItems := new List<JsonQuerySortItem>;
            for lItem in Items(lInput) do begin
              var lKey := lItem;
              if assigned(aExpression.Left) then begin
                var lKeys := new JsonArray;
                for lPart in Evaluate(aExpression.Left, lItem, aDepth+1) do
                  lKeys.Add(Value(lPart));
                lKey := Value(lKeys);
              end;
              lItems.Add(new JsonQuerySortItem(Value := lItem, Key := lKey));
            end;
            // Stable insertion order for equal keys is preserved by merge sort.
            lItems := Sort(lItems);
            var lArray := new JsonArray;
            var lGroup: JsonArray;
            var lPrevious: JsonNode;
            for lItem in lItems do begin
              var lNew := not assigned(lPrevious) or (Compare(lPrevious, lItem.Key) ≠ 0);
              if lName = "group_by" then begin
                if lNew then begin
                  lGroup := new JsonArray;
                  lArray.Add(Value(lGroup));
                end;
                lGroup.Add(Value(lItem.Value));
              end
              else if (lName ≠ "unique") or lNew then
                lArray.Add(Value(lItem.Value));
              lPrevious := lItem.Key;
            end;
            result.Add(Value(lArray));
          end;
        end;
      end;
    end;

    method Sort(aItems: List<JsonQuerySortItem>): List<JsonQuerySortItem>;
    begin
      if aItems.Count < 2 then
        exit aItems;
      var lLeft := new List<JsonQuerySortItem>;
      var lRight := new List<JsonQuerySortItem>;
      for i: Integer := 0 to aItems.Count-1 do begin
        Check;
        if i < aItems.Count/2 then
          lLeft.Add(aItems[i])
        else
          lRight.Add(aItems[i]);
      end;
      lLeft := Sort(lLeft);
      lRight := Sort(lRight);
      result := new List<JsonQuerySortItem>;
      var lLeftIndex := 0;
      var lRightIndex := 0;
      while (lLeftIndex < lLeft.Count) or (lRightIndex < lRight.Count) do begin
        Check;
        if (lRightIndex = lRight.Count) or ((lLeftIndex < lLeft.Count) and (Compare(lLeft[lLeftIndex].Key, lRight[lRightIndex].Key) ≤ 0)) then begin
          result.Add(lLeft[lLeftIndex]);
          inc(lLeftIndex);
        end
        else begin
          result.Add(lRight[lRightIndex]);
          inc(lRightIndex);
        end;
      end;
    end;

  public

    constructor(aOptions: nullable JsonQueryOptions);
    begin
      var lOptions := coalesce(aOptions, new JsonQueryOptions);
      fMaxSteps := lOptions.MaxSteps;
      fMaxValues := lOptions.MaxValues;
      fMaxDepth := lOptions.MaxDepth;
      fMaxStringLength := lOptions.MaxStringLength;
      fIsCancelled := lOptions.IsCancelled;
      if (fMaxSteps ≤ 0) or (fMaxValues ≤ 0) or (fMaxDepth ≤ 0) or (fMaxDepth > 256) or (fMaxStringLength ≤ 0) then
        raise new JsonQueryException("Limits must be positive; MaxDepth must not exceed 256");
    end;

    method Evaluate(aExpression: JsonQueryExpression; aInput: JsonNode; aDepth: Integer): List<JsonNode>;
    begin
      Check(aDepth);
      result := new List<JsonNode>;
      case aExpression.Kind of
        "identity": result.Add(Value(aInput));
        "literal": result.Add(Value(aExpression.Value));
        "function": exit EvaluateFunction(aExpression, aInput, aDepth);
        "pipe": begin
          for lItem in Evaluate(aExpression.Left, aInput, aDepth+1) do
            for lOutput in Evaluate(aExpression.Right, lItem, aDepth+1) do
              result.Add(Value(lOutput));
        end;
        "comma": begin
          for lOutput in Evaluate(aExpression.Left, aInput, aDepth+1) do
            result.Add(Value(lOutput));
          for lOutput in Evaluate(aExpression.Right, aInput, aDepth+1) do
            result.Add(Value(lOutput));
        end;
        "array": begin
          var lArray := new JsonArray;
          if assigned(aExpression.Left) then
            for lOutput in Evaluate(aExpression.Left, aInput, aDepth+1) do
              lArray.Add(Value(lOutput));
          result.Add(Value(lArray));
        end;
        "object": begin
          result.Add(Value(new JsonObject));
          for i: Integer := 0 to aExpression.Children.Count-1 do begin
            var lValues := Evaluate(aExpression.Children[i], aInput, aDepth+1);
            var lNext := new List<JsonNode>;
            for lObject in result do
              for lValue in lValues do begin
                var lCopy := CopyObject(lObject as JsonObject);
                lCopy[aExpression.Names[i]] := Value(lValue);
                lNext.Add(lCopy);
              end;
            result := lNext;
          end;
        end;
        "field", "index", "iterate": begin
          for lInput in Evaluate(aExpression.Left, aInput, aDepth+1) do begin
            if aExpression.Kind = "iterate" then begin
              for lItem in Items(lInput) do
                result.Add(Value(lItem));
            end
            else if lInput is JsonNullValue then
              result.Add(Value(lInput))
            else if (aExpression.Kind = "field") or (aExpression.Value is JsonStringValue) then begin
              if lInput is not JsonObject then
                raise new JsonQueryException("Member lookup requires an object");
              var lKey := if aExpression.Kind = "field" then aExpression.Text else aExpression.Value.StringValue;
              result.Add(Value((lInput as JsonObject)[lKey]));
            end
            else begin
              if lInput is not JsonArray then
                raise new JsonQueryException("Integer indexing requires an array");
              var lArray := lInput as JsonArray;
              var lIndex := aExpression.Value.IntegerValue;
              if lIndex < 0 then
                lIndex := lIndex+lArray.Count;
              result.Add(Value(if (lIndex ≥ 0) and (lIndex < lArray.Count) then lArray[Integer(lIndex)] else JsonNullValue.Null));
            end;
          end;
        end;
        else begin
          for lLeft in Evaluate(aExpression.Left, aInput, aDepth+1) do begin
            if ((aExpression.Kind = "and") and not Truth(lLeft)) or ((aExpression.Kind = "or") and Truth(lLeft)) then begin
              result.Add(Value(new JsonBooleanValue(Truth(lLeft))));
              continue;
            end;
            for lRight in Evaluate(aExpression.Right, aInput, aDepth+1) do begin
              var lMatch: Boolean;
              if aExpression.Kind in ["and", "or"] then
                lMatch := Truth(lRight)
              else begin
                var lComparison := Compare(lLeft, lRight);
                lMatch := case aExpression.Kind of "==": lComparison = 0; "!=": lComparison ≠ 0; "<": lComparison < 0; "<=": lComparison ≤ 0; ">": lComparison > 0; else lComparison ≥ 0; end;
              end;
              result.Add(Value(new JsonBooleanValue(lMatch)));
            end;
          end;
        end;
      end;
    end;

  end;

end.
