/** Error codes shared with the conformance suite (`testdata/manifest.json`). */
export type CodecErrorCode =
  | "UNSIGNED_MALFORMED"
  | "UNSIGNED_OUT_OF_RANGE"
  | "UNSIGNED_NOT_REPRESENTABLE"
  | "LATLNG_OUT_OF_RANGE"
  | "NESTING_TOO_DEEP"
  | "UNSUPPORTED_MAP_KEY"
  | "UNSUPPORTED_TYPE"
  | "ENUM_VALUE_UNKNOWN";

/** Thrown for anything the encoding refuses to represent. */
export class CodecError extends Error {
  constructor(
    readonly code: CodecErrorCode,
    message: string,
    /** Dotted field path to the offending value, when there is one. */
    readonly path?: string,
  ) {
    super(path === undefined ? message : `${message} (at ${path})`);
    this.name = "CodecError";
  }
}
