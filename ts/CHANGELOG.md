# Changelog

## 0.1.0

Not yet published. First release of the TypeScript implementation of
[encoding specification v0.1](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md).

- Encode a protobuf message to a map of Firestore-native values, and decode it
  back.
- Pluggable `FirestoreTypes` adapter, so the core carries no Firebase
  dependency.
- Passes all 37 shared conformance vectors.
- Ships `proto/codebinge/firestore/codec/v1/options.proto` for annotating your
  own schemas.
- `encode` and `decode` are generic over the descriptor, so the message type is
  checked at compile time rather than accepted as `unknown`.
- `encode` rejects anything that is not a protobuf-es message with
  `UNSUPPORTED_TYPE`. A `protoc-gen-js` message would otherwise read as
  entirely unset and encode to an empty document; see the README on bridging
  from `google-protobuf`.

**`int64` requires `useBigInt`.** The Firestore JS SDKs return integers as
`number`, which loses precision above 2^53. Configure the admin SDK with
`settings({useBigInt: true})`. Unsigned 64-bit fields are unaffected — they
encode as strings and never touch `number`.

The `options.proto` extension number is provisional and will change before 1.0.
See [§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options).
