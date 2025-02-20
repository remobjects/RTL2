namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

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
        with matching lElement := Current.FirstElementWithName(aName) do begin
          Hierarchy.Push(lElement);
          result := lElement:Elements.Any;
        end;
      end
      else begin
        result := true;
      end;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      Hierarchy.Pop;
      if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    method DecodeArrayStart(aName: String): Boolean; override;
    begin
      if assigned(aName) then begin
        with matching lElement := Current.FirstElementWithName(aName) do begin
          Hierarchy.Push(lElement);
          result := true;
        end;
      end
      else begin
        raise new CodingExeption("Nested arrays do not support decoding");
      end;
    end;

    {$IF ECHOES}
    method DecodeArrayElements<T>(aName: String): array of T; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new array of T(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement<T>(aName);
        if assigned(lValue) then
          result[i] := lValue as T;
        Hierarchy.Pop;
      end;
    end;
    {$ENDIF}

    method DecodeArrayEnd(aName: String); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    {$IF ECHOES}
    method DecodeListElements<T>(aName: String): array of T; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new List<T>(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement<T>(aName);
        if assigned(lValue) then
          result[i] := lValue as T;
        Hierarchy.Pop;
      end;
    end;
    {$ELSEIF TOFFEE}
    method DecodeListElements(aName: String; aType: &Type): NSMutableArray; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new NSMutableArray withCapacity(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement(aName, aType);
        if assigned(lValue) then
          result[i] := lValue;
        Hierarchy.Pop;
      end;
    end;
    {$ENDIF}

    //

    method DecodeStringDictionaryStart(aName: String): Boolean; override;
    begin
      if assigned(aName) then begin
        with matching lElement := Current.FirstElementWithName(aName) do begin
          Hierarchy.Push(lElement);
          result := true;
        end;
      end
      else begin
        raise new CodingExeption("Nested dictionaries do not support decoding");
      end;
    end;

    {$IF ECHOES}
    method DecodeStringDictionaryElements<T>(aName: String): Dictionary<String,T>; override;
    begin
      result := new Dictionary<String,T>;
      for each e in Current.Elements do begin
        if assigned(e.Attribute["Name"]) then begin
          Hierarchy.Push(e);
          var lValue := DecodeArrayElement<T>(aName);
          if assigned(lValue) then
            result[e.Attribute["Name"].Value] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ELSEIF TOFFEE}
    method DecodeStringDictionaryElements(aName: String; aType: &Type): NSMutableDictionary; override;
    begin
      result := new NSMutableDictionary;
      for each e in Current.Elements do begin
        if assigned(e.Attribute["Name"]) then begin
          Hierarchy.Push(e);
          var lValue := DecodeArrayElement(aName, aType);
          if assigned(lValue) then
            result[e.Attribute["Name"].Value] := lValue;
          Hierarchy.Pop;
        end;
      end;
   end;
    {$ENDIF}

    method DecodeStringDictionaryEnd(aName: String); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

  end;

end.