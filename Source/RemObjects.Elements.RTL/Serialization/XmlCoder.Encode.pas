namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  XmlCoder = public partial class
  public

    method EncodeString(aName: String; aValue: nullable String); override;
    begin
      if assigned(aValue) then
        if assigned(aName) then
          Current.AddElement(aName, aValue)
        else
          Current.AddElement("Element", aValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeNil(aName: String); override;
    begin
      if assigned(aName) then
        Current.AddElement(aName)
      else
        Current.AddElement("Element")
    end;

  protected

    method EncodeObjectStart(aName: String; aValue: IEncodable; aExpectedType: &Type := nil); override;
    begin
      var lNew := new XmlElement withName(typeOf(aValue).ToString);

      if assigned(aName) then
        Current.AddElement(aName).AddElement(lNew)
      else if assigned(Current) then
        Current.AddElement("Element").AddElement(lNew)
      else
        Xml := lNew;
      Hierarchy.Push(lNew);
    end;

    method EncodeObjectEnd(aName: String; aValue: IEncodable); override;
    begin
      if Current ≠ Xml then
        Hierarchy.Pop;
    end;

    method EncodeArrayStart(aName: String); override;
    begin
      EncodeArrayOrListStart(aName, "Array");
    end;

    method EncodeListStart(aName: String); override;
    begin
      EncodeArrayOrListStart(aName, "List");
    end;

    method EncodeStringDictionaryStart(aName: String); override;
    begin
      EncodeArrayOrListStart(aName, "Dictionary")
    end;

    method EncodeArrayOrListStart(aName: String; aKind: String); private;
    begin
      if assigned(aName) then begin
        Hierarchy.Push(Current.AddElement(aName))//.AddElement(lNew)
      end
      else if assigned(Current) then begin
        Hierarchy.Push(Current.AddElement("Element"))//.AddElement(lNew)
      end
      else begin
        Xml := new XmlElement withName(aKind);
        Hierarchy.Push(Xml);
      end;
    end;

    method EncodeArrayEnd(aName: String); override;
    begin
      if Current ≠ Xml then
        Hierarchy.Pop;
    end;

    method EncodeStringDictionaryValue<T>(aKey: String; aValue: T; aExpectedType: &Type := nil); override;
    begin
      if assigned(aValue) or ShouldEncodeNil then begin
        Hierarchy.Push(Current.AddElement("Element"));
        Current.SetAttribute("Name", aKey);
        if assigned(aValue) then
          Encode(nil, aValue, aExpectedType)
        else
          EncodeNil(nil);
        Hierarchy.Pop;
      end;
    end;

    method EncodeStringDictionaryEnd(aName: String); override;
    begin
      if Current ≠ Xml then
        Hierarchy.Pop;
    end;

  end;

end.