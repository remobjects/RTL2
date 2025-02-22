namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  JsonCoder = public partial class
  protected

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

    {$IF ECHOES}
    method DecodeArrayElements<T>(aName: String; aType: &Type): array of T; override;
    begin
      if Current is var lJsonArray: JsonArray then begin
        result := new array of T(lJsonArray.Count);
        for i := 0 to lJsonArray.Count-1 do begin
          Hierarchy.Push(lJsonArray[i]);
          var lValue := DecodeArrayElement(aName, typeOf(T));
          if assigned(lValue) then
            result[i] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ENDIF}

    method DecodeArrayEnd(aName: String); override;
    begin
      Hierarchy.Pop;

      //
    end;

    {$IF ECHOES}
    method DecodeListElements<T>(aName: String; aType: &Type): List<T>; override;
    begin
      if Current is var lJsonArray: JsonArray then begin
        result := new List<T> withCapacity(lJsonArray.Count);
        for i := 0 to lJsonArray.Count-1 do begin
          Hierarchy.Push(lJsonArray[i]);
          var lValue := DecodeArrayElement(aName, typeOf(T));
          if assigned(lValue) then
            result.Add(lValue as T);
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeListElements(aName: String; aType: &Type): NonGenericPlatformList; override;
    begin
      if Current is var lJsonArray: JsonArray then begin
        result := {$IF TOFFEE}new NonGenericPlatformList withCapacity(lJsonArray.Count){$ELSEIF COOPER}new NonGenericPlatformList(lJsonArray.Count){$ENDIF};
        for i := 0 to lJsonArray.Count-1 do begin
          Hierarchy.Push(lJsonArray[i]);
          var lValue := DecodeArrayElement(aName, aType);
          if assigned(lValue) then
            {$IF TOFFEE}result.addObject(lValue){$ELSEIF COOPER}result.Add(lValue){$ENDIF};
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ENDIF}

    //

    method DecodeStringDictionaryStart(aName: String): Boolean; override;
    begin
      with matching lValue := JsonObject(DoGetValue(aName)) do begin
        Hierarchy.Push(lValue);
        result := true;
      end;
    end;

    {$IF ECHOES} // E703 Virtual generic methods not supported on Island
    method DecodeStringDictionaryElements<T>(aName: String; aType: &Type): Dictionary<String,T>; override;
    begin
      with matching lJsonObject := JsonObject(Current) do begin
        result := new Dictionary<String,T> withCapacity(lJsonObject.Count);
        for each k in lJsonObject.Keys do begin
          Hierarchy.Push(lJsonObject[k]);
          var lValue := DecodeArrayElement(aName, typeOf(T));
          if assigned(lValue) then
            result[k] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeStringDictionaryElements(aName: String; aType: &Type): NonGenericPlatformDictionary; override;
    begin
      with matching lJsonObject := JsonObject(Current) do begin
        result := {$IF TOFFEE}new NonGenericPlatformDictionary withCapacity(lJsonObject.Count){$ELSEIF COOPER}new NonGenericPlatformDictionary(lJsonObject.Count){$ENDIF};
        for each k in lJsonObject.Keys do begin
          Hierarchy.Push(lJsonObject[k]);
          var lValue := DecodeArrayElement(aName, aType);
          if assigned(lValue) then
            result[k] := lValue;
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ENDIF}

    method DecodeStringDictionaryEnd(aName: String); override;
    begin
      Hierarchy.Pop;
    end;

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

    //

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