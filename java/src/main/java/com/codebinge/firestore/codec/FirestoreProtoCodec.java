// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import com.codebinge.firestore.codec.v1.EnumEncoding;
import com.codebinge.firestore.codec.v1.Kind;
import com.codebinge.firestore.codec.v1.Options;
import com.google.protobuf.ByteString;
import com.google.protobuf.Descriptors.Descriptor;
import com.google.protobuf.Descriptors.EnumValueDescriptor;
import com.google.protobuf.Descriptors.FieldDescriptor;
import com.google.protobuf.DescriptorProtos.FieldOptions;
import com.google.protobuf.Message;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Encodes a protobuf message as a Firestore value, and decodes it back.
 *
 * <p>See {@code docs/encoding.md} for the rules. The output is a map of
 * Firestore-native values: plain Java types, plus whatever {@link FirestoreTypes}
 * produces for timestamps, blobs, and geo points.
 */
public final class FirestoreProtoCodec {

  /** Firestore's limit on the depth of fields in a map or array. */
  public static final int MAX_NESTING_DEPTH = 20;

  private static final String TIMESTAMP = "google.protobuf.Timestamp";
  private static final String DURATION = "google.protobuf.Duration";
  private static final String LAT_LNG = "google.type.LatLng";

  private static final Set<String> UNSUPPORTED =
      Set.of(
          "google.protobuf.Any",
          "google.protobuf.Struct",
          "google.protobuf.Value",
          "google.protobuf.ListValue",
          "google.protobuf.FieldMask");

  private static final Pattern CANONICAL_UNSIGNED = Pattern.compile("^(0|[1-9][0-9]*)$");
  private static final BigInteger MAX_UINT64 =
      BigInteger.ONE.shiftLeft(64).subtract(BigInteger.ONE);

  private record FieldRules(
      boolean skip,
      String name,
      boolean enumAsNumber,
      boolean omitWhenDefault,
      boolean unsignedAsInteger,
      boolean geoPoint) {}

  private static final FieldRules DEFAULT_RULES =
      new FieldRules(false, null, false, true, false, false);

  private final FirestoreTypes types;

  public FirestoreProtoCodec() {
    this(new DefaultFirestoreTypes());
  }

  public FirestoreProtoCodec(FirestoreTypes types) {
    this.types = types;
  }

  public Map<String, Object> encode(Message message) {
    return encodeMessage(message, 1, "");
  }

  /** Decodes into a new message of {@code prototype}'s type. */
  public <T extends Message> T decode(Map<String, Object> document, T prototype) {
    Message.Builder builder = prototype.newBuilderForType();
    decodeInto(builder, document, "");
    @SuppressWarnings("unchecked")
    T result = (T) builder.build();
    return result;
  }

  /** Throws if this type, or any type it reaches, cannot be encoded. */
  public void validateSchema(Descriptor descriptor) {
    validate(descriptor, new HashSet<>(), descriptor.getFullName());
  }

  /**
   * Reads the custom options straight off the descriptor. protobuf-java
   * re-parses a generated file's options with its extensions registered, so
   * unlike the Dart runtime this needs no registration step.
   */
  private static FieldRules rulesFor(FieldDescriptor fd) {
    FieldOptions options = fd.getOptions();
    if (!options.hasExtension(Options.field)) {
      return DEFAULT_RULES;
    }
    com.codebinge.firestore.codec.v1.Field f = options.getExtension(Options.field);
    return new FieldRules(
        f.getSkip(),
        f.getName().isEmpty() ? null : f.getName(),
        f.getEnumAs() == EnumEncoding.ENUM_ENCODING_NUMBER,
        // Explicit presence: the intended default is true, which an implicit
        // proto3 bool could not express.
        !f.hasOmitWhenDefault() || f.getOmitWhenDefault(),
        f.getKind() == Kind.KIND_UNSIGNED_AS_INTEGER,
        f.getKind() == Kind.KIND_GEO_POINT);
  }

  private static String storedName(FieldDescriptor fd, FieldRules rules) {
    return rules.name() != null ? rules.name() : fd.getName();
  }

  // ------------------------------------------------------------------ encoding

