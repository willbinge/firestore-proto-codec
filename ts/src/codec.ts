import { create, getOption, hasOption, ScalarType } from "@bufbuild/protobuf";
import type { DescEnum, DescField, DescMessage } from "@bufbuild/protobuf";
import { FeatureSet_FieldPresence } from "@bufbuild/protobuf/wkt";

import { CodecError } from "./errors.js";
import {
  DefaultFirestoreTypes,
  type FirestoreTypes,
} from "./values.js";
import {
  EnumEncoding,
  Kind,
  field as fieldOption,
} from "./generated/codebinge/firestore/codec/v1/options_pb.js";

/** Firestore's limit on the depth of fields in a map or array. */
export const MAX_NESTING_DEPTH = 20;

const TIMESTAMP = "google.protobuf.Timestamp";
const DURATION = "google.protobuf.Duration";
const LAT_LNG = "google.type.LatLng";

const UNSUPPORTED = new Set([
  "google.protobuf.Any",
  "google.protobuf.Struct",
  "google.protobuf.Value",
  "google.protobuf.ListValue",
  "google.protobuf.FieldMask",
]);

const CANONICAL_UNSIGNED = /^(0|[1-9][0-9]*)$/;
const MAX_UINT64 = 2n ** 64n - 1n;
const MAX_INT64 = 2n ** 63n - 1n;

type AnyMessage = Record<string, unknown>;
export type FirestoreDocument = Record<string, unknown>;

interface FieldRules {
  skip: boolean;
  name?: string;
  enumAsNumber: boolean;
  omitWhenDefault: boolean;
  unsignedAsInteger: boolean;
  geoPoint: boolean;
}

const DEFAULT_RULES: FieldRules = {
  skip: false,
  enumAsNumber: false,
  omitWhenDefault: true,
  unsignedAsInteger: false,
  geoPoint: false,
};

/**
 * Reads the custom options straight off the descriptor. Unlike the Dart
 * runtime, protobuf-es keeps them, so no registration step is needed.
 */
function rulesFor(field: DescField): FieldRules {
  if (!hasOption(field, fieldOption)) return DEFAULT_RULES;
  const o = getOption(field, fieldOption);
  return {
    skip: o.skip,
    name: o.name !== "" ? o.name : undefined,
    enumAsNumber: o.enumAs === EnumEncoding.NUMBER,
    // Explicit presence: the intended default is true, which an implicit
    // proto3 bool could not express.
    omitWhenDefault: o.omitWhenDefault ?? true,
    unsignedAsInteger: o.kind === Kind.UNSIGNED_AS_INTEGER,
    geoPoint: o.kind === Kind.GEO_POINT,
  };
}

const storedName = (field: DescField, rules: FieldRules): string =>
  rules.name ?? field.name;

const isExplicit = (field: DescField): boolean =>
  field.presence !== FeatureSet_FieldPresence.IMPLICIT;

/** Encodes a protobuf message as a Firestore value, and decodes it back. */
export class FirestoreProtoCodec {
  constructor(readonly types: FirestoreTypes = new DefaultFirestoreTypes()) {}

  encode(schema: DescMessage, message: unknown): FirestoreDocument {
    return this.encodeMessage(schema, message as AnyMessage, 1, "");
  }

  decode(schema: DescMessage, document: FirestoreDocument): unknown {
    return this.decodeMessage(schema, document, "");
  }

  /** Throws if this type, or any type it reaches, cannot be encoded. */
  validateSchema(schema: DescMessage): void {
    this.validate(schema, new Set<string>(), schema.typeName);
  }

  // ---------------------------------------------------------------- encoding

