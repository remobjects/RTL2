# JSON serialization key ordering

`JsonNode` provides callback-first overloads of `ToJsonString`, `ToJsonBytes`,
`ToJsonBinary`, and `SaveToFile`. Existing overloads and `JsonFormat` values are
unchanged. The callback belongs to one serialization call; it is not stored on
the document.

```pascal
var lText := lJson.ToJsonString(context -> begin
  if context.Path = '' then begin
    context.Order := JsonKeyOrder.Custom;
    context.CustomKeys := new List<String>('Settings', 'Items');
  end
  else begin
    context.Order := JsonKeyOrder.Alpha;
  end;
end, JsonFormat.HumanReadable);
```

This example expects exactly `Settings` and `Items` at the root. A general
schema-aware callback must construct its custom order from all keys actually
present, including any extension properties.

## Context and ordering

The serializer invokes `JsonObjectSerializationCallback` once per object
occurrence, before writing its properties, including for empty objects. The
`JsonObjectSerializationContext` exposes:

| Member | Meaning |
| --- | --- |
| `Node` | The current `JsonObject` (read-only reference). |
| `Path` | Its JSON Pointer path; `""` identifies the root. |
| `Keys` | An immutable snapshot of its existing keys. |
| `Order` | Writable `JsonKeyOrder`, initially `AsIs`. |
| `CustomKeys` | Writable nullable `ImmutableList<String>`, initially `nil`. |

`AsIs` uses the captured dictionary enumeration order. It does not promise
insertion order. `Alpha` compares invariant-lowercased keys ordinally and breaks
ties by comparing the original keys ordinally. Key spelling is preserved.
`Custom` requires `CustomKeys` to contain exactly the captured keys, each once,
using case-sensitive identity. An empty object requires an empty list. Missing,
additional, duplicate, and null keys raise `JsonSerializationException` with the
object path and failure reason. `CustomKeys` is ignored for the other modes.

Paths include array indices. Property-name `~` and `/` characters are escaped
as `~0` and `~1`; an object in the first element of property `a/b` has path
`/a~1b/0`. Empty property names remain empty path segments. A shared object used
at multiple locations receives a separate callback for each occurrence.

Callbacks must not modify the document during serialization. Serialization
neither changes the stored dictionary nor reorders arrays. Scalar roots do not
invoke the callback. Callback exceptions propagate unchanged.

## Entry points

| Overload | Defaults |
| --- | --- |
| `ToJsonString(callback, format)` | `HumanReadable` |
| `ToJsonBytes(callback, format, encoding, includeBOM)` | `Minimal`, UTF-8, no BOM |
| `ToJsonBinary(callback, format, encoding, includeBOM)` | `Minimal`, UTF-8, no BOM |
| `SaveToFile(fileName, callback, format, encoding, includeBOM)` | `HumanReadable`, UTF-8, no BOM |

File saving is available under the same platform guards as the existing file
APIs. It finishes serialization and key-order validation before opening the
destination, so callback or ordering failures leave existing contents untouched.
This guarantee does not cover subsequent filesystem write failures.

`HumanReadable` renders empty objects and arrays inline as `{}` and `[]`.
Nonempty-container formatting and `Minimal` formatting remain unchanged.
