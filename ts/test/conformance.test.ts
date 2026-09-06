import { readFileSync } from "node:fs";
import { deepStrictEqual, ok, throws } from "node:assert/strict";
import { test } from "node:test";

import { fromJson, toBinary } from "@bufbuild/protobuf";
import type { DescMessage, JsonValue } from "@bufbuild/protobuf";

import { CodecError, FirestoreProtoCodec } from "../src/index.js";
import {
  AnyFieldSchema,
  IntKeyMapSchema,
  StructFieldSchema,
} from "./generated/invalid_pb.js";
import {
  CompositeSchema,
  DoublesSchema,
  EnumsSchema,
  InnerSchema,
  OptionsSchema,
  PresenceSchema,
  RecursiveSchema,
  ScalarsSchema,
  UnsignedSchema,
  WellKnownSchema,
} from "./generated/testdata_pb.js";
import { fromRestDocument, toRestDocument } from "./rest-json.js";

const schemas: DescMessage[] = [
  ScalarsSchema,
  DoublesSchema,
  EnumsSchema,
  InnerSchema,
  PresenceSchema,
  UnsignedSchema,
  WellKnownSchema,
  CompositeSchema,
  OptionsSchema,
  RecursiveSchema,
  IntKeyMapSchema,
  AnyFieldSchema,
  StructFieldSchema,
];
const byName = new Map(schemas.map((s) => [s.typeName, s]));

const ROOT = new URL("../../testdata/", import.meta.url);
const readJson = (relative: string): Record<string, unknown> =>
  JSON.parse(readFileSync(new URL(relative, ROOT), "utf8")) as Record<
    string,
    unknown
  >;

interface Case {
  name: string;
  message: string;
  direction: "roundtrip" | "encode" | "decode" | "schema";
  expect_error?: string;
  message_file?: string;
  document_file?: string;
}

const manifest = readJson("manifest.json") as unknown as { cases: Case[] };
const codec = new FirestoreProtoCodec();

const buildMessage = (schema: DescMessage, relative: string): unknown =>
  fromJson(schema, readJson(relative) as JsonValue);

const hasCode = (code: string) => (error: unknown) => {
  ok(error instanceof CodecError, `expected CodecError, got ${String(error)}`);
  deepStrictEqual(error.code, code);
  return true;
};

for (const c of manifest.cases) {
  test(`${c.name} (${c.direction})`, () => {
    const schema = byName.get(c.message);
    ok(schema, `no schema registered for ${c.message}`);

    if (c.direction === "schema") {
      throws(() => codec.validateSchema(schema), hasCode(c.expect_error!));
      return;
    }

    if (c.direction === "encode" || c.direction === "roundtrip") {
      const message = buildMessage(schema, c.message_file!);
      if (c.expect_error !== undefined) {
        throws(() => codec.encode(schema, message), hasCode(c.expect_error));
      } else {
        deepStrictEqual(
          toRestDocument(codec.encode(schema, message)),
          readJson(c.document_file!),
        );
      }
    }

    if (c.direction === "decode" || c.direction === "roundtrip") {
      const document = fromRestDocument(readJson(c.document_file!));
      if (c.expect_error !== undefined) {
        throws(() => codec.decode(schema, document), hasCode(c.expect_error));
      } else {
        // Compared as serialized bytes: the wire format omits implicit
        // defaults and encodes NaN deterministically, so it normalizes exactly
        // the way the spec means.
        const actual = codec.decode(schema, document);
        const expected = buildMessage(schema, c.message_file!);
        deepStrictEqual(
          Buffer.from(toBinary(schema, actual as never)),
          Buffer.from(toBinary(schema, expected as never)),
        );
      }
    }
  });
}
