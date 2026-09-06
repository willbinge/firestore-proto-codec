# firestore-proto-codec

Encode a protobuf message as a Firestore value, and decode it back.

**Status: draft, v0.1.** The encoding is defined in
[docs/encoding.md](docs/encoding.md) and pinned by 37 shared
[conformance vectors](testdata/). Dart, TypeScript, and Java implementations all
pass them. Not yet published — see the extension-number note in
[§7](docs/encoding.md#7-options).

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
| [`dart/`](dart/) | Dart implementation — passes all 37 vectors |
| [`ts/`](ts/) | TypeScript implementation — passes all 37 vectors |
| [`java/`](java/) | Java implementation — passes all 37 vectors |
| `proto/codebinge/firestore/codec/v1/options.proto` | per-field encoding options |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | how to change the encoding, and why vectors come first |

A conforming implementation in any language must pass the vectors described in
[§9](docs/encoding.md#9-conformance).

Each package ships its own copy of `options.proto`, so annotating your own
schemas needs no separate download. `tool/sync-options-proto.sh` keeps the
copies identical to the canonical file, and CI enforces it.

## Licensing and use

Apache-2.0. The specification is meant to be implemented and `testdata/` is
meant to be copied into other implementations' repositories and run as their
tests — the license permits both, and [§9](docs/encoding.md#9-conformance)
depends on it.

Read [§10](docs/encoding.md#10-stability) before storing production data: this
is a draft specification, and the option extension number in
[§7](docs/encoding.md#7-options) is provisional.

*Not affiliated with, endorsed by, or sponsored by Google LLC. "Firestore",
"Firebase", and "Protocol Buffers" are trademarks of Google LLC, used here only
to describe what this software interoperates with.*

---

Copyright 2026 Code Binge LLC. Licensed under the
[Apache License, Version 2.0](LICENSE); see [NOTICE](NOTICE) for third-party
attributions.
