# @codebinge/firestore-proto-codec

TypeScript implementation of the [encoding spec](../docs/encoding.md). Passes all
37 [conformance vectors](../testdata/).

```ts
const codec = new FirestoreProtoCodec();

await doc.set(codec.encode(TaskSchema, task));              // whole document
await doc.set({ task: codec.encode(TaskSchema, task) });    // one field
const task = codec.decode(TaskSchema, snap.data()!);        // and back
```

Built on [protobuf-es](https://github.com/bufbuild/protobuf-es) v2. The schema is
passed explicitly because protobuf-es messages are plain objects rather than
class instances.

## Required: `useBigInt`

```ts
firestore.settings({ useBigInt: true });
```

Without it the SDK returns every integer as a `number`, which silently loses
precision above 2^53 — and `int64` fields are exactly the ones that exceed it.
The codec emits `bigint` for signed 64-bit fields and expects `bigint` back.

Unsigned fields are unaffected: they encode as strings and never touch `number`.

Fields annotated `[jstype = JS_STRING]`, which protobuf-es generates as
`string`, are coerced through `BigInt` and stored as Integers like every other
int64; decoding hands them back as strings.

## Binding to an SDK

The default adapter emits dependency-free `FsTimestamp` / `FsBlob` /
`FsGeoPoint`. Supply your own to write straight to Firestore:

```ts
class AdminTypes implements FirestoreTypes {
  timestamp = (seconds: bigint, nanos: number) =>
    new Timestamp(Number(seconds), nanos);
  blob = (bytes: Uint8Array) => Buffer.from(bytes);
  geoPoint = (lat: number, lng: number) => new GeoPoint(lat, lng);

  readTimestamp = (v: unknown) =>
    v instanceof Timestamp
      ? { seconds: BigInt(v.seconds), nanos: v.nanoseconds }
      : undefined;
  // Buffer extends Uint8Array, so this covers both.
  readBlob = (v: unknown) =>
    v instanceof Uint8Array ? new Uint8Array(v) : undefined;
  readGeoPoint = (v: unknown) =>
    v instanceof GeoPoint
      ? { latitude: v.latitude, longitude: v.longitude }
      : undefined;
}

const codec = new FirestoreProtoCodec(new AdminTypes());
```

Verified against `@google-cloud/firestore` 9.0.1: there is no `Bytes` class in
the admin SDK (that one belongs to the web client SDK), and bytes values are
plain `Buffer`s.

Keeping this an interface is why the core has no Firebase dependency.

## No registration step

Unlike the [Dart implementation](../dart/), nothing needs registering. protobuf-es
keeps custom options and field presence on the descriptor, so `getOption()` and
`field.presence` answer everything the codec needs directly from the schema.

## Known limits

> **JavaScript cannot write a Firestore double holding an integral value.**
> The Firestore JS SDK picks the stored type from the value —
> `Number.isSafeInteger(val)` and not negative zero writes `integerValue`,
> anything else writes `doubleValue`. JavaScript has one numeric type, so a proto
> `double` field holding `3.0` is stored as a Firestore **integer**, where Dart
> and Java store a double.
>
> The proto round-trip still works and queries are unaffected, since Firestore
> orders integers and doubles together by value. What diverges is the stored
> type, so a rule asserting `is float` will disagree across languages. There is
> no workaround in the SDK.

`DocumentReference` is not modelled at all ([§7](../docs/encoding.md#7-options)) --
store document paths in plain `string` fields.

## Development

```sh
npm test          # node:test via tsx
npm run typecheck
./tool/generate.sh
```
