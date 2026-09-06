// This is a generated file - do not edit.
//
// Generated from codebinge/firestore/codec/v1/options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use kindDescriptor instead')
const Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'KIND_UNSPECIFIED', '2': 0},
    {'1': 'KIND_GEO_POINT', '2': 1},
    {'1': 'KIND_UNSIGNED_AS_INTEGER', '2': 2},
  ],
};

/// Descriptor for `Kind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List kindDescriptor = $convert.base64Decode(
    'CgRLaW5kEhQKEEtJTkRfVU5TUEVDSUZJRUQQABISCg5LSU5EX0dFT19QT0lOVBABEhwKGEtJTk'
    'RfVU5TSUdORURfQVNfSU5URUdFUhAC');

@$core.Deprecated('Use enumEncodingDescriptor instead')
const EnumEncoding$json = {
  '1': 'EnumEncoding',
  '2': [
    {'1': 'ENUM_ENCODING_NAME', '2': 0},
    {'1': 'ENUM_ENCODING_NUMBER', '2': 1},
  ],
};

/// Descriptor for `EnumEncoding`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List enumEncodingDescriptor = $convert.base64Decode(
    'CgxFbnVtRW5jb2RpbmcSFgoSRU5VTV9FTkNPRElOR19OQU1FEAASGAoURU5VTV9FTkNPRElOR1'
    '9OVU1CRVIQAQ==');

@$core.Deprecated('Use fieldDescriptor instead')
const Field$json = {
  '1': 'Field',
  '2': [
    {'1': 'skip', '3': 1, '4': 1, '5': 8, '10': 'skip'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'enum_as',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.codebinge.firestore.codec.v1.EnumEncoding',
      '10': 'enumAs'
    },
    {
      '1': 'omit_when_default',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'omitWhenDefault',
      '17': true
    },
    {
      '1': 'kind',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.codebinge.firestore.codec.v1.Kind',
      '10': 'kind'
    },
  ],
  '8': [
    {'1': '_omit_when_default'},
  ],
};

/// Descriptor for `Field`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldDescriptor = $convert.base64Decode(
    'CgVGaWVsZBISCgRza2lwGAEgASgIUgRza2lwEhIKBG5hbWUYAiABKAlSBG5hbWUSQwoHZW51bV'
    '9hcxgDIAEoDjIqLmNvZGViaW5nZS5maXJlc3RvcmUuY29kZWMudjEuRW51bUVuY29kaW5nUgZl'
    'bnVtQXMSLwoRb21pdF93aGVuX2RlZmF1bHQYBCABKAhIAFIPb21pdFdoZW5EZWZhdWx0iAEBEj'
    'YKBGtpbmQYBSABKA4yIi5jb2RlYmluZ2UuZmlyZXN0b3JlLmNvZGVjLnYxLktpbmRSBGtpbmRC'
    'FAoSX29taXRfd2hlbl9kZWZhdWx0');
