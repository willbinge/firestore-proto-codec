// Server-backed vectors. The shared conformance suite is in-memory by
// construction, so three things it cannot reach are pinned here instead: what
// Firestore does to a value on the way in, what it hands back, and whether the
// default adapter is usable at all.
//
// Skipped unless FIRESTORE_EMULATOR_HOST is set, which `npm run test:emulator`
// does by running the suite inside `firebase emulators:exec`. The project id is
// a `demo-` one, which the SDK refuses to take outside the emulator, so these
// tests cannot touch a real database even if the variable is set by hand.
import { after, describe, test } from "node:test";
import { deepStrictEqual, match, ok, strictEqual, throws } from "node:assert/strict";

import { create, toBinary } from "@bufbuild/protobuf";
import { Firestore, GeoPoint, Timestamp } from "@google-cloud/firestore";

import { FirestoreProtoCodec, type FirestoreTypes } from "../src/index.js";
import { ScalarsSchema, WellKnownSchema } from "./generated/testdata_pb.js";

const PROJECT = "demo-codec";
const emulator = process.env.FIRESTORE_EMULATOR_HOST;
const skip =
  emulator === undefined
    ? "requires FIRESTORE_EMULATOR_HOST -- run `npm run test:emulator`"
    : false;

/** The adapter from README.md, under test rather than only written down. */
class AdminTypes implements FirestoreTypes {
  timestamp = (seconds: bigint, nanos: number) =>
    new Timestamp(Number(seconds), nanos);
  blob = (bytes: Uint8Array) => Buffer.from(bytes);
  geoPoint = (lat: number, lng: number) => new GeoPoint(lat, lng);

  readTimestamp = (v: unknown) =>
    v instanceof Timestamp
      ? { seconds: BigInt(v.seconds), nanos: v.nanoseconds }
      : undefined;
  readBlob = (v: unknown) =>
    v instanceof Uint8Array ? new Uint8Array(v) : undefined;
  readGeoPoint = (v: unknown) =>
    v instanceof GeoPoint
      ? { latitude: v.latitude, longitude: v.longitude }
      : undefined;
}

// useBigInt is not optional: without it every integer comes back as a number
// and int64 loses precision above 2^53, which the scalars test would catch.
const db =
  emulator === undefined
    ? undefined
    : new Firestore({ projectId: PROJECT, useBigInt: true });
after(() => db?.terminate());

const codec = new FirestoreProtoCodec(new AdminTypes());
const bytesOf = (schema: typeof WellKnownSchema | typeof ScalarsSchema, m: never) =>
  Buffer.from(toBinary(schema, m));

