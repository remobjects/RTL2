namespace RemObjects.Elements.RTL;

type
  JsonNode = public abstract class // old Document
  public

    [Obsolete("JsonDocument now is the root node")]
    property Root: not nullable JsonNode read self;

    property NodeKind: JsonNodeKind read; abstract;

    //
    // Creation
    //

    {$IF NOT WEBASSEMBLY}
    class method FromFile(aFile: not nullable File): not nullable JsonDocument;
    begin
      result := new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize;
    end;

    class method FromUrl(aUrl: not nullable Url): not nullable JsonDocument;
    begin
      if {not defined("WEBASSEMBLY") and} aUrl.IsFileUrl and aUrl.FilePath.FileExists then begin
        result := FromFile(File(aUrl.FilePath));
      end
      else if (aUrl.Scheme = "http") or (aUrl.Scheme = "https") then begin
        result := Http.GetJson(new HttpRequest(aUrl))
      end
      else begin
        raise new XmlException(String.Format("Cannot load Json from URL '{0}'.", aUrl.ToAbsoluteString()));
      end;
    end;
    {$ENDIF}

    class method FromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil): not nullable JsonDocument;
    begin
      if aEncoding = nil then aEncoding := Encoding.Default;
      result := new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize;
    end;

    class method FromBytes(aBinary: not nullable array of Byte; aEncoding: Encoding := nil): not nullable JsonDocument;
    begin
      if aEncoding = nil then aEncoding := Encoding.Default;
      result := new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize;
    end;

    class method FromString(aString: not nullable String): not nullable JsonDocument;
    begin
      result := new JsonDeserializer(aString).Deserialize;
    end;

    {$IF NOT WEBASSEMBLY}
    class method TryFromFile(aFile: not nullable File): nullable JsonDocument;
    begin
      try
        result := new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize;
      except
      end;
    end;

    class method TryFromFile(aFile: not nullable File; out aException: Exception): nullable JsonDocument;
    begin
      try
        result := new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize;
      except
        on E: Exception do
          aException := E;
      end;
    end;

    class method TryFromUrl(aUrl: not nullable Url): nullable JsonDocument;
    begin
      try
        result := FromUrl(aUrl);
      except
      end;
    end;

    class method TryFromUrl(aUrl: not nullable Url; out aException: Exception): nullable JsonDocument;
    begin
      try
        result := FromUrl(aUrl);
      except
        on E: Exception do
          aException := E;
      end;
    end;
    {$ENDIF}

    class method TryFromBinary(aBinary: nullable ImmutableBinary; aEncoding: Encoding := nil): nullable JsonDocument;
    begin
      if not assigned(aBinary) then
        exit;
      try
        if not assigned(aEncoding) then
          aEncoding := Encoding.Default;
        result := new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize;
      except
      end;
    end;

    class method TryFromBinary(aBinary: nullable ImmutableBinary; aEncoding: Encoding := nil; out aException: Exception): nullable JsonDocument;
    begin
      if not assigned(aBinary) then
        exit;
      try
        if not assigned(aEncoding) then
          aEncoding := Encoding.Default;
        result := new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize;
      except
        on E: Exception do
          aException := E;
      end;
    end;

    class method TryFromBytes(aBinary: nullable array of Byte; aEncoding: Encoding := nil): nullable JsonDocument;
    begin
      if not assigned(aBinary) then
        exit;
      try
        if not assigned(aEncoding) then
          aEncoding := Encoding.Default;
        result := new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize;
      except
      end;
    end;

    class method TryFromBytes(aBinary: nullable array of Byte; aEncoding: Encoding := nil; out aException: Exception): nullable JsonDocument;
    begin
      if not assigned(aBinary) then
        exit;
      try
        if not assigned(aEncoding) then
          aEncoding := Encoding.Default;
        result := new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize;
      except
        on E: Exception do
          aException := E;
      end;
    end;

    class method TryFromString(aString: nullable String): nullable JsonDocument;
    begin
      try
        if length(aString) > 0 then
          result := new JsonDeserializer(aString).Deserialize;
      except
      end;
    end;

    class method TryFromString(aString: nullable String; out aException: Exception): nullable JsonDocument;
    begin
      try
        if length(aString) > 0 then
          result := new JsonDeserializer(aString).Deserialize;
      except
        on E: Exception do
          aException := E;
      end;
    end;

    //
    // Create Empty
    //

    [Obsolete("Use JsonDocument.CreateObject")]
    class method CreateDocument: not nullable JsonObject;
    begin
      result := new JsonObject();
    end;

    class method CreateObject: not nullable JsonObject;
    begin
      result := new JsonObject();
    end;

    class method CreateArray: not nullable JsonArray;
    begin
      result := new JsonArray();
    end;

    //
    // Create with Others
    //

    class method Create(aValue: nullable Dictionary<String,JsonNode>): nullable JsonObject;
    begin
      if assigned(aValue) then
        result := new JsonObject(aValue);
    end;

    class method Create(aValue: nullable List<JsonNode>): nullable JsonArray;
    begin
      if assigned(aValue) then
        result := new JsonArray(aValue);
    end;

    class method Create(aValue: nullable array of JsonNode): nullable JsonArray;
    begin
      if assigned(aValue) then
        result := new JsonArray(aValue);
    end;

    class method Create(aValue: nullable String): nullable JsonStringValue;
    begin
      if assigned(aValue) then
        result := new JsonStringValue(aValue);
    end;

    class method Create(aValue: nullable Double): nullable JsonFloatValue;
    begin
      if assigned(aValue) then
        result := new JsonFloatValue(aValue);
    end;

    class method Create(aValue: nullable Int64): nullable JsonIntegerValue;
    begin
      if assigned(aValue) then
        result := new JsonIntegerValue(aValue);
    end;

    class method Create(aValue: nullable Boolean): nullable JsonBooleanValue;
    begin
      if assigned(aValue) then
        result := new JsonBooleanValue(aValue);
    end;

    //
    // To String & Saving
    //

    [ToString]
    method ToString: String; override;
    begin
      result := ToJsonString(JsonFormat.HumanReadable);
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): not nullable String; abstract;

    method ToJsonBytes(aFormat: JsonFormat := JsonFormat.Minimal; aEncoding: Encoding := Encoding.UTF8; aIncludeBOM: Boolean := false): not nullable array of Byte;
    begin
      result := aEncoding.GetBytes(ToJsonString(aFormat)) includeBOM(aIncludeBOM);
    end;

    method ToJsonBinary(aFormat: JsonFormat := JsonFormat.Minimal; aEncoding: Encoding := Encoding.UTF8; aIncludeBOM: Boolean := false): not nullable ImmutableBinary;
    begin
      result := new ImmutableBinary(aEncoding.GetBytes(ToJsonString(aFormat)) includeBOM(aIncludeBOM));
    end;

    {$IF NOT WEBASSEMBLY}
    method SaveToFile(aFileName: not nullable File);
    begin
      File.WriteText(aFileName, ToString);
    end;

    method SaveToFile(aFileName: not nullable File; aFormat: JsonFormat; aEncoding: Encoding := nil; aIncludeBOM: Boolean := false);
    begin
      File.WriteText(aFileName, ToJsonString(aFormat), coalesce(aEncoding, Encoding.UTF8), aIncludeBOM);
    end;
    {$ENDIF}

    method UniqueCopy: InstanceType; abstract;
    //begin
      //result := FromString(ToString);
    //end;

    //property Item[aIndex: Integer]: nullable JsonNode read GetRootArrayItem; default; virtual;
    //property Item[aKey: not nullable String]: nullable JsonNode read GetRootObjectItem write SetRootObjectItem; default; virtual;
    //property Item[aKey: not nullable String]: nullable String write SetRootObjectItem; default; virtual;
    //property Item[aKey: not nullable String]: Boolean write SetRootObjectItem; default; virtual;
    //property Item[aKey: not nullable String]: Int32 write SetRootObjectItem; default; virtual;
    //property Item[aKey: not nullable String]: Double write SetRootObjectItem; default; virtual;

    //[Obsolete("Use Root: JsonNode, instead")] property RootObject: not nullable JsonObject read fRootNode as JsonObject;
    //[Obsolete("Use Root: JsonNode, instead")] property Keys: not nullable sequence of String read GetRootObjectKeys; virtual;

    property Count: Integer read 1; virtual;
    property Item[aKey: not nullable String]: nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: nullable String write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: nullable array of String write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Boolean write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Int32 write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Double write CantSetItem; default; virtual;
    property Item[&Index: Integer]: not nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
    property Keys: not nullable sequence of String read CantGetKeys; virtual;
    property IntegerValue: Int64 read GetIntegerValue /*write SetIntegerValue*/; virtual;
    property FloatValue: Double read GetFloatValue /*write SetFloatValue*/; virtual;
    property BooleanValue: Boolean read GetBooleanValue /*write SetBooleanValue*/; virtual;
    property StringValue: String read GetStringValue /*write SetStringValue*/; virtual;

    {$IF NOT TOFFEE}[&Sequence]{$ENDIF}
    method GetSequence: sequence of JsonNode; iterator; virtual;
    begin
      raise new JsonNodeTypeException("This JsonNode is not an array.")
    end;

    {$IF TOFFEE}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger; virtual;
    begin
      raise new JsonNodeTypeException("This JsonNode is not an array.")
    end;
    {$ENDIF}

    operator &Equal(lhs: JsonNode; rhs: JsonNode): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      if (lhs is JsonArray) and (rhs is JsonArray) then
        exit (lhs as JsonArray) = (rhs as JsonArray);
      if (lhs is JsonObject) and (rhs is JsonObject) then
        exit (lhs as JsonObject) = (rhs as JsonObject);
      if (lhs is JsonStringValue) and (rhs is JsonStringValue) then
        exit (lhs as JsonStringValue) = (rhs as JsonStringValue);
      if (lhs is JsonIntegerValue) and (rhs is JsonIntegerValue) then
        exit (lhs as JsonIntegerValue) = (rhs as JsonIntegerValue);
      if (lhs is JsonFloatValue) and (rhs is JsonFloatValue) then
        exit (lhs as JsonFloatValue) = (rhs as JsonFloatValue);
      if (lhs is JsonBooleanValue) and (rhs is JsonBooleanValue) then
        exit (lhs as JsonBooleanValue) = (rhs as JsonBooleanValue);
      if (lhs is JsonNullValue) and (rhs is JsonNullValue) then
        exit true;

      if not assigned(lhs) and (rhs is JsonNullValue) then
        exit true;
      if (lhs is JsonNullValue) and not assigned(rhs) then
        exit true;
    end;

    operator &Equal(lhs: JsonNode; rhs: Object): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      if (lhs is JsonNode) and (rhs is JsonNode) then
        exit (lhs as JsonNode) = (rhs as JsonNode);

      {$IF NOT TOFFEE}
      if (lhs is JsonArray) and (rhs is array of String) then
        exit (lhs as JsonArray) = (rhs as array of String);
      {$ENDIF}
      if (lhs is JsonStringValue) and (rhs is String) then
        exit (lhs as JsonStringValue) = (rhs as String);
      if (lhs is JsonIntegerValue) and (rhs is Integer) then
        exit (lhs as JsonIntegerValue) = (rhs as Integer);
      if (lhs is JsonFloatValue) and (rhs is Double) then
        exit (lhs as JsonFloatValue) = (rhs as Double);
      if (lhs is JsonBooleanValue) and (rhs is Boolean) then
        exit (lhs as JsonBooleanValue) = (rhs as Boolean);
      if (lhs is JsonNullValue) and not assigned(rhs) then
        exit true;
    end;

    operator &Equal(lhs: Object; rhs: JsonNode): Boolean;
    begin
      if Object(lhs) = Object(rhs) then
        exit true;
      if not assigned(lhs) or not assigned(rhs) then
        exit false;

      if (lhs is JsonNode) and (rhs is JsonNode) then
        exit (lhs as JsonNode) = (rhs as JsonNode);

      {$IF NOT TOFFEE}
      if (lhs is array of String) and (rhs is JsonArray) then
        exit (lhs as array of String) = (rhs as JsonArray);
      {$ENDIF}
      if (lhs is String) and (rhs is JsonStringValue) then
        exit (lhs as String) = (rhs as JsonStringValue);
      if (lhs is Integer) and (rhs is JsonIntegerValue) then
        exit (lhs as Integer) = (rhs as JsonIntegerValue);
      if (lhs is Double) and (rhs is JsonFloatValue) then
        exit (lhs as Double) = (rhs as JsonFloatValue);
      if (lhs is Boolean) and (rhs is JsonBooleanValue) then
        exit (lhs as Boolean) = (rhs as JsonBooleanValue);
      if not assigned(lhs) and (rhs is JsonNullValue) then
        exit true;
    end;

    operator NotEqual(lhs: JsonNode; rhs: JsonNode): Boolean;
    begin
      result := not (lhs = rhs);
    end;

    operator NotEqual(lhs: JsonNode; rhs: Object): Boolean;
    begin
      result := not (lhs = rhs);
    end;

    operator NotEqual(lhs: Object; rhs: JsonNode): Boolean;
    begin
      result := not (lhs = rhs);
    end;

  private

    method CantGetItem(aKey: String): nullable JsonNode;
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: JsonNode);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: String);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: array of String);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Boolean);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Int32);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Double);
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method CantGetItem(aIndex: Integer): not nullable JsonNode;
    begin
      raise new JsonNodeTypeException("This JsonNode is not an array.")
    end;

    method CantSetItem(aIndex: Integer; Value: not nullable JsonNode);
    begin
      raise new JsonNodeTypeException("This JsonNode is not an array.")
    end;

    method CantGetKeys: not nullable sequence of String;
    begin
      raise new JsonNodeTypeException("This JsonNode is not a dictionary.")
    end;

    method GetIntegerValue: Int64;
    begin
      if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).Value
      else if self is JsonFloatValue then
        result := Int64((self as JsonFloatValue).Value)
      else
        raise new JsonNodeTypeException("This JsonNode is not a number.")
    end;

    method GetFloatValue: Double;
    begin
      if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).Value
      else if self is JsonFloatValue then
        result := (self as JsonFloatValue).Value
      else
        raise new JsonNodeTypeException("This JsonNode is not a number.")
    end;

    method GetBooleanValue: Boolean;
    begin
      if self is JsonBooleanValue then
        result := (self as JsonBooleanValue).Value
      else
        raise new JsonNodeTypeException("This JsonNode is not a boolean.")
    end;

    method GetStringValue: String;
    begin
      if self is JsonStringValue then
        result := (self as JsonStringValue).Value
      else if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).ToString
      else if self is JsonFloatValue then
        result := (self as JsonFloatValue).ToString
      else if self is JsonBooleanValue then
        result := (self as JsonBooleanValue).ToString
      else
        raise new JsonNodeTypeException("This JsonNode is not a string.")
    end;

    //method SetIntegerValue(aValue: Int64);
    //begin
      //if self is JsonIntegerValue then
        //(self as JsonIntegerValue).Value := aValue
      //else if self is JsonFloatValue then
        //(self as JsonFloatValue).Value := aValue
      //else
        //raise new JsonNodeTypeException("This JsonNode is not an integer.")
    //end;

    //method SetFloatValue(aValue: Double);
    //begin
      //if self is JsonFloatValue then
        //(self as JsonFloatValue).Value := aValue
      //else
        //raise new JsonNodeTypeException("This JsonNode is not a float.")
    //end;

    //method SetBooleanValue(aValue: Boolean);
    //begin
      //if self is JsonBooleanValue then
        //(self as JsonBooleanValue).Value := aValue
      //else
        //raise new JsonNodeTypeException("This JsonNode is not a boolean.")
    //end;

    //method SetStringValue(aValue: String);
    //begin
      //if self is JsonStringValue then
        //(self as JsonStringValue).Value := aValue
      //else
        //raise new JsonNodeTypeException("This JsonNode is not a string.")
    //end;

  end;

  JsonFormat = public enum (HumanReadable, Minimal);
  JsonNodeKind = public enum (Object, &Array, String, Integer, Float, Boolean, Null);

  JsonDocument = public JsonNode;

end.