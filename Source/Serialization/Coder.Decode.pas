namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  Coder = public partial class
  public

    method Decode(aType: &Type): IDecodable;
    begin
      result := aType.Instantiate() as IDecodable;
      result.Decode(self);
    end;

    method Decode(aValue: IDecodable);
    begin
      aValue.Decode(self);
    end;

    {$IF ECHOES OR ISLAND}
    method Decode<T>: T; where T has constructor, T is IDecodable;
    begin
      result := new T;
      result.Decode(self);
    end;
    {$ENDIF}

    method DecodeArray<T>(aName: String): array of T;
    begin
      if DecodeArrayStart(aName) then begin
        {$IF NOT ISLAND}
        result := DecodeArrayElements<T>(aName);
        {$ELSE}
        raise new CodingExeption($"Decoding of arrays and lists is not (yet) supported on Island.");
        {$ENDIF}
        DecodeArrayEnd(aName);
      end;
    end;

    method DecodeList<T>(aName: String): List<T>;
    begin
      if DecodeArrayStart(aName) then begin
        {$IF NOT ISLAND}
        result := DecodeListElements<T>(aName);
        {$ELSE}
        raise new CodingExeption($"Decoding of arrays and lists is not (yet) supported on Island.");
        {$ENDIF}
        DecodeArrayEnd(aName);
      end;
    end;

    method DecodeStringDictionary<T>(aName: String): Dictionary<String, T>;
    begin
      if DecodeStringDictionaryStart(aName) then begin
        {$IF NOT ISLAND}
        result := DecodeStringDictionaryElements<T>(aName);
        {$ELSE}
        raise new CodingExeption($"Decoding of arrays and lists is not (yet) supported on Island.");
        {$ENDIF}
        DecodeStringDictionaryEnd(aName);
      end;
    end;

    method DecodeObject(aName: String; aType: &Type): IDecodable;
    begin
      if DecodeObjectStart(aName) then begin
        var lTypeName := DecodeObjectType(aName);

        if assigned(lTypeName) then begin
          var aConcreteType := FindType(lTypeName);
          if not assigned(aConcreteType) then
            raise new CoderException($"Unknown type '{lTypeName}'.");
          if assigned(aType) and (aConcreteType ≠ aType) and not aConcreteType.IsSubclassOf(aType) then
            raise new CoderException($"Concrete type '{aConcreteType.Name}' does not descend from {aType.Name}.");
          aType := aConcreteType;
        end;

        if not assigned(aType) then
          raise new CoderException($"Unknown type.");

        result := aType.Instantiate() as IDecodable;
        result.Decode(self);
        DecodeObjectEnd(aName);
      end;
    end;


    //method BeginReadObject(aObject: IDecodable);
    //begin

    //end;

    //method EndReadObject(aObject: IDecodable);
    //begin

    //end;

    method DecodeDateTime(aName: String): DateTime; virtual;
    begin
      result := DateTime.TryParseISO8601(DecodeString(aName));
    end;

    {$IF NOT COOPER}
    method DecodeIntPtr(aName: String): nullable IntPtr; virtual;
    begin
      result := Convert.TryToIntPtr(DecodeString(aName));
    end;

    method DecodeUIntPtr(aName: String): nullable UIntPtr; virtual;
    begin
      result := Convert.TryToUIntPtr(DecodeString(aName));
    end;
    {$ENDIF}

    method DecodeInt64(aName: String): nullable Int64; virtual;
    begin
      result := Convert.TryToInt64(DecodeString(aName));
    end;

    method DecodeUInt64(aName: String): nullable UInt64; virtual;
    begin
      result := Convert.TryToUInt64(DecodeString(aName));
    end;

    method DecodeDouble(aName: String): nullable Double; virtual;
    begin
      result := Convert.TryToDoubleInvariant(DecodeString(aName));
    end;

    method DecodeBoolean(aName: String): nullable Boolean; virtual;
    begin
      result := DecodeString(aName):ToLowerInvariant = "true";
    end;

    method DecodeGuid(aName: String): nullable Guid; virtual;
    begin
      result := Guid.TryParse(DecodeString(aName));
    end;

    method DecodeInt8(aName: String): nullable SByte; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeInt16(aName: String): nullable Int16; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeInt32(aName: String): nullable Int32; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeUInt8(aName: String): nullable Byte; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeUInt16(aName: String): nullable UInt16; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeUInt32(aName: String): nullable UInt32; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeSingle(aName: String): nullable Single; virtual;
    begin
      result := DecodeDouble(aName);
    end;

    method DecodeString(aName: String): String; abstract;

    method DecodeJsonNode(aName: String): JsonNode; virtual;
    begin
      var lValue := DecodeString(aName);
      if length(lValue) > 0 then
        result := JsonDocument.FromString(lValue);
    end;

    method DecodeObjectType(aName: String): String; virtual; empty;
    method DecodeObjectStart(aName: String): Boolean; abstract;
    method DecodeObjectEnd(aName: String); abstract;

    method DecodeArrayStart(aName: String): Boolean; abstract;
    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeArrayElements<T>(aName: String): array of T; abstract;
    {$ENDIF}
    method DecodeArrayEnd(aName: String); abstract;

    method DecodeStringDictionaryStart(aName: String): Boolean; abstract;
    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeStringDictionaryElements<T>(aName: String): Dictionary<String,T>; abstract;
    {$ENDIF}
    method DecodeStringDictionaryEnd(aName: String); abstract;

    {$IF NOT ISLAND} // E703 Virtual generic methods not supported on Island
    method DecodeArrayElement<T>(aName: String): Object;
    begin
      {$IF SERIALIZATION}
      result := DecodeArrayElement(aName, typeOf(T))
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeArrayElement(aName: String; aType: &Type): Object; {$IF NOT ISLAND}virtual;{$ENDIF}
    begin
      {$IF SERIALIZATION}
      case aType of
        DateTime: result := DecodeDateTime(nil);
        String: result := DecodeString(nil);
        SByte: result := DecodeInt8(nil);
        Int16: result := DecodeInt16(nil);
        Int32: result := DecodeInt32(nil);
        Int64: result := DecodeInt64(nil);
        {$IF NOT COOPER}
        IntPtr: result := DecodeInt64(nil) as IntPtr;
        {$ENDIF}
        Byte: result := DecodeUInt8(nil);
        UInt16: result := DecodeUInt16(nil);
        UInt32: result := DecodeUInt32(nil);
        UInt64: result := DecodeUInt64(nil);
        {$IF NOT COOPER}
        UIntPtr: result := DecodeUInt64(nil) as UIntPtr;
        {$ENDIF}
        Boolean: result := DecodeBoolean(nil);
        Single: result := DecodeSingle(nil);
        Double: result := DecodeDouble(nil);
        Guid: result := DecodeGuid(nil);
        {$IF NOT COOPER} // On these platforms the types are aliased
        PlatformDateTime: result := DecodeDateTime(nil);
        PlatformGuid: result := DecodeGuid(nil);
        {$ENDIF}
        else result := DecodeObject(nil, aType);
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;

    method DecodeListStart(aName: String): Boolean; virtual;
    begin
      result := DecodeArrayStart(aName);
    end;

    {$IF NOT ISLAND}
    method DecodeListElements<T>(aName: String): List<T>; virtual;
    begin
      {$IF SERIALIZATION}
      result := DecodeArrayElements<T>(aName).ToList;
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeListEnd(aName: String); virtual;
    begin
      DecodeArrayEnd(aName);
    end;

  private

    method FindType(aName: String): &Type;
    begin
      {$IF NOT (COOPER OR TOFFEEV2)}
      if not assigned(fTypesCache) then
        fTypesCache := &Type.AllTypes;
      result := fTypesCache.FirstOrDefault(t -> t.FullName = aName);
      if not assigned(result) then begin
        fTypesCache := &Type.AllTypes; // load again, maye we have new types now
        result := fTypesCache.FirstOrDefault(t -> t.FullName = aName);
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;

    {$IF NOT (COOPER OR TOFFEEV2)} // E671 Type "RemObjects.Elements.RTL.ImmutableList<T>" has a different class model than "Type" (Cocoa vs Island)
    var fTypesCache: ImmutableList<&Type>;
    {$ENDIF}

  end;

end.