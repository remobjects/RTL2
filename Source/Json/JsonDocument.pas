namespace RemObjects.Elements.RTL;

type
  JsonNode = public abstract class // old Document
  public
    [Obsolete("JsonDocument now is the root node")]
    property Root: not nullable JsonNode read self;

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

    class method FromBinary(aBinary: not nullable array of Byte; aEncoding: Encoding := nil): not nullable JsonDocument;
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

    class method TryFromBinary(aBinary: nullable array of Byte; aEncoding: Encoding := nil): nullable JsonDocument;
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

    class method TryFromBinary(aBinary: nullable array of Byte; aEncoding: Encoding := nil; out aException: Exception): nullable JsonDocument;
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
      if not assigned(aString) then
        exit;
      try
        result := new JsonDeserializer(aString).Deserialize;
      except
      end;
    end;

    class method TryFromString(aString: nullable String; out aException: Exception): nullable JsonDocument;
    begin
      if not assigned(aString) then
        exit;
      try
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
      result := ToString(JsonFormat.HumanReadable);
    end;

    method ToString(aFormat: JsonFormat): String; virtual; abstract;

    [Obsolete("Use ToString")]
    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := ToString(aFormat);
    end;

    {$IF NOT WEBASSEMBLY}
    method SaveToFile(aFileName: not nullable File);
    begin
      File.WriteText(aFileName, ToString);
    end;

    method SaveToFile(aFileName: not nullable File; aFormat: JsonFormat; aEncoding: Encoding := nil; aIncludeBOM: Boolean := false);
    begin
      File.WriteText(aFileName, ToString(aFormat), coalesce(aEncoding, Encoding.UTF8), aIncludeBOM);
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
    property Item[aKey: not nullable String]: Boolean write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Int32 write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Double write CantSetItem; default; virtual;
    property Item[&Index: Integer]: not nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
    property Keys: not nullable sequence of String read CantGetKeys; virtual;
    property IntegerValue: Int64 read GetIntegerValue /*write SetIntegerValue*/; virtual;
    property FloatValue: Double read GetFloatValue /*write SetFloatValue*/; virtual;
    property BooleanValue: Boolean read GetBooleanValue /*write SetBooleanValue*/; virtual;
    property StringValue: String read GetStringValue /*write SetStringValue*/; virtual;

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

  JsonDocument = public JsonNode;

end.