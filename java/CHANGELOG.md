# Changelog

## 0.1.0

Not yet published. First release of the Java implementation of
[encoding specification v0.1](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md).

- Encode a protobuf message to a map of Firestore-native values, and decode it
  back.
- Pluggable `FirestoreTypes` adapter, so the core carries no Firebase
  dependency.
- Passes all 37 shared conformance vectors, plus three gencode compatibility
  checks.
- Ships `codebinge/firestore/codec/v1/options.proto` on the classpath for
  annotating your own schemas.

**Gencode and runtime must match.** protobuf 4.x generated code refuses to load
against an older runtime, and that surfaces as a class-load failure rather than
a compile error. `ProtoGencodeTest` pins this.

The `options.proto` extension number is provisional and will change before 1.0.
See [§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options).