  private Map<String, Object> encodeMessage(Message message, int depth, String path) {
    checkDepth(depth, path);
    Map<String, Object> out = new LinkedHashMap<>();
    for (FieldDescriptor fd : message.getDescriptorForType().getFields()) {
      FieldRules rules = rulesFor(fd);
      if (rules.skip()) {
        continue;
      }
      String name = storedName(fd, rules);
      String fieldPath = path.isEmpty() ? name : path + "." + name;

      if (fd.isMapField()) {
        requireStringKeys(fd, fieldPath);
        List<?> entries = (List<?>) message.getField(fd);
        if (entries.isEmpty()) {
          continue;
        }
        // The map is a level of its own, and each value sits inside it.
        checkDepth(depth + 1, fieldPath);
        FieldDescriptor keyField = fd.getMessageType().findFieldByName("key");
        FieldDescriptor valueField = fd.getMessageType().findFieldByName("value");
        Map<String, Object> encoded = new LinkedHashMap<>();
        for (Object raw : entries) {
          Message entry = (Message) raw;
          String key = (String) entry.getField(keyField);
          encoded.put(
              key,
              encodeValue(
                  valueField,
                  entry.getField(valueField),
                  DEFAULT_RULES,
                  depth + 1,
                  fieldPath + "." + key));
        }
        out.put(name, encoded);
      } else if (fd.isRepeated()) {
        List<?> items = (List<?>) message.getField(fd);
        if (items.isEmpty()) {
          continue;
        }
        // The array is a level of its own, and each element sits inside it.
        checkDepth(depth + 1, fieldPath);
        List<Object> encoded = new ArrayList<>(items.size());
        for (int i = 0; i < items.size(); i++) {
          encoded.add(
              encodeValue(fd, items.get(i), rules, depth + 1, fieldPath + "[" + i + "]"));
        }
        out.put(name, encoded);
      } else if (fd.hasPresence()) {
        if (!message.hasField(fd)) {
          continue;
        }
        out.put(name, encodeValue(fd, message.getField(fd), rules, depth, fieldPath));
      } else {
        Object value = message.getField(fd);
        if (rules.omitWhenDefault() && isDefault(fd, value)) {
          continue;
        }
        out.put(name, encodeValue(fd, value, rules, depth, fieldPath));
      }
    }
    return out;
  }

  private Object encodeValue(
      FieldDescriptor fd, Object value, FieldRules rules, int depth, String path) {
    switch (fd.getType()) {
      case STRING:
      case BOOL:
        return value;
      case BYTES:
        return types.blob((ByteString) value);
      case DOUBLE:
      case FLOAT:
        return ((Number) value).doubleValue();
      case INT32:
      case SINT32:
      case SFIXED32:
        return ((Number) value).longValue();
      case UINT32:
      case FIXED32:
        // Java stores uint32 in a signed int, so anything above 2^31-1 reads
        // back negative and must be widened as unsigned.
        return Integer.toUnsignedLong((Integer) value);
      case INT64:
      case SINT64:
      case SFIXED64:
        return value;
      case UINT64:
      case FIXED64:
        return encodeUnsigned((Long) value, rules, path);
      case ENUM: {
        EnumValueDescriptor enumValue = (EnumValueDescriptor) value;
        if (rules.enumAsNumber()) {
          return (long) enumValue.getNumber();
        }
        if (fd.getEnumType().findValueByNumber(enumValue.getNumber()) == null) {
          // A number with no declared name, relayed from a newer writer. Its
          // synthetic UNKNOWN_ENUM_VALUE_* name would decode to zero everywhere,
          // silently destroying the value, so refuse (§4).
          throw new CodecError(
              CodecErrorCode.ENUM_VALUE_UNKNOWN,
              fd.getEnumType().getFullName() + " has no name for value " + enumValue.getNumber(),
              path);
        }
        return enumValue.getName();
      }
      case MESSAGE:
      case GROUP:
        return encodeMessageValue((Message) value, rules, depth, path);
      default:
        throw new CodecError(
            CodecErrorCode.UNSUPPORTED_TYPE, "no encoding for field type " + fd.getType(), path);
    }
  }