  private encodeMessage(
    schema: DescMessage,
    message: AnyMessage,
    depth: number,
    path: string,
  ): FirestoreDocument {
    if (depth > MAX_NESTING_DEPTH) {
      throw new CodecError(
        "NESTING_TOO_DEEP",
        `nesting exceeds Firestore's limit of ${MAX_NESTING_DEPTH} levels`,
        path,
      );
    }
    const out: FirestoreDocument = {};
    for (const field of schema.fields) {
      const rules = rulesFor(field);
      if (rules.skip) continue;
      const name = storedName(field, rules);
      const fieldPath = path === "" ? name : `${path}.${name}`;
      const value = readField(message, field);

      if (field.fieldKind === "map") {
        const entries = Object.entries((value ?? {}) as Record<string, unknown>);
        if (entries.length === 0) continue;
        out[name] = Object.fromEntries(
          entries.map(([k, v]) => [
            k,
            this.encodeElement(
              field.scalar,
              field.enum,
              field.message,
              v,
              DEFAULT_RULES,
              depth,
              `${fieldPath}.${k}`,
            ),
          ]),
        );
      } else if (field.fieldKind === "list") {
        const items = (value ?? []) as unknown[];
        if (items.length === 0) continue;
        out[name] = items.map((item, i) =>
          this.encodeElement(
            field.scalar,
            field.enum,
            field.message,
            item,
            rules,
            depth,
            `${fieldPath}[${i}]`,
          ),
        );
      } else if (isExplicit(field)) {
        if (value === undefined) continue;
        out[name] = this.encodeElement(
          field.scalar,
          field.enum,
          field.message,
          value,
          rules,
          depth,
          fieldPath,
        );
      } else {
        if (rules.omitWhenDefault && isDefault(value)) continue;
        out[name] = this.encodeElement(
          field.scalar,
          field.enum,
          field.message,
          value,
          rules,
          depth,
          fieldPath,
        );
      }
    }
    return out;
  }

  private encodeElement(
    scalar: ScalarType | undefined,
    enumDesc: DescEnum | undefined,
    messageDesc: DescMessage | undefined,
    value: unknown,
    rules: FieldRules,
    depth: number,
    path: string,
  ): unknown {
    if (messageDesc !== undefined) {
      return this.encodeMessageValue(messageDesc, value, rules, depth, path);
    }
    if (enumDesc !== undefined) {
      const number = value as number;
      if (rules.enumAsNumber) return number;
      const match = enumDesc.values.find((v) => v.number === number);
      return match?.name ?? number;
    }
    switch (scalar) {
      case ScalarType.STRING:
      case ScalarType.BOOL:
      case ScalarType.DOUBLE:
      case ScalarType.FLOAT:
      case ScalarType.INT32:
      case ScalarType.SINT32:
      case ScalarType.SFIXED32:
      case ScalarType.UINT32:
      case ScalarType.FIXED32:
        return value;
      case ScalarType.BYTES:
        return this.types.blob(value as Uint8Array);
      case ScalarType.INT64:
      case ScalarType.SINT64:
      case ScalarType.SFIXED64:
        return value as bigint;
      case ScalarType.UINT64:
      case ScalarType.FIXED64:
        return this.encodeUnsigned(value as bigint, rules, path);
      default:
        throw new CodecError(
          "UNSUPPORTED_TYPE",
          `no encoding for scalar type ${String(scalar)}`,
          path,
        );
    }
  }

  private encodeUnsigned(value: bigint, rules: FieldRules, path: string): unknown {
    if (!rules.unsignedAsInteger) return value.toString();
    if (value > MAX_INT64) {
      throw new CodecError(
        "UNSIGNED_NOT_REPRESENTABLE",
        `KIND_UNSIGNED_AS_INTEGER cannot represent ${value}; ` +
          "Firestore integers are signed 64-bit",
        path,
      );
    }
    return value;
  }

  private encodeMessageValue(
    schema: DescMessage,
    value: unknown,
    rules: FieldRules,
    depth: number,
    path: string,
  ): unknown {
    if (UNSUPPORTED.has(schema.typeName)) {
      throw new CodecError(
        "UNSUPPORTED_TYPE",
        `${schema.typeName} has no Firestore representation`,
        path,
      );
    }
    const sub = value as AnyMessage;
    if (schema.typeName === TIMESTAMP) {
      return this.types.timestamp(
        (sub.seconds as bigint | undefined) ?? 0n,
        (sub.nanos as number | undefined) ?? 0,
      );
    }
    if (schema.typeName === DURATION) {
      const seconds = (sub.seconds as bigint | undefined) ?? 0n;
      const nanos = (sub.nanos as number | undefined) ?? 0;
      return seconds * 1_000_000n + BigInt(Math.trunc(nanos / 1000));
    }
    if (schema.typeName === LAT_LNG || rules.geoPoint) {
      const { latitude, longitude } = readLatLng(schema, sub, path);
      return this.types.geoPoint(latitude, longitude);
    }
    return this.encodeMessage(schema, sub, depth + 1, path);
  }

  // ---------------------------------------------------------------- decoding

