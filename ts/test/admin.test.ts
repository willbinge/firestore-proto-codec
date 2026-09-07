// The shipped admin adapter, against the real SDK classes but no server. The
// emulator suite exercises it end to end, but that needs a JDK and runs weekly;
// this keeps the adapter under `npm test` on every pull request.
import { describe, test } from "node:test";
import { deepStrictEqual, ok, strictEqual } from "node:assert/strict";

import { create, toBinary } from "@bufbuild/protobuf";
import { GeoPoint, Timestamp } from "@google-cloud/firestore";

import { AdminFirestoreTypes, adminCodec } from "../src/admin.js";
import { ScalarsSchema, WellKnownSchema } from "./generated/testdata_pb.js";

const types = new AdminFirestoreTypes();

describe("admin adapter", () => {
  test("encodes to native SDK values", () => {
    const message = create(WellKnownSchema, {
      timestamp: { seconds: 1700000000n, nanos: 123456000 },
      location: { latitude: 37.4, longitude: -122.1 },
    });
    const document = adminCodec.encode(WellKnownSchema, message);

    ok(document.timestamp instanceof Timestamp, "a native Timestamp");
    ok(document.location instanceof GeoPoint, "a native GeoPoint");
    strictEqual((document.timestamp as Timestamp).seconds, 1700000000);
    strictEqual((document.timestamp as Timestamp).nanoseconds, 123456000);

    deepStrictEqual(
      toBinary(WellKnownSchema, adminCodec.decode(WellKnownSchema, document)),
      toBinary(WellKnownSchema, message),
    );
  });

  test("bytes encode as a Buffer and decode as a plain Uint8Array", () => {
    const message = create(ScalarsSchema, {
      bytesField: new Uint8Array([1, 2, 3]),
    });
    const document = adminCodec.encode(ScalarsSchema, message);
    ok(Buffer.isBuffer(document.bytes_field), "the SDK wants a Buffer");

    // Not a Buffer on the way back: a decoded message must deep-equal one built
    // by hand, and node:assert treats the two prototypes as different types.
    const decoded = adminCodec.decode(ScalarsSchema, document);
    ok(!Buffer.isBuffer(decoded.bytesField), "a plain Uint8Array");
    deepStrictEqual(decoded.bytesField, new Uint8Array([1, 2, 3]));
  });

  test("encoding copies the bytes rather than viewing them", () => {
    const bytes = new Uint8Array([1, 2, 3]);
    const blob = types.blob(bytes) as Buffer;
    bytes[0] = 9;
    strictEqual(blob[0], 1, "a pending write must not change under the caller");
  });

  test("the reads accept a foreign copy of the SDK classes", () => {
    // What two copies of @google-cloud/firestore in the tree look like: the
    // right shape, the wrong class identity. `instanceof` would reject these
    // and fail every decode with `expected a timestamp`.
    const foreignTimestamp = {
      seconds: 1700000000,
      nanoseconds: 5,
      toDate: () => new Date(),
    };
    deepStrictEqual(types.readTimestamp(foreignTimestamp), {
      seconds: 1700000000n,
      nanos: 5,
    });
    deepStrictEqual(types.readGeoPoint({ latitude: 37.4, longitude: -122.1 }), {
      latitude: 37.4,
      longitude: -122.1,
    });
  });

  test("the reads still refuse a value of the wrong shape", () => {
    for (const value of [undefined, null, 7, "x", {}, { seconds: 1 }]) {
      strictEqual(types.readTimestamp(value), undefined);
      strictEqual(types.readGeoPoint(value), undefined);
      strictEqual(types.readBlob(value), undefined);
    }
  });
});