  private Object encodeUnsigned(long value, FieldRules rules, String path) {
    if (!rules.unsignedAsInteger()) {
      return Long.toUnsignedString(value);
    }
    if (Long.compareUnsigned(value, Long.MAX_VALUE) > 0) {
      throw new CodecError(
          CodecErrorCode.UNSIGNED_NOT_REPRESENTABLE,
          "KIND_UNSIGNED_AS_INTEGER cannot represent "
              + Long.toUnsignedString(value)
              + "; Firestore integers are signed 64-bit",
          path);
    }
    return value;
  }

  private Object encodeMessageValue(Message sub, FieldRules rules, int depth, String path) {
    Descriptor descriptor = sub.getDescriptorForType();
    String typeName = descriptor.getFullName();
    if (UNSUPPORTED.contains(typeName)) {
      throw new CodecError(
          CodecErrorCode.UNSUPPORTED_TYPE, typeName + " has no Firestore representation", path);
    }
    if (TIMESTAMP.equals(typeName)) {
      return types.timestamp(longField(sub, "seconds"), (int) longField(sub, "nanos"));
    }
    if (DURATION.equals(typeName)) {
      return longField(sub, "seconds") * 1_000_000L + longField(sub, "nanos") / 1000L;
    }
    if (LAT_LNG.equals(typeName) || rules.geoPoint()) {
      double latitude = doubleField(sub, "latitude", path);
      double longitude = doubleField(sub, "longitude", path);
      if (Double.isNaN(latitude)
          || Double.isNaN(longitude)
          || latitude < -90
          || latitude > 90
          || longitude < -180
          || longitude > 180) {
        throw new CodecError(
            CodecErrorCode.LATLNG_OUT_OF_RANGE,
            "latitude must be within [-90, 90] and longitude within [-180, 180], got ("
                + latitude
                + ", "
                + longitude
                + ")",
            path);
      }
      return types.geoPoint(latitude, longitude);
    }
    return encodeMessage(sub, depth + 1, path);
  }

  // ------------------------------------------------------------------ decoding

  private void decodeInto(Message.Builder builder, Map<String, Object> document, String path) {
    for (FieldDescriptor fd : builder.getDescriptorForType().getFields()) {
      FieldRules rules = rulesFor(fd);
      if (rules.skip()) {
        continue;
      }
      String name = storedName(fd, rules);
      String fieldPath = path.isEmpty() ? name : path + "." + name;
      if (fd.isMapField()) {
        requireStringKeys(fd, fieldPath);
      }
      if (!document.containsKey(name)) {
        continue;
      }
      Object raw = document.get(name);
      if (raw == null) {
        continue;
      }

      if (fd.isMapField()) {
        FieldDescriptor keyField = fd.getMessageType().findFieldByName("key");
        FieldDescriptor valueField = fd.getMessageType().findFieldByName("value");
        for (Map.Entry<?, ?> entry : ((Map<?, ?>) raw).entrySet()) {
          String key = (String) entry.getKey();
          Message.Builder entryBuilder = builder.newBuilderForField(fd);
          entryBuilder.setField(keyField, key);
          entryBuilder.setField(
              valueField,
              decodeValue(
                  valueField, entry.getValue(), DEFAULT_RULES, entryBuilder, fieldPath + "." + key));
          builder.addRepeatedField(fd, entryBuilder.build());
        }
      } else if (fd.isRepeated()) {
        List<?> items = (List<?>) raw;
        for (int i = 0; i < items.size(); i++) {
          builder.addRepeatedField(
              fd, decodeValue(fd, items.get(i), rules, builder, fieldPath + "[" + i + "]"));
        }
      } else {
        Object decoded = decodeValue(fd, raw, rules, builder, fieldPath);
        // Leaving an implicit field at its default keeps a decoded message
        // equal to one that never had it set.
        if (!fd.hasPresence() && isDefault(fd, decoded)) {
          continue;
        }
        builder.setField(fd, decoded);
      }
    }
  }

