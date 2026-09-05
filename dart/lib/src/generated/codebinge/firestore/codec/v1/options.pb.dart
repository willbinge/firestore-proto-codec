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

import 'options.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'options.pbenum.dart';

class Field extends $pb.GeneratedMessage {
  factory Field({
    $core.bool? skip,
    $core.String? name,
    EnumEncoding? enumAs,
    $core.bool? omitWhenDefault,
    Kind? kind,
  }) {
    final result = create();
    if (skip != null) result.skip = skip;
    if (name != null) result.name = name;
    if (enumAs != null) result.enumAs = enumAs;
    if (omitWhenDefault != null) result.omitWhenDefault = omitWhenDefault;
    if (kind != null) result.kind = kind;
    return result;
  }

  Field._();

  factory Field.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Field.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Field',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'skip')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<EnumEncoding>(3, _omitFieldNames ? '' : 'enumAs',
        enumValues: EnumEncoding.values)
    ..aOB(4, _omitFieldNames ? '' : 'omitWhenDefault')
    ..aE<Kind>(5, _omitFieldNames ? '' : 'kind', enumValues: Kind.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field copyWith(void Function(Field) updates) =>
      super.copyWith((message) => updates(message as Field)) as Field;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Field create() => Field._();
  @$core.override
  Field createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Field getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Field>(create);
  static Field? _defaultInstance;

  /// Never encoded.
  @$pb.TagNumber(1)
  $core.bool get skip => $_getBF(0);
  @$pb.TagNumber(1)
  set skip($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSkip() => $_has(0);
  @$pb.TagNumber(1)
  void clearSkip() => $_clearField(1);

  /// Stored-name override. Exists only for adopting an existing collection;
  /// the default is the proto field name verbatim (§1).
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// Default: encode enum values as their name string (§4).
  @$pb.TagNumber(3)
  EnumEncoding get enumAs => $_getN(2);
  @$pb.TagNumber(3)
  set enumAs(EnumEncoding value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEnumAs() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnumAs() => $_clearField(3);

  /// Default true: omit singular scalar fields holding their default value (§6).
  /// Set false where an index or security rule depends on the field existing.
  ///
  /// Explicit presence is required. The intended default is true, and a proto3
  /// implicit-presence bool would not serialize `false`, leaving "set to false"
  /// indistinguishable from "not set".
  @$pb.TagNumber(4)
  $core.bool get omitWhenDefault => $_getBF(3);
  @$pb.TagNumber(4)
  set omitWhenDefault($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOmitWhenDefault() => $_has(3);
  @$pb.TagNumber(4)
  void clearOmitWhenDefault() => $_clearField(4);

  /// Overrides the encoding inferred from the proto type.
  @$pb.TagNumber(5)
  Kind get kind => $_getN(4);
  @$pb.TagNumber(5)
  set kind(Kind value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);
}

class Options {
  static final field_50000 = $pb.Extension<Field>(
      _omitMessageNames ? '' : 'google.protobuf.FieldOptions',
      _omitFieldNames ? '' : 'field_50000',
      50000,
      $pb.PbFieldType.OM,
      defaultOrMaker: Field.getDefault,
      subBuilder: Field.create);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(field_50000);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
