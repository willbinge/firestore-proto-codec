# firestore-proto-codec

Encode a protobuf message as a Firestore value, and decode it back.

**Status: draft specification, no implementation yet.** The encoding is defined
in [docs/encoding.md](docs/encoding.md); conformance vectors and the first
implementation come next.

## What it is

A pure function in each direction:

```
encode(Message)                                  -> Map<String, FirestoreValue>
decode(Map<String, FirestoreValue>, MessageType) -> Message
```

A message encodes to a map of **Firestore-native values** — the thing you hand
to `set()`. The caller decides what to do with it:

```dart
// as an entire document
await doc.set(codec.encode(task));

// as one field of a document
await doc.set({'task': codec.encode(task), 'updated_at': serverTimestamp});

// and back
final task = codec.decode(snapshot.data()!, Task());
```

Nested messages encode by the same rule, so the field case and the document case
are the same operation at different depths.

## What it is not

Deliberately out of scope, because these are properties of an application's
schema rather than of the encoding:

- Collection paths, document ids, subcollections
- Security rules and index definitions
- Partial writes, merge semantics, field masks
- Migration between shapes

A codec that knows about collections is a persistence framework. This is not one.

## Why not `toProto3Json()`

Proto3 JSON is the obvious mapping and it is wrong for Firestore in ways that
fail silently — the write succeeds and the query is quietly incorrect:

| | proto3 JSON | this codec |
|---|---|---|
| `int64` | String — sorts lexicographically, breaks every range query | Integer |
| `bytes` | base64 String | Blob |
| `Timestamp` | RFC-3339 String | Timestamp — orderable, indexable |
| `double` NaN/±Inf | String | Double |
| Field names | `lowerCamelCase`, and each runtime's default differs | proto name verbatim |

Several of the choices here are not conventions at all. Firestore's own wire
format is a protobuf, and `google.firestore.v1.Value` declares
`bytes bytes_value`, `google.protobuf.Timestamp timestamp_value`, and
`google.type.LatLng geo_point_value` — so those mappings are the identity.

## Layout

| Path | What |
|---|---|
| [`docs/encoding.md`](docs/encoding.md) | the specification |
| [`testdata/`](testdata/) | conformance vectors, shared by every implementation |
| [`dart/`](dart/) | Dart implementation — passes all 23 vectors |
| `proto/codebinge/firestore/codec/v1/options.proto` | per-field encoding options |

TypeScript and Java are planned. A conforming implementation in any language
must pass the vectors described in [§9](docs/encoding.md#9-conformance).

---

Copyright 2026 Code Binge LLC. All rights reserved.