  private Object decodeValue(
      FieldDescriptor fd, Object raw, FieldRules rules, Message.Builder parent, String path) {
    switch (fd.getType()) {
      case STRING:
      case BOOL:
        return raw;
      case BYTES:
        return types
            .readBlob(raw)
            .orElseThrow(
                () ->
                    new CodecError(
                        CodecErrorCode.UNSUPPORTED_TYPE, "expected a blob", path));
      // Coerced through Number, never cast: an integral double is stored as a
      // Firestore Integer by the JavaScript SDK, so this field may legitimately
      // arrive as a Long.
      case DOUBLE:
        return ((Number) raw).doubleValue();
      case FLOAT:
        return ((Number) raw).floatValue();
      case INT32:
      case SINT32:
      case SFIXED32:
        return ((Number) raw).intValue();
      case UINT32:
      case FIXED32:
        return (int) ((Number) raw).longValue();
      case INT64:
      case SINT64:
      case SFIXED64:
        return ((Number) raw).longValue();
      case UINT64:
      case FIXED64:
        return rules.unsignedAsInteger() ? ((Number) raw).longValue() : decodeUnsigned(raw, path);
      case ENUM:
        return decodeEnum(fd, raw);
      case MESSAGE:
      case GROUP:
        return decodeMessageValue(fd, raw, rules, parent, path);
      default:
        throw new CodecError(
            CodecErrorCode.UNSUPPORTED_TYPE, "no decoding for field type " + fd.getType(), path);
    }
  }

  /** An unknown name decodes to the zero value rather than throwing, so an old
   * reader survives a document written by a newer writer. */
  private static EnumValueDescriptor decodeEnum(FieldDescriptor fd, Object raw) {
    EnumValueDescriptor zero = fd.getEnumType().findValueByNumber(0);
    EnumValueDescriptor found =
        raw instanceof Number number
            ? fd.getEnumType().findValueByNumber(number.intValue())
            : fd.getEnumType().findValueByName((String) raw);
    if (found != null) {
      return found;
    }
    return zero != null ? zero : fd.getEnumType().getValues().get(0);
  }

  private long decodeUnsigned(Object raw, String path) {
    if (!(raw instanceof String text)) {
      throw new CodecError(
          CodecErrorCode.UNSIGNED_MALFORMED,
          "expected a decimal string, got " + raw.getClass().getSimpleName(),
          path);
    }
    if (!CANONICAL_UNSIGNED.matcher(text).matches()) {
      throw new CodecError(
          CodecErrorCode.UNSIGNED_MALFORMED,
          "not a canonical unsigned decimal (no sign, no leading zeros): \"" + text + "\"",
          path);
    }
    if (new BigInteger(text).compareTo(MAX_UINT64) > 0) {
      throw new CodecError(
          CodecErrorCode.UNSIGNED_OUT_OF_RANGE,
          text + " exceeds the maximum unsigned 64-bit value",
          path);
    }
    // Reinterpreted as two's complement: Java's long is signed, so anything at
    // or above 2^63 is stored negative and only reads back correctly unsigned.
    return Long.parseUnsignedLong(text);
  }

  private Object decodeMessageValue(
      FieldDescriptor fd, Object raw, FieldRules rules, Message.Builder parent, String path) {
    Descriptor descriptor = fd.getMessageType();
    String typeName = descriptor.getFullName();
    if (UNSUPPORTED.contains(typeName)) {
      throw new CodecError(
          CodecErrorCode.UNSUPPORTED_TYPE, typeName + " has no Firestore representation", path);
    }
    Message.Builder sub = parent.newBuilderForField(fd);
    if (TIMESTAMP.equals(typeName)) {
      FirestoreTypes.TimestampParts parts =
          types
              .readTimestamp(raw)
              .orElseThrow(
                  () ->
                      new CodecError(
                          CodecErrorCode.UNSUPPORTED_TYPE, "expected a timestamp", path));
      sub.setField(descriptor.findFieldByName("seconds"), parts.seconds());
      sub.setField(descriptor.findFieldByName("nanos"), parts.nanos());
      return sub.build();
    }
    if (DURATION.equals(typeName)) {
      long micros = ((Number) raw).longValue();
      sub.setField(descriptor.findFieldByName("seconds"), micros / 1_000_000L);
      sub.setField(descriptor.findFieldByName("nanos"), (int) (micros % 1_000_000L) * 1000);
      return sub.build();
    }
    if (LAT_LNG.equals(typeName) || rules.geoPoint()) {
      FirestoreTypes.GeoPointParts parts =
          types
              .readGeoPoint(raw)
              .orElseThrow(
                  () ->
                      new CodecError(
                          CodecErrorCode.UNSUPPORTED_TYPE, "expected a geo point", path));
      sub.setField(descriptor.findFieldByName("latitude"), parts.latitude());
      sub.setField(descriptor.findFieldByName("longitude"), parts.longitude());
      return sub.build();
    }
    @SuppressWarnings("unchecked")
    Map<String, Object> nested = (Map<String, Object>) raw;
    decodeInto(sub, nested, path);
    return sub.build();
  }

