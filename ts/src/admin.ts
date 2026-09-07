/**
 * `FirestoreTypes` for the Firestore Admin SDK. `firebase-admin/firestore` and
 * `@google-cloud/firestore` re-export the same `Timestamp` and `GeoPoint`, so
 * this adapter serves both.
 *
 * ```ts
 * import { adminCodec } from "firestore-proto-codec/admin";
 * ```
 *
 * Not a convenience: without an adapter the codec emits `FsTimestamp` /
 * `FsBlob` / `FsGeoPoint`, and the admin SDK refuses a custom prototype
 * outright, so the write throws and stores nothing (pinned by
 * test/emulator.test.ts). Every admin consumer needs this, which is why it
 * ships here rather than being copied out of the README.
 *
 * `@google-cloud/firestore` is an optional peer dependency. Only this module
 * imports it -- the root entry point stays dependency-free.
 */
import { GeoPoint, Timestamp } from "@google-cloud/firestore";

import { FirestoreProtoCodec } from "./codec.js";
import type { FirestoreTypes } from "./values.js";

/**
 * The reads are structural rather than `instanceof`. They can afford to be:
 * the codec never uses them to discriminate a type, only to unwrap a value at
 * a position the schema has already declared a `Timestamp`, `bytes` or
 * `LatLng`, so a loose check cannot misclassify anything. What it buys is
 * immunity to two copies of `@google-cloud/firestore` in the tree -- a
 * version-range accident a consumer does not control, which makes `instanceof`
 * false and turns every read into `expected a timestamp`. That failure reads
 * like data corruption rather than like a dependency problem.
 */
export class AdminFirestoreTypes implements FirestoreTypes {
  timestamp(seconds: bigint, nanos: number): unknown {
    // Firestore spans years 1--9999, so seconds stays far inside
    // Number.MAX_SAFE_INTEGER and the narrowing is lossless.
    return new Timestamp(Number(seconds), nanos);
  }

  blob(bytes: Uint8Array): unknown {
    // Copies rather than viewing `bytes.buffer`: a pending write must not
    // change under a caller who mutates the message after encoding it.
    return Buffer.from(bytes);
  }

  geoPoint(latitude: number, longitude: number): unknown {
    return new GeoPoint(latitude, longitude);
  }

  readTimestamp(value: unknown): { seconds: bigint; nanos: number } | undefined {
    const ts = value as Timestamp | undefined;
    return typeof ts?.seconds === "number" &&
      typeof ts?.nanoseconds === "number" &&
      typeof ts?.toDate === "function"
      ? { seconds: BigInt(ts.seconds), nanos: ts.nanoseconds }
      : undefined;
  }

  readBlob(value: unknown): Uint8Array | undefined {
    // `instanceof` is right here, unlike above: `Uint8Array` is a realm
    // intrinsic, not a package export, so a duplicated dependency cannot
    // detach it. The copy hands the decoded message a plain `Uint8Array`
    // rather than the SDK's `Buffer`, which a strict deep-equal against an
    // encoded message would otherwise report as a type mismatch.
    return value instanceof Uint8Array ? new Uint8Array(value) : undefined;
  }

  readGeoPoint(value: unknown): { latitude: number; longitude: number } | undefined {
    const point = value as GeoPoint | undefined;
    return typeof point?.latitude === "number" &&
      typeof point?.longitude === "number"
      ? { latitude: point.latitude, longitude: point.longitude }
      : undefined;
  }
}

/** Shared instance: the codec keeps no per-call state. */
export const adminCodec = new FirestoreProtoCodec(new AdminFirestoreTypes());
