# Changelog

## 0.1.0

Not yet published. First release of the Dart implementation of
[encoding specification v0.1](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md).

- Encode a protobuf message to a map of Firestore-native values, and decode it
  back.
- Pluggable `FirestoreTypes` adapter, so the core carries no Firebase
  dependency and can be tested off-device.
- Passes the 37 shared conformance vectors, except `enum_unknown_number`, whose
  input Dart's closed enums cannot construct — conformant by construction.
- Ships `proto/codebinge/firestore/codec/v1/options.proto` for annotating your
  own schemas.

**Not supported on the web.** `int64` fields convert through Dart `int`, which
is a double on the web and loses precision above 2^53.

The `options.proto` extension number is provisional and will change before 1.0.
See [§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options).
