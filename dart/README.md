# firestore_proto_codec (Dart)

Dart implementation of the
[encoding spec](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md).
Passes all 37
[conformance vectors](https://github.com/willbinge/firestore-proto-codec/tree/main/testdata)
(one is skipped: Dart's closed enums cannot construct the input for
`enum_unknown_number`, so it is conformant by construction).

```dart
final codec = FirestoreProtoCodec();

await doc.set(codec.encode(task));                    // whole document
await doc.set({'task': codec.encode(task)});          // one field
final task = codec.decode(snapshot.data()!, Task());  // and back
```

`encode` returns a `Map<String, Object?>` of plain Dart values — `String`,
`int`, `double`, `bool`, `List`, `Map` — plus whatever the `FirestoreTypes`
adapter produces for the three types protobuf cannot express.

`decode`'s second argument is a type token: it is never read and never
modified, and the message you get back is always a fresh one.

## Binding to an SDK

The default adapter emits dependency-free `FsTimestamp` / `FsBlob` /
`FsGeoPoint`, which are placeholders rather than Firestore values. Bind the
SDK's own classes by handing over their constructors:

```dart
final codec = FirestoreProtoCodec(
  types: SdkFirestoreTypes(
    timestamp: Timestamp.new,
    blob: Blob.new,
    geoPoint: GeoPoint.new,
  ),
);
```

Verified against `cloud_firestore_platform_interface` 8.0.6, whose
`Timestamp(int, int)`, `Blob(Uint8List)` and `GeoPoint(double, double)` match
those signatures exactly. Any SDK of the same shape works, a server-side Dart
client included, provided its timestamp exposes `seconds` and `nanoseconds`, its
blob `bytes`, and its geo point `latitude` and `longitude`.

**Why constructors rather than a class you import.** The
[TypeScript package](../ts/) ships its adapter outright, on a subpath that
pulls the SDK in only for consumers who import it. Pub has no equivalent --
no optional dependencies, no conditional exports -- and
`cloud_firestore_platform_interface`, where those three classes live, depends
on the Flutter SDK. Naming them here would make this package Flutter-only and
untestable off-device, so it takes their constructors instead and stays pure
Dart.

The reads are duck-typed for that same reason rather than TypeScript's: there
is no type here to write `is` against. It costs less than it appears to,
because the codec never uses these to discriminate a type -- it calls them only
at a position the schema has already declared a `Timestamp`, `bytes` or
`LatLng`. A value of the wrong shape reads as null, and the codec reports the
field path.

Implementing [`FirestoreTypes`](lib/src/values.dart) by hand still works, and is
the better answer if you want the SDK's types checked at compile time.

Keeping this an interface is why the core has no Firebase dependency and can be
tested off-device.

## When you must register a descriptor

Field *names* come from reflection and need no setup. Two things do not survive
into `BuilderInfo`, and for those the codec reads the binary descriptor that the
generated `.pbjson.dart` already contains:

```dart
final registry = SchemaRegistry()
  ..register(Unsigned(), unsignedDescriptor)
  ..register(Presence(), presenceDescriptor);

final codec = FirestoreProtoCodec(registry: registry);
```

Register a message when it uses either:

1. **Custom options** from `options.proto` — `skip`, `name`, `enum_as`,
   `omit_when_default`, `kind`.
2. **Proto3 `optional` scalars.** This one is easy to miss. package:protobuf
   registers a proto3 `optional` field *identically* to an implicit-presence
   one, so without the descriptor the codec cannot tell that a default value
   should still be written. An unregistered message with `optional` fields
   silently omits them when they hold defaults.

Messages using neither need no registration. Real `oneof` groups are fine
unregistered: the generated code records them on `BuilderInfo`, and the
`oneof_set_*` vectors pass without registering `Choice`.

## Known limits

- **Web is unsupported.** `int64` fields convert through Dart `int`, which is a
  double on the web and loses precision above 2^53. Unsigned fields are fine —
  they encode as strings — but the signed 64-bit path is VM/Flutter-native only.
- **`-Dprotobuf.omit_field_names=true` breaks the encoding**, which is defined
  in terms of proto field names. The codec throws a `StateError` naming the
  field rather than writing a document with empty keys.
- **`-Dprotobuf.omit_message_names=true` breaks it too.** The codec recognizes
  `Timestamp`, `Duration`, and `LatLng` by type name and keys registered
  options by it, so stripped names would silently encode all three as plain
  maps. The codec throws a `StateError` instead.
- `DocumentReference` is not modelled at all
  ([§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options))
  — store document paths in plain `string` fields.

## Development

```sh
dart test                 # from dart/
./dart/tool/generate.sh   # from the repo root, after changing a .proto
```
