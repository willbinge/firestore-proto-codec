import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';

import 'errors.dart';
import 'schema.dart';
import 'values.dart';

/// Firestore's limit on the depth of fields in a map or array.
const int maxNestingDepth = 20;

const _timestampType = 'google.protobuf.Timestamp';
const _durationType = 'google.protobuf.Duration';
const _latLngType = 'google.type.LatLng';

const _unsupportedTypes = {
  'google.protobuf.Any',
  'google.protobuf.Struct',
  'google.protobuf.Value',
  'google.protobuf.ListValue',
  'google.protobuf.FieldMask',
};

final _canonicalUnsigned = RegExp(r'^(0|[1-9][0-9]*)$');
final BigInt _maxUint64 = (BigInt.one << 64) - BigInt.one;
final BigInt _maxInt64 = (BigInt.one << 63) - BigInt.one;

/// Encodes a protobuf message as a Firestore value, and decodes it back.
///
/// See `docs/encoding.md` for the rules. The output is a map of Firestore-native
/// values: plain Dart types, plus whatever [FirestoreTypes] produces for
/// timestamps, blobs, and geo points.
class FirestoreProtoCodec {
  FirestoreProtoCodec({SchemaRegistry? registry, FirestoreTypes? types})
      : registry = registry ?? SchemaRegistry(),
        types = types ?? const DefaultFirestoreTypes();

  final SchemaRegistry registry;
  final FirestoreTypes types;

  Map<String, Object?> encode(GeneratedMessage message) =>
      _encodeMessage(message, 1, '');

  /// Decodes [document] into [into], which is mutated and returned.
  T decode<T extends GeneratedMessage>(Map<String, Object?> document, T into) {
    _decodeInto(into, document, '');
    return into;
  }

  /// Throws if [prototype]'s type, or any type it reaches, cannot be encoded.
  /// Call once at startup rather than discovering it on the first write.
  void validateSchema(GeneratedMessage prototype) =>
      _validate(prototype, <String>{}, prototype.info_.qualifiedMessageName);

  // --------------------------------------------------------------- encoding

  Map<String, Object?> _encodeMessage(
      GeneratedMessage m, int depth, String path) {
    if (depth > maxNestingDepth) {
      throw CodecError(
        CodecErrorCode.nestingTooDeep,
        'nesting exceeds Firestore\'s limit of $maxNestingDepth levels',
        path: path,
      );
    }
    final info = m.info_;
    final out = <String, Object?>{};
    for (final fi in info.byIndex) {
      final rules = registry.rulesFor(info.qualifiedMessageName, fi.tagNumber);
      if (rules.skip) continue;
      final name = _storedName(info, fi, rules);
      final fieldPath = path.isEmpty ? name : '$path.$name';
      final value = m.getField(fi.tagNumber);

      if (fi is MapFieldInfo) {
        final map = value as Map<Object?, Object?>;
        if (map.isEmpty) continue;
        out[name] = _encodeMap(fi, map, depth, fieldPath);
      } else if (fi.isRepeated) {
        final list = value as List<Object?>;
        if (list.isEmpty) continue;
        final base = _baseType(fi.type);
        out[name] = <Object?>[
          for (var i = 0; i < list.length; i++)
            _encodeSingle(
                base, list[i]!, rules, fi.subBuilder, depth, '$fieldPath[$i]'),
        ];
      } else if (_hasPresence(info, fi)) {
        if (!m.hasField(fi.tagNumber)) continue;
        out[name] = _encodeSingle(_baseType(fi.type), value as Object, rules,
            fi.subBuilder, depth, fieldPath);
      } else {
        if (rules.omitWhenDefault && _isDefault(value)) continue;
        out[name] = _encodeSingle(_baseType(fi.type), value as Object, rules,
            fi.subBuilder, depth, fieldPath);
      }
    }
    return out;
  }

  Map<String, Object?> _encodeMap(
      MapFieldInfo<dynamic, dynamic> fi, Map<Object?, Object?> map, int depth, String path) {
    final valueInfo = fi.mapEntryBuilderInfo.fieldInfo[2];
    final base = _baseType(fi.valueFieldType);
    return {
      for (final entry in map.entries)
        entry.key as String: _encodeSingle(base, entry.value!,
            FieldRules.defaults, valueInfo?.subBuilder, depth, '$path.${entry.key}'),
    };
  }

