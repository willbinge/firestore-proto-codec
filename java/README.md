# firestore-proto-codec (Java)

Java implementation of the [encoding spec](../docs/encoding.md). Passes all 30
[conformance vectors](../testdata/).

```java
FirestoreProtoCodec codec = new FirestoreProtoCodec();

Map<String, Object> data = codec.encode(task);   // whole document
transaction.set(document, data);
transaction.set(document, Map.of("task", data)); // one field

Task decoded = codec.decode(snapshot.getData(), Task.getDefaultInstance());
```

`encode` returns a `Map<String, Object>` of plain Java values -- `String`,
`Long`, `Double`, `Boolean`, `List`, `Map` -- plus whatever the
[`FirestoreTypes`](src/main/java/com/codebinge/firestore/codec/FirestoreTypes.java)
adapter produces for the three types protobuf cannot express.

## Binding to an SDK

The default adapter emits dependency-free `FsTimestamp` / `FsBlob` /
`FsGeoPoint`. Supply your own to write straight to Firestore:

```java
final class CloudTypes implements FirestoreTypes {
  @Override public Object timestamp(long seconds, int nanos) {
    return Timestamp.ofTimeSecondsAndNanos(seconds, nanos);
  }
  @Override public Object blob(ByteString bytes) { return Blob.fromByteString(bytes); }
  @Override public Object geoPoint(double lat, double lng) { return new GeoPoint(lat, lng); }

  @Override public Optional<TimestampParts> readTimestamp(Object v) {
    return v instanceof Timestamp t
        ? Optional.of(new TimestampParts(t.getSeconds(), t.getNanos()))
        : Optional.empty();
  }
  @Override public Optional<ByteString> readBlob(Object v) {
    return v instanceof Blob b ? Optional.of(b.toByteString()) : Optional.empty();
  }
  @Override public Optional<GeoPointParts> readGeoPoint(Object v) {
    return v instanceof GeoPoint g
        ? Optional.of(new GeoPointParts(g.getLatitude(), g.getLongitude()))
        : Optional.empty();
  }
}

FirestoreProtoCodec codec = new FirestoreProtoCodec(new CloudTypes());
```

Verified against `google-cloud-firestore` 3.44.0 and `google-cloud-core` 2.72.0.

Keeping this an interface is why the core depends only on `protobuf-java`, with
no Google Cloud jars.

## No registration step

Like the [TypeScript implementation](../ts/) and unlike
[Dart](../dart/), nothing needs registering. protobuf-java re-parses a
generated file's options with its own extensions registered, so
`fd.getOptions().getExtension(Options.field)` works directly.
`ProtoGencodeTest` pins that behaviour.

## Signed integers hold unsigned values

Java stores both `uint32` and `uint64` in signed types, so a value past the
signed maximum reads back negative:

| Proto | Java storage | Correct handling |
|---|---|---|
| `uint64`, `fixed64` | `long` | `Long.toUnsignedString` / `Long.parseUnsignedLong` |
| `uint32`, `fixed32` | `int` | `Integer.toUnsignedLong` when widening |

Neither is caught by the compiler; both are caught by the vectors.

## Version pinning

`protobuf.version` in `pom.xml` must match the protoc that produced the
generated sources. protobuf 4.x gencode refuses to load against an older
runtime, and that is a *class-load* failure -- compilation succeeds and the
mismatch surfaces at runtime. `ProtoGencodeTest` turns it into a build failure.

## Development

```sh
mvn test
./tool/generate.sh
```
