namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  XmlCoder = public partial class
  public

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
    method DecodeArrayElements<T>(aName: String; aType: &Type): array of T; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new array of T(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement(aName, typeOf(T));
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
    method DecodeListElements<T>(aName: String; aType: &Type): List<T>; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new List<T> withCapacity(lElements.Count);
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement(aName, typeOf(T));
        if assigned(lValue) then
          result.Add(lValue as T);
        Hierarchy.Pop;
      end;
    end;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeListElements(aName: String; aType: &Type): NonGenericPlatformList; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := {$IF TOFFEE}new NonGenericPlatformList withCapacity(lElements.Count){$ELSEIF COOPER}new NonGenericPlatformList(lElements.Count){$ENDIF};
      for i := 0 to lElements.Count-1 do begin
        Hierarchy.Push(lElements[i]);
        var lValue := DecodeArrayElement(aName, aType);
        if assigned(lValue) then
          {$IF TOFFEE}result.addObject(lValue){$ELSEIF COOPER}result.Add(lValue){$ENDIF};
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
    method DecodeStringDictionaryElements<T>(aName: String; aType: &Type): Dictionary<String,T>; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := new Dictionary<String,T> withCapacity(lElements.Count);
      for each e in lElements do begin
        if assigned(e.Attribute["Name"]) then begin
          Hierarchy.Push(e);
          var lValue := DecodeArrayElement(aName, typeOf(T));
          if assigned(lValue) then
            result[e.Attribute["Name"].Value] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
    end;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeStringDictionaryElements(aName: String; aType: &Type): NonGenericPlatformDictionary; override;
    begin
      var lElements := Current.ElementsWithName("Element").ToList;
      result := {$IF TOFFEE}new NonGenericPlatformDictionary withCapacity(lElements.Count){$ELSEIF COOPER}new NonGenericPlatformDictionary(lElements.Count){$ENDIF};
      for each e in lElements do begin
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

    //

    method DecodeString(aName: String): String; override;
    begin
      if assigned(aName) then
        result := Current.FirstElementWithName(aName):Value
      else
        result := Current:Value;
    end;

  end;

end.