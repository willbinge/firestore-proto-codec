// This is a generated file - do not edit.
//
// Generated from testdata.proto.

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

@$core.Deprecated('Use statusDescriptor instead')
const Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'STATUS_UNKNOWN', '2': 0},
    {'1': 'STATUS_ACTIVE', '2': 1},
    {'1': 'STATUS_ARCHIVED', '2': 2},
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode(
    'CgZTdGF0dXMSEgoOU1RBVFVTX1VOS05PV04QABIRCg1TVEFUVVNfQUNUSVZFEAESEwoPU1RBVF'
    'VTX0FSQ0hJVkVEEAI=');

@$core.Deprecated('Use scalarsDescriptor instead')
const Scalars$json = {
  '1': 'Scalars',
  '2': [
    {'1': 'string_field', '3': 1, '4': 1, '5': 9, '10': 'stringField'},
    {'1': 'bool_field', '3': 2, '4': 1, '5': 8, '10': 'boolField'},
    {'1': 'bytes_field', '3': 3, '4': 1, '5': 12, '10': 'bytesField'},
    {'1': 'int32_field', '3': 4, '4': 1, '5': 5, '10': 'int32Field'},
    {'1': 'sint32_field', '3': 5, '4': 1, '5': 17, '10': 'sint32Field'},
    {'1': 'sfixed32_field', '3': 6, '4': 1, '5': 15, '10': 'sfixed32Field'},
    {'1': 'uint32_field', '3': 7, '4': 1, '5': 13, '10': 'uint32Field'},
    {'1': 'fixed32_field', '3': 8, '4': 1, '5': 7, '10': 'fixed32Field'},
    {'1': 'int64_field', '3': 9, '4': 1, '5': 3, '10': 'int64Field'},
    {'1': 'sint64_field', '3': 10, '4': 1, '5': 18, '10': 'sint64Field'},
    {'1': 'sfixed64_field', '3': 11, '4': 1, '5': 16, '10': 'sfixed64Field'},
    {'1': 'uint64_field', '3': 12, '4': 1, '5': 4, '10': 'uint64Field'},
    {'1': 'fixed64_field', '3': 13, '4': 1, '5': 6, '10': 'fixed64Field'},
    {'1': 'double_field', '3': 14, '4': 1, '5': 1, '10': 'doubleField'},
    {'1': 'float_field', '3': 15, '4': 1, '5': 2, '10': 'floatField'},
  ],
};

/// Descriptor for `Scalars`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scalarsDescriptor = $convert.base64Decode(
    'CgdTY2FsYXJzEiEKDHN0cmluZ19maWVsZBgBIAEoCVILc3RyaW5nRmllbGQSHQoKYm9vbF9maW'
    'VsZBgCIAEoCFIJYm9vbEZpZWxkEh8KC2J5dGVzX2ZpZWxkGAMgASgMUgpieXRlc0ZpZWxkEh8K'
    'C2ludDMyX2ZpZWxkGAQgASgFUgppbnQzMkZpZWxkEiEKDHNpbnQzMl9maWVsZBgFIAEoEVILc2'
    'ludDMyRmllbGQSJQoOc2ZpeGVkMzJfZmllbGQYBiABKA9SDXNmaXhlZDMyRmllbGQSIQoMdWlu'
    'dDMyX2ZpZWxkGAcgASgNUgt1aW50MzJGaWVsZBIjCg1maXhlZDMyX2ZpZWxkGAggASgHUgxmaX'
    'hlZDMyRmllbGQSHwoLaW50NjRfZmllbGQYCSABKANSCmludDY0RmllbGQSIQoMc2ludDY0X2Zp'
    'ZWxkGAogASgSUgtzaW50NjRGaWVsZBIlCg5zZml4ZWQ2NF9maWVsZBgLIAEoEFINc2ZpeGVkNj'
    'RGaWVsZBIhCgx1aW50NjRfZmllbGQYDCABKARSC3VpbnQ2NEZpZWxkEiMKDWZpeGVkNjRfZmll'
    'bGQYDSABKAZSDGZpeGVkNjRGaWVsZBIhCgxkb3VibGVfZmllbGQYDiABKAFSC2RvdWJsZUZpZW'
    'xkEh8KC2Zsb2F0X2ZpZWxkGA8gASgCUgpmbG9hdEZpZWxk');