  // ---------------------------------------------------------------- validation

  private void validate(Descriptor descriptor, Set<String> seen, String path) {
    if (!seen.add(descriptor.getFullName())) {
      return;
    }
    for (FieldDescriptor fd : descriptor.getFields()) {
      if (rulesFor(fd).skip()) {
        continue;
      }
      String fieldPath = path + "." + fd.getName();
      if (fd.isMapField()) {
        requireStringKeys(fd, fieldPath);
        FieldDescriptor valueField = fd.getMessageType().findFieldByName("value");
        if (valueField.getJavaType() == FieldDescriptor.JavaType.MESSAGE) {
          validateSub(valueField.getMessageType(), seen, fieldPath);
        }
      } else if (fd.getJavaType() == FieldDescriptor.JavaType.MESSAGE) {
        validateSub(fd.getMessageType(), seen, fieldPath);
      }
    }
  }

  private void validateSub(Descriptor descriptor, Set<String> seen, String path) {
    String typeName = descriptor.getFullName();
    if (UNSUPPORTED.contains(typeName)) {
      throw new CodecError(
          CodecErrorCode.UNSUPPORTED_TYPE, typeName + " has no Firestore representation", path);
    }
    if (TIMESTAMP.equals(typeName) || DURATION.equals(typeName) || LAT_LNG.equals(typeName)) {
      return;
    }
    validate(descriptor, seen, path);
  }

  // --------------------------------------------------------------------- utils

  /** Every map and array is a level; the document itself is level 1. */
  private static void checkDepth(int depth, String path) {
    if (depth > MAX_NESTING_DEPTH) {
      throw new CodecError(
          CodecErrorCode.NESTING_TOO_DEEP,
          "nesting exceeds Firestore's limit of " + MAX_NESTING_DEPTH + " levels",
          path);
    }
  }

  /**
   * Checked on every encode and decode, not only in {@link #validateSchema}, so
   * a caller who skips validation still cannot write stringified keys.
   */
  private static void requireStringKeys(FieldDescriptor fd, String path) {
    FieldDescriptor keyField = fd.getMessageType().findFieldByName("key");
    if (keyField.getType() != FieldDescriptor.Type.STRING) {
      throw new CodecError(
          CodecErrorCode.UNSUPPORTED_MAP_KEY,
          "map keys must be strings; Firestore has no other key type",
          path);
    }
  }

  /**
   * Floating-point defaults are compared numerically rather than through
   * {@code equals}, so that -0.0 counts as the default. {@code Double.equals}
   * compares bits and would keep it, which would write a field the Dart and
   * TypeScript implementations omit.
   */
  private static boolean isDefault(FieldDescriptor fd, Object value) {
    if (fd.getJavaType() == FieldDescriptor.JavaType.DOUBLE
        || fd.getJavaType() == FieldDescriptor.JavaType.FLOAT) {
      return ((Number) value).doubleValue() == 0.0;
    }
    return java.util.Objects.equals(value, fd.getDefaultValue());
  }

  private static long longField(Message message, String name) {
    Object value = message.getField(message.getDescriptorForType().findFieldByName(name));
    return ((Number) value).longValue();
  }

  private static double doubleField(Message message, String name, String path) {
    FieldDescriptor fd = message.getDescriptorForType().findFieldByName(name);
    if (fd == null) {
      throw new CodecError(
          CodecErrorCode.UNSUPPORTED_TYPE,
          "KIND_GEO_POINT requires double fields named latitude and longitude",
          path);
    }
    return ((Number) message.getField(fd)).doubleValue();
  }
}
