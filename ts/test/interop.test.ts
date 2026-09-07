import { deepStrictEqual, match, ok, throws } from "node:assert/strict";
import { test } from "node:test";

import { create } from "@bufbuild/protobuf";

import { CodecError, FirestoreProtoCodec } from "../src/index.js";
import {
  CompositeSchema,
  InnerSchema,
  ScalarsSchema,
} from "./generated/testdata_pb.js";

const codec = new FirestoreProtoCodec();

/**
 * Shaped the way `protoc-gen-js` generates a message: the fields live in a
 * private array behind getters, and nothing carries `$typeName`. Reading it
 * with protobuf-es field names yields undefined every time.
 */
class LegacyScalars {
  private readonly array: unknown[] = ["hello", true];
  getStringField(): string {
    return this.array[0] as string;
  }
  getBoolField(): boolean {
    return this.array[1] as boolean;
  }
}

class LegacyInner {
  private readonly array: unknown[] = ["inner"];
  getValue(): string {
    return this.array[0] as string;
  }
}

const refused = (detail: RegExp) => (error: unknown) => {
  ok(error instanceof CodecError, `expected CodecError, got ${String(error)}`);
  deepStrictEqual(error.code, "UNSUPPORTED_TYPE");
  match(error.message, detail);
  return true;
};

test("a google-protobuf message is refused, not silently emptied", () => {
  throws(
    () => codec.encode(ScalarsSchema, new LegacyScalars() as never),
    refused(/expected a protobuf-es \S+\.Scalars, got a LegacyScalars/),
  );
});

test("a plain object is refused", () => {
  throws(
    () => codec.encode(ScalarsSchema, { stringField: "hello" } as never),
    refused(/got a plain object/),
  );
});

test("a message of the wrong type reports the type it got", () => {
  throws(
    () => codec.encode(ScalarsSchema, create(InnerSchema) as never),
    refused(/got codebinge\.firestore\.codec\.testdata\.v1\.Inner/),
  );
});

test("a foreign nested message is refused at its field path", () => {
  const composite = create(CompositeSchema);
  composite.single = new LegacyInner() as never;
  throws(
    () => codec.encode(CompositeSchema, composite),
    refused(/\(at single\)/),
  );
});

test("a foreign repeated element is refused at its index", () => {
  const composite = create(CompositeSchema);
  composite.messages = [new LegacyInner() as never];
  throws(
    () => codec.encode(CompositeSchema, composite),
    refused(/\(at messages\[0\]\)/),
  );
});
