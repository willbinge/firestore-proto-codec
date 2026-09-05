// This is a generated file - do not edit.
//
// Generated from invalid.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $0;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Non-string map keys are rejected rather than stringified (§5).
class IntKeyMap extends $pb.GeneratedMessage {
  factory IntKeyMap({
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? bad,
  }) {
    final result = create();
    if (bad != null) result.bad.addEntries(bad);
    return result;
  }

  IntKeyMap._();

  factory IntKeyMap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IntKeyMap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IntKeyMap',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..m<$core.int, $core.String>(1, _omitFieldNames ? '' : 'bad',
        entryClassName: 'IntKeyMap.BadEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName:
            const $pb.PackageName('codebinge.firestore.codec.testdata.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntKeyMap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IntKeyMap copyWith(void Function(IntKeyMap) updates) =>
      super.copyWith((message) => updates(message as IntKeyMap)) as IntKeyMap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IntKeyMap create() => IntKeyMap._();
  @$core.override
  IntKeyMap createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IntKeyMap getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IntKeyMap>(create);
  static IntKeyMap? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.int, $core.String> get bad => $_getMap(0);
}

/// google.protobuf.Any is not supported (§3.4).
class AnyField extends $pb.GeneratedMessage {
  factory AnyField({
    $0.Any? bad,
  }) {
    final result = create();
    if (bad != null) result.bad = bad;
    return result;
  }

  AnyField._();

  factory AnyField.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnyField.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnyField',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Any>(1, _omitFieldNames ? '' : 'bad', subBuilder: $0.Any.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnyField clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnyField copyWith(void Function(AnyField) updates) =>
      super.copyWith((message) => updates(message as AnyField)) as AnyField;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnyField create() => AnyField._();
  @$core.override
  AnyField createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnyField getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnyField>(create);
  static AnyField? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Any get bad => $_getN(0);
  @$pb.TagNumber(1)
  set bad($0.Any value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBad() => $_has(0);
  @$pb.TagNumber(1)
  void clearBad() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Any ensureBad() => $_ensure(0);
}

/// google.protobuf.Struct is not supported (§3.4).
class StructField extends $pb.GeneratedMessage {
  factory StructField({
    $1.Struct? bad,
  }) {
    final result = create();
    if (bad != null) result.bad = bad;
    return result;
  }

  StructField._();

  factory StructField.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StructField.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StructField',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'bad',
        subBuilder: $1.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StructField clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StructField copyWith(void Function(StructField) updates) =>
      super.copyWith((message) => updates(message as StructField))
          as StructField;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StructField create() => StructField._();
  @$core.override
  StructField createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StructField getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StructField>(create);
  static StructField? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Struct get bad => $_getN(0);
  @$pb.TagNumber(1)
  set bad($1.Struct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBad() => $_has(0);
  @$pb.TagNumber(1)
  void clearBad() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureBad() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
