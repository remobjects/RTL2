namespace RemObjects.Elements.RTL;

interface

type
  JsonDocument = public class
  private
    fRootNode: not nullable JsonNode;

    method GetRootObjectItem(Key: String): nullable JsonNode;
    method SetRootObjectItem(Key: String; Value: JsonNode);
    method GetRootObjectKeys: not nullable sequence of String;

  protected
  public
    property Root: not nullable JsonNode read fRootNode;

    {$IF NOT WEBASSEMBLY}
    class method FromFile(aFile: not nullable File): not nullable JsonDocument;
    class method FromUrl(aUrl: not nullable Url): not nullable JsonDocument;
    {$ENDIF}
    class method FromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil): not nullable JsonDocument;
    class method FromString(aString: not nullable String): not nullable JsonDocument;
    {$IF NOT WEBASSEMBLY}
    class method TryFromFile(aFile: not nullable File): nullable JsonDocument;
    class method TryFromFile(aFile: not nullable File; out aException: Exception): nullable JsonDocument;
    {$ENDIF}
    class method TryFromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil): nullable JsonDocument;
    class method TryFromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil; out aException: Exception): nullable JsonDocument;
    class method TryFromString(aString: not nullable String): nullable JsonDocument;
    class method TryFromString(aString: not nullable String; out aException: Exception): nullable JsonDocument;
    class method CreateDocument: not nullable JsonDocument;

    constructor;
    constructor(aRoot: not nullable JsonNode);

    {method Save(aFile: File);
    method Save(aFile: File; XmlDeclaration: XmlDocumentDeclaration);
    method Save(aFile: File; Version: String; Encoding: String; Standalone: Boolean);}
    [ToString]
    method ToString: String; override;
    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;

    [Obsolete("Use Root: JsonNode, instead")] property RootObject: not nullable JsonObject read fRootNode as JsonObject;
    [Obsolete("Use Root: JsonNode, instead")] property Item[Key: String]: nullable JsonNode read GetRootObjectItem write SetRootObjectItem; default; virtual;
    [Obsolete("Use Root: JsonNode, instead")] property Keys: not nullable sequence of String read GetRootObjectKeys; virtual;
  end;

  JsonNode = public abstract class
  private
    method CantGetItem(Key: String): nullable JsonNode;
    method CantSetItem(Key: String; Value: JsonNode);
    method CantSetItem(Key: String; Value: String);
    method CantSetItem(Key: String; Value: Boolean);
    method CantSetItem(Key: String; Value: Int32);
    method CantSetItem(Key: String; Value: Double);
    method CantGetItem(aIndex: Integer): not nullable JsonNode;
    method CantSetItem(aIndex: Integer; Value: not nullable JsonNode);
    method CantGetKeys: not nullable sequence of String;
    method GetIntegerValue: Int64;
    method GetFloatValue: Double;
    method GetBooleanValue: Boolean;
    method GetStringValue: String;
    method SetIntegerValue(aValue: Int64);
    method SetFloatValue(aValue: Double);
    method SetBooleanValue(aValue: Boolean);
    method SetStringValue(aValue: String);
  protected
  public
    [ToString]
    method ToString: String; override;
    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String; virtual; abstract;

    property Count: Integer read 1; virtual;
    property Item[Key: not nullable String]: nullable JsonNode read CantGetItem write CantSetItem; default; virtual;
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
    class method Create(aValue: nullable List<JsonNode>): nullable JsonArray;
    class method Create(aValue: nullable array of JsonNode): nullable JsonArray;
    class method Create(aValue: nullable String): nullable JsonStringValue;
    class method Create(aValue: nullable Double): nullable JsonFloatValue;
    class method Create(aValue: nullable Int64): nullable JsonIntegerValue;
    class method Create(aValue: nullable Boolean): nullable JsonBooleanValue;
  end;

  JsonFormat = public enum (HumanReadable, Minimal);

implementation

{ JsonDocument }

constructor JsonDocument;
begin
  fRootNode := new JsonObject();
end;

constructor JsonDocument(aRoot: not nullable JsonNode);
begin
  fRootNode := aRoot;
end;

{$IF NOT WEBASSEMBLY}
class method JsonDocument.FromFile(aFile: not nullable File): not nullable JsonDocument;
begin
  result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize)
end;

class method JsonDocument.FromUrl(aUrl: not nullable Url): not nullable JsonDocument;
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

class method JsonDocument.FromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil): not nullable JsonDocument;
begin
  if aEncoding = nil then aEncoding := Encoding.Default;
  result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
end;

class method JsonDocument.FromString(aString: not nullable String): not nullable JsonDocument;
begin
  result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
end;

{$IF NOT WEBASSEMBLY}
class method JsonDocument.TryFromFile(aFile: not nullable File): nullable JsonDocument;
begin
  try
    result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize);
  except
  end;
end;

class method JsonDocument.TryFromFile(aFile: not nullable File; out aException: Exception): nullable JsonDocument;
begin
  try
    result := new JsonDocument(new JsonDeserializer(aFile.ReadText(Encoding.Default)).Deserialize);
  except
    on E: JsonException do
      aException := E;
  end;
end;
{$ENDIF}

class method JsonDocument.TryFromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil): nullable JsonDocument;
begin
  try
    if aEncoding = nil then aEncoding := Encoding.Default;
    result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
  except
  end;
end;