@$core.Deprecated('Use doublesDescriptor instead')
const Doubles$json = {
  '1': 'Doubles',
  '2': [
    {'1': 'nan_field', '3': 1, '4': 1, '5': 1, '10': 'nanField'},
    {'1': 'pos_inf_field', '3': 2, '4': 1, '5': 1, '10': 'posInfField'},
    {'1': 'neg_inf_field', '3': 3, '4': 1, '5': 1, '10': 'negInfField'},
  ],
};

/// Descriptor for `Doubles`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doublesDescriptor = $convert.base64Decode(
    'CgdEb3VibGVzEhsKCW5hbl9maWVsZBgBIAEoAVIIbmFuRmllbGQSIgoNcG9zX2luZl9maWVsZB'
    'gCIAEoAVILcG9zSW5mRmllbGQSIgoNbmVnX2luZl9maWVsZBgDIAEoAVILbmVnSW5mRmllbGQ=');

@$core.Deprecated('Use enumsDescriptor instead')
const Enums$json = {
  '1': 'Enums',
  '2': [
    {
      '1': 'as_name',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.codebinge.firestore.codec.testdata.v1.Status',
      '10': 'asName'
    },
    {
      '1': 'as_number',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.codebinge.firestore.codec.testdata.v1.Status',
      '8': {},
      '10': 'asNumber'
    },
  ],
};

/// Descriptor for `Enums`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enumsDescriptor = $convert.base64Decode(
    'CgVFbnVtcxJGCgdhc19uYW1lGAEgASgOMi0uY29kZWJpbmdlLmZpcmVzdG9yZS5jb2RlYy50ZX'
    'N0ZGF0YS52MS5TdGF0dXNSBmFzTmFtZRJSCglhc19udW1iZXIYAiABKA4yLS5jb2RlYmluZ2Uu'
    'ZmlyZXN0b3JlLmNvZGVjLnRlc3RkYXRhLnYxLlN0YXR1c0IGgrUYAhgBUghhc051bWJlcg==');

@$core.Deprecated('Use innerDescriptor instead')
const Inner$json = {
  '1': 'Inner',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Inner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List innerDescriptor =
    $convert.base64Decode('CgVJbm5lchIUCgV2YWx1ZRgBIAEoCVIFdmFsdWU=');

@$core.Deprecated('Use presenceDescriptor instead')
const Presence$json = {
  '1': 'Presence',
  '2': [
    {
      '1': 'opt_string',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'optString',
      '17': true
    },
    {
      '1': 'opt_int32',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'optInt32',
      '17': true
    },
    {
      '1': 'inner',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Inner',
      '10': 'inner'
    },
  ],
  '8': [
    {'1': '_opt_string'},
    {'1': '_opt_int32'},
  ],
};

/// Descriptor for `Presence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceDescriptor = $convert.base64Decode(
    'CghQcmVzZW5jZRIiCgpvcHRfc3RyaW5nGAEgASgJSABSCW9wdFN0cmluZ4gBARIgCglvcHRfaW'
    '50MzIYAiABKAVIAVIIb3B0SW50MzKIAQESQgoFaW5uZXIYAyABKAsyLC5jb2RlYmluZ2UuZmly'
    'ZXN0b3JlLmNvZGVjLnRlc3RkYXRhLnYxLklubmVyUgVpbm5lckINCgtfb3B0X3N0cmluZ0IMCg'
    'pfb3B0X2ludDMy');

@$core.Deprecated('Use unsignedDescriptor instead')
const Unsigned$json = {
  '1': 'Unsigned',
  '2': [
    {'1': 'zero', '3': 1, '4': 1, '5': 4, '10': 'zero'},
    {'1': 'max_signed', '3': 2, '4': 1, '5': 4, '10': 'maxSigned'},
    {'1': 'min_unsigned_only', '3': 3, '4': 1, '5': 4, '10': 'minUnsignedOnly'},
    {'1': 'max_unsigned', '3': 4, '4': 1, '5': 4, '10': 'maxUnsigned'},
    {'1': 'fixed', '3': 5, '4': 1, '5': 6, '10': 'fixed'},
    {'1': 'as_integer', '3': 6, '4': 1, '5': 4, '8': {}, '10': 'asInteger'},
    {'1': 'always', '3': 7, '4': 1, '5': 4, '8': {}, '10': 'always'},
  ],
};

/// Descriptor for `Unsigned`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsignedDescriptor = $convert.base64Decode(
    'CghVbnNpZ25lZBISCgR6ZXJvGAEgASgEUgR6ZXJvEh0KCm1heF9zaWduZWQYAiABKARSCW1heF'
    'NpZ25lZBIqChFtaW5fdW5zaWduZWRfb25seRgDIAEoBFIPbWluVW5zaWduZWRPbmx5EiEKDG1h'
    'eF91bnNpZ25lZBgEIAEoBFILbWF4VW5zaWduZWQSFAoFZml4ZWQYBSABKAZSBWZpeGVkEiUKCm'
    'FzX2ludGVnZXIYBiABKARCBoK1GAIoAlIJYXNJbnRlZ2VyEh4KBmFsd2F5cxgHIAEoBEIGgrUY'
    'AiAAUgZhbHdheXM=');

@$core.Deprecated('Use wellKnownDescriptor instead')
const WellKnown$json = {
  '1': 'WellKnown',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'duration',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'duration'
    },
    {
      '1': 'location',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.type.LatLng',
      '10': 'location'
    },
  ],
};

/// Descriptor for `WellKnown`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wellKnownDescriptor = $convert.base64Decode(
    'CglXZWxsS25vd24SOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIJdGltZXN0YW1wEjUKCGR1cmF0aW9uGAIgASgLMhkuZ29vZ2xlLnByb3RvYnVmLkR1cmF0'
    'aW9uUghkdXJhdGlvbhIvCghsb2NhdGlvbhgDIAEoCzITLmdvb2dsZS50eXBlLkxhdExuZ1IIbG'
    '9jYXRpb24=');

@$core.Deprecated('Use compositeDescriptor instead')
const Composite$json = {
  '1': 'Composite',
  '2': [
    {
      '1': 'single',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Inner',
      '10': 'single'
    },
    {'1': 'strings', '3': 2, '4': 3, '5': 9, '10': 'strings'},
    {
      '1': 'messages',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Inner',
      '10': 'messages'
    },
    {
      '1': 'string_map',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Composite.StringMapEntry',
      '10': 'stringMap'
    },
    {
      '1': 'message_map',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Composite.MessageMapEntry',
      '10': 'messageMap'
    },
  ],
  '3': [Composite_StringMapEntry$json, Composite_MessageMapEntry$json],
};

@$core.Deprecated('Use compositeDescriptor instead')
const Composite_StringMapEntry$json = {
  '1': 'StringMapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use compositeDescriptor instead')
const Composite_MessageMapEntry$json = {
  '1': 'MessageMapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Inner',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Composite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compositeDescriptor = $convert.base64Decode(
    'CglDb21wb3NpdGUSRAoGc2luZ2xlGAEgASgLMiwuY29kZWJpbmdlLmZpcmVzdG9yZS5jb2RlYy'
    '50ZXN0ZGF0YS52MS5Jbm5lclIGc2luZ2xlEhgKB3N0cmluZ3MYAiADKAlSB3N0cmluZ3MSSAoI'
    'bWVzc2FnZXMYAyADKAsyLC5jb2RlYmluZ2UuZmlyZXN0b3JlLmNvZGVjLnRlc3RkYXRhLnYxLk'
    'lubmVyUghtZXNzYWdlcxJeCgpzdHJpbmdfbWFwGAQgAygLMj8uY29kZWJpbmdlLmZpcmVzdG9y'
    'ZS5jb2RlYy50ZXN0ZGF0YS52MS5Db21wb3NpdGUuU3RyaW5nTWFwRW50cnlSCXN0cmluZ01hcB'
    'JhCgttZXNzYWdlX21hcBgFIAMoCzJALmNvZGViaW5nZS5maXJlc3RvcmUuY29kZWMudGVzdGRh'
    'dGEudjEuQ29tcG9zaXRlLk1lc3NhZ2VNYXBFbnRyeVIKbWVzc2FnZU1hcBo8Cg5TdHJpbmdNYX'
    'BFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGmsKD01l'
    'c3NhZ2VNYXBFbnRyeRIQCgNrZXkYASABKAlSA2tleRJCCgV2YWx1ZRgCIAEoCzIsLmNvZGViaW'
    '5nZS5maXJlc3RvcmUuY29kZWMudGVzdGRhdGEudjEuSW5uZXJSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use optionsDescriptor instead')
const Options$json = {
  '1': 'Options',
  '2': [
    {'1': 'kept', '3': 1, '4': 1, '5': 9, '10': 'kept'},
    {'1': 'dropped', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'dropped'},
    {'1': 'renamed', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'renamed'},
  ],
};

/// Descriptor for `Options`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionsDescriptor = $convert.base64Decode(
    'CgdPcHRpb25zEhIKBGtlcHQYASABKAlSBGtlcHQSIAoHZHJvcHBlZBgCIAEoCUIGgrUYAggBUg'
    'dkcm9wcGVkEisKB3JlbmFtZWQYAyABKAlCEYK1GA0SC3N0b3JlZF9uYW1lUgdyZW5hbWVk');

@$core.Deprecated('Use choiceDescriptor instead')
const Choice$json = {
  '1': 'Choice',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'text'},
    {'1': 'number', '3': 2, '4': 1, '5': 5, '9': 0, '10': 'number'},
    {
      '1': 'inner',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Inner',
      '9': 0,
      '10': 'inner'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Choice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List choiceDescriptor = $convert.base64Decode(
    'CgZDaG9pY2USFAoEdGV4dBgBIAEoCUgAUgR0ZXh0EhgKBm51bWJlchgCIAEoBUgAUgZudW1iZX'
    'ISRAoFaW5uZXIYAyABKAsyLC5jb2RlYmluZ2UuZmlyZXN0b3JlLmNvZGVjLnRlc3RkYXRhLnYx'
    'LklubmVySABSBWlubmVyQgYKBGtpbmQ=');

@$core.Deprecated('Use stringifiedInt64Descriptor instead')
const StringifiedInt64$json = {
  '1': 'StringifiedInt64',
  '2': [
    {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 3,
      '8': {'6': 1},
      '10': 'id',
    },
    {
      '1': 'ids',
      '3': 2,
      '4': 3,
      '5': 3,
      '8': {'6': 1},
      '10': 'ids',
    },
  ],
};

/// Descriptor for `StringifiedInt64`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringifiedInt64Descriptor = $convert.base64Decode(
    'ChBTdHJpbmdpZmllZEludDY0EhIKAmlkGAEgASgDQgIwAVICaWQSFAoDaWRzGAIgAygDQgIwAV'
    'IDaWRz');

@$core.Deprecated('Use recursiveDescriptor instead')
const Recursive$json = {
  '1': 'Recursive',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {
      '1': 'child',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.codebinge.firestore.codec.testdata.v1.Recursive',
      '10': 'child'
    },
  ],
};

/// Descriptor for `Recursive`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recursiveDescriptor = $convert.base64Decode(
    'CglSZWN1cnNpdmUSFAoFbGFiZWwYASABKAlSBWxhYmVsEkYKBWNoaWxkGAIgASgLMjAuY29kZW'
    'JpbmdlLmZpcmVzdG9yZS5jb2RlYy50ZXN0ZGF0YS52MS5SZWN1cnNpdmVSBWNoaWxk');
