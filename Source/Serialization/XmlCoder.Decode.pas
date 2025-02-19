namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL;

type
  XmlCoder = public partial class
  public

    method DecodeString(aName: String): String; override;
    begin
      if assigned(aName) then
        result := Current.FirstElementWithName(aName):Value
      else
        result := Current:Value;
    end;

    method DecodeObjectType(aName: String): String; override;
    begin
      result := Current.Elements.First.LocalName;
      Hierarchy.Push(Current.Elements.First);
    end;

    method DecodeObjectStart(aName: String): Boolean; override;
    begin
      if assigned(aName) then begin
        var lElement := Current.FirstElementWithName(aName);
        Hierarchy.Push(lElement);
        result := lElement:Elements.Any;
      end
      else begin
        result := true;
      end;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      if assigned(aName) then begin
        Hierarchy.Pop;
        Hierarchy.Pop;
      end;
    end;

    //

    method DecodeArrayStart(aName: String): Boolean; override;
    begin
      if assigned(aName) then begin
        var lElement := Current.FirstElementWithName(aName);
        Hierarchy.Push(lElement);
        result := true;
      end
      else begin
        raise new CodingExeption("Nested arrays do not support decoding");
      end;
    end;

    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeArrayElements<T>(aName: String): array of T; override;
    begin
      {$IF NOT COOPER} // JE9 Generic type "T" is not available at runtime// JE9 Generic type "T" is not available at runtime
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new array of T(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement<T>(aName);
        if assigned(lValue) then
          result[i] := lValue as T;
        Hierarchy.Pop;
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeArrayEnd(aName: String); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    method DecodeStringDictionaryStart(aName: String): Boolean; override;
    begin
      raise new NotImplementedException($"EncodeStringDictionary is not implemented yet");
    end;

    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeStringDictionaryElements<T>(aName: String): Dictionary<String,T>; override;
    begin
      raise new NotImplementedException($"EncodeStringDictionary is not implemented yet");
    end;
    {$ENDIF}

    method DecodeStringDictionaryEnd(aName: String); override;
    begin
      raise new NotImplementedException($"EncodeStringDictionary is not implemented yet");
    end;

  end;

end.