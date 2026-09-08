// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Blob;
import com.google.cloud.firestore.GeoPoint;
import com.google.protobuf.ByteString;
import java.util.Optional;

/**
 * {@link FirestoreTypes} for the Firestore server SDK. {@code google-cloud-firestore}
 * and {@code firebase-admin} share these classes -- the latter bundles the former
 * and re-exports {@code com.google.cloud.firestore.*} -- so one adapter serves both.
 *
 * <pre>{@code
 * Map<String, Object> document = CloudFirestoreTypes.CODEC.encode(task);
 * }</pre>
 *
 * <p>Not a convenience. Without an adapter the codec emits {@link FsTimestamp} /
 * {@link FsBlob} / {@link FsGeoPoint}, which are this library's placeholders
 * rather than Firestore values: a document carrying them is not a document you
 * want stored. Every consumer writing to a real database needs this, which is
 * why it ships here rather than being copied out of the README.
 *
 * <p>{@code google-cloud-firestore} is an <em>optional</em> dependency, so it does
 * not enter a consumer's tree on this library's account and nobody who skips this
 * class pays for it. Declare it yourself -- directly, or through firebase-admin --
 * to use this adapter.
 *
 * <p>The reads are {@code instanceof}, unlike the TypeScript adapter's structural
 * checks. That difference is Maven's doing, not a disagreement: npm nests
 * duplicate versions routinely, so two copies of a class can coexist and defeat
 * an identity check, while Maven resolves one version per coordinate onto the
 * classpath. Two live copies here would take shading or separate classloaders,
 * which no version range produces on its own.
 */
public final class CloudFirestoreTypes implements FirestoreTypes {

  /** Shared instance: neither the codec nor this adapter keeps any state. */
  public static final FirestoreProtoCodec CODEC =
      new FirestoreProtoCodec(new CloudFirestoreTypes());

  @Override
  public Object timestamp(long seconds, int nanos) {
    return Timestamp.ofTimeSecondsAndNanos(seconds, nanos);
  }

  @Override
  public Object blob(ByteString bytes) {
    // Blob wraps the ByteString without copying, which is safe because
    // ByteString is immutable.
    return Blob.fromByteString(bytes);
  }

  @Override
  public Object geoPoint(double latitude, double longitude) {
    return new GeoPoint(latitude, longitude);
  }

  @Override
  public Optional<TimestampParts> readTimestamp(Object value) {
    return value instanceof Timestamp ts
        ? Optional.of(new TimestampParts(ts.getSeconds(), ts.getNanos()))
        : Optional.empty();
  }

  @Override
  public Optional<ByteString> readBlob(Object value) {
    return value instanceof Blob blob ? Optional.of(blob.toByteString()) : Optional.empty();
  }

  @Override
  public Optional<GeoPointParts> readGeoPoint(Object value) {
    return value instanceof GeoPoint point
        ? Optional.of(new GeoPointParts(point.getLatitude(), point.getLongitude()))
        : Optional.empty();
  }
}
