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
 * Models `protoc-gen-js`'s *field access*: the values live in a private array
 * behind getters, and nothing carries `$typeName`, so reading it with
 * protobuf-es field names yields undefined every time.
 *
 * It does not model jspb's *identity surface* -- this class has a real `.name`
 * and no `serializeBinary`. [legacyMessage] covers that; use it for anything
 * asserting on how the value is described.
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

/**
 * The identity surface of real `protoc-gen-js` output: an anonymous class, so
 * `constructor.name` is `""`, carrying the two methods every jspb message has.
 */
const legacyMessage = (): object =>
  new (class {
    private readonly array: unknown[] = ["hello"];
    serializeBinary(): Uint8Array {
      return new Uint8Array();
    }
    toObject(): { stringField: unknown } {
      return { stringField: this.array[0] };
    }
  })();

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

test("a real protoc-gen-js message is named, and so is the fix", () => {
  ok(legacyMessage().constructor.name === "", "the double must be anonymous");
  throws(
    () => codec.encode(ScalarsSchema, legacyMessage() as never),
    refused(/got a google-protobuf message; convert it first .*README/),
  );
});

test("an anonymous class does not degrade to a dangling \"got a \"", () => {
  throws(
    () => codec.encode(ScalarsSchema, new (class {})() as never),
    refused(/got a plain object/),
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
