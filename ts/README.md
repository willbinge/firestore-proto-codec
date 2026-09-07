# firestore-proto-codec (TypeScript)

TypeScript implementation of the
[encoding spec](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md).
Passes all 37
[conformance vectors](https://github.com/willbinge/firestore-proto-codec/tree/main/testdata).

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

That string is a trade, not a detail. Firestore compares strings
lexicographically, so `"9"` sorts after `"10"`: `==` and `in` on a `uint64` field
still work, but `orderBy`, range filters, and `sum`/`average` do not
([§2.1](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#21-unsigned-64-bit)).
**Declare anything you intend to order or range-query as `int64`**, which stores
as a native Firestore Integer. Money in cents is the usual casualty — a
`uint64 total_cents` cannot answer `where('total_cents', '>', 1000)`, and an
`int64 total_cents` can.

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

Unlike the
[Dart implementation](https://github.com/willbinge/firestore-proto-codec/tree/main/dart),
nothing needs registering. protobuf-es
keeps custom options and field presence on the descriptor, so `getOption()` and
`field.presence` answer everything the codec needs directly from the schema.

## Bridging from `google-protobuf`

`protoc-gen-js` is the older JavaScript generator, and it is what most
Firebase-era proto tooling emits. Its messages are class instances that keep
their fields in a private array behind `getFoo()` accessors — nothing this
codec can read, and nothing protobuf-es can describe. Handing one to `encode`
throws `CodecError("UNSUPPORTED_TYPE")`; it does not write an empty document.

Generate a protobuf-es copy of the same `.proto` and convert through the binary
form, which is the one representation both runtimes agree on:

```ts
import { fromBinary, toBinary } from "@bufbuild/protobuf";

// google-protobuf -> protobuf-es -> Firestore
const task = fromBinary(TaskSchema, legacy.serializeBinary());
await doc.set(codec.encode(TaskSchema, task));

// Firestore -> protobuf-es -> google-protobuf
const back = proto.Task.deserializeBinary(
  toBinary(TaskSchema, codec.decode(TaskSchema, snap.data()!)),
);
```

`protoc-gen-es` runs in the same `protoc` invocation as `protoc-gen-js`, so the
two outputs coexist and nothing else in the application has to move. Only the
messages you persist need a protobuf-es copy.

Each direction costs one serialization and one parse per document. The binary
conversion itself is lossless, unknown fields included; what reaches Firestore
is still only what the schema declares.

## Known limits

**Admin SDK only.** The web client SDK (`firebase/firestore`) does not accept
`bigint` field values and throws on write, so a message with any signed 64-bit
field cannot be handed to it. It also has no `useBigInt` setting, so integers
above 2^53 would come back as imprecise `number`s on read. Use this codec from
`firebase-admin` / `@google-cloud/firestore`, or keep 64-bit fields out of
schemas the web client writes.

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

`DocumentReference` is not modelled at all
([§7](https://github.com/willbinge/firestore-proto-codec/blob/main/docs/encoding.md#7-options))
-- store document paths in plain `string` fields.

## Development

```sh
npm test              # node:test via tsx
npm run test:emulator # server-backed vectors, see below
npm run typecheck
./tool/generate.sh
```

`npm test` is entirely in-memory. `npm run test:emulator` runs
[test/emulator.test.ts](test/emulator.test.ts) inside
`firebase emulators:exec`, pinning the three things no in-memory vector can
reach: that a `Timestamp`, `Duration` and `LatLng` come back as native
Firestore types, that Firestore truncates a stored `Timestamp` to
**microseconds** so sub-microsecond nanos do not survive, and that a `double`
holding an integral value is stored as an Integer. It also checks that the
default adapter is refused outright by the admin SDK, which is what makes
forgetting the adapter a loud failure rather than a wrong storage type.

It needs a JDK 21 or newer, which the Firestore emulator requires;
`firebase-tools` is fetched by the script at a pinned version, so the emulator
build is the same one CI runs. The suite is skipped when
`FIRESTORE_EMULATOR_HOST` is unset, so `npm test` stays green without a JDK.
`@google-cloud/firestore` is a dev dependency only -- the published package
still has no Firebase dependency.

Nothing in a pull request can change what the server does, so CI runs this
[weekly](../.github/workflows/emulator.yml) rather than per-PR, and it can be
fired by hand from the Actions tab before a release.
