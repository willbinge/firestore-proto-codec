// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

/** Thrown for anything the encoding refuses to represent. */
public final class CodecError extends RuntimeException {

  private final CodecErrorCode code;
  private final String path;

  public CodecError(CodecErrorCode code, String message, String path) {
    super(path == null ? message : message + " (at " + path + ")");
    this.code = code;
    this.path = path;
  }

  public CodecErrorCode code() {
    return code;
  }

  /** Dotted field path to the offending value, or null. */
  public String path() {
    return path;
  }
}
