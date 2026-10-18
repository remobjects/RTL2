# JSON queries

`JsonQuery` compiles a bounded, read-only subset of [jq](https://jqlang.org/manual/v1.7/).
It operates on existing RTL2 `JsonNode` trees and has no filesystem, network, shell,
provider, or CodeBot dependency.

```pascal
var lQuery := new JsonQuery('group_by(.practice) | map({practice: .[0].practice, count: length})');
var lResults := lQuery.Evaluate(lDocument);
```

Compile once and evaluate against multiple documents. Each evaluation owns its
limits and intermediate state. Input trees must remain unchanged during evaluation.
The returned `ImmutableList<JsonNode>` represents a stream: `empty` returns zero
items, `null` returns one null item, and `.[]` can return many items. Use `[filter]`
to collect a stream into one JSON array. Selected nodes can share storage with the
input or compiled literals; treat results as read-only or copy before modifying them.

## Supported syntax

- Identity `.`, member paths `.a.b`, quoted members `."a.b"` and `.["a.b"]`.
- Literal integer indexes `.[0]`, including negative indexes from the end.
- Array/object value iteration `.[]`, pipes `|`, result concatenation `,`, parentheses.
- JSON scalar literals, array construction `[filter]`, object projections
  `{name, count: .items | length}`. Parenthesize a comma expression in an object
  value: `{x: (1,2)}`. Multiple-valued fields produce a Cartesian product.
- Comparisons `==`, `!=`, `<`, `<=`, `>`, `>=`; short-circuit `and`, `or`, and `not`.
  Only false and null are falsey.
- `select(filter)`, `map(filter)`, `sort_by(filter)`, `group_by(filter)`.
- `keys`, `length`, `type`, `empty`, `unique`, `sort`, `add`, `min`, `max`, `flatten`.

`group_by` sorts by key and emits groups in key order. `sort_by(.a, .b)` uses both
results as a composite key. Equal keys retain input order. `unique` sorts and
removes duplicate values. `flatten` flattens all nested arrays. Missing object
members and out-of-range indexes return null; incompatible input types raise
`JsonQueryException`. `min`, `max`, and `add` return null for an empty array.
Object key ordering and string comparison use Unicode code points.

This is deliberately a subset, not a general jq runtime. Arithmetic operators,
variables, definitions/modules, assignments, dynamic indexes, slices, recursive
descent, optional access `?`, `//`, regex, interpolation, and function arguments
not listed above are unsupported and rejected. Query text is limited to 65,536
UTF-16 code units and parser nesting to 64 levels.

## Numbers and limits

Integer operations preserve RTL2 `Int64` values, including comparisons against
floating-point values. Integer sum/absolute-value overflow raises an error rather
than silently losing precision. Floating-point arithmetic uses `Double`; non-finite
generated results are rejected. These numeric boundaries can differ from jq builds
that store all numbers as doubles.

`Evaluate(input, options)` accepts `JsonQueryOptions`:

| Option | Default | Meaning |
| --- | ---: | --- |
| `MaxSteps` | 1,000,000 | Evaluation and comparison work units |
| `MaxValues` | 100,000 | Cumulative intermediate/output values, including references |
| `MaxDepth` | 64 | Evaluation/recursive traversal depth; maximum configurable value 256 |
| `MaxStringLength` | 1,048,576 | Selected/generated scalar string length in UTF-16 code units |
| `IsCancelled` | nil | Optional callback checked during evaluation |

Limits must be positive and are copied at evaluation start. Cancellation and limit
violations raise `JsonQueryException` and return no partial result. `Position` is a
zero-based query offset for syntax errors, or -1 when no offset applies.

Limits bound evaluator work and newly constructed values; they do not bound an
already-loaded input tree or the serialized size of a selected subtree. A host
exposing this through a file tool must independently enforce file access, input
size, and serialized output limits. Inputs should be valid, acyclic JSON trees.

## Tests

`Test/JsonQueryTests.pas` is included in the shared EUnit test project. It covers
streams, paths, projections, grouping, ordering, aggregation, Unicode, nulls,
integer precision, errors, resource limits, cancellation, query reuse, and input
preservation. Tests use offline data and RemObjects Elements.
