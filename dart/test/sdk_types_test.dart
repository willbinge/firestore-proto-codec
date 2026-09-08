// The shipped injected-constructor adapter, against classes shaped like
// cloud_firestore's. Those real classes cannot appear here -- they live in a
// package that depends on the Flutter SDK, which is the whole reason
// SdkFirestoreTypes takes constructors instead of naming types -- so the fakes
// below carry the shape the adapter actually reads: `seconds`/`nanoseconds`,
// `bytes`, and `latitude`/`longitude`.
import 'dart:typed_data';

import 'package:firestore_proto_codec/firestore_proto_codec.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as wkt;
import 'package:test/test.dart';

import 'generated/google/type/latlng.pb.dart' as gt;
import 'generated/testdata.pb.dart' as td;

class FakeTimestamp {
  FakeTimestamp(this.seconds, this.nanoseconds);
  final int seconds;
  final int nanoseconds;
}

class FakeBlob {
  FakeBlob(this.bytes);
  final Uint8List bytes;
}

class FakeGeoPoint {
  FakeGeoPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

final types = SdkFirestoreTypes(
  timestamp: FakeTimestamp.new,
  blob: FakeBlob.new,
  geoPoint: FakeGeoPoint.new,
);
final codec = FirestoreProtoCodec(types: types);

void main() {
  group('SdkFirestoreTypes', () {
    test('encodes through the injected constructors and back', () {
      final message = td.WellKnown(
        timestamp: wkt.Timestamp(
          seconds: Int64(1700000000),
          nanos: 123456000,
        ),
        location: gt.LatLng(latitude: 37.4, longitude: -122.1),
      );

      final document = codec.encode(message);
      final stored = document['timestamp'];
      expect(stored, isA<FakeTimestamp>());
      expect((stored! as FakeTimestamp).seconds, 1700000000);
      expect((stored as FakeTimestamp).nanoseconds, 123456000);
      expect(document['location'], isA<FakeGeoPoint>());

      expect(codec.decode(document, td.WellKnown()), message);
    });

    test('bytes go out through the blob constructor and come back raw', () {
      final message = td.Scalars(bytesField: [1, 2, 3]);

      final document = codec.encode(message);
      expect(document['bytes_field'], isA<FakeBlob>());

      expect(codec.decode(document, td.Scalars()), message);
    });

    test('an SDK that hands bytes back unwrapped is read directly', () {
      expect(types.readBlob(Uint8List.fromList([1, 2, 3])), [1, 2, 3]);
    });

    test('a value of the wrong shape reads as null rather than throwing', () {
      for (final value in <Object>[
        'x',
        7,
        <String, Object>{},
        FakeGeoPoint(1, 2),
      ]) {
        expect(types.readTimestamp(value), isNull);
        expect(types.readBlob(value), isNull);
      }
      expect(types.readGeoPoint('x'), isNull);
      expect(types.readGeoPoint(FakeTimestamp(1, 0)), isNull);
    });

    test('half a timestamp is not a timestamp', () {
      // `seconds` alone would be enough for a cast to succeed in a language
      // with structural typing; here it must not be.
      expect(types.readTimestamp(_SecondsOnly(1)), isNull);
    });
  });
}

class _SecondsOnly {
  _SecondsOnly(this.seconds);
  final int seconds;
}
