# Proto ↔ Firestore value encoding

**`firestore_proto_codec` — specification v0.1, draft.**

Defines how a protobuf message is encoded as a Firestore value and decoded back,
such that independent implementations in different languages produce identical
results.

## Scope

The codec is a pure function in each direction:

```
encode(Message)                  → Map<String, FirestoreValue>
decode(Map<String, FirestoreValue>, MessageType) → Message
```

A message encodes to a **map of Firestore-native values** — the thing you hand to
`set()`. The caller decides what to do with it:

```dart
// as an entire document
await doc.set(codec.encode(task));

// as one field of a document
await doc.set({'task': codec.encode(task), 'updated_at': serverTimestamp});
```

Nested messages encode by the same rule, so the field case and the document case
are the same operation at different depths.

### Non-goals

Deliberately outside this spec, because they are properties of an application's
schema rather than of the encoding:

- Collection paths, document ids, subcollections
- Security rules and index definitions
- Partial writes, merge semantics, field masks
- Migration between shapes

A codec that knows about collections is a persistence framework. This is not one.

## 1. Field naming

**A Firestore field name is the proto field name, verbatim** — `snake_case`, as
declared in the `.proto`.

This rejects proto3 JSON's `lowerCamelCase` default deliberately. Java's
`JsonFormat`, Dart's `toProto3Json`, and the JS runtimes each default differently
and each needs a different opt-out to agree; `snake_case` is the one spelling all
three produce *without configuration*, because it is the spelling in the schema.

Field numbers never appear in encoded output. **Renumbering is safe; renaming is
a breaking change to stored data.**

## 2. Scalar types

