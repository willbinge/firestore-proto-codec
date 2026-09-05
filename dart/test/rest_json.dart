import 'dart:convert';
import 'dart:typed_data';

import 'package:firestore_proto_codec/firestore_proto_codec.dart';

/// Converts between the codec's native output and Firestore REST `Value` JSON,
/// which is how the conformance vectors are written down. The REST form names
/// the Firestore type explicitly, which plain JSON cannot do — it carries an
/// integer as a string and a blob as base64 purely as transport.
Object toRestValue(Object? value) {
  if (value is String) return {'stringValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': _restDouble(value)};
  if (value is FsBlob) return {'bytesValue': base64Encode(value.bytes)};
  if (value is FsTimestamp) return {'timestampValue': _toRfc3339(value)};
  if (value is FsGeoPoint) {
    return {
      'geoPointValue': {
        'latitude': value.latitude,
        'longitude': value.longitude,
      }
    };
  }
  if (value is List) {
    return {
      'arrayValue': {'values': [for (final v in value) toRestValue(v)]}
    };
  }
  if (value is Map) {
    return {
      'mapValue': {
        'fields': {
          for (final e in value.entries)
            e.key as String: toRestValue(e.value as Object?),
        }
      }
    };
  }
  throw ArgumentError('no REST encoding for ${value.runtimeType}');
}

Map<String, Object?> toRestDocument(Map<String, Object?> fields) => {
      for (final e in fields.entries) e.key: toRestValue(e.value),
    };

Object fromRestValue(Object? value) {
  final v = value! as Map<String, Object?>;
  if (v.containsKey('stringValue')) return v['stringValue']! as String;
  if (v.containsKey('booleanValue')) return v['booleanValue']! as bool;
  if (v.containsKey('integerValue')) {
    return int.parse(v['integerValue']! as String);
  }
  if (v.containsKey('doubleValue')) {
    final d = v['doubleValue'];
    return d is String ? _parseDouble(d) : (d! as num).toDouble();
  }
  if (v.containsKey('bytesValue')) {
    return FsBlob(Uint8List.fromList(base64Decode(v['bytesValue']! as String)));
  }
  if (v.containsKey('timestampValue')) {
    return _fromRfc3339(v['timestampValue']! as String);
  }
  if (v.containsKey('geoPointValue')) {
    final g = v['geoPointValue']! as Map<String, Object?>;
    return FsGeoPoint(
      (g['latitude']! as num).toDouble(),
      (g['longitude']! as num).toDouble(),
    );
  }
  if (v.containsKey('arrayValue')) {
    final a = v['arrayValue']! as Map<String, Object?>;
    final values = (a['values'] as List<Object?>?) ?? const <Object?>[];
    return [for (final e in values) fromRestValue(e)];
  }
  if (v.containsKey('mapValue')) {
    final m = v['mapValue']! as Map<String, Object?>;
    final fields = (m['fields'] as Map<String, Object?>?) ?? const {};
    return {for (final e in fields.entries) e.key: fromRestValue(e.value)};
  }
  throw ArgumentError('unrecognized REST value: $v');
}

Map<String, Object?> fromRestDocument(Map<String, Object?> document) => {
      for (final e in document.entries) e.key: fromRestValue(e.value),
    };

Object _restDouble(double d) {
  if (d.isNaN) return 'NaN';
  if (d == double.infinity) return 'Infinity';
  if (d == double.negativeInfinity) return '-Infinity';
  return d;
}

double _parseDouble(String s) => switch (s) {
      'NaN' => double.nan,
      'Infinity' => double.infinity,
      '-Infinity' => double.negativeInfinity,
      _ => double.parse(s),
    };

String _toRfc3339(FsTimestamp ts) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ts.seconds * 1000, isUtc: true);
  final base = '${_pad(dt.year, 4)}-${_pad(dt.month, 2)}-${_pad(dt.day, 2)}'
      'T${_pad(dt.hour, 2)}:${_pad(dt.minute, 2)}:${_pad(dt.second, 2)}';
  if (ts.nanos == 0) return '${base}Z';
  return '$base.${_pad(ts.nanos, 9)}Z';
}

/// `DateTime.parse` truncates at microseconds, so the fractional part is taken
/// apart by hand: these vectors deliberately carry nanosecond precision.
FsTimestamp _fromRfc3339(String s) {
  final dot = s.indexOf('.');
  if (dot < 0) {
    final dt = DateTime.parse(s);
    return FsTimestamp(dt.millisecondsSinceEpoch ~/ 1000, 0);
  }
  final end = s.indexOf(RegExp('[Z+-]', ), dot);
  final digits = s.substring(dot + 1, end == -1 ? s.length : end);
  final nanos = int.parse(digits.padRight(9, '0').substring(0, 9));
  final dt = DateTime.parse('${s.substring(0, dot)}Z');
  return FsTimestamp(dt.millisecondsSinceEpoch ~/ 1000, nanos);
}

String _pad(int v, int width) => v.toString().padLeft(width, '0');
