# firestore-proto-codec (Java)

Java implementation of the [encoding spec](../docs/encoding.md). Passes all 37
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
`FsGeoPoint`, which are placeholders rather than Firestore values. For
`google-cloud-firestore` -- and so for `firebase-admin`, which bundles it and
re-exports the same `com.google.cloud.firestore.*` classes -- the adapter ships:

```java
Map<String, Object> data = CloudFirestoreTypes.CODEC.encode(task);
transaction.set(document, data);
```

`CODEC` is a shared instance; use `new FirestoreProtoCodec(new CloudFirestoreTypes())`
if you would rather construct your own.

`google-cloud-firestore` is an **optional** dependency here, so it never enters
your tree on this library's account and nothing changes for a consumer who does
not use the adapter. Declare it yourself -- directly, or through
`firebase-admin` -- to use it. Verified against `google-cloud-firestore` 3.44.0,
which brings `com.google.cloud.Timestamp` in with `google-cloud-core` 2.72.0.

Its reads are `instanceof`, where the [TypeScript adapter](../ts/src/admin.ts)
uses structural checks. That is Maven's doing rather than a disagreement: npm
nests duplicate versions routinely, so two copies of a class can coexist and
defeat an identity check, while Maven resolves one version per coordinate onto
the classpath. Two live copies here would take shading or separate classloaders,
which no version range produces on its own.

For any other SDK, implement
[`FirestoreTypes`](src/main/java/com/codebinge/firestore/codec/FirestoreTypes.java)
yourself;
[`CloudFirestoreTypes`](src/main/java/com/codebinge/firestore/codec/CloudFirestoreTypes.java)
is the worked example.

Keeping this an interface is why the core depends only on `protobuf-java`, with
no Google Cloud jars of its own.

## No registration step

Like the [TypeScript implementation](../ts/) and unlike
[Dart](../dart/), nothing needs registering. protobuf-java re-parses a
generated file's options with its own extensions registered, so
`fd.getOptions().getExtension(Options.field)` works directly.
`ProtoGencodeTest` pins that behaviour.

## Decode trusts the document's types

Decoding narrows numerically rather than checking: an integer field reads its
value through `Number.intValue()` / `longValue()`, so a stored value outside
the field's range wraps silently rather than failing. That only arises when a
document was written under a wider schema than the one reading it. A value of
the wrong kind altogether, such as a String where an int64 field expects an
Integer, surfaces as a `ClassCastException` rather than a `CodecError`. Neither
is a data-loss path for documents this codec wrote.

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

Publishing to Maven Central is covered in
[RELEASING.md](https://github.com/willbinge/firestore-proto-codec/blob/main/RELEASING.md)
at the repository root, alongside npm and pub.dev.