| Proto | Firestore | Notes |
|---|---|---|
| `string` | String | |
| `bool` | Boolean | |
| `bytes` | Blob | never base64 — Firestore has a native type |
| `int32`, `sint32`, `sfixed32` | Integer | |
| `uint32`, `fixed32` | Integer | widens safely |
| `int64`, `sint64`, `sfixed64` | Integer | Firestore integers are int64 — exact |
| `uint64`, `fixed64` | String | decimal, unsigned — [§2.1](#21-unsigned-64-bit) |
| `double`, `float` | Double | NaN and ±Inf supported natively; see [§8](#8-language-notes) for a JavaScript caveat |
| enum | String | [§4](#4-enums) |

> **This table is most of the argument against `toProto3Json()`.** Proto3 JSON
> renders *all* 64-bit integers as strings, which sort lexicographically and break
> range queries and `orderBy`. This spec diverges for the **signed** types, which
> fit Firestore's own int64 exactly and stay fully queryable; it agrees for the
> **unsigned** ones, which do not fit ([§2.1](#21-unsigned-64-bit)). Proto3 JSON
> also base64s `bytes` and stringifies NaN, neither of which this spec does. Every
> one of those failures is silent: the write succeeds, the query is quietly wrong.

**Decoding accepts either numeric type.** A `double` or `float` field must
decode from a Firestore **Integer** as well as a Double. This is not a
convenience: the JavaScript SDK stores an integral double as an integer
([§8](#8-language-notes)), so a document written by one language has to stay
readable by another. Coerce numerically rather than type-checking the incoming
value. The reverse does not arise -- an integer field is only ever written as an
Integer.

**A `float` encodes as its binary32 value.** Firestore has only doubles, so a
`float` field is widened, and the widened value must be the one the wire format
would carry: `0.1` is stored as `0.10000000149011612`. Java does this by
construction. Dart and protobuf-es hold a `float` in a double without rounding,
so an implementation that passes the value through writes `0.1` from a message
built in memory and `0.10000000149011612` from the same message after a wire
trip, and equality queries then disagree by writer. Round to binary32 on encode
and on decode. The `float_rounding` vector pins it.

### 2.1 Unsigned 64-bit

`uint64` and `fixed64` range up to 2^64−1; Firestore's integer is a **signed**
int64. Values above 2^63−1 therefore have no integer representation, and are
encoded as a **decimal string**, matching proto3 JSON.

Canonical form is decimal digits only — no sign, no leading zeros, no separators.
Zero encodes as `"0"`, though a zero-valued field is omitted entirely under
[§6](#6-presence-and-defaults) unless `omit_when_default: false`.

**The encoding is unconditional.** A `uint64` is always a string, even when its
value would fit in an integer. Choosing the type per value would be a serious
bug: Firestore orders by **type before value**, and numbers sort before strings,
so a field with mixed encodings splits into two disjoint sort blocks, any index
on it becomes meaningless, and a rules `is int` check passes for some documents
and fails for others.

What the string costs, precisely:

| Operation | Works? |
|---|---|
| `==`, `in`, `not-in` | **yes** — exact string match |
| `orderBy` | no — lexicographic, so `"9"` sorts after `"10"` |
| `<`, `<=`, `>`, `>=` | no — same reason |
| `sum`, `average` aggregations | no — not a number |

Equality surviving is what makes this an acceptable trade: `uint64` usually
carries ids, hashes, bitfields, and opaque handles, which are looked up by exact
value and never ordered. A field that genuinely needs ordering should be `int64`.

**Escape hatch.** `kind: KIND_UNSIGNED_AS_INTEGER` encodes an unsigned field as a
Firestore Integer, keeping it ordered and queryable, and **throws at encode time**
on any value above 2^63−1. Use it only where the domain genuinely bounds the
value — the throw is a data-loss guard, not a formality.

## 3. Well-known and common types

Firestore's own value model is itself a protobuf. `google.firestore.v1.Value`
declares, among others:

```protobuf
int64                     integer_value   = 2;
double                    double_value    = 3;
bytes                     bytes_value     = 18;
google.protobuf.Timestamp timestamp_value = 10;
google.type.LatLng        geo_point_value = 8;
```

Several rules in this spec are therefore not conventions at all — they are the
**identity mapping** onto types Firestore already uses on the wire. That covers
`bytes` → Blob in [§2](#2-scalar-types), `Timestamp` below, and `LatLng` in
[§3.3](#33-googletypelatlng--firestore-geopoint). It also settles
[§2.1](#21-unsigned-64-bit): `integer_value` is an `int64`, so there is genuinely
no representation for an unsigned value above 2^63−1.

### 3.1 `google.protobuf.Timestamp` → Firestore `Timestamp`

Native, so it orders and range-queries correctly.

> ⚠️ **Lossy.** Firestore truncates stored timestamps to **microsecond**
> precision; protobuf `Timestamp` carries nanoseconds. The low three digits of
> `nanos` do not survive a round trip through the database.

The codec itself is exact — truncation happens in Firestore, not here — but
conformance vectors must be microsecond-aligned or they fail for the wrong
reason. A field genuinely needing nanoseconds should be an `int64` of epoch-nanos.

### 3.2 `google.protobuf.Duration` → Integer (microseconds)

No Firestore equivalent. Encoded as an `int64` count of microseconds.
Microseconds to match Firestore's own timestamp resolution, and to stay inside
int64 for any plausible duration.

### 3.3 `google.type.LatLng` → Firestore `GeoPoint`

The canonical type, and again the identity mapping:

```protobuf
// google/type/latlng.proto
package google.type;

message LatLng {
  double latitude = 1;
  double longitude = 2;
}
```

Recognized automatically by fully-qualified type name. No annotation required.

**The codec validates at encode time**: latitude in [−90, +90], longitude in
[−180, +180], neither NaN. `LatLng` and Firestore document the same bounds and the
same WGS84 datum, but protobuf has no range constraints, and a Firestore
rejection surfaces as an opaque write error far from the field that caused it.
Validating here turns that into a precise failure.

> **`LatLng` is a *common* type, not a well-known type.** It is not shipped with
> `protoc` or bundled into language runtimes the way `google/protobuf/*` is, so it
> has to be sourced explicitly. Two separate things get called "vendoring" here,
> and only one of them is ever a hazard:
>
> 1. **Vendoring the `.proto`** — copying `google/type/latlng.proto` into the tree
>    so `protoc -I` resolves the import while compiling a schema that uses it.
>    Always safe: it generates no code and registers no descriptor.
> 2. **Generating from it** — passing it to `--dart_out`, `--es_out`, `--java_out`.
>    This produces a *second* artifact claiming the descriptor path
>    `google/type/latlng.proto` and the message name `google.type.LatLng`.
>
> Everyone needs (1). Only a language with no packaged generated code needs (2):
> **Dart and TypeScript**, where generating is correct and collides with nothing.
> **Java, Python and Go** already ship it — `proto-google-common-protos`,
> `googleapis-common-protos`, `google.golang.org/genproto` — so take the generated
> code from the dependency and do not generate. A second copy is not a build
> error in Java: the classloader picks one `com.google.type.LatLng` by classpath
> order, and a shape mismatch then surfaces as a class-load failure far from the
> cause. Python's descriptor pool is strict and fails outright on the duplicate
> file name; Go's registry panics at `init`.
>
> None of this reaches the codec, which matches `LatLng` by descriptor full name
> and reads `latitude`/`longitude` reflectively. It never links against a
> generated class and works against whichever copy it is handed — the hazard is
> in a consumer's build, not in this library's.
>
> *(`java/tool/generate.sh` does generate `latlng.proto`, for the conformance
> fixtures only, to avoid pinning `proto-google-common-protos` against the
> protobuf runtime. It is test-scoped and never ships in the jar; it is not the
> pattern a consumer should copy.)*

**Presence matters more than usual here.** `(0, 0)` is a real coordinate in the
Gulf of Guinea, and it is also the all-defaults `LatLng`. Because singular message
fields carry explicit presence ([§6](#6-presence-and-defaults)), "no location" and
"null island" remain distinguishable. A codec that flattened the pair into two
scalar fields would lose that distinction — a second reason to keep the message.

#### Using a project's own lat/lng message

`kind: KIND_GEO_POINT` opts a local message into the same encoding. It is
**opt-in by declaration, never structural**: the codec does not scan messages for
fields that happen to be named `latitude`/`longitude`. A silent match on a
coincidentally-shaped message is a worse failure than an explicit error, and
structural matching would make adding a field to an unrelated message change how
it is stored.

An annotated message must have exactly two `double` fields named `latitude` and
`longitude`; anything else is a generator-time error. Prefer `google.type.LatLng`
unless the dependency is genuinely unwanted.

### 3.4 Not supported

`Any`, `Struct`, `Value`, `ListValue`, `FieldMask`. `Any` in particular
reintroduces the cross-language type-key mismatch this spec exists to prevent —
its type key is spelled differently by every runtime.

Other `google.type.*` messages — `Date`, `Money`, `Color`, `Interval` — have no
Firestore counterpart and encode as ordinary maps under [§5](#5-composite-kinds).
That is correct behavior rather than a gap: only `LatLng` has a native Firestore
type to map onto.

## 4. Enums

**Encoded as the value name, a string.** `"STATUS_ACTIVE"`, not `1`.

Readable in the console, and checkable in a security rule
(`data.status in ['STATUS_ACTIVE', 'STATUS_ARCHIVED']`) in a way an integer is
not. Stable across renumbering.

The cost, which must be accepted explicitly:

- **Enum value names are permanent once written.** Never rename one, never reuse
  a name for a different meaning. Adding values is fine. Stricter than protobuf
  requires; the price of the readable encoding.
- **Unknown names decode to the zero value**, never throw. Reserve `0` as
  `*_UNSPECIFIED`/`*_UNKNOWN` in every enum, or old readers break on documents
  written by newer writers.
- **Unknown numbers do not encode.** A message parsed from a newer writer can
  hold an enum number the reader's schema has no name for (Java and protobuf-es
  keep it; Dart's closed enums cannot). There is no correct name-encoding for
  it: writing the raw integer mixes types on a String field, and writing a
  runtime's synthetic placeholder name decodes to zero everywhere, silently
  destroying the newer writer's value. The codec throws `ENUM_VALUE_UNKNOWN`
  instead. Under `enum_as: NUMBER` the integer is representable and is written.

Per-field escape hatch: `enum_as: NUMBER`.

## 5. Composite kinds

| Proto | Firestore |
|---|---|
| singular message | Map |
| `repeated` scalar | Array |
| `repeated` message | Array of Maps |
| `map<string, V>` | Map |
| `map<K, V>`, K not string | **rejected** |

Non-string map keys are rejected rather than stringified: proto3 JSON stringifies
them, which round-trips ambiguously (`1` vs `"1"`), and Firestore map keys must be
strings regardless. Refuse rather than silently rename. The check runs on every
encode and decode as well as in schema validation, since a caller may never run
the latter; a field marked `skip` is exempt, which is the escape hatch for a
schema that carries such a map for other consumers.

**Nesting depth is capped at 20** by Firestore, counting maps and arrays together.
The document itself is level 1, and every map or array below it adds one. A
singular message field is therefore one level below its parent, but a message
reached through a `repeated` field or a `map` field is **two** levels below:
the array or map is a level of its own, and the element map sits inside it. A
`repeated` scalar costs one level for the array. A recursive message type is only
encodable if the caller keeps it under that bound; the codec detects overflow and
throws rather than let Firestore reject the write. The `nesting_*` vectors pin
both the singular chain and the array and map shapes.

## 6. Presence and defaults

**Omit singular scalar fields holding their default value.** Zero, `false`, `""`,
empty bytes, and the zero-valued enum are not written. Empty repeated fields and
empty maps are omitted, not written as `[]` or `{}`.

The comparison for floating-point fields is **numeric**, so `-0.0` counts as the
default and is omitted. Java is where this bites: `Double.equals` compares bits,
so the obvious `Objects.equals(value, field.getDefaultValue())` keeps `-0.0` and
diverges from the other runtimes. A field with explicit presence is unaffected --
there `-0.0` is written and preserved everywhere.

This matches proto3's implicit-presence semantics — the decoder supplies the
default either way — and avoids paying index entries for fields carrying nothing.

Fields with **explicit presence** (`optional` in proto3, and all singular message
fields) follow the opposite rule: written when set, absent when not.

Two consequences for callers:

- **A security rule reading these fields must use `.get(field, default)`.** A rule
  reading `data.count` rejects exactly those documents whose count is zero. This
  is the most likely way to misuse the encoding, and it looks like an unrelated
  permissions bug.
- **Clearing a field on update means `FieldValue.delete()`**, not writing a
  default — which is the caller's job, since merge semantics are out of scope.

Per-field override: `omit_when_default: false` where an index or rule depends on
the field existing.

## 7. Options

Encoding-level only. Published as `codebinge/firestore/codec/v1/options.proto`:

```protobuf
syntax = "proto3";
package codebinge.firestore.codec.v1;
import "google/protobuf/descriptor.proto";

option java_package = "com.codebinge.firestore.codec.v1";
option java_multiple_files = true;

extend google.protobuf.FieldOptions { Field field = 50000; }

message Field {
  bool   skip = 1;               // never encoded
  string name = 2;               // stored-name override
  EnumEncoding enum_as = 3;      // NAME (default) | NUMBER
  optional bool omit_when_default = 4;  // default true; `optional` is load-bearing
  Kind   kind = 5;
}

enum Kind {
  KIND_UNSPECIFIED = 0;          // infer from proto type
  KIND_GEO_POINT = 1;            // a local lat/lng message -> GeoPoint (§3.3)
  KIND_UNSIGNED_AS_INTEGER = 2;  // uint64/fixed64 -> Integer; throws above 2^63−1
}

enum EnumEncoding { ENUM_ENCODING_NAME = 0; ENUM_ENCODING_NUMBER = 1; }
```

> ⚠️ **The extension number is provisional.** 50000–99999 is protobuf's
> *organization-internal* range, which is safe only while nothing outside this
> org imports the file. That assumption holds while this repo is private and
> breaks the moment the library is published: two libraries both claiming 50000
> collide in any project that imports both.
>
> Before any public release, the extension must be registered in protobuf's
> [Global Extension Registry](https://github.com/protocolbuffers/protobuf/blob/main/docs/options.md)
> and this number replaced with the assigned one. **Changing it afterwards is
> breaking** — every `.proto` using the option must be regenerated, and a consumer
> pinned to the old number silently stops seeing the annotation rather than
> failing loudly. Register before v1.0.

`KIND_GEO_POINT` is only for a project's own lat/lng message
([§3.3](#33-googletypelatlng--firestore-geopoint)); `google.type.LatLng` needs no
annotation.

**`DocumentReference` is deliberately not modelled.** It is the one Firestore
value type protobuf cannot express, and constructing one requires a live
`Firestore` instance — which would make the codec dependency-bound for something
every project can do without. Store the document path in a plain `string` field
instead: `reference_value` is a path string on the wire anyway, and a path in a
string field stays queryable and portable. Leaving it out is what lets the codec
be a pure function with no SDK dependency at all.

Server sentinels (`serverTimestamp`, `increment`, `arrayUnion`, `arrayRemove`)
are **not modeled**: they are operations on a write, not properties of a value,
and belong in calling code.

## 8. Language notes

Where the same rules need different handling per runtime.

| | Dart | TypeScript | Java |
|---|---|---|---|
| proto int64 | `Int64` (`fixnum`) | `bigint` or `string` | `long` |
| Firestore int64 | `int` (64-bit native) | **`number` — 53-bit!** | `long` |
| unsigned 64-bit | format/parse **as unsigned** | `bigint.toString()` | `Long.toUnsignedString` / `parseUnsignedLong` |
| unsigned 32-bit | `int`, already positive | `number`, already positive | **signed `int`** — `Integer.toUnsignedLong` |
| Blob | `Blob` | `Buffer` | `Blob` |
| Timestamp | `Timestamp` | `Timestamp` | `com.google.cloud.Timestamp` |

> ⚠️ **JavaScript is the sharp edge.** The Firestore JS SDKs return integers as
> `number`, which silently loses precision above 2^53. An implementation must
> require `settings({useBigInt: true})` on the admin SDK, or reject int64 fields
> outright. Round-tripping a large int64 through the default JS configuration
> loses data with no error.

Dart's `Int64` from `fixnum` is not the same type as `int`, so the codec converts
explicitly in both directions; overflow is impossible but the conversion is not
free.

**Unsigned values need explicit handling in Dart and Java**, both of which model
`uint64` as a signed 64-bit integer in two's complement. A value at or above 2^63
reads back as *negative*, so the default `toString()` produces a wrong,
round-trip-breaking encoding. Format and parse through the unsigned path
explicitly: `Long.toUnsignedString` / `Long.parseUnsignedLong` in Java, and
`Int64.toStringUnsigned()` in Dart — never `toString()`. Decoding needs the same
care; the Dart implementation reinterprets through `BigInt.toSigned(64)` rather
than trusting a parse helper. This is the most likely single bug in an
implementation of §2.1, and it only shows up above 2^63.

**Dart needs the descriptor for explicit presence.** `package:protobuf`
registers a proto3 `optional` field exactly like an implicit-presence one, so
[§6](#6-presence-and-defaults) cannot be implemented from its runtime
reflection alone — the distinction survives only in the binary descriptor that
generated code already carries. Implementations on other runtimes should check
the same thing before assuming reflection is enough.

One upside falls out of the string encoding: **unsigned fields are immune to the
JavaScript 53-bit problem.** They round-trip correctly under the default JS SDK
configuration, because they never touch `number`. `int64` remains the type that
requires `useBigInt` — and note that with it enabled *every* integer comes back
as a `bigint`, including a numerically-encoded enum ([§4](#4-enums)).

**TypeScript escapes the 2^63 trap entirely.** protobuf-es models `uint64` as an
unsigned `bigint`, so there is no sign to flip and `toString()` is already
correct. The trap belongs to runtimes that reuse a signed 64-bit integer for
unsigned values, which is Dart and Java.

**TypeScript has a different trap: `jstype = JS_STRING`.** protobuf-es honours
the option and generates such a 64-bit field as a `string`, where Dart and Java
ignore it. The option changes only the in-memory JavaScript type; the encoding
is defined on the integer, so an implementation must coerce through `BigInt`
before encoding, treat `"0"` as the default under [§6](#6-presence-and-defaults),
and hand the value back as a string on decode. Passing the value through writes
a Firestore **String** for a field every other language writes as an Integer —
the split [§2.1](#21-unsigned-64-bit) exists to prevent. The
`int64_jstype_string` vectors pin this.

**A oneof member is stored under the oneof's name in protobuf-es**, as one
tagged `{ case, value }` object; the member has no property of its own. A
decoder that assigns the member name directly leaves the oneof unset and the
value invisible to every protobuf-es API. Dart and Java set oneof members
through the ordinary field setter, so only TypeScript needs the distinction.
The `oneof_set_*` vectors pin it.

**Splitting a Duration back into seconds and nanos needs a sign-preserving
remainder.** Protobuf keeps both parts the same sign, so -1.5s is
`seconds: -1, nanos: -500000000`. Java's `%` and JavaScript's `BigInt` `%` take
the dividend's sign; Dart's `%` is Euclidean and never negative, and turns
-1.5s into `seconds: -1, nanos: +500000000` — which is -0.5s. Use `remainder()`
in Dart. The `duration_negative` vector pins it.

**Java's signed-integer hazard is not limited to 64 bits.** `uint32` and
`fixed32` live in a signed `int`, so a value above 2^31−1 reads back negative and
must be widened with `Integer.toUnsignedLong` before encoding — the same shape of
bug as [§2.1](#21-unsigned-64-bit), one type smaller and easier to miss because
the encoding rule for `uint32` is unremarkable. Dart and TypeScript are
unaffected; both hold `uint32` in a type wide enough to keep it positive. The
`uint32_field` in the `scalars_full` vector is `4294967295`, which catches it.

**Only Dart needs a registration step.** protobuf-es keeps custom options and
field presence on the descriptor and exposes them through `getOption()` and
`field.presence`, so a TypeScript implementation reads [§6](#6-presence-and-defaults)
and [§7](#7-options) straight from the schema. Java is the same: protobuf-java
re-parses a generated file's options with its own extensions registered, so
`getOptions().getExtension(...)` works with no setup. The registry the Dart implementation needs is a property of that runtime,
not of this encoding.

> ⚠️ **JavaScript cannot write a Firestore double holding an integral value.**
> The Firestore JS SDK picks the stored type from the value: `Number.isSafeInteger(val)`
> and not negative zero writes `integerValue`, anything else writes `doubleValue`.
> JavaScript has one numeric type, so a proto `double` field holding `3.0` is
> stored as a Firestore **integer** — where Dart and Java store a double.
>
> The window is bounded: `isSafeInteger` is false beyond 2^53, so an integral
> double larger than that is still stored as a double. Only integral values
> within the safe-integer range flip.
>
> The proto round-trip still works, and Firestore orders integers and doubles
> together by value, so queries are unaffected. What diverges is the stored type:
> a security rule asserting `is float`, or a reader switching on the value's type,
> will disagree across languages. There is no workaround in the SDK — the only
> defence is not to depend on the distinction. The conformance vectors avoid
> integral doubles for this reason.

## 9. Conformance

**The only thing that keeps implementations aligned.** The suite lives in
[`testdata/`](../testdata/) and is driven by `testdata/manifest.json`, which
names for each case a message type, a direction, and either the files to compare
or the error to expect.

| Direction | Assertion |
|---|---|
| `roundtrip` | `encode(message) == document` and `decode(document) == message` |
| `encode` | `encode(message) == document`, or raises the expected error |
| `decode` | `decode(document) == message`, or raises the expected error |
| `schema` | registering the named message type raises the expected error |

Inputs are **proto3 JSON**, not text format: text format has no parser in the
Dart runtime or in protobuf-es, so a `.textproto` fixture would be unreadable in
two of the three target languages. Expected output is **Firestore REST `Value`
JSON**, which names the Firestore type explicitly — plain JSON cannot distinguish
an integer from a double, and that distinction is most of [§2](#2-scalar-types).

Errors are reported by name from a fixed set: `UNSIGNED_MALFORMED`,
`UNSIGNED_OUT_OF_RANGE`, `UNSIGNED_NOT_REPRESENTABLE`, `LATLNG_OUT_OF_RANGE`,
`NESTING_TOO_DEEP`, `UNSUPPORTED_MAP_KEY`, `UNSUPPORTED_TYPE`,
`ENUM_VALUE_UNKNOWN`. An implementation may raise whatever exception type it
likes, so long as it maps to these.

A case may carry a `requires` key naming a runtime capability from
`manifest.requirements`. An implementation whose runtime lacks the capability
cannot construct the input and may skip the case; it is conformant by
construction. Today the only requirement is `open_enum_values`, which Dart's
closed enums do not meet.

Coverage: every scalar type; a `float` needing binary32 rounding; NaN and both
infinities; both enum encodings, an
unknown enum name, and an unknown enum number; all-defaults; explicit presence
set and unset, including a oneof member at its default and a message-typed
oneof member; a negative `Duration`; `int64` under `jstype = JS_STRING` at
2^53+1 and at its default; unsigned
round-trips at `0`, `2^63−1`, `2^63`, and `2^64−1` plus four decode rejections
and an encode rejection; a `Timestamp` with sub-microsecond nanos; `Duration`;
`LatLng` and an out-of-range rejection; nested, repeated, and map fields; the
`skip` and `name` options; nesting at depth 20 and 21 through singular fields,
through arrays, and through maps; a non-string map key rejected on encode and on
decode; and three schemas that must be rejected outright.

The four unsigned boundary values are the ones to understand first — an
implementation that handles `0` and `2^64−1` but gets `2^63` wrong is the
expected failure, since that is exactly where a signed 64-bit representation goes
negative.

**These come before a codec, not after.** They are useful even where a mapping
stays hand-written, and they are what makes "conforming implementation" mean
something.
