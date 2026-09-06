// This is a generated file - do not edit.
//
// Generated from testdata.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'google/type/latlng.pb.dart' as $2;
import 'testdata.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'testdata.pbenum.dart';

/// Every scalar type in one message (§2).
class Scalars extends $pb.GeneratedMessage {
  factory Scalars({
    $core.String? stringField,
    $core.bool? boolField,
    $core.List<$core.int>? bytesField,
    $core.int? int32Field,
    $core.int? sint32Field,
    $core.int? sfixed32Field,
    $core.int? uint32Field,
    $core.int? fixed32Field,
    $fixnum.Int64? int64Field,
    $fixnum.Int64? sint64Field,
    $fixnum.Int64? sfixed64Field,
    $fixnum.Int64? uint64Field,
    $fixnum.Int64? fixed64Field,
    $core.double? doubleField,
    $core.double? floatField,
  }) {
    final result = create();
    if (stringField != null) result.stringField = stringField;
    if (boolField != null) result.boolField = boolField;
    if (bytesField != null) result.bytesField = bytesField;
    if (int32Field != null) result.int32Field = int32Field;
    if (sint32Field != null) result.sint32Field = sint32Field;
    if (sfixed32Field != null) result.sfixed32Field = sfixed32Field;
    if (uint32Field != null) result.uint32Field = uint32Field;
    if (fixed32Field != null) result.fixed32Field = fixed32Field;
    if (int64Field != null) result.int64Field = int64Field;
    if (sint64Field != null) result.sint64Field = sint64Field;
    if (sfixed64Field != null) result.sfixed64Field = sfixed64Field;
    if (uint64Field != null) result.uint64Field = uint64Field;
    if (fixed64Field != null) result.fixed64Field = fixed64Field;
    if (doubleField != null) result.doubleField = doubleField;
    if (floatField != null) result.floatField = floatField;
    return result;
  }

  Scalars._();

