namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  {$IF TOFFEEV1 OR COOPER}
  NonGenericPlatformList = assembly {$IF COOPER}java.util.ArrayList{$ELSEIF TOFFEE}Foundation.NSMutableArray{$ENDIF};
  NonGenericPlatformDictionary = Assembly {$IF COOPER}java.util.Hashtable{$ELSEIF TOFFEE}Foundation.NSMutableDictionary{$ENDIF};
  {$ENDIF}

  Coder = public partial class
  public

    method Decode(aType: not nullable &Type): IDecodable;
    begin
      result := aType.Instantiate() as IDecodable;
      result.Decode(self);
    end;

    method Decode(aValue: not nullable IDecodable);
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

    method DecodeArray<T>(aName: String; aType: &Type): array of T;
    begin
      if DecodeArrayStart(aName) then begin
        {$IF ECHOES}
        result := DecodeArrayElements<T>(aName, aType);
        {$ELSEIF TOFFEEV1}
        result := (DecodeArrayElements(aName, aType) as PlatformList<T>):ToArray;
        {$ELSEIF COOPER}
        {$HINT this doesn't work result array is if wrong type.}
        // class [Ljava.lang.Object; cannot be cast to class [LTestApp.Bar;
        //result := ((DecodeArrayElements(aName, aType) as PlatformList<T>) as List<T>).ToArray;
        var lResult := ((DecodeArrayElements(aName, aType) as PlatformList<T>) as List<T>).ToArray;
        if assigned(lResult) then
          result := java.lang.reflect.Array.newInstance(aType, lResult.Count) as array of T;
        for i := 0 to lResult.Count-1 do
          result[i] := lResult[i];
        {$ELSE}
        raise new CodingExeption($"Decoding of collections is not (yet) supported on this platform.");
        {$ENDIF}
        DecodeArrayEnd(aName);
      end;
    end;

    method DecodeList<T>(aName: String; aType: &Type): List<T>;
    begin
      if DecodeArrayStart(aName) then begin
        {$IF ECHOES}
        result := DecodeListElements<T>(aName, aType);
        {$ELSEIF TOFFEEV1 OR COOPER}
        result := DecodeListElements(aName, aType);
        {$ELSE}
        raise new CodingExeption($"Decoding of collections is not (yet) supported on this platform.");
        {$ENDIF}
        DecodeArrayEnd(aName);
      end;
    end;

    method DecodeStringDictionary<T>(aName: String; aType: &Type): Dictionary<String, T>;
    begin
      if DecodeStringDictionaryStart(aName) then begin
        {$IF ECHOES}
        result := DecodeStringDictionaryElements<T>(aName, aType);
        {$ELSEIF TOFFEEV1}
        result := DecodeStringDictionaryElements(aName, aType);
        {$ELSEIF COOPER}
        var lResult := DecodeStringDictionaryElements(aName, aType);
        result := new Dictionary<String, T>();
        for each matching k: String in lResult.Keys do
          result[k] := lResult[k] as T;
        {$ELSE}
        raise new CodingExeption($"Decoding of collections is not (yet) supported on this platform.");
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
            raise new CoderException($"Concrete type '{aConcreteType.FullName}' does not descend from {aType.FullName}.");
          aType := aConcreteType;
        end;

        if not assigned(aType) then
          raise new CoderException($"Unknown type.");

        result := aType.Instantiate() as IDecodable;

        result.Decode(self);
        DecodeObjectEnd(aName);
      end;
    end;

    {$IF TOFFEEV1}
    method DecodeObject(aName: String; aType: PlatformType): IDecodable; inline;
    begin
      result := DecodeObject(aName, new &Type withPlatformType(aType));
    end;
    {$ENDIF}

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

    method DecodeJsonArray(aName: String): JsonArray; virtual;
    begin
      result := DecodeJsonNode(aName) as JsonArray;
    end;

    method DecodeJsonObject(aName: String): JsonObject; virtual;
    begin
      result := DecodeJsonNode(aName) as JsonObject;
    end;

    method DecodeObjectType(aName: String): String; virtual; empty;
    method DecodeObjectStart(aName: String): Boolean; abstract;
    method DecodeObjectEnd(aName: String); abstract;

    method DecodeArrayStart(aName: String): Boolean; abstract;
    method DecodeArrayEnd(aName: String); abstract;
    {$IF ECHOES}
    method DecodeArrayElements<T>(aName: String; aType: &Type): array of T; abstract;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeArrayElements(aName: String; aType: &Type): NonGenericPlatformList; virtual;
    begin
      result := DecodeListElements(aName, aType);
    end;
    {$ENDIF}

    method DecodeStringDictionaryStart(aName: String): Boolean; abstract;
    method DecodeStringDictionaryEnd(aName: String); abstract;
    {$IF ECHOES}
    method DecodeStringDictionaryElements<T>(aName: String; aType: &Type): Dictionary<String,T>; abstract;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeStringDictionaryElements(aName: String; aType: &Type): NonGenericPlatformDictionary; abstract;
    {$ENDIF}

    {$IF ECHOES}
    method DecodeArrayElement<T>(aName: String): Object;
    begin
      {$IF SERIALIZATION}
      result := DecodeArrayElement(aName, typeOf(T))
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;
    {$ENDIF}

    method DecodeArrayElement(aName: String; aType: &Type): Object; virtual;
    begin
      {$IF SERIALIZATION}
      var lType := if defined("COCOA") then aType.TypeClass else aType;
      case lType of
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
        {$IF NOT (TOFFEE OR COOPER)} // On these platforms the types are aliased
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

    {$IF ECHOES}
    method DecodeListElements<T>(aName: String; aType: &Type): List<T>; virtual;
    begin
      result := DecodeArrayElements<T>(aName, aType).ToList;
    end;
    {$ELSEIF TOFFEEV1 OR COOPER}
    method DecodeListElements(aName: String; aType: &Type): NonGenericPlatformList; abstract;
    {$ENDIF}

    method DecodeListEnd(aName: String); virtual;
    begin
      DecodeArrayEnd(aName);
    end;

  private

    method FindType(aName: String): &Type;
    begin
      {$IF TOFFEEV1 OR COOPER}
      if not assigned(fTypesCache) then
        fTypesCache := new;
      result := fTypesCache[aName];
      if not assigned(result) then begin
        result := &Type.GetType(aName);
        fTypesCache[aName] := result;
      end;
      {$ELSEIF NOT TOFFEEV2}
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

    {$IF TOFFEEV1 OR COOPER}
    var fTypesCache: Dictionary<String, &Type>;
    {$ELSEIF NOT TOFFEEV2} // E671 Type "RemObjects.Elements.RTL.ImmutableList<T>" has a different class model than "Type" (Cocoa vs Island)
    var fTypesCache: ImmutableList<&Type>;
    {$ENDIF}

  end;

end.