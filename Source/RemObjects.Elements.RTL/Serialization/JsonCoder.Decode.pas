namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL;

type
  JsonCoder = public partial class
  public

    method DecodeString(aName: String): String; override;
    begin
      try
        result := DoGetValue(aName):StringValue
      except
        on JsonNodeTypeException do raise new Exception($"Error decoding '{aName}' Value: {DoGetValue(aName):NodeKind}");
        on Exception do raise;
      end;
    end;

    {$IF NOT COOPER}
    method DecodeIntPtr(aName: String): nullable IntPtr; override;
    begin
      result := DoGetValue(aName):IntegerValue
    end;

    method DecodeUIntPtr(aName: String): nullable UIntPtr; override;
    begin
      result := DoGetValue(aName):IntegerValue {$HINT Handle UInt properly}
    end;
    {$ENDIF}

    method DecodeInt64(aName: String): nullable Int64; override;
    begin
      result := DoGetValue(aName):IntegerValue
    end;

    method DecodeUInt64(aName: String): nullable UInt64; override;
    begin
      result := DoGetValue(aName):IntegerValue {$HINT Handle UInt properly}
    end;

    method DecodeDouble(aName: String): nullable Double; override;
    begin
      result := DoGetValue(aName):FloatValue
    end;

    method DecodeBoolean(aName: String): nullable Boolean; override;
    begin
      result := DoGetValue(aName):BooleanValue
    end;

    method DecodeJsonNode(aName: String): JsonNode; override;
    begin
      result := DoGetValue(aName);
    end;

    //

    method DecodeObjectType(aName: String): String; override;
    begin
      result := Current["__Type"]:StringValue;
    end;

    method DecodeObjectStart(aName: String): Boolean; override;
    begin
      if DoGetValue(aName) is JsonObject then begin
        Hierarchy.Push(DoGetValue(aName));
        result := true;
      end;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      //if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    method DecodeArrayStart(aName: String): Boolean; override;
    begin
      with matching lValue := JsonArray(DoGetValue(aName)) do begin
        Hierarchy.Push(lValue);
        result := true;
      end;
    end;

    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeArrayElements<T>(aName: String): array of T; override;
    begin
      {$IF NOT COOPER} // JE9 Generic type "T" is not available at runtime// JE9 Generic type "T" is not available at runtime
      if Current is var lJsonArray: JsonArray then begin
        result := new array of T(lJsonArray.Count);
        for i := 0 to lJsonArray.Count-1 do begin
          Hierarchy.Push(lJsonArray[i]);
          var lValue := DecodeArrayElement<T>(aName);
          if assigned(lValue) then
            result[i] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeArrayEnd(aName: String); override;
    begin
      //if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    method DecodeStringDictionaryStart(aName: String): Boolean; override;
    begin
      Log($"aName {aName}");
      Log($"Current {Current}");
      with matching lValue := JsonObject(DoGetValue(aName)) do begin
        Hierarchy.Push(lValue);
        result := true;
      end;
    end;

    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeStringDictionaryElements<T>(aName: String): Dictionary<String,T>; override;
    begin
      {$IF NOT COOPER} // JE9 Generic type "T" is not available at runtime// JE9 Generic type "T" is not available at runtime
      with matching lJsonObject := JsonObject(Current) do begin
        result := new Dictionary<String,T> withCapacity(lJsonObject.Count);
        for each k in lJsonObject.Keys do begin
          Hierarchy.Push(lJsonObject[k]);
          var lValue := DecodeArrayElement<T>(aName);
          if assigned(lValue) then
            result[k] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeStringDictionaryEnd(aName: String); override;
    begin
      //if assigned(aName) then
        Hierarchy.Pop;
    end;

  private

    method DoGetValue(aName: nullable String): JsonNode;
    begin
      if assigned(aName) and (Current is JsonObject) then
        result := Current[aName]
      else
        result := Current;
    end;

  end;

end.