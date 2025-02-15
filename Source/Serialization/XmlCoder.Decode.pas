namespace RemObjects.Elements.Serialization;

{$IF SERIALIZATION}

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

    {$IF NOT ISLAND}
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

  end;

{$ENDIF}

end.