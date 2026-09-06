// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

/** Error codes shared with the conformance suite ({@code testdata/manifest.json}). */
public enum CodecErrorCode {
  UNSIGNED_MALFORMED,
  UNSIGNED_OUT_OF_RANGE,
  UNSIGNED_NOT_REPRESENTABLE,
  LATLNG_OUT_OF_RANGE,
  NESTING_TOO_DEEP,
  UNSUPPORTED_MAP_KEY,
  UNSUPPORTED_TYPE;

  /** The name reported by the conformance suite. */
  public String wireName() {
    return name();
  }
}