  private decodeMessage(
    schema: DescMessage,
    document: FirestoreDocument,
    path: string,
  ): unknown {
    const message = create(schema) as AnyMessage;
    for (const field of schema.fields) {
      const rules = rulesFor(field);
      if (rules.skip) continue;
      const name = storedName(field, rules);
      if (!(name in document)) continue;
      const raw = document[name];
      if (raw === undefined || raw === null) continue;
      const fieldPath = path === "" ? name : `${path}.${name}`;

      if (field.fieldKind === "map") {
        message[field.localName] = Object.fromEntries(
          Object.entries(raw as Record<string, unknown>).map(([k, v]) => [
            k,
            this.decodeElement(
              field.scalar,
              field.enum,
              field.message,
              v,
              DEFAULT_RULES,
              `${fieldPath}.${k}`,
            ),
          ]),
        );
      } else if (field.fieldKind === "list") {
        message[field.localName] = (raw as unknown[]).map((item, i) =>
          this.decodeElement(
            field.scalar,
            field.enum,
            field.message,
            item,
            rules,
            `${fieldPath}[${i}]`,
          ),
        );
      } else {
        const decoded = this.decodeElement(
          field.scalar,
          field.enum,
          field.message,
          raw,
          rules,
          fieldPath,
        );
        // Leaving an implicit field at its default keeps a decoded message
        // equal to one that never had it set.
        if (!isExplicit(field) && isDefault(decoded)) continue;
        message[field.localName] = decoded;
      }
    }
    return message;
  }

  private decodeElement(
    scalar: ScalarType | undefined,
    enumDesc: DescEnum | undefined,
    messageDesc: DescMessage | undefined,
    raw: unknown,
    rules: FieldRules,
    path: string,
  ): unknown {
    if (messageDesc !== undefined) {
      return this.decodeMessageValue(messageDesc, raw, rules, path);
    }
    if (enumDesc !== undefined) {
      // An unknown name decodes to the zero value rather than throwing, so an
      // old reader survives a document written by a newer writer.
      const zero = enumDesc.values.find((v) => v.number === 0)?.number ?? 0;
      // An admin SDK configured with `useBigInt: true` hands back every
      // integer as a bigint, so a numerically-encoded enum arrives that way.
      if (typeof raw === "number" || typeof raw === "bigint") {
        const number = Number(raw);
        return enumDesc.values.some((v) => v.number === number) ? number : zero;
      }
      return enumDesc.values.find((v) => v.name === raw)?.number ?? zero;
    }
    switch (scalar) {
      case ScalarType.STRING:
      case ScalarType.BOOL:
        return raw;
      case ScalarType.DOUBLE:
      case ScalarType.FLOAT:
        return Number(raw);
      case ScalarType.INT32:
      case ScalarType.SINT32:
      case ScalarType.SFIXED32:
      case ScalarType.UINT32:
      case ScalarType.FIXED32:
        return Number(raw);
      case ScalarType.BYTES: {
        const bytes = this.types.readBlob(raw);
        if (bytes === undefined) {
          throw new CodecError("UNSUPPORTED_TYPE", "expected a blob", path);
        }
        return bytes;
      }
      case ScalarType.INT64:
      case ScalarType.SINT64:
      case ScalarType.SFIXED64:
        return BigInt(raw as string | number | bigint);
      case ScalarType.UINT64:
      case ScalarType.FIXED64:
        return rules.unsignedAsInteger
          ? BigInt(raw as string | number | bigint)
          : decodeUnsigned(raw, path);
      default:
        throw new CodecError(
          "UNSUPPORTED_TYPE",
          `no decoding for scalar type ${String(scalar)}`,
          path,
        );
    }
  }

  private decodeMessageValue(
    schema: DescMessage,
    raw: unknown,
    rules: FieldRules,
    path: string,
  ): unknown {
    if (UNSUPPORTED.has(schema.typeName)) {
      throw new CodecError(
        "UNSUPPORTED_TYPE",
        `${schema.typeName} has no Firestore representation`,
        path,
      );
    }
    if (schema.typeName === TIMESTAMP) {
      const ts = this.types.readTimestamp(raw);
      if (ts === undefined) {
        throw new CodecError("UNSUPPORTED_TYPE", "expected a timestamp", path);
      }
      const sub = create(schema) as AnyMessage;
      sub.seconds = ts.seconds;
      sub.nanos = ts.nanos;
      return sub;
    }
    if (schema.typeName === DURATION) {
      const micros = BigInt(raw as string | number | bigint);
      const sub = create(schema) as AnyMessage;
      sub.seconds = micros / 1_000_000n;
      sub.nanos = Number(micros % 1_000_000n) * 1000;
      return sub;
    }
    if (schema.typeName === LAT_LNG || rules.geoPoint) {
      const point = this.types.readGeoPoint(raw);
      if (point === undefined) {
        throw new CodecError("UNSUPPORTED_TYPE", "expected a geo point", path);
      }
      const sub = create(schema) as AnyMessage;
      for (const f of schema.fields) {
        if (f.name === "latitude") sub[f.localName] = point.latitude;
        if (f.name === "longitude") sub[f.localName] = point.longitude;
      }
      return sub;
    }
    return this.decodeMessage(schema, raw as FirestoreDocument, path);
  }

