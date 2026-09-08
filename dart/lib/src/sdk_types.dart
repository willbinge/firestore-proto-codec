import 'dart:typed_data';

import 'values.dart';

/// [FirestoreTypes] for an SDK whose classes this package cannot import.
///
/// ```dart
/// final codec = FirestoreProtoCodec(
///   types: SdkFirestoreTypes(
///     timestamp: Timestamp.new,
///     blob: Blob.new,
///     geoPoint: GeoPoint.new,
///   ),
/// );
/// ```
///
/// Three constructor tear-offs in place of the twenty-five line adapter the
/// README used to ask every consumer to copy. The TypeScript package ships its
/// adapter outright, under a subpath that pulls the SDK in only for consumers
/// who import it. Pub has no equivalent — no optional dependencies, no
/// conditional exports — and `cloud_firestore_platform_interface`, where
/// `Timestamp`, `Blob` and `GeoPoint` live, depends on the Flutter SDK. Naming
/// those classes here would make this package Flutter-only, so it takes their
/// constructors instead and stays pure Dart.
///
/// The reads are duck-typed for the same reason, not the TypeScript one: there
/// is no type here to write `is` against. It costs less than it looks like it
/// should, because the codec never uses these to discriminate a type — it calls
/// them only at a position the schema has already declared a `Timestamp`,
/// `bytes` or `LatLng`, so a loose check cannot misclassify anything. A value of
/// the wrong shape still returns null, and the codec reports the field path.
///
/// Any SDK with the same shape works — `cloud_firestore` on Flutter, or a
/// server-side Dart client — provided its timestamp exposes `seconds` and
/// `nanoseconds`, its blob `bytes`, and its geo point `latitude` and
/// `longitude`.
class SdkFirestoreTypes implements FirestoreTypes {
  SdkFirestoreTypes({
    required Object Function(int seconds, int nanos) timestamp,
    required Object Function(Uint8List bytes) blob,
    required Object Function(double latitude, double longitude) geoPoint,
  })  : _timestamp = timestamp,
        _blob = blob,
        _geoPoint = geoPoint;

  final Object Function(int, int) _timestamp;
  final Object Function(Uint8List) _blob;
  final Object Function(double, double) _geoPoint;

  @override
  Object timestamp(int seconds, int nanos) => _timestamp(seconds, nanos);

  @override
  Object blob(Uint8List bytes) => _blob(bytes);

  @override
  Object geoPoint(double latitude, double longitude) =>
      _geoPoint(latitude, longitude);

  @override
  ({int seconds, int nanos})? readTimestamp(Object value) {
    final seconds = _read(value, (dynamic v) => v.seconds);
    final nanos = _read(value, (dynamic v) => v.nanoseconds);
    return seconds is int && nanos is int
        ? (seconds: seconds, nanos: nanos)
        : null;
  }

  @override
  Uint8List? readBlob(Object value) {
    // An SDK that hands bytes back unwrapped needs no property read at all.
    if (value is Uint8List) return value;
    final bytes = _read(value, (dynamic v) => v.bytes);
    return bytes is Uint8List ? bytes : null;
  }

  @override
  ({double latitude, double longitude})? readGeoPoint(Object value) {
    final latitude = _read(value, (dynamic v) => v.latitude);
    final longitude = _read(value, (dynamic v) => v.longitude);
    return latitude is double && longitude is double
        ? (latitude: latitude, longitude: longitude)
        : null;
  }
}

/// Reads one property off [value], or returns null when it has no such member.
///
/// A [NoSuchMethodError] raised *inside* the getter is swallowed with it. That
/// is the price of having no type to test against, and it is bounded: these
/// getters are field reads on SDK value classes.
Object? _read(Object value, Object? Function(dynamic) get) {
  try {
    return get(value);
  } on NoSuchMethodError {
    return null;
  }
}