  Object? _encodeSingle(int base, Object value, FieldRules rules,
      CreateBuilderFunc? subBuilder, int depth, String path) {
    if (_is(base, PbFieldType.STRING_BIT)) return value as String;
    if (_is(base, PbFieldType.BOOL_BIT)) return value as bool;
    if (_is(base, PbFieldType.BYTES_BIT)) {
      return types.blob(Uint8List.fromList(value as List<int>));
    }
    if (_is(base, PbFieldType.DOUBLE_BIT) || _is(base, PbFieldType.FLOAT_BIT)) {
      return value as double;
    }
    if (_is(base, PbFieldType.ENUM_BIT)) {
      final e = value as ProtobufEnum;
      return rules.enumAsNumber ? e.value : e.name;
    }
    if (_is(base, PbFieldType.INT32_BIT) ||
        _is(base, PbFieldType.SINT32_BIT) ||
        _is(base, PbFieldType.SFIXED32_BIT) ||
        _is(base, PbFieldType.UINT32_BIT) ||
        _is(base, PbFieldType.FIXED32_BIT)) {
      return value as int;
    }
    if (_is(base, PbFieldType.INT64_BIT) ||
        _is(base, PbFieldType.SINT64_BIT) ||
        _is(base, PbFieldType.SFIXED64_BIT)) {
      return (value as Int64).toInt();
    }
    if (_is(base, PbFieldType.UINT64_BIT) || _is(base, PbFieldType.FIXED64_BIT)) {
      return _encodeUnsigned(value as Int64, rules, path);
    }
    if (_is(base, PbFieldType.MESSAGE_BIT) || _is(base, PbFieldType.GROUP_BIT)) {
      return _encodeMessageValue(value as GeneratedMessage, rules, depth, path);
    }
    throw CodecError(CodecErrorCode.unsupportedType,
        'no encoding for field type $base', path: path);
  }

  Object _encodeUnsigned(Int64 value, FieldRules rules, String path) {
    final text = value.toStringUnsigned();
    if (!rules.unsignedAsInteger) return text;
    if (BigInt.parse(text) > _maxInt64) {
      throw CodecError(
        CodecErrorCode.unsignedNotRepresentable,
        'KIND_UNSIGNED_AS_INTEGER cannot represent $text; '
        'Firestore integers are signed 64-bit',
        path: path,
      );
    }
    return value.toInt();
  }

  Object _encodeMessageValue(
      GeneratedMessage sub, FieldRules rules, int depth, String path) {
    final qualified = sub.info_.qualifiedMessageName;
    if (_unsupportedTypes.contains(qualified)) {
      throw CodecError(CodecErrorCode.unsupportedType,
          '$qualified has no Firestore representation', path: path);
    }
    if (qualified == _timestampType) {
      return types.timestamp(
          (sub.getField(1) as Int64).toInt(), sub.getField(2) as int);
    }
    if (qualified == _durationType) {
      final seconds = (sub.getField(1) as Int64).toInt();
      final nanos = sub.getField(2) as int;
      return seconds * 1000000 + nanos ~/ 1000;
    }
    if (qualified == _latLngType || rules.geoPoint) {
      final point = _readLatLng(sub, path);
      return types.geoPoint(point.latitude, point.longitude);
    }
    return _encodeMessage(sub, depth + 1, path);
  }

  ({double latitude, double longitude}) _readLatLng(
      GeneratedMessage m, String path) {
    double? lat, lng;
    for (final fi in m.info_.byIndex) {
      if (fi.protoName == 'latitude') lat = m.getField(fi.tagNumber) as double;
      if (fi.protoName == 'longitude') lng = m.getField(fi.tagNumber) as double;
    }
    if (lat == null || lng == null) {
      throw CodecError(
        CodecErrorCode.unsupportedType,
        'KIND_GEO_POINT requires double fields named latitude and longitude',
        path: path,
      );
    }
    if (lat.isNaN || lng.isNaN || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw CodecError(
        CodecErrorCode.latLngOutOfRange,
        'latitude must be within [-90, 90] and longitude within [-180, 180], '
        'got ($lat, $lng)',
        path: path,
      );
    }
    return (latitude: lat, longitude: lng);
  }

  // --------------------------------------------------------------- decoding

  void _decodeInto(
      GeneratedMessage m, Map<String, Object?> document, String path) {
    final info = m.info_;
    for (final fi in info.byIndex) {
      final rules = registry.rulesFor(info.qualifiedMessageName, fi.tagNumber);
      if (rules.skip) continue;
      final name = _storedName(info, fi, rules);
      if (!document.containsKey(name)) continue;
      final raw = document[name];
      if (raw == null) continue;
      final fieldPath = path.isEmpty ? name : '$path.$name';

      if (fi is MapFieldInfo) {
        final valueInfo = fi.mapEntryBuilderInfo.fieldInfo[2];
        final base = _baseType(fi.valueFieldType);
        final target = m.getField(fi.tagNumber) as Map<Object?, Object?>;
        for (final entry in (raw as Map<Object?, Object?>).entries) {
          target[entry.key as String] = _decodeSingle(base, entry.value!,
              FieldRules.defaults, valueInfo, '$fieldPath.${entry.key}');
        }
      } else if (fi.isRepeated) {
        final base = _baseType(fi.type);
        final target = m.getField(fi.tagNumber) as List<Object?>;
        final items = raw as List<Object?>;
        for (var i = 0; i < items.length; i++) {
          target.add(
              _decodeSingle(base, items[i]!, rules, fi, '$fieldPath[$i]'));
        }
      } else {
        final value =
            _decodeSingle(_baseType(fi.type), raw, rules, fi, fieldPath);
        if (!_hasPresence(info, fi) && _isDefault(value)) continue;
        m.setField(fi.tagNumber, value);
      }
    }
  }