  // -------------------------------------------------------------- validation

  private validate(schema: DescMessage, seen: Set<string>, path: string): void {
    if (seen.has(schema.typeName)) return;
    seen.add(schema.typeName);
    for (const field of schema.fields) {
      const rules = rulesFor(field);
      if (rules.skip) continue;
      const fieldPath = `${path}.${field.name}`;
      if (field.fieldKind === "map" && field.mapKey !== ScalarType.STRING) {
        throw new CodecError(
          "UNSUPPORTED_MAP_KEY",
          "map keys must be strings; Firestore has no other key type",
          fieldPath,
        );
      }
      if (field.message !== undefined) {
        this.validateSub(field.message, seen, fieldPath);
      }
    }
  }

  private validateSub(
    schema: DescMessage,
    seen: Set<string>,
    path: string,
  ): void {
    if (UNSUPPORTED.has(schema.typeName)) {
      throw new CodecError(
        "UNSUPPORTED_TYPE",
        `${schema.typeName} has no Firestore representation`,
        path,
      );
    }
    if (
      schema.typeName === TIMESTAMP ||
      schema.typeName === DURATION ||
      schema.typeName === LAT_LNG
    ) {
      return;
    }
    this.validate(schema, seen, path);
  }
}

function readField(message: AnyMessage, field: DescField): unknown {
  if (field.oneof !== undefined) {
    const holder = message[field.oneof.localName] as
      | { case?: string; value?: unknown }
      | undefined;
    return holder?.case === field.localName ? holder.value : undefined;
  }
  return message[field.localName];
}

function readLatLng(
  schema: DescMessage,
  message: AnyMessage,
  path: string,
): { latitude: number; longitude: number } {
  let latitude: number | undefined;
  let longitude: number | undefined;
  for (const f of schema.fields) {
    if (f.name === "latitude") latitude = (message[f.localName] as number) ?? 0;
    if (f.name === "longitude") longitude = (message[f.localName] as number) ?? 0;
  }
  if (latitude === undefined || longitude === undefined) {
    throw new CodecError(
      "UNSUPPORTED_TYPE",
      "KIND_GEO_POINT requires double fields named latitude and longitude",
      path,
    );
  }
  if (
    Number.isNaN(latitude) ||
    Number.isNaN(longitude) ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180
  ) {
    throw new CodecError(
      "LATLNG_OUT_OF_RANGE",
      "latitude must be within [-90, 90] and longitude within [-180, 180], " +
        `got (${latitude}, ${longitude})`,
      path,
    );
  }
  return { latitude, longitude };
}

function decodeUnsigned(raw: unknown, path: string): bigint {
  if (typeof raw !== "string") {
    throw new CodecError(
      "UNSIGNED_MALFORMED",
      `expected a decimal string, got ${typeof raw}`,
      path,
    );
  }
  if (!CANONICAL_UNSIGNED.test(raw)) {
    throw new CodecError(
      "UNSIGNED_MALFORMED",
      `not a canonical unsigned decimal (no sign, no leading zeros): "${raw}"`,
      path,
    );
  }
  const value = BigInt(raw);
  if (value > MAX_UINT64) {
    throw new CodecError(
      "UNSIGNED_OUT_OF_RANGE",
      `${raw} exceeds the maximum unsigned 64-bit value`,
      path,
    );
  }
  return value;
}

function isDefault(value: unknown): boolean {
  if (value === undefined || value === null) return true;
  if (typeof value === "string") return value === "";
  if (typeof value === "boolean") return !value;
  if (typeof value === "number") return value === 0;
  if (typeof value === "bigint") return value === 0n;
  if (value instanceof Uint8Array) return value.length === 0;
  if (Array.isArray(value)) return value.length === 0;
  return false;
}
