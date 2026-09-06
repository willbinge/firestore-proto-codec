// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import com.google.protobuf.ByteString;
import java.util.Optional;

/** Dependency-free default. Swap in an SDK-specific implementation to write
 * directly to Firestore. */
public final class DefaultFirestoreTypes implements FirestoreTypes {

  @Override
  public Object timestamp(long seconds, int nanos) {
    return new FsTimestamp(seconds, nanos);
  }

  @Override
  public Object blob(ByteString bytes) {
    return new FsBlob(bytes);
  }

  @Override
  public Object geoPoint(double latitude, double longitude) {
    return new FsGeoPoint(latitude, longitude);
  }

  @Override
  public Optional<TimestampParts> readTimestamp(Object value) {
    return value instanceof FsTimestamp ts
        ? Optional.of(new TimestampParts(ts.seconds(), ts.nanos()))
        : Optional.empty();
  }

  @Override
  public Optional<ByteString> readBlob(Object value) {
    return value instanceof FsBlob blob ? Optional.of(blob.bytes()) : Optional.empty();
  }

  @Override
  public Optional<GeoPointParts> readGeoPoint(Object value) {
    return value instanceof FsGeoPoint point
        ? Optional.of(new GeoPointParts(point.latitude(), point.longitude()))
        : Optional.empty();
  }
}