  Object _decodeSingle(
      int base, Object raw, FieldRules rules, FieldInfo<dynamic>? fi, String path) {
    if (_is(base, PbFieldType.STRING_BIT)) return raw as String;
    if (_is(base, PbFieldType.BOOL_BIT)) return raw as bool;
    if (_is(base, PbFieldType.BYTES_BIT)) {
      final bytes = types.readBlob(raw);
      if (bytes == null) {
        throw CodecError(CodecErrorCode.unsupportedType,
            'expected a blob, got ${raw.runtimeType}', path: path);
      }
      return bytes;
    }
    if (_is(base, PbFieldType.DOUBLE_BIT) || _is(base, PbFieldType.FLOAT_BIT)) {
      return (raw as num).toDouble();
    }
    if (_is(base, PbFieldType.ENUM_BIT)) return _decodeEnum(raw, fi, path);
    if (_is(base, PbFieldType.INT32_BIT) ||
        _is(base, PbFieldType.SINT32_BIT) ||
        _is(base, PbFieldType.SFIXED32_BIT) ||
        _is(base, PbFieldType.UINT32_BIT) ||
        _is(base, PbFieldType.FIXED32_BIT)) {
      return raw as int;
    }
    if (_is(base, PbFieldType.INT64_BIT) ||
        _is(base, PbFieldType.SINT64_BIT) ||
        _is(base, PbFieldType.SFIXED64_BIT)) {
      return Int64(raw as int);
    }
    if (_is(base, PbFieldType.UINT64_BIT) || _is(base, PbFieldType.FIXED64_BIT)) {
      if (rules.unsignedAsInteger) return Int64(raw as int);
      return _decodeUnsigned(raw, path);
    }
    if (_is(base, PbFieldType.MESSAGE_BIT) || _is(base, PbFieldType.GROUP_BIT)) {
      return _decodeMessageValue(raw, rules, fi, path);
    }
    throw CodecError(CodecErrorCode.unsupportedType,
        'no decoding for field type $base', path: path);
  }

  /// An unknown name decodes to the zero value rather than throwing, so an old
  /// reader survives a document written by a newer writer.
  Object _decodeEnum(Object raw, FieldInfo<dynamic>? fi, String path) {
    final values = fi?.enumValues;
    if (values == null || values.isEmpty) {
      throw CodecError(CodecErrorCode.unsupportedType,
          'enum field has no registered values', path: path);
    }
    // Iterated by hand rather than with firstWhere: enumValues is statically
    // List<ProtobufEnum> but is a List<Status> at runtime, so an orElse
    // returning ProtobufEnum fails the runtime subtype check.
    ProtobufEnum? zero;
    for (final v in values) {
      if (v.value == 0) zero ??= v;
      final matches = raw is int ? v.value == raw : v.name == raw;
      if (matches) return v;
    }
    return zero ?? values.first;
  }

  Int64 _decodeUnsigned(Object raw, String path) {
    if (raw is! String) {
      throw CodecError(CodecErrorCode.unsignedMalformed,
          'expected a decimal string, got ${raw.runtimeType}', path: path);
    }
    if (!_canonicalUnsigned.hasMatch(raw)) {
      throw CodecError(
        CodecErrorCode.unsignedMalformed,
        'not a canonical unsigned decimal (no sign, no leading zeros): "$raw"',
        path: path,
      );
    }
    final value = BigInt.parse(raw);
    if (value > _maxUint64) {
      throw CodecError(CodecErrorCode.unsignedOutOfRange,
          '$raw exceeds the maximum unsigned 64-bit value', path: path);
    }
    // Reinterpret as two's complement: Int64 is signed, so anything at or above
    // 2^63 is stored negative and only reads back correctly as unsigned.
    return Int64(value.toSigned(64).toInt());
  }

