/**
 * Firestore has three value types protobuf cannot express as plain data.
 * Implement this to bind them to a particular SDK's classes -- `Timestamp`,
 * `Buffer`, and `GeoPoint` in `firebase-admin`, for example. (Bytes are plain
 * `Buffer`s there; the `Bytes` class belongs to the web client SDK.)
 * Everything else in the encoding is a plain string, number, bigint, boolean,
 * array, or object.
 *
 * The admin implementation ships as `firestore-proto-codec/admin`. Write your
 * own only for another SDK.
 */
export interface FirestoreTypes {
  timestamp(seconds: bigint, nanos: number): unknown;
  blob(bytes: Uint8Array): unknown;
  geoPoint(latitude: number, longitude: number): unknown;

  /** Return undefined when the value is not of this type, so decoding can
   * report a useful error rather than throwing on a bad cast. */
  readTimestamp(value: unknown): { seconds: bigint; nanos: number } | undefined;
  readBlob(value: unknown): Uint8Array | undefined;
  readGeoPoint(value: unknown): { latitude: number; longitude: number } | undefined;
}

export class FsTimestamp {
  constructor(
    readonly seconds: bigint,
    readonly nanos: number,
  ) {}
}

export class FsBlob {
  constructor(readonly bytes: Uint8Array) {}
}

export class FsGeoPoint {
  constructor(
    readonly latitude: number,
    readonly longitude: number,
  ) {}
}

/** Dependency-free default. It cannot write to Firestore: the admin SDK
 * refuses these custom prototypes outright. Swap in an SDK-specific
 * implementation -- `firestore-proto-codec/admin` for firebase-admin. */
export class DefaultFirestoreTypes implements FirestoreTypes {
  timestamp(seconds: bigint, nanos: number): unknown {
    return new FsTimestamp(seconds, nanos);
  }
  blob(bytes: Uint8Array): unknown {
    return new FsBlob(bytes);
  }
  geoPoint(latitude: number, longitude: number): unknown {
    return new FsGeoPoint(latitude, longitude);
  }
  readTimestamp(value: unknown): { seconds: bigint; nanos: number } | undefined {
    return value instanceof FsTimestamp
      ? { seconds: value.seconds, nanos: value.nanos }
      : undefined;
  }
  readBlob(value: unknown): Uint8Array | undefined {
    return value instanceof FsBlob ? value.bytes : undefined;
  }
  readGeoPoint(value: unknown): { latitude: number; longitude: number } | undefined {
    return value instanceof FsGeoPoint
      ? { latitude: value.latitude, longitude: value.longitude }
      : undefined;
  }
}
