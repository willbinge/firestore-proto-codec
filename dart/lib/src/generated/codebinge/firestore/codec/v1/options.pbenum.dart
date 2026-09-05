// This is a generated file - do not edit.
//
// Generated from codebinge/firestore/codec/v1/options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Kind extends $pb.ProtobufEnum {
  /// Infer from the proto type. The default for every field.
  static const Kind KIND_UNSPECIFIED =
      Kind._(0, _omitEnumNames ? '' : 'KIND_UNSPECIFIED');

  /// string -> DocumentReference. Requires the codec to hold a Firestore
  /// instance; the one place this codec is not dependency-free.
  static const Kind KIND_REFERENCE =
      Kind._(1, _omitEnumNames ? '' : 'KIND_REFERENCE');

  /// A project's own lat/lng message -> GeoPoint (§3.3). Not needed for
  /// google.type.LatLng, which is recognized automatically. The annotated
  /// message must have exactly two double fields named `latitude` and
  /// `longitude`.
  static const Kind KIND_GEO_POINT =
      Kind._(2, _omitEnumNames ? '' : 'KIND_GEO_POINT');

  /// uint64/fixed64 -> Integer rather than String, keeping the field ordered
  /// and queryable. Throws at encode time above 2^63-1 (§2.1).
  static const Kind KIND_UNSIGNED_AS_INTEGER =
      Kind._(3, _omitEnumNames ? '' : 'KIND_UNSIGNED_AS_INTEGER');

  static const $core.List<Kind> values = <Kind>[
    KIND_UNSPECIFIED,
    KIND_REFERENCE,
    KIND_GEO_POINT,
    KIND_UNSIGNED_AS_INTEGER,
  ];

  static final $core.List<Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Kind._(super.value, super.name);
}

class EnumEncoding extends $pb.ProtobufEnum {
  static const EnumEncoding ENUM_ENCODING_NAME =
      EnumEncoding._(0, _omitEnumNames ? '' : 'ENUM_ENCODING_NAME');
  static const EnumEncoding ENUM_ENCODING_NUMBER =
      EnumEncoding._(1, _omitEnumNames ? '' : 'ENUM_ENCODING_NUMBER');

  static const $core.List<EnumEncoding> values = <EnumEncoding>[
    ENUM_ENCODING_NAME,
    ENUM_ENCODING_NUMBER,
  ];

  static final $core.List<EnumEncoding?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static EnumEncoding? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EnumEncoding._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
