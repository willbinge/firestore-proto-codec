/// Error codes shared with the conformance suite (`testdata/manifest.json`).
enum CodecErrorCode {
  unsignedMalformed('UNSIGNED_MALFORMED'),
  unsignedOutOfRange('UNSIGNED_OUT_OF_RANGE'),
  unsignedNotRepresentable('UNSIGNED_NOT_REPRESENTABLE'),
  latLngOutOfRange('LATLNG_OUT_OF_RANGE'),
  nestingTooDeep('NESTING_TOO_DEEP'),
  unsupportedMapKey('UNSUPPORTED_MAP_KEY'),
  unsupportedType('UNSUPPORTED_TYPE');

  const CodecErrorCode(this.wireName);

  /// The name reported by the conformance suite.
  final String wireName;
}

/// Thrown for anything the encoding refuses to represent.
class CodecError implements Exception {
  CodecError(this.code, this.message, {this.path});

  final CodecErrorCode code;
  final String message;

  /// Dotted field path to the offending value, when there is one.
  final String? path;

  @override
  String toString() =>
      'CodecError(${code.wireName})${path == null ? '' : ' at $path'}: $message';
}