  Object _decodeMessageValue(
      Object raw, FieldRules rules, FieldInfo<dynamic>? fi, String path) {
    final create = fi?.subBuilder;
    if (create == null) {
      throw CodecError(CodecErrorCode.unsupportedType,
          'message field has no builder', path: path);
    }
    final sub = create();
    final qualified = sub.info_.qualifiedMessageName;
    if (_unsupportedTypes.contains(qualified)) {
      throw CodecError(CodecErrorCode.unsupportedType,
          '$qualified has no Firestore representation', path: path);
    }
    if (qualified == _timestampType) {
      final ts = types.readTimestamp(raw);
      if (ts == null) {
        throw CodecError(CodecErrorCode.unsupportedType,
            'expected a timestamp, got ${raw.runtimeType}', path: path);
      }
      sub.setField(1, Int64(ts.seconds));
      sub.setField(2, ts.nanos);
      return sub;
    }
    if (qualified == _durationType) {
      final micros = raw as int;
      // remainder(), not %: Dart's % is Euclidean and never negative, which
      // would turn -1.5s (seconds -1, nanos -500000000) into seconds -1,
      // nanos +500000000, i.e. -0.5s. Protobuf keeps both parts the same sign.
      sub.setField(1, Int64(micros ~/ 1000000));
      sub.setField(2, micros.remainder(1000000) * 1000);
      return sub;
    }
    if (qualified == _latLngType || rules.geoPoint) {
      final point = types.readGeoPoint(raw);
      if (point == null) {
        throw CodecError(CodecErrorCode.unsupportedType,
            'expected a geo point, got ${raw.runtimeType}', path: path);
      }
      for (final f in sub.info_.byIndex) {
        if (f.protoName == 'latitude') sub.setField(f.tagNumber, point.latitude);
        if (f.protoName == 'longitude') {
          sub.setField(f.tagNumber, point.longitude);
        }
      }
      return sub;
    }
    _decodeInto(sub, raw as Map<String, Object?>, path);
    return sub;
  }

  // ------------------------------------------------------------- validation

  void _validate(GeneratedMessage m, Set<String> seen, String path) {
    final info = m.info_;
    if (!seen.add(info.qualifiedMessageName)) return;
    for (final fi in info.byIndex) {
      final rules = registry.rulesFor(info.qualifiedMessageName, fi.tagNumber);
      if (rules.skip) continue;
      final fieldPath = '$path.${fi.protoName}';
      if (fi is MapFieldInfo) {
        if (!_is(_baseType(fi.keyFieldType), PbFieldType.STRING_BIT)) {
          throw CodecError(
            CodecErrorCode.unsupportedMapKey,
            'map keys must be strings; Firestore has no other key type',
            path: fieldPath,
          );
        }
        final valueInfo = fi.mapEntryBuilderInfo.fieldInfo[2];
        _validateSub(valueInfo?.subBuilder, seen, fieldPath);
      } else if (fi.isGroupOrMessage) {
        _validateSub(fi.subBuilder, seen, fieldPath);
      }
    }
  }

  void _validateSub(CreateBuilderFunc? create, Set<String> seen, String path) {
    if (create == null) return;
    final sub = create();
    final qualified = sub.info_.qualifiedMessageName;
    if (_unsupportedTypes.contains(qualified)) {
      throw CodecError(CodecErrorCode.unsupportedType,
          '$qualified has no Firestore representation', path: path);
    }
    if (qualified == _timestampType ||
        qualified == _durationType ||
        qualified == _latLngType) {
      return;
    }
    _validate(sub, seen, path);
  }

  // ------------------------------------------------------------------ utils

  String _storedName(BuilderInfo info, FieldInfo<dynamic> fi, FieldRules rules) {
    final name = rules.name ?? fi.protoName;
    if (name.isEmpty) {
      throw StateError(
        'field ${fi.tagNumber} of ${info.qualifiedMessageName} has no name. '
        'This build was compiled with -Dprotobuf.omit_field_names=true, which '
        'strips the names this encoding is defined in terms of.',
      );
    }
    return name;
  }

  bool _hasPresence(BuilderInfo info, FieldInfo<dynamic> fi) =>
      fi.isGroupOrMessage ||
      info.oneofs.containsKey(fi.tagNumber) ||
      registry.hasExplicitPresence(info.qualifiedMessageName, fi.tagNumber);

  bool _isDefault(Object? v) {
    if (v == null) return true;
    if (v is String) return v.isEmpty;
    if (v is bool) return !v;
    if (v is Int64) return v == Int64.ZERO;
    if (v is int) return v == 0;
    if (v is double) return v == 0.0;
    if (v is ProtobufEnum) return v.value == 0;
    if (v is List) return v.isEmpty;
    return false;
  }
}

int _baseType(int type) =>
    type &
    ~(PbFieldType.REPEATED_BIT |
        PbFieldType.PACKED_BIT |
        PbFieldType.REQUIRED_BIT);

bool _is(int type, int bit) => (type & bit) != 0;
