// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.codebinge.firestore.codec.testdata.v1.Scalars;
import com.codebinge.firestore.codec.testdata.v1.WellKnown;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Blob;
import com.google.cloud.firestore.GeoPoint;
import com.google.protobuf.ByteString;
import com.google.type.LatLng;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The shipped SDK adapter, against the real classes but no server. Every value
 * class it touches is constructible on its own, so this needs no emulator and
 * runs in the ordinary suite.
 */
final class CloudFirestoreTypesTest {

  private final CloudFirestoreTypes types = new CloudFirestoreTypes();

  @Test
  @DisplayName("encodes to native SDK values and back")
  void encodesNativeValues() {
    WellKnown message =
        WellKnown.newBuilder()
            .setTimestamp(
                com.google.protobuf.Timestamp.newBuilder().setSeconds(1700000000).setNanos(123456000))
            .setLocation(LatLng.newBuilder().setLatitude(37.4).setLongitude(-122.1))
            .build();

    Map<String, Object> document = CloudFirestoreTypes.CODEC.encode(message);

    Timestamp stored = assertInstanceOf(Timestamp.class, document.get("timestamp"));
    assertEquals(1700000000L, stored.getSeconds());
    assertEquals(123456000, stored.getNanos());
    GeoPoint point = assertInstanceOf(GeoPoint.class, document.get("location"));
    assertEquals(37.4, point.getLatitude());
    assertEquals(-122.1, point.getLongitude());

    assertEquals(message, CloudFirestoreTypes.CODEC.decode(document, WellKnown.getDefaultInstance()));
  }

  @Test
  @DisplayName("bytes encode as a Blob and decode back to a ByteString")
  void encodesBytesAsBlob() {
    Scalars message =
        Scalars.newBuilder().setBytesField(ByteString.copyFrom(new byte[] {1, 2, 3})).build();

    Map<String, Object> document = CloudFirestoreTypes.CODEC.encode(message);
    assertInstanceOf(Blob.class, document.get("bytes_field"));

    assertEquals(message, CloudFirestoreTypes.CODEC.decode(document, Scalars.getDefaultInstance()));
  }

  @Test
  @DisplayName("the reads refuse a value of the wrong type rather than throwing")
  void readsRefuseWrongTypes() {
    // The codec turns an empty Optional into a CodecError naming the field, so
    // these must not throw a ClassCastException on the way past.
    for (Object value : new Object[] {"x", 7L, Map.of(), new FsTimestamp(1, 0)}) {
      assertEquals(Optional.empty(), types.readTimestamp(value));
      assertEquals(Optional.empty(), types.readBlob(value));
      assertEquals(Optional.empty(), types.readGeoPoint(value));
    }
  }

  @Test
  @DisplayName("a nanosecond value survives the round trip through the SDK class")
  void keepsNanoseconds() {
    // com.google.cloud.Timestamp holds nanoseconds, so nothing is lost here.
    // Firestore itself truncates to microseconds on a real write; that is the
    // server's doing and only the TypeScript emulator suite can pin it.
    Object stored = types.timestamp(1700000000L, 123456789);
    assertTrue(types.readTimestamp(stored).isPresent());
    assertEquals(
        new FirestoreTypes.TimestampParts(1700000000L, 123456789),
        types.readTimestamp(stored).orElseThrow());
  }
}