  factory Scalars.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Scalars.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Scalars',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stringField')
    ..aOB(2, _omitFieldNames ? '' : 'boolField')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'bytesField', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'int32Field')
    ..aI(5, _omitFieldNames ? '' : 'sint32Field',
        fieldType: $pb.PbFieldType.OS3)
    ..aI(6, _omitFieldNames ? '' : 'sfixed32Field',
        fieldType: $pb.PbFieldType.OSF3)
    ..aI(7, _omitFieldNames ? '' : 'uint32Field',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'fixed32Field',
        fieldType: $pb.PbFieldType.OF3)
    ..aInt64(9, _omitFieldNames ? '' : 'int64Field')
    ..a<$fixnum.Int64>(
        10, _omitFieldNames ? '' : 'sint64Field', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        11, _omitFieldNames ? '' : 'sfixed64Field', $pb.PbFieldType.OSF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        12, _omitFieldNames ? '' : 'uint64Field', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        13, _omitFieldNames ? '' : 'fixed64Field', $pb.PbFieldType.OF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(14, _omitFieldNames ? '' : 'doubleField')
    ..aD(15, _omitFieldNames ? '' : 'floatField', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Scalars clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Scalars copyWith(void Function(Scalars) updates) =>
      super.copyWith((message) => updates(message as Scalars)) as Scalars;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Scalars create() => Scalars._();
  @$core.override
  Scalars createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Scalars getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Scalars>(create);
  static Scalars? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stringField => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringField($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStringField() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringField() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get boolField => $_getBF(1);
  @$pb.TagNumber(2)
  set boolField($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBoolField() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoolField() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get bytesField => $_getN(2);
  @$pb.TagNumber(3)
  set bytesField($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesField() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesField() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get int32Field => $_getIZ(3);
  @$pb.TagNumber(4)
  set int32Field($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInt32Field() => $_has(3);
  @$pb.TagNumber(4)
  void clearInt32Field() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sint32Field => $_getIZ(4);
  @$pb.TagNumber(5)
  set sint32Field($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSint32Field() => $_has(4);
  @$pb.TagNumber(5)
  void clearSint32Field() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sfixed32Field => $_getIZ(5);
  @$pb.TagNumber(6)
  set sfixed32Field($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSfixed32Field() => $_has(5);
  @$pb.TagNumber(6)
  void clearSfixed32Field() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get uint32Field => $_getIZ(6);
  @$pb.TagNumber(7)
  set uint32Field($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUint32Field() => $_has(6);
  @$pb.TagNumber(7)
  void clearUint32Field() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get fixed32Field => $_getIZ(7);
  @$pb.TagNumber(8)
  set fixed32Field($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFixed32Field() => $_has(7);
  @$pb.TagNumber(8)
  void clearFixed32Field() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get int64Field => $_getI64(8);
  @$pb.TagNumber(9)
  set int64Field($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInt64Field() => $_has(8);
  @$pb.TagNumber(9)
  void clearInt64Field() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get sint64Field => $_getI64(9);
  @$pb.TagNumber(10)
  set sint64Field($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSint64Field() => $_has(9);
  @$pb.TagNumber(10)
  void clearSint64Field() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get sfixed64Field => $_getI64(10);
  @$pb.TagNumber(11)
  set sfixed64Field($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSfixed64Field() => $_has(10);
  @$pb.TagNumber(11)
  void clearSfixed64Field() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get uint64Field => $_getI64(11);
  @$pb.TagNumber(12)
  set uint64Field($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUint64Field() => $_has(11);
  @$pb.TagNumber(12)
  void clearUint64Field() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get fixed64Field => $_getI64(12);
  @$pb.TagNumber(13)
  set fixed64Field($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFixed64Field() => $_has(12);
  @$pb.TagNumber(13)
  void clearFixed64Field() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get doubleField => $_getN(13);
  @$pb.TagNumber(14)
  set doubleField($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDoubleField() => $_has(13);
  @$pb.TagNumber(14)
  void clearDoubleField() => $_clearField(14);

  /// scalars_full uses 1.5, exactly representable in binary32, so that vector
  /// tests the type mapping alone. float_rounding uses 0.1 to pin the rule that
  /// a float encodes as its binary32 value, 0.10000000149011612 (§2).
  @$pb.TagNumber(15)
  $core.double get floatField => $_getN(14);
  @$pb.TagNumber(15)
  set floatField($core.double value) => $_setFloat(14, value);
  @$pb.TagNumber(15)
  $core.bool hasFloatField() => $_has(14);
  @$pb.TagNumber(15)
  void clearFloatField() => $_clearField(15);
}

/// NaN and the infinities, which Firestore supports natively (§2).
class Doubles extends $pb.GeneratedMessage {
  factory Doubles({
    $core.double? nanField,
    $core.double? posInfField,
    $core.double? negInfField,
  }) {
    final result = create();
    if (nanField != null) result.nanField = nanField;
    if (posInfField != null) result.posInfField = posInfField;
    if (negInfField != null) result.negInfField = negInfField;
    return result;
  }

  Doubles._();

  factory Doubles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Doubles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Doubles',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'nanField')
    ..aD(2, _omitFieldNames ? '' : 'posInfField')
    ..aD(3, _omitFieldNames ? '' : 'negInfField')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Doubles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Doubles copyWith(void Function(Doubles) updates) =>
      super.copyWith((message) => updates(message as Doubles)) as Doubles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Doubles create() => Doubles._();
  @$core.override
  Doubles createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Doubles getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Doubles>(create);
  static Doubles? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get nanField => $_getN(0);
  @$pb.TagNumber(1)
  set nanField($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNanField() => $_has(0);
  @$pb.TagNumber(1)
  void clearNanField() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get posInfField => $_getN(1);
  @$pb.TagNumber(2)
  set posInfField($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPosInfField() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosInfField() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get negInfField => $_getN(2);
  @$pb.TagNumber(3)
  set negInfField($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNegInfField() => $_has(2);
  @$pb.TagNumber(3)
  void clearNegInfField() => $_clearField(3);
}

/// Both enum encodings (§4).
class Enums extends $pb.GeneratedMessage {
  factory Enums({
    Status? asName,
    Status? asNumber,
  }) {
    final result = create();
    if (asName != null) result.asName = asName;
    if (asNumber != null) result.asNumber = asNumber;
    return result;
  }

  Enums._();

  factory Enums.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Enums.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Enums',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aE<Status>(1, _omitFieldNames ? '' : 'asName', enumValues: Status.values)
    ..aE<Status>(2, _omitFieldNames ? '' : 'asNumber',
        enumValues: Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Enums clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Enums copyWith(void Function(Enums) updates) =>
      super.copyWith((message) => updates(message as Enums)) as Enums;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Enums create() => Enums._();
  @$core.override
  Enums createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Enums getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Enums>(create);
  static Enums? _defaultInstance;

  @$pb.TagNumber(1)
  Status get asName => $_getN(0);
  @$pb.TagNumber(1)
  set asName(Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAsName() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsName() => $_clearField(1);

  @$pb.TagNumber(2)
  Status get asNumber => $_getN(1);
  @$pb.TagNumber(2)
  set asNumber(Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAsNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearAsNumber() => $_clearField(2);
}

class Inner extends $pb.GeneratedMessage {
  factory Inner({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Inner._();

  factory Inner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Inner.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Inner',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inner copyWith(void Function(Inner) updates) =>
      super.copyWith((message) => updates(message as Inner)) as Inner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Inner create() => Inner._();
  @$core.override
  Inner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Inner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Inner>(create);
  static Inner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// Explicit presence (§6). `optional` scalars and singular message fields are
/// written even when they hold a default, and omitted when unset.
class Presence extends $pb.GeneratedMessage {
  factory Presence({
    $core.String? optString,
    $core.int? optInt32,
    Inner? inner,
  }) {
    final result = create();
    if (optString != null) result.optString = optString;
    if (optInt32 != null) result.optInt32 = optInt32;
    if (inner != null) result.inner = inner;
    return result;
  }

  Presence._();

  factory Presence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Presence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Presence',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'optString')
    ..aI(2, _omitFieldNames ? '' : 'optInt32')
    ..aOM<Inner>(3, _omitFieldNames ? '' : 'inner', subBuilder: Inner.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Presence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Presence copyWith(void Function(Presence) updates) =>
      super.copyWith((message) => updates(message as Presence)) as Presence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Presence create() => Presence._();
  @$core.override
  Presence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Presence getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Presence>(create);
  static Presence? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get optString => $_getSZ(0);
  @$pb.TagNumber(1)
  set optString($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptString() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptString() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get optInt32 => $_getIZ(1);
  @$pb.TagNumber(2)
  set optInt32($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptInt32() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptInt32() => $_clearField(2);

  @$pb.TagNumber(3)
  Inner get inner => $_getN(2);
  @$pb.TagNumber(3)
  set inner(Inner value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInner() => $_has(2);
  @$pb.TagNumber(3)
  void clearInner() => $_clearField(3);
  @$pb.TagNumber(3)
  Inner ensureInner() => $_ensure(2);
}

/// Unsigned 64-bit boundaries (§2.1).
class Unsigned extends $pb.GeneratedMessage {
  factory Unsigned({
    $fixnum.Int64? zero,
    $fixnum.Int64? maxSigned,
    $fixnum.Int64? minUnsignedOnly,
    $fixnum.Int64? maxUnsigned,
    $fixnum.Int64? fixed,
    $fixnum.Int64? asInteger,
    $fixnum.Int64? always,
  }) {
    final result = create();
    if (zero != null) result.zero = zero;
    if (maxSigned != null) result.maxSigned = maxSigned;
    if (minUnsignedOnly != null) result.minUnsignedOnly = minUnsignedOnly;
    if (maxUnsigned != null) result.maxUnsigned = maxUnsigned;
    if (fixed != null) result.fixed = fixed;
    if (asInteger != null) result.asInteger = asInteger;
    if (always != null) result.always = always;
    return result;
  }

  Unsigned._();

  factory Unsigned.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Unsigned.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Unsigned',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'zero', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'maxSigned', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'minUnsignedOnly', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'maxUnsigned', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'fixed', $pb.PbFieldType.OF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'asInteger', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'always', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Unsigned clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Unsigned copyWith(void Function(Unsigned) updates) =>
      super.copyWith((message) => updates(message as Unsigned)) as Unsigned;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Unsigned create() => Unsigned._();
  @$core.override
  Unsigned createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Unsigned getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Unsigned>(create);
  static Unsigned? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get zero => $_getI64(0);
  @$pb.TagNumber(1)
  set zero($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZero() => $_has(0);
  @$pb.TagNumber(1)
  void clearZero() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get maxSigned => $_getI64(1);
  @$pb.TagNumber(2)
  set maxSigned($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxSigned() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxSigned() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get minUnsignedOnly => $_getI64(2);
  @$pb.TagNumber(3)
  set minUnsignedOnly($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinUnsignedOnly() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinUnsignedOnly() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get maxUnsigned => $_getI64(3);
  @$pb.TagNumber(4)
  set maxUnsigned($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxUnsigned() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxUnsigned() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get fixed => $_getI64(4);
  @$pb.TagNumber(5)
  set fixed($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFixed() => $_has(4);
  @$pb.TagNumber(5)
  void clearFixed() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get asInteger => $_getI64(5);
  @$pb.TagNumber(6)
  set asInteger($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAsInteger() => $_has(5);
  @$pb.TagNumber(6)
  void clearAsInteger() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get always => $_getI64(6);
  @$pb.TagNumber(7)
  set always($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAlways() => $_has(6);
  @$pb.TagNumber(7)
  void clearAlways() => $_clearField(7);
}

/// Well-known and common types (§3).
class WellKnown extends $pb.GeneratedMessage {
  factory WellKnown({
    $0.Timestamp? timestamp,
    $1.Duration? duration,
    $2.LatLng? location,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (duration != null) result.duration = duration;
    if (location != null) result.location = location;
    return result;
  }

  WellKnown._();

  factory WellKnown.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WellKnown.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WellKnown',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(2, _omitFieldNames ? '' : 'duration',
        subBuilder: $1.Duration.create)
    ..aOM<$2.LatLng>(3, _omitFieldNames ? '' : 'location',
        subBuilder: $2.LatLng.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnown clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnown copyWith(void Function(WellKnown) updates) =>
      super.copyWith((message) => updates(message as WellKnown)) as WellKnown;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WellKnown create() => WellKnown._();
  @$core.override
  WellKnown createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WellKnown getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WellKnown>(create);
  static WellKnown? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Duration get duration => $_getN(1);
  @$pb.TagNumber(2)
  set duration($1.Duration value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Duration ensureDuration() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.LatLng get location => $_getN(2);
  @$pb.TagNumber(3)
  set location($2.LatLng value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLocation() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocation() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.LatLng ensureLocation() => $_ensure(2);
}

/// Nested messages, repeated fields, and maps (§5).
class Composite extends $pb.GeneratedMessage {
  factory Composite({
    Inner? single,
    $core.Iterable<$core.String>? strings,
    $core.Iterable<Inner>? messages,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? stringMap,
    $core.Iterable<$core.MapEntry<$core.String, Inner>>? messageMap,
  }) {
    final result = create();
    if (single != null) result.single = single;
    if (strings != null) result.strings.addAll(strings);
    if (messages != null) result.messages.addAll(messages);
    if (stringMap != null) result.stringMap.addEntries(stringMap);
    if (messageMap != null) result.messageMap.addEntries(messageMap);
    return result;
  }

  Composite._();

  factory Composite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Composite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Composite',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOM<Inner>(1, _omitFieldNames ? '' : 'single', subBuilder: Inner.create)
    ..pPS(2, _omitFieldNames ? '' : 'strings')
    ..pPM<Inner>(3, _omitFieldNames ? '' : 'messages', subBuilder: Inner.create)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'stringMap',
        entryClassName: 'Composite.StringMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName:
            const $pb.PackageName('codebinge.firestore.codec.testdata.v1'))
    ..m<$core.String, Inner>(5, _omitFieldNames ? '' : 'messageMap',
        entryClassName: 'Composite.MessageMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Inner.create,
        valueDefaultOrMaker: Inner.getDefault,
        packageName:
            const $pb.PackageName('codebinge.firestore.codec.testdata.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Composite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Composite copyWith(void Function(Composite) updates) =>
      super.copyWith((message) => updates(message as Composite)) as Composite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Composite create() => Composite._();
  @$core.override
  Composite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Composite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Composite>(create);
  static Composite? _defaultInstance;

  @$pb.TagNumber(1)
  Inner get single => $_getN(0);
  @$pb.TagNumber(1)
  set single(Inner value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSingle() => $_has(0);
  @$pb.TagNumber(1)
  void clearSingle() => $_clearField(1);
  @$pb.TagNumber(1)
  Inner ensureSingle() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get strings => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Inner> get messages => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get stringMap => $_getMap(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, Inner> get messageMap => $_getMap(4);
}

/// The `skip` and `name` options (§7).
class Options extends $pb.GeneratedMessage {
  factory Options({
    $core.String? kept,
    $core.String? dropped,
    $core.String? renamed,
  }) {
    final result = create();
    if (kept != null) result.kept = kept;
    if (dropped != null) result.dropped = dropped;
    if (renamed != null) result.renamed = renamed;
    return result;
  }

  Options._();

  factory Options.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Options.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Options',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'kept')
    ..aOS(2, _omitFieldNames ? '' : 'dropped')
    ..aOS(3, _omitFieldNames ? '' : 'renamed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Options clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Options copyWith(void Function(Options) updates) =>
      super.copyWith((message) => updates(message as Options)) as Options;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Options create() => Options._();
  @$core.override
  Options createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Options getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Options>(create);
  static Options? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kept => $_getSZ(0);
  @$pb.TagNumber(1)
  set kept($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKept() => $_has(0);
  @$pb.TagNumber(1)
  void clearKept() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dropped => $_getSZ(1);
  @$pb.TagNumber(2)
  set dropped($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDropped() => $_has(1);
  @$pb.TagNumber(2)
  void clearDropped() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get renamed => $_getSZ(2);
  @$pb.TagNumber(3)
  set renamed($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRenamed() => $_has(2);
  @$pb.TagNumber(3)
  void clearRenamed() => $_clearField(3);
}

enum Choice_Kind { text, number, inner, notSet }

/// Oneof members carry explicit presence (§6): the selected member is written
/// even when it holds its default, and it must decode back into the oneof rather
/// than into a stray property.
class Choice extends $pb.GeneratedMessage {
  factory Choice({
    $core.String? text,
    $core.int? number,
    Inner? inner,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (number != null) result.number = number;
    if (inner != null) result.inner = inner;
    return result;
  }

  Choice._();

  factory Choice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Choice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Choice_Kind> _Choice_KindByTag = {
    1: Choice_Kind.text,
    2: Choice_Kind.number,
    3: Choice_Kind.inner,
    0: Choice_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Choice',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aI(2, _omitFieldNames ? '' : 'number')
    ..aOM<Inner>(3, _omitFieldNames ? '' : 'inner', subBuilder: Inner.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Choice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Choice copyWith(void Function(Choice) updates) =>
      super.copyWith((message) => updates(message as Choice)) as Choice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Choice create() => Choice._();
  @$core.override
  Choice createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Choice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Choice>(create);
  static Choice? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  Choice_Kind whichKind() => _Choice_KindByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get number => $_getIZ(1);
  @$pb.TagNumber(2)
  set number($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  Inner get inner => $_getN(2);
  @$pb.TagNumber(3)
  set inner(Inner value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInner() => $_has(2);
  @$pb.TagNumber(3)
  void clearInner() => $_clearField(3);
  @$pb.TagNumber(3)
  Inner ensureInner() => $_ensure(2);
}

/// `jstype = JS_STRING` changes only the in-memory JavaScript type of an int64
/// field; the Firestore type is still Integer (§8). Dart and Java ignore the
/// option entirely.
class StringifiedInt64 extends $pb.GeneratedMessage {
  factory StringifiedInt64({
    $fixnum.Int64? id,
    $core.Iterable<$fixnum.Int64>? ids,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  StringifiedInt64._();

  factory StringifiedInt64.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringifiedInt64.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringifiedInt64',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringifiedInt64 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringifiedInt64 copyWith(void Function(StringifiedInt64) updates) =>
      super.copyWith((message) => updates(message as StringifiedInt64))
          as StringifiedInt64;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringifiedInt64 create() => StringifiedInt64._();
  @$core.override
  StringifiedInt64 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StringifiedInt64 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringifiedInt64>(create);
  static StringifiedInt64? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get ids => $_getList(1);
}

/// Nesting depth (§5). A chain of N `child` values puts the innermost map at
/// depth N; Firestore's limit is 20.
class Recursive extends $pb.GeneratedMessage {
  factory Recursive({
    $core.String? label,
    Recursive? child,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (child != null) result.child = child;
    return result;
  }

  Recursive._();

  factory Recursive.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Recursive.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Recursive',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOM<Recursive>(2, _omitFieldNames ? '' : 'child',
        subBuilder: Recursive.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Recursive clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Recursive copyWith(void Function(Recursive) updates) =>
      super.copyWith((message) => updates(message as Recursive)) as Recursive;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Recursive create() => Recursive._();
  @$core.override
  Recursive createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Recursive getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Recursive>(create);
  static Recursive? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  Recursive get child => $_getN(1);
  @$pb.TagNumber(2)
  set child(Recursive value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasChild() => $_has(1);
  @$pb.TagNumber(2)
  void clearChild() => $_clearField(2);
  @$pb.TagNumber(2)
  Recursive ensureChild() => $_ensure(1);
}

/// Nesting depth through arrays and maps (§5). Every map and array is a level,
/// so a Tree reached through `children` or `named` sits two levels below its
/// parent, not one, and `tags` is a level of its own.
class Tree extends $pb.GeneratedMessage {
  factory Tree({
    $core.String? label,
    $core.Iterable<Tree>? children,
    $core.Iterable<$core.MapEntry<$core.String, Tree>>? named,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (children != null) result.children.addAll(children);
    if (named != null) result.named.addEntries(named);
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  Tree._();

  factory Tree.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tree',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'codebinge.firestore.codec.testdata.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..pPM<Tree>(2, _omitFieldNames ? '' : 'children', subBuilder: Tree.create)
    ..m<$core.String, Tree>(3, _omitFieldNames ? '' : 'named',
        entryClassName: 'Tree.NamedEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Tree.create,
        valueDefaultOrMaker: Tree.getDefault,
        packageName:
            const $pb.PackageName('codebinge.firestore.codec.testdata.v1'))
    ..pPS(4, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree copyWith(void Function(Tree) updates) =>
      super.copyWith((message) => updates(message as Tree)) as Tree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tree create() => Tree._();
  @$core.override
  Tree createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tree getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tree>(create);
  static Tree? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Tree> get children => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, Tree> get named => $_getMap(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get tags => $_getList(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