class method JsonDocument.TryFromBinary(aBinary: not nullable ImmutableBinary; aEncoding: Encoding := nil; out aException: Exception): nullable JsonDocument;
begin
  try
    if aEncoding = nil then aEncoding := Encoding.Default;
    result := new JsonDocument(new JsonDeserializer(new String(aBinary.ToArray, aEncoding)).Deserialize);
  except
    on E: Exception do
      aException := E;
  end;
end;

class method JsonDocument.TryFromString(aString: not nullable String): nullable JsonDocument;
begin
  try
    result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
  except
  end;
end;

class method JsonDocument.TryFromString(aString: not nullable String; out aException: Exception): nullable JsonDocument;
begin
  try
    result := new JsonDocument(new JsonDeserializer(aString).Deserialize)
  except
    on E: Exception do
      aException := E;
  end;
end;

class method JsonDocument.CreateDocument: not nullable JsonDocument;
begin
  result := new JsonDocument();
end;

method JsonDocument.ToString: String;
begin
  result := fRootNode.ToJson();
end;

method JsonDocument.ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
begin
  result := fRootNode.ToJson(aFormat);
end;

method JsonDocument.GetRootObjectItem(Key: String): nullable JsonNode;
begin
  result := fRootNode[Key];
end;

method JsonDocument.SetRootObjectItem(Key: String; Value: JsonNode);
begin
  fRootNode[Key] := Value;
end;

method JsonDocument.GetRootObjectKeys: not nullable sequence of String;
begin
  result := fRootNode.Keys;
end;

{ JsonNode }

method JsonNode.ToString: String;
begin
  result := ToJson();
end;

method JsonNode.CantGetItem(Key: String): nullable JsonNode;
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantSetItem(Key: String; Value: JsonNode);
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantSetItem(Key: String; Value: String);
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantSetItem(Key: String; Value: Boolean);
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantSetItem(Key: String; Value: Int32);
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantSetItem(Key: String; Value: Double);
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantGetKeys: not nullable sequence of String;
begin
  raise new JsonNodeTypeException("JSON Node is not a dictionary.")
end;

method JsonNode.CantGetItem(aIndex: Integer): not nullable JsonNode;
begin
  raise new JsonNodeTypeException("JSON Node is not an array.")
end;

method JsonNode.CantSetItem(aIndex: Integer; Value: not nullable JsonNode);
begin
  raise new JsonNodeTypeException("JSON Node is not an array.")
end;

method JsonNode.GetIntegerValue: Int64;
begin
  if self is JsonIntegerValue then
    result := (self as JsonIntegerValue).Value
  else if self is JsonFloatValue then
    result := Int64((self as JsonFloatValue).Value)
  else
    raise new JsonNodeTypeException("JSON Node is not an integer.")
end;

method JsonNode.GetFloatValue: Double;
begin
  if self is JsonIntegerValue then
    result := (self as JsonIntegerValue).Value
  else if self is JsonFloatValue then
    result := (self as JsonFloatValue).Value
  else
    raise new JsonNodeTypeException("JSON Node is not a float.")
end;

method JsonNode.GetBooleanValue: Boolean;
begin
  if self is JsonBooleanValue then
    result := (self as JsonBooleanValue).Value
  else
    raise new JsonNodeTypeException("JSON Node is not a boolean.")
end;

method JsonNode.GetStringValue: String;
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

method JsonNode.SetIntegerValue(aValue: Int64);
begin
  if self is JsonIntegerValue then
    (self as JsonIntegerValue).Value := aValue
  else if self is JsonFloatValue then
    (self as JsonFloatValue).Value := aValue
  else
    raise new JsonNodeTypeException("JSON Node is not an integer.")
end;

method JsonNode.SetFloatValue(aValue: Double);
begin
  if self is JsonFloatValue then
    (self as JsonFloatValue).Value := aValue
  else
    raise new JsonNodeTypeException("JSON Node is not a float.")
end;

method JsonNode.SetBooleanValue(aValue: Boolean);
begin
  if self is JsonBooleanValue then
    (self as JsonBooleanValue).Value := aValue
  else
    raise new JsonNodeTypeException("JSON Node is not a boolean.")
end;

method JsonNode.SetStringValue(aValue: String);
begin
  if self is JsonStringValue then
    (self as JsonStringValue).Value := aValue
  else
    raise new JsonNodeTypeException("JSON Node is not a string.")
end;

class method JsonNode.Create(aValue: nullable Dictionary<String,JsonNode>): nullable JsonObject;
begin
  if assigned(aValue) then
    result := new JsonObject(aValue);
end;

class method JsonNode.Create(aValue: nullable List<JsonNode>): nullable JsonArray;
begin
  if assigned(aValue) then
    result := new JsonArray(aValue);
end;

class method JsonNode.Create(aValue: nullable array of JsonNode): nullable JsonArray;
begin
  if assigned(aValue) then
    result := new JsonArray(aValue);
end;

class method JsonNode.Create(aValue: nullable String): nullable JsonStringValue;
begin
  if assigned(aValue) then
    result := new JsonStringValue(aValue);
end;

class method JsonNode.Create(aValue: nullable Double): nullable JsonFloatValue;
begin
  if assigned(aValue) then
    result := new JsonFloatValue(aValue);
end;

class method JsonNode.Create(aValue: nullable Int64): nullable JsonIntegerValue;
begin
  if assigned(aValue) then
    result := new JsonIntegerValue(aValue);
end;

class method JsonNode.Create(aValue: nullable Boolean): nullable JsonBooleanValue;
begin
  if assigned(aValue) then
    result := new JsonBooleanValue(aValue);
end;

end.