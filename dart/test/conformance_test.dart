import 'dart:convert';
import 'dart:io';

import 'package:firestore_proto_codec/firestore_proto_codec.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as wkt;
import 'package:test/test.dart';

import 'generated/invalid.pb.dart' as inv;
import 'generated/testdata.pb.dart' as td;
import 'generated/testdata.pbjson.dart' as tdj;
import 'rest_json.dart';

const _pkg = 'codebinge.firestore.codec.testdata.v1.';

final _factories = <String, GeneratedMessage Function()>{
  '${_pkg}Scalars': td.Scalars.new,
  '${_pkg}Doubles': td.Doubles.new,
  '${_pkg}Enums': td.Enums.new,
  '${_pkg}Inner': td.Inner.new,
  '${_pkg}Presence': td.Presence.new,
  '${_pkg}Unsigned': td.Unsigned.new,
  '${_pkg}WellKnown': td.WellKnown.new,
  '${_pkg}Composite': td.Composite.new,
  '${_pkg}Options': td.Options.new,
  '${_pkg}Recursive': td.Recursive.new,
  '${_pkg}Tree': td.Tree.new,
  '${_pkg}Choice': td.Choice.new,
  '${_pkg}StringifiedInt64': td.StringifiedInt64.new,
  '${_pkg}IntKeyMap': inv.IntKeyMap.new,
  '${_pkg}AnyField': inv.AnyField.new,
  '${_pkg}StructField': inv.StructField.new,
};

FirestoreProtoCodec _buildCodec() {
  final registry = SchemaRegistry()
    ..register(td.Enums(), tdj.enumsDescriptor)
    ..register(td.Presence(), tdj.presenceDescriptor)
    ..register(td.Unsigned(), tdj.unsignedDescriptor)
    ..register(td.Options(), tdj.optionsDescriptor);
  return FirestoreProtoCodec(registry: registry);
}

void main() {
  final root = Directory.current.parent.path;
  final manifest = jsonDecode(
    File('$root/testdata/manifest.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final codec = _buildCodec();

  Map<String, Object?> readJson(String relative) => jsonDecode(
        File('$root/testdata/$relative').readAsStringSync(),
      ) as Map<String, Object?>;

  GeneratedMessage buildMessage(String type, String relative) {
    final message = _factories[type]!();
    message.mergeFromProto3Json(
      jsonDecode(File('$root/testdata/$relative').readAsStringSync()),
      supportNamesWithUnderscores: true,
    );
    return message;
  }

  // Not a shared vector: Dart's proto3 JSON parser drops the sign of a
  // Duration whose integer part is zero ("-0.5s" parses as +0.5s), so the input
  // cannot be written down portably. Built by hand instead. This is the case
  // where a Euclidean modulo decoded -250us as +0.99975s.
  test('negative sub-second Duration round-trips', () {
    final message = td.WellKnown()
      ..duration = (wkt.Duration()
        ..seconds = Int64.ZERO
        ..nanos = -250000);
    final document = codec.encode(message);
    expect(document, equals({'duration': -250}));
    final decoded = codec.decode(document, td.WellKnown());
    expect(decoded.duration.seconds, equals(Int64.ZERO));
    expect(decoded.duration.nanos, equals(-250000));
  });

  group('conformance', () {
    for (final entry in (manifest['cases']! as List<Object?>)) {
      final c = entry! as Map<String, Object?>;
      final name = c['name']! as String;
      final type = c['message']! as String;
      final direction = c['direction']! as String;
      final expectError = c['expect_error'] as String?;
      final messageFile = c['message_file'] as String?;
      final documentFile = c['document_file'] as String?;
      final requires = c['requires'] as String?;

      test('$name ($direction)', () {
        if (requires == 'open_enum_values') {
          // Dart enums are closed: the runtime cannot hold an undeclared
          // number, so this input cannot be constructed and the codec is
          // conformant by construction (see manifest.requirements).
          markTestSkipped('requires $requires');
          return;
        }

        Matcher throwsCode(String code) => throwsA(
              isA<CodecError>()
                  .having((e) => e.code.wireName, 'code', code),
            );

        if (direction == 'schema') {
          expect(() => codec.validateSchema(_factories[type]!()),
              throwsCode(expectError!));
          return;
        }

        if (direction == 'encode' || direction == 'roundtrip') {
          final message = buildMessage(type, messageFile!);
          if (expectError != null) {
            expect(() => codec.encode(message), throwsCode(expectError));
          } else {
            expect(toRestDocument(codec.encode(message)),
                equals(readJson(documentFile!)));
          }
        }

        if (direction == 'decode' || direction == 'roundtrip') {
          final document = fromRestDocument(readJson(documentFile!));
          if (expectError != null) {
            expect(() => codec.decode(document, _factories[type]!()),
                throwsCode(expectError));
          } else {
            // Compared as serialized bytes. Dart's toProto3Json leaks whether
            // an implicit-presence field was ever assigned, which is not part
            // of proto semantics; the wire format omits defaults and so
            // normalizes exactly the way the spec means.
            final expected = buildMessage(type, messageFile!);
            final actual = codec.decode(document, _factories[type]!());
            expect(actual.writeToBuffer(), equals(expected.writeToBuffer()),
                reason: 'decoded: $actual\nexpected: $expected');
          }
        }
      });
    }
  });
}
