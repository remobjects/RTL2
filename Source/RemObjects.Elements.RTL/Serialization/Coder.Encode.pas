namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.RTL.Reflection;

type
  Coder = public partial class
  public

    method BeginWriteObject(aObject: IEncodable);
    begin

    end;

    method EndWriteObject(aObject: IEncodable);
    begin

    end;

    method Encode(aObject: Object; aExpectedType: &Type := nil);
    begin
      Encode(nil, aObject);
    end;

    {$IF ECHOES OR ISLAND}
    method Encode<T>(aValue: T; aExpectedType: &Type := nil);
    begin
      Encode(nil, aValue, typeOf(T));
    end;

    //method Encode<T>(aName: String; aValue: T);
    //begin
      //Encode(aName, aValue);
    //end;
    {$ENDIF}

    method Encode(aName: String; aValue: Object; aExpectedType: &Type := nil);
    begin
      {$IF SERIALIZATION}
      if not assigned(aValue) then begin
        if ShouldEncodeNil then
          EncodeNil(aName);
        exit;
      end;

      //Log($"typeOf(aValue) {typeOf(aValue)}");
      {$HINT `typeOf(aValue)` is nil here, for Cocoa. why?}
      var lType := if defined("COCOA") then aValue.class else typeOf(aValue);
      case lType of
        DateTime: EncodeDateTime(aName, aValue as DateTime);
        String: EncodeString(aName, aValue as String);
        //{$IF TOFFEE}
        //NSNumber: EncodeNumber(aName, aValue as SByte);
        //{$ELSE}
        SByte: EncodeInt8(aName, aValue as SByte);
        Int16: EncodeInt16(aName, aValue as Int16);
        Int32: EncodeInt32(aName, aValue as Int32);
        Int64: EncodeInt64(aName, aValue as Int64);
        Byte: EncodeUInt8(aName, aValue as Byte);
        UInt16: EncodeUInt16(aName, aValue as UInt16);
        UInt32: EncodeUInt32(aName, aValue as UInt32);
        UInt64: EncodeUInt64(aName, aValue as UInt64);
        {$IF NOT (TOFFEE OR COOPER)}
        IntPtr: EncodeIntPtr(aName, aValue as IntPtr);
        UIntPtr: EncodeUIntPtr(aName, aValue as UIntPtr);
        {$ENDIF}
        Boolean: EncodeBoolean(aName, aValue as Boolean);
        Single: EncodeSingle(aName, aValue as Single);
        Double: EncodeDouble(aName, aValue as Double);
        //{$ENDIF}
        Guid: EncodeGuid(aName, aValue as Guid);
        {$IF NOT (TOFFEE OR COOPER)} // On these platforms the types are aliased
        PlatformDateTime: EncodeDateTime(aName, aValue as DateTime);
        PlatformGuid: EncodeGuid(aName, aValue as Guid);
        {$ENDIF}
        else begin
          if aValue is IEncodable then
            EncodeObject(aName, aValue as IEncodable, aExpectedType)
          else if defined("ECHOES") and (aValue is var lGuid: RemObjects.Elements.System.GenericNullable<Guid>) then
            EncodeGuid(aName, lGuid as Guid)
          else if defined("ECHOES") and (aValue is var lDateTime: RemObjects.Elements.System.GenericNullable<DateTime>) then
            EncodeDateTime(aName, lDateTime as DateTime)
          else if defined("TOFFEE") and aValue is PlatformGuid then
            EncodeGuid(aName, aValue as Guid) // sometimes a Guid is __NSConcreteUUID and doesnt hit the "case"
          else if defined("TOFFEE") and aValue is PlatformString then
            EncodeString(aName, aValue as PlatformString) // sometimes a Guid is __NSCFConstantString and doesnt hit the "case"
          else if assigned(aName) then
            raise new CodingExeption($"Type '{lType}' for field or property '{aName}' is not encodable.")
          else
            raise new CodingExeption($"Type '{lType}' is not encodable.");
        end;
      end;
      {$ELSE}
      raise new NotImplementedException($"Serialization is not fully implemented for this platform, yet.");
      {$ENDIF}
    end;

    method EncodeObject(aName: String; aValue: IEncodable; aExpectedType: &Type := nil); virtual;
    begin
      if assigned(aValue) then begin
        EncodeObjectStart(aName, aValue, aExpectedType);
        aValue.Encode(self);
        EncodeObjectEnd(aName, aValue);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    //{$IF TOFFEEV1}
    //method EncodeObject(aName: String; aValue: IEncodable; aExpectedType: PlatformType := nil); inline;
    //begin
      //EncodeObject(aName, aValue, if assigned(aExpectedType) then new &Type withPlatformType(aExpectedType));
    //end;
    //{$ENDIF}

    method EncodeArray<T>(aName: String; aValue: array of T; aExpectedType: &Type := nil);
    begin
      if assigned(aValue) then begin
        EncodeArrayStart(aName);
        for each e in aValue do begin
          if assigned(e) then
            Encode(nil, e, aExpectedType)
          else
            EncodeNil(nil);
        end;
        EncodeArrayEnd(aName);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    method EncodeList<T>(aName: String; aValue: List<T>; aExpectedType: &Type := nil);
    begin
      if assigned(aValue) then begin
        EncodeListStart(aName);
        for each e in aValue do begin
          if assigned(e) then
            Encode(nil, e, aExpectedType)
          else
            EncodeNil(nil);
        end;
        EncodeListEnd(aName);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    //{$IF TOFFEEV1}
    //method EncodeList<T>(aName: String; aValue: List<T>; aExpectedType: &Class := nil); inline;
    //begin
      //EncodeList(aName, aValue, if assigned(aExpectedType) then new &Type withPlatformType(aExpectedType));
    //end;
    //{$ENDIF}

    method EncodeStringDictionary<T>(aName: String; aValue: Dictionary<String, T>; aExpectedType: &Type := nil);
    begin
      if assigned(aValue) then begin
        EncodeStringDictionaryStart(aName);
        for each k in aValue.Keys do begin
          var v := aValue[k];
          EncodeStringDictionaryValue(k, v, aExpectedType);
        end;
        EncodeStringDictionaryEnd(aName);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    //{$IF TOFFEEV1}
    //method EncodeStringDictionary<T>(aName: String; aValue: Dictionary<String, T>; aExpectedType: &Class := nil); inline;
    //begin
      //EncodeStringDictionary(aName, aValue, if assigned(aExpectedType) then new &Type withPlatformType(aExpectedType));
    //end;
    //{$ENDIF}

    method EncodeDateTime(aName: String; aValue: nullable DateTime); virtual;
    begin
      EncodeString(aName, aValue:ToISO8601String)
    end;

    {$IF NOT COOPER}
    method EncodeIntPtr(aName: String; aValue: nullable IntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeUIntPtr(aName: String; aValue: nullable UIntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;
    {$ENDIF}

    method EncodeInt64(aName: String; aValue: nullable Int64); virtual;
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeUInt64(aName: String; aValue: nullable UInt64); virtual;
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeDouble(aName: String; aValue: nullable Double); virtual;
    begin
      if assigned(aValue) then
        EncodeString(aName, Convert.ToStringInvariant(aValue))
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeBoolean(aName: String; aValue: nullable Boolean); virtual;
    begin
      EncodeString(aName, if assigned(aValue) then (if aValue then "True" else "False"));
    end;

    method EncodeGuid(aName: String; aValue: nullable Guid); virtual;
    begin
      if assigned(aValue) then begin
        if (aValue ≠ Guid.Empty) or ShouldEncodeDefault then
          EncodeString(aName, aValue.ToString(GuidFormat.Default));
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;

      if assigned(aValue) and ((aValue ≠ Guid.Empty) or ShouldEncodeDefault) then
      else if ShouldEncodeNil then
        EncodeString(aName, nil);
    end;

    {$IF TOFFEE}
    method EncodeNumber(aName: String; aValue: nullable NSNumber); virtual;
    begin
      EncodeString(aName, aValue:ToString);
    end;
    {$ENDIF}

    method EncodeInt8(aName: String; aValue: nullable SByte); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt16(aName: String; aValue: nullable Int16); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt32(aName: String; aValue: nullable Int32); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeUInt8(aName: String; aValue: nullable Byte); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt16(aName: String; aValue: nullable UInt16); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt32(aName: String; aValue: nullable UInt32); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeSingle(aName: String; aValue: nullable Single); virtual;
    begin
      EncodeDouble(aName, aValue);
    end;

    method EncodeString(aName: String; aValue: nullable String); abstract;
    method EncodeNil(aName: String); abstract;

    method EncodeJsonNode(aName: String; aValue: nullable JsonNode); virtual;
    begin
      EncodeString(aName, aValue:ToJsonString(JsonFormat.Minimal));
    end;

    method EncodeJsonArray(aName: String; aValue: nullable JsonArray); virtual;
    begin
      EncodeJsonNode(aName, aValue);
    end;

    method EncodeJsonObject(aName: String; aValue: nullable JsonObject); virtual;
    begin
      EncodeJsonNode(aName, aValue);
    end;

    property ShouldEncodeNil: Boolean := false;
    property ShouldEncodeDefault: Boolean := false;

  protected

    method EncodeObjectStart(aName: String; aValue: IEncodable; aExpectedType: &&Type := nil); abstract;
    method EncodeObjectEnd(aName: String; aValue: IEncodable); abstract;

    method EncodeArrayStart(aName: String); abstract;
    method EncodeArrayEnd(aName: String); abstract;

    method EncodeListStart(aName: String); virtual;
    begin
      EncodeArrayStart(aName);
    end;

    method EncodeListEnd(aName: String); virtual;
    begin
      EncodeArrayEnd(aName);
    end;

    method EncodeStringDictionaryStart(aName: String); abstract;
    method EncodeStringDictionaryEnd(aName: String); abstract;

    method EncodeStringDictionaryValue(aKey: String; aValue: Object; aExpectedType: &Type := nil); virtual;
    begin
      if assigned(aValue) then
        Encode(aKey, aValue, aExpectedType)
      else if ShouldEncodeNil then
        EncodeNil(nil);
    end;

  end;


end.