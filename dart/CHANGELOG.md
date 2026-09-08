# Changelog

## 0.2.0

Not yet published.

- `SdkFirestoreTypes` binds an SDK by taking its three constructors --
  `SdkFirestoreTypes(timestamp: Timestamp.new, blob: Blob.new, geoPoint:
  GeoPoint.new)` -- in place of the adapter class every consumer was copying out
  of the README. It reads properties structurally, because naming
  `cloud_firestore`'s types here would drag in the Flutter SDK and pub has no
  optional dependency to hide that behind.

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
- `decode` treats its second argument as a type token and returns a fresh
  message, matching the Java implementation. It previously decoded into that
  instance and returned it, which left fields the document omits untouched and
  *appended* to repeated fields — so reusing one message across two documents
  silently accumulated.

**Not supported on the web.** `int64` fields convert through Dart `int`, which
is a double on the web and loses precision above 2^53.

The `options.proto` extension number is 1376, registered to this project in
protobuf's Global Extension Registry. It is fixed and will not change.
See [§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options).
