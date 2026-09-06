// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import com.google.protobuf.ByteString;
import java.util.Optional;

/**
 * Firestore has three value types protobuf cannot express as plain data.
 * Implement this to bind them to a particular SDK's classes -- {@code Timestamp},
 * {@code Blob}, and {@code GeoPoint} in {@code google-cloud-firestore}, for
 * example. Everything else in the encoding is a {@code String}, {@code Long},
 * {@code Double}, {@code Boolean}, {@code List}, or {@code Map}.
 */
public interface FirestoreTypes {

  record TimestampParts(long seconds, int nanos) {}

  record GeoPointParts(double latitude, double longitude) {}

  Object timestamp(long seconds, int nanos);

  Object blob(ByteString bytes);

  Object geoPoint(double latitude, double longitude);

  /** Empty when the value is not of this type, so decoding can report a useful
   * error rather than throwing a ClassCastException. */
  Optional<TimestampParts> readTimestamp(Object value);

  Optional<ByteString> readBlob(Object value);

  Optional<GeoPointParts> readGeoPoint(Object value);
}
