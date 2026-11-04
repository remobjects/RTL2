namespace RemObjects.Elements.RTL;

type
  /// Selects the serialization order of one object's keys; array order is unaffected.
  JsonKeyOrder = public enum (AsIs, Alpha, Custom);

  /// Per-occurrence context. The callback must not modify the document being serialized.
  JsonObjectSerializationContext = public class
  public

    constructor(aNode: not nullable JsonObject; aPath: not nullable String; aKeys: not nullable ImmutableList<String>);
    begin
      Node := aNode;
      Path := aPath;
      Keys := aKeys;
    end;

    property Node: not nullable JsonObject; readonly;
    /// JSON Pointer; the root path is the empty string.
    property Path: not nullable String; readonly;
    property Keys: not nullable ImmutableList<String>; readonly;
    property Order: JsonKeyOrder := JsonKeyOrder.AsIs;
    /// For Custom, exactly the captured keys, each once, using case-sensitive identity.
    property CustomKeys: nullable ImmutableList<String>;

  end;

  JsonObjectSerializationCallback = public block(aContext: not nullable JsonObjectSerializationContext);

end.
