# Changelog

## 0.2.0

Unreleased, and waiting on the option extension number registration
([§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options)).
The number changes before this ships; that change is the whole reason 0.1.0 is
deprecated rather than quietly superseded.

## 0.1.0

Published 2026-09-07 and **deprecated on npm**, because it carries the
provisional option extension number.

The deprecation is a caution, not a defect: the codec is correct and passes all
37 conformance vectors. It matters only if you annotate your own schemas with
`codebinge.firestore.codec.v1.field` — once the number changes, an
unregenerated consumer stops seeing the annotation *silently* rather than
failing, so those fields revert to default encoding. Code that only encodes and
decodes never touches the number and is unaffected.

First release of the TypeScript implementation of
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
- Emulator-backed tests (`npm run test:emulator`) for the behaviour no
  in-memory vector can reach: native Firestore types on a real write, the
  microsecond truncation of a stored `Timestamp`, and an integral `double`
  stored as an Integer.

**`int64` requires `useBigInt`.** The Firestore JS SDKs return integers as
`number`, which loses precision above 2^53. Configure the admin SDK with
`settings({useBigInt: true})`. Unsigned 64-bit fields are unaffected — they
encode as strings and never touch `number`.

The `options.proto` extension number is provisional and will change before 1.0.
See [§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options).
