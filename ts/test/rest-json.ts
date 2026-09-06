import { FsBlob, FsGeoPoint, FsTimestamp } from "../src/index.js";

/**
 * Converts between the codec's native output and Firestore REST `Value` JSON,
 * which is how the conformance vectors are written down. The REST form names
 * the Firestore type explicitly, which plain JSON cannot do -- it carries an
 * integer as a string and a blob as base64 purely as transport.
 *
 * Integer-vs-double is decided by `Number.isInteger`, which is exactly what the
 * Firestore JS SDK itself does: JavaScript has one numeric type, so a `double`
 * field holding an integral value is genuinely indistinguishable from an
 * integer here. See the note in the package README.
 */
export function toRestValue(value: unknown): unknown {
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "bigint") return { integerValue: value.toString() };
  if (typeof value === "number") {
    return Number.isInteger(value)
      ? { integerValue: value.toString() }
      : { doubleValue: restDouble(value) };
  }
  if (value instanceof FsBlob) {
    return { bytesValue: Buffer.from(value.bytes).toString("base64") };
  }
  if (value instanceof FsTimestamp) {
    return { timestampValue: toRfc3339(value) };
  }
  if (value instanceof FsGeoPoint) {
    return {
      geoPointValue: { latitude: value.latitude, longitude: value.longitude },
    };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toRestValue) } };
  }
  if (typeof value === "object" && value !== null) {
    return {
      mapValue: {
        fields: Object.fromEntries(
          Object.entries(value as Record<string, unknown>).map(([k, v]) => [
            k,
            toRestValue(v),
          ]),
        ),
      },
    };
  }
  throw new Error(`no REST encoding for ${typeof value}`);
}

export const toRestDocument = (
  fields: Record<string, unknown>,
): Record<string, unknown> =>
  Object.fromEntries(
    Object.entries(fields).map(([k, v]) => [k, toRestValue(v)]),
  );

export function fromRestValue(value: unknown): unknown {
  const v = value as Record<string, unknown>;
  if ("stringValue" in v) return v.stringValue;
  if ("booleanValue" in v) return v.booleanValue;
  // Integers arrive as bigint, matching an admin SDK configured with
  // `useBigInt: true` -- which this encoding requires (see README).
  if ("integerValue" in v) return BigInt(v.integerValue as string);
  if ("doubleValue" in v) {
    const d = v.doubleValue;
    return typeof d === "string" ? parseSpecialDouble(d) : (d as number);
  }
  if ("bytesValue" in v) {
    return new FsBlob(
      new Uint8Array(Buffer.from(v.bytesValue as string, "base64")),
    );
  }
  if ("timestampValue" in v) return fromRfc3339(v.timestampValue as string);
  if ("geoPointValue" in v) {
    const g = v.geoPointValue as { latitude?: number; longitude?: number };
    return new FsGeoPoint(g.latitude ?? 0, g.longitude ?? 0);
  }
  if ("arrayValue" in v) {
    const a = v.arrayValue as { values?: unknown[] };
    return (a.values ?? []).map(fromRestValue);
  }
  if ("mapValue" in v) {
    const m = v.mapValue as { fields?: Record<string, unknown> };
    return Object.fromEntries(
      Object.entries(m.fields ?? {}).map(([k, x]) => [k, fromRestValue(x)]),
    );
  }
  throw new Error(`unrecognized REST value: ${JSON.stringify(v)}`);
}

export const fromRestDocument = (
  document: Record<string, unknown>,
): Record<string, unknown> =>
  Object.fromEntries(
    Object.entries(document).map(([k, v]) => [k, fromRestValue(v)]),
  );

const restDouble = (d: number): number | string =>
  Number.isNaN(d)
    ? "NaN"
    : d === Infinity
      ? "Infinity"
      : d === -Infinity
        ? "-Infinity"
        : d;

const parseSpecialDouble = (s: string): number =>
  s === "NaN"
    ? NaN
    : s === "Infinity"
      ? Infinity
      : s === "-Infinity"
        ? -Infinity
        : Number(s);

function toRfc3339(ts: FsTimestamp): string {
  const date = new Date(Number(ts.seconds) * 1000);
  const base = date.toISOString().slice(0, 19);
  return ts.nanos === 0
    ? `${base}Z`
    : `${base}.${ts.nanos.toString().padStart(9, "0")}Z`;
}

/** `Date` truncates at milliseconds, so the fraction is taken apart by hand:
 * these vectors deliberately carry nanosecond precision. */
function fromRfc3339(s: string): FsTimestamp {
  const match = /^(.*?)(?:\.(\d+))?(Z|[+-]\d\d:\d\d)$/.exec(s);
  if (match === null) throw new Error(`not an RFC 3339 timestamp: ${s}`);
  const base = match[1] ?? "";
  const fraction = match[2] ?? "";
  const zone = match[3] ?? "Z";
  const nanos =
    fraction === "" ? 0 : Number(fraction.padEnd(9, "0").slice(0, 9));
  const seconds = BigInt(Math.floor(Date.parse(`${base}${zone}`) / 1000));
  return new FsTimestamp(seconds, nanos);
}
