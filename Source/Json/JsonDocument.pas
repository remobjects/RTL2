namespace RemObjects.Elements.RTL;

type
  JsonDocument = public class
  private
    fRootNode: not nullable JsonNode;

    method GetRootObjectItem(aKey: String): nullable JsonNode;
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      result := fRootNode[aKey];
    end;

    method SetRootObjectItem(aKey: String; Value: JsonNode);
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      fRootNode[aKey] := Value;
    end;

    method SetRootObjectItem(aKey: String; Value: nullable String);
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      fRootNode[aKey] := Value;
    end;

    method SetRootObjectItem(aKey: String; Value: Boolean);
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      fRootNode[aKey] := Value;
    end;

    method SetRootObjectItem(aKey: String; Value: Int32);
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      fRootNode[aKey] := Value;
    end;

    method SetRootObjectItem(aKey: String; Value: Double);
    begin
      if fRootNode is not JsonObject then
        raise new JsonException("Root object is not an object");
      fRootNode[aKey] := Value;
    end;

    method GetRootArrayItem(aIndex: Integer): nullable JsonNode;
    begin
      if fRootNode is not JsonArray then
        raise new JsonException("Root object is not an array");
      result := fRootNode[aIndex];
    end;

    method GetRootObjectKeys: not nullable sequence of String;
    begin
      result := fRootNode.Keys;
    end;


  protected
  public
    property Root: not nullable JsonNode read fRootNode;

    {$IF NOT WEBASSEMBLY}
    class method FromFile(aFile: not nullable File): not nullable JsonDocument;
    begin
      result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize)
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
      result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
    end;

    class method FromBinary(aBinary: not nullable array of Byte; aEncoding: Encoding := nil): not nullable JsonDocument;
    begin
      if aEncoding = nil then aEncoding := Encoding.Default;
      result := new JsonDocument(new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize);
    end;

    class method FromString(aString: not nullable String): not nullable JsonDocument;
    begin
      result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
    end;

    {$IF NOT WEBASSEMBLY}
    class method TryFromFile(aFile: not nullable File): nullable JsonDocument;
    begin
      try
        result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize);
      except
      end;
    end;

    class method TryFromFile(aFile: not nullable File; out aException: Exception): nullable JsonDocument;
    begin
      try
        result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize);
      except
        on E: JsonException do
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
        result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
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
        result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
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
        result := new JsonDocument(new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize);
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
        result := new JsonDocument(new JsonDeserializer(new String(aBinary, aEncoding)).Deserialize);
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
        result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
      except
      end;
    end;

    class method TryFromString(aString: nullable String; out aException: Exception): nullable JsonDocument;
    begin
      if not assigned(aString) then
        exit;
      try
        result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
      except
        on E: Exception do
          aException := E;
      end;
    end;

    class method CreateDocument: not nullable JsonDocument;
    begin
      result := new JsonDocument();
    end;


    constructor;
    begin
      fRootNode := new JsonObject();
    end;

    constructor(aRoot: not nullable JsonNode);
    begin
      fRootNode := aRoot;
    end;


    {method Save(aFile: File);
    method Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
    method Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);}
    [ToString]
    method ToString: String; override;
    begin
      result := fRootNode.ToJson();
    end;

    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := fRootNode.ToJson(aFormat);
    end;


    property Item[aIndex: Integer]: nullable JsonNode read GetRootArrayItem; default; virtual;
    property Item[aKey: not nullable String]: nullable JsonNode read GetRootObjectItem write SetRootObjectItem; default; virtual;
    property Item[aKey: not nullable String]: nullable String write SetRootObjectItem; default; virtual;
    property Item[aKey: not nullable String]: Boolean write SetRootObjectItem; default; virtual;
    property Item[aKey: not nullable String]: Int32 write SetRootObjectItem; default; virtual;
    property Item[aKey: not nullable String]: Double write SetRootObjectItem; default; virtual;

    [Obsolete("Use Root: JsonNode, instead")] property RootObject: not nullable JsonObject read fRootNode as JsonObject;
    [Obsolete("Use Root: JsonNode, instead")] property Keys: not nullable sequence of String read GetRootObjectKeys; virtual;
  end;

  JsonNode = public abstract class
  private
    method CantGetItem(aKey: String): nullable JsonNode;
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: JsonNode);
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: String);
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Boolean);
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Int32);
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantSetItem(aKey: String; Value: Double);
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method CantGetItem(aIndex: Integer): not nullable JsonNode;
    begin
      raise new JsonNodeTypeException("JSON Node is not an array.")
    end;

    method CantSetItem(aIndex: Integer; Value: not nullable JsonNode);
    begin
      raise new JsonNodeTypeException("JSON Node is not an array.")
    end;

    method CantGetKeys: not nullable sequence of String;
    begin
      raise new JsonNodeTypeException("JSON Node is not a dictionary.")
    end;

    method GetIntegerValue: Int64;
    begin
      if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).Value
      else if self is JsonFloatValue then
        result := Int64((self as JsonFloatValue).Value)
      else
        raise new JsonNodeTypeException("JSON Node is not an integer.")
    end;

    method GetFloatValue: Double;
    begin
      if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).Value
      else if self is JsonFloatValue then
        result := (self as JsonFloatValue).Value
      else
        raise new JsonNodeTypeException("JSON Node is not a float.")
    end;

    method GetBooleanValue: Boolean;
    begin
      if self is JsonBooleanValue then
        result := (self as JsonBooleanValue).Value
      else
        raise new JsonNodeTypeException("JSON Node is not a boolean.")
    end;

    method GetStringValue: String;
    begin
      if self is JsonStringValue then
        result := (self as JsonStringValue).Value
      else if self is JsonIntegerValue then
        result := (self as JsonIntegerValue).ToJson()
      else if self is JsonFloatValue then
        result := (self as JsonFloatValue).ToJson()
      else if self is JsonBooleanValue then
        result := (self as JsonBooleanValue).ToJson()
      else
        raise new JsonNodeTypeException("JSON Node is not a string.")
    end;

    method SetIntegerValue(aValue: Int64);
    begin
      if self is JsonIntegerValue then
        (self as JsonIntegerValue).Value := aValue
      else if self is JsonFloatValue then
        (self as JsonFloatValue).Value := aValue
      else
        raise new JsonNodeTypeException("JSON Node is not an integer.")
    end;

    method SetFloatValue(aValue: Double);
    begin
      if self is JsonFloatValue then
        (self as JsonFloatValue).Value := aValue
      else
        raise new JsonNodeTypeException("JSON Node is not a float.")
    end;

    method SetBooleanValue(aValue: Boolean);
    begin
      if self is JsonBooleanValue then
        (self as JsonBooleanValue).Value := aValue
      else
        raise new JsonNodeTypeException("JSON Node is not a boolean.")
    end;

    method SetStringValue(aValue: String);
    begin
      if self is JsonStringValue then
        (self as JsonStringValue).Value := aValue
      else
        raise new JsonNodeTypeException("JSON Node is not a string.")
    end;

  protected
  public
    [ToString]
    method ToString: String; override;
    begin
      result := ToJson();
    end;

    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String; virtual; abstract;

    property Count: Integer read 1; virtual;
    property Item[aKey: not nullable String]: nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: nullable String write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Boolean write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Int32 write CantSetItem; default; virtual;
    property Item[aKey: not nullable String]: Double write CantSetItem; default; virtual;
    property Item[&Index: Integer]: not nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
    property Keys: not nullable sequence of String read CantGetKeys; virtual;
    property IntegerValue: Int64 read GetIntegerValue write SetIntegerValue; virtual;
    property FloatValue: Double read GetFloatValue write SetFloatValue; virtual;
    property BooleanValue: Boolean read GetBooleanValue write SetBooleanValue; virtual;
    property StringValue: String read GetStringValue write SetStringValue; virtual;

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

  end;

  JsonFormat = public enum (HumanReadable, Minimal);

end.