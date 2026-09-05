import 'dart:typed_data';

/// Firestore has three value types protobuf cannot express as plain Dart.
/// Implement this to bind them to a particular SDK's classes — `Timestamp`,
/// `Blob`, and `GeoPoint` in `cloud_firestore`, for example. Everything else in
/// the encoding is a plain `String`, `int`, `double`, `bool`, `List`, or `Map`.
abstract class FirestoreTypes {
  Object timestamp(int seconds, int nanos);
  Object blob(Uint8List bytes);
  Object geoPoint(double latitude, double longitude);

  /// Return null when [value] is not of this type, so decoding can report a
  /// useful error rather than crashing on a cast.
  ({int seconds, int nanos})? readTimestamp(Object value);
  Uint8List? readBlob(Object value);
  ({double latitude, double longitude})? readGeoPoint(Object value);
}

class FsTimestamp {
  const FsTimestamp(this.seconds, this.nanos);
  final int seconds;
  final int nanos;

  @override
  bool operator ==(Object other) =>
      other is FsTimestamp && other.seconds == seconds && other.nanos == nanos;

  @override
  int get hashCode => Object.hash(seconds, nanos);

  @override
  String toString() => 'FsTimestamp($seconds, $nanos)';
}

class FsBlob {
  FsBlob(this.bytes);
  final Uint8List bytes;

  @override
  bool operator ==(Object other) {
    if (other is! FsBlob || other.bytes.length != bytes.length) return false;
    for (var i = 0; i < bytes.length; i++) {
      if (other.bytes[i] != bytes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(bytes);

  @override
  String toString() => 'FsBlob(${bytes.length} bytes)';
}

class FsGeoPoint {
  const FsGeoPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is FsGeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'FsGeoPoint($latitude, $longitude)';
}

/// Dependency-free default. Swap in an SDK-specific implementation to write
/// directly to Firestore.
class DefaultFirestoreTypes implements FirestoreTypes {
  const DefaultFirestoreTypes();

  @override
  Object timestamp(int seconds, int nanos) => FsTimestamp(seconds, nanos);

  @override
  Object blob(Uint8List bytes) => FsBlob(bytes);

  @override
  Object geoPoint(double latitude, double longitude) =>
      FsGeoPoint(latitude, longitude);

  @override
  ({int seconds, int nanos})? readTimestamp(Object value) => value is FsTimestamp
      ? (seconds: value.seconds, nanos: value.nanos)
      : null;

  @override
  Uint8List? readBlob(Object value) => value is FsBlob ? value.bytes : null;

  @override
  ({double latitude, double longitude})? readGeoPoint(Object value) =>
      value is FsGeoPoint
          ? (latitude: value.latitude, longitude: value.longitude)
          : null;
}
