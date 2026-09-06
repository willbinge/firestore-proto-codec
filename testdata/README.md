# Conformance vectors

Shared test data for every implementation of this codec. An implementation is
conforming when it passes all of these.

## Running them

`manifest.json` drives everything. Each entry names a message type, a direction,
and either the files to compare or the error to expect:

| Direction | Assertion |
|---|---|
| `roundtrip` | `encode(message) == document` **and** `decode(document) == message` |
| `encode` | `encode(message) == document`, or raises `expect_error` |
| `decode` | `decode(document) == message`, or raises `expect_error` |
| `schema` | registering the named message type raises `expect_error` |

Error names come from the fixed set in `manifest.errors`. An implementation may
use its own exception types, but must map them to these names to report results.

A case may carry `requires`, naming a runtime capability described in
`manifest.requirements`. An implementation whose runtime lacks it cannot build
the input and should skip the case, reporting why; it is conformant by
construction. `enum_unknown_number` requires `open_enum_values`, which Dart's
closed enums do not provide.

Compile the schemas with the repo root and `testdata/schema` on the include path:

```bash
protoc -I proto -I testdata/schema \
  --<lang>_out=<dir> \
  testdata/schema/testdata.proto testdata/schema/invalid.proto
```

`schema/invalid.proto` is separate on purpose: an implementation that rejects
unsupported constructs at load time would otherwise fail to load the valid
schema alongside them.

## File formats, and two things that look like contradictions

**Input (`*.message.json`) is proto3 JSON.** Not text format. Text format has no
parser in the Dart runtime or in protobuf-es, so a `.textproto` fixture would be
unreadable in two of the three target languages. Proto3 JSON is human-readable
*and* parseable everywhere — `fromProto3Json` in Dart, `fromJson` in protobuf-es,
`JsonFormat.parser()` in Java.

Inputs spell fields with their **proto names** (`string_field`), which every
conforming proto3 JSON parser accepts alongside the `lowerCamelCase` form. That
keeps the input visually aligned with the output, where the proto name is the
only spelling (§1).

**Output (`*.document.json`) is Firestore REST `Value` JSON** — the wire encoding
of `google.firestore.v1.Value`, chosen because it names the Firestore type
explicitly. Plain JSON cannot distinguish an integer from a double, and that
distinction is most of §2.

Two encodings in that format look like they contradict the spec, and do not:

- **`{"integerValue": "42"}` is a string.** REST JSON carries int64 as a string
  because JSON numbers cannot hold one exactly. The *Firestore type* is still
  Integer — which is exactly what §2 requires, and exactly what
  `toProto3Json()` fails to produce (it yields a Firestore **String**).
- **`{"bytesValue": "AAH/"}` is base64.** Again a transport detail: the Firestore
  type is Blob. §2's "never base64" is about not landing a Firestore String
  holding base64 text, which is what proto3 JSON would give you.

In both cases the vector describes the *value type*, not the codec's in-memory
output. A Dart implementation compares against `int` and `Blob`; the JSON is how
that is written down portably.

## Deliberate gaps

- **`DocumentReference`.** Not modelled by the encoding at all (§7); document
  paths are stored as plain strings.
- **Server sentinels.** Not part of the encoding (§7).
- **`nullValue`.** Unreachable: proto has no null, and absent fields are omitted.

## Case index

Names map to files as `cases/<name>.message.json` and
`cases/<name>.document.json`. `manifest.json` carries a note on each explaining
what it pins.

The four unsigned boundary values in `unsigned_boundaries` are the ones most
worth understanding before implementing: `2^63` is where a signed 64-bit
representation goes negative, so an implementation that handles `0` and `2^64−1`
correctly can still fail there. That is the expected failure mode in Dart and
Java, which both model `uint64` as a signed long.
