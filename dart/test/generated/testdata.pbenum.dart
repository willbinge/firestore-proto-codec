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

import 'package:protobuf/protobuf.dart' as $pb;

class Status extends $pb.ProtobufEnum {
  static const Status STATUS_UNKNOWN =
      Status._(0, _omitEnumNames ? '' : 'STATUS_UNKNOWN');
  static const Status STATUS_ACTIVE =
      Status._(1, _omitEnumNames ? '' : 'STATUS_ACTIVE');
  static const Status STATUS_ARCHIVED =
      Status._(2, _omitEnumNames ? '' : 'STATUS_ARCHIVED');

  static const $core.List<Status> values = <Status>[
    STATUS_UNKNOWN,
    STATUS_ACTIVE,
    STATUS_ARCHIVED,
  ];

  static final $core.List<Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Status._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
