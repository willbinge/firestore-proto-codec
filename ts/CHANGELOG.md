# Changelog

## 0.3.0

Unreleased.

- Ships the admin adapter as `firestore-proto-codec/admin` -- `adminCodec` and
  `AdminFirestoreTypes` for `firebase-admin` / `@google-cloud/firestore`, which
  every admin consumer previously had to copy out of the README. Its reads are
  structural rather than `instanceof`, so a duplicated `@google-cloud/firestore`
  in the tree no longer fails every decode with `expected a timestamp`.
  `@google-cloud/firestore` is an optional peer dependency and only that subpath
  imports it, so the root entry point still carries no Firebase dependency.

## 0.2.0

Unreleased.

**The option extension number changed, from 50000 to 1376**, now registered to
this project in protobuf's Global Extension Registry
([§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options)).
It is fixed from here.

This is the change 0.1.0 was deprecated for. If you annotated your own schemas
while on 0.1.0, regenerate them against this release — an unregenerated consumer
stops seeing the annotation *silently* rather than failing, so those fields
revert to default encoding. Code that only encodes and decodes is unaffected.

## 0.1.0

Published 2026-09-07 and **deprecated on npm**, because it carries extension
number 50000 — since replaced by the registered 1376 in 0.2.0.

The deprecation is a caution, not a defect: the codec is correct and passes all
37 conformance vectors. It matters only if you annotate your own schemas with
`codebinge.firestore.codec.v1.field`. Those annotations no longer apply as of
0.2.0, and the failure is *silent* — fields revert to default encoding rather
than erroring. Code that only encodes and decodes never touches the number and
is unaffected.

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

This release carries extension number 50000. See the 0.2.0 entry above.