describe("firestore emulator", { skip }, () => {
  test("the default adapter is refused by the admin SDK", async () => {
    // DefaultFirestoreTypes emits FsTimestamp / FsBlob / FsGeoPoint, which are
    // class instances. The SDK rejects any custom prototype, so a consumer who
    // forgets the adapter fails at the write and stores nothing -- the failure
    // is loud, not a silently wrong storage type. It is thrown synchronously
    // out of argument validation, before the write is attempted at all, so
    // this is `throws` and not `rejects`.
    const plain = new FirestoreProtoCodec();
    const message = create(WellKnownSchema, {
      timestamp: { seconds: 1700000000n, nanos: 0 },
    });
    const document = plain.encode(WellKnownSchema, message);
    throws(
      () => void db!.doc("probe/default-adapter").set(document),
      (error: Error) => {
        match(error.message, /Couldn't serialize object of type "FsTimestamp"/);
        match(error.message, /custom prototypes/);
        return true;
      },
    );
    const snap = await db!.doc("probe/default-adapter").get();
    ok(!snap.exists, "the rejected write must not have stored anything");
  });

  test("Timestamp, Duration and LatLng survive a real write", async () => {
    // Nanos on a microsecond boundary; the sub-microsecond case is below.
    const message = create(WellKnownSchema, {
      timestamp: { seconds: 1700000000n, nanos: 123456000 },
      duration: { seconds: -1n, nanos: -500000000 },
      location: { latitude: 37.4, longitude: -122.1 },
    });
    const ref = db!.doc("probe/well-known");
    await ref.set(codec.encode(WellKnownSchema, message));
    const raw = (await ref.get()).data()!;

    ok(raw.timestamp instanceof Timestamp, "stored as a native Timestamp");
    ok(raw.location instanceof GeoPoint, "stored as a native GeoPoint");
    strictEqual(typeof raw.duration, "bigint", "a Duration is microseconds");

    deepStrictEqual(
      bytesOf(WellKnownSchema, codec.decode(WellKnownSchema, raw) as never),
      bytesOf(WellKnownSchema, message as never),
    );
  });

  test("Firestore truncates a Timestamp to microseconds", async () => {
    // The one place a round trip that passes every in-memory vector is still
    // lossy: proto Timestamp carries nanoseconds, Firestore stores microseconds.
    // Built from the proto field directly -- going through a JS Date would lose
    // the digits to millisecond precision before Firestore ever saw them.
    const message = create(WellKnownSchema, {
      timestamp: { seconds: 1700000000n, nanos: 123456789 },
    });
    const ref = db!.doc("probe/nanos");
    await ref.set(codec.encode(WellKnownSchema, message));
    const raw = (await ref.get()).data()!;

    const stored = raw.timestamp as Timestamp;
    strictEqual(stored.seconds, 1700000000);
    strictEqual(stored.nanoseconds, 123456000, "789 nanoseconds are dropped");

    const decoded = codec.decode(WellKnownSchema, raw);
    strictEqual(decoded.timestamp?.nanos, 123456000);
    // Stated as a failure so the loss is pinned, not merely described.
    ok(
      !bytesOf(WellKnownSchema, decoded as never).equals(
        bytesOf(WellKnownSchema, message as never),
      ),
      "sub-microsecond nanos cannot survive; if this passes, Firestore changed",
    );
  });

  test("scalars survive a real write, including int64 above 2^53", async () => {
    const message = create(ScalarsSchema, {
      stringField: "hello",
      boolField: true,
      bytesField: new Uint8Array([1, 2, 3]),
      int32Field: -7,
      uint32Field: 7,
      int64Field: 9007199254740993n, // 2^53 + 1, unrepresentable as a number
      uint64Field: 18446744073709551615n, // 2^64 - 1
      doubleField: 3, // integral: see below
      floatField: 0.1,
    });
    const ref = db!.doc("probe/scalars");
    await ref.set(codec.encode(ScalarsSchema, message));
    const raw = (await ref.get()).data()!;

    strictEqual(raw.int64_field, 9007199254740993n, "exact under useBigInt");
    strictEqual(raw.uint64_field, "18446744073709551615", "unsigned is a String");
    strictEqual(raw.float_field, 0.10000000149011612, "float is its binary32 value");
    ok(Buffer.isBuffer(raw.bytes_field), "bytes come back as a Buffer");

    deepStrictEqual(
      bytesOf(ScalarsSchema, codec.decode(ScalarsSchema, raw) as never),
      bytesOf(ScalarsSchema, message as never),
    );
  });

  test("a double holding an integral value is stored as an Integer", async () => {
    // README "Known limits": the JS SDK picks the stored type from the value,
    // so a proto double of 3.0 lands as a Firestore Integer where Dart and Java
    // store a Double. Confirmed against a server rather than asserted.
    const raw = (await db!.doc("probe/scalars").get()).data()!;
    strictEqual(typeof raw.double_field, "bigint", "an Integer, not a Double");
    // The proto round trip is unaffected: it decodes back to a double.
    const decoded = codec.decode(ScalarsSchema, raw);
    strictEqual(decoded.doubleField, 3);
  });
});
