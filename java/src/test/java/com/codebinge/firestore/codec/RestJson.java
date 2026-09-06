// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.protobuf.ByteString;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Converts between the codec's native output and Firestore REST {@code Value}
 * JSON, which is how the conformance vectors are written down. The REST form
 * names the Firestore type explicitly, which plain JSON cannot do -- it carries
 * an integer as a string and a blob as base64 purely as transport.
 */
final class RestJson {

  private RestJson() {}

  static JsonObject toRestDocument(Map<String, Object> fields) {
    JsonObject out = new JsonObject();
    fields.forEach((key, value) -> out.add(key, toRestValue(value)));
    return out;
  }

  static JsonElement toRestValue(Object value) {
    if (value instanceof String text) {
      return wrap("stringValue", new JsonPrimitive(text));
    }
    if (value instanceof Boolean flag) {
      return wrap("booleanValue", new JsonPrimitive(flag));
    }
    if (value instanceof Long number) {
      return wrap("integerValue", new JsonPrimitive(Long.toString(number)));
    }
    if (value instanceof Double number) {
      return wrap("doubleValue", restDouble(number));
    }
    if (value instanceof FsBlob blob) {
      return wrap(
          "bytesValue",
          new JsonPrimitive(Base64.getEncoder().encodeToString(blob.bytes().toByteArray())));
    }
    if (value instanceof FsTimestamp timestamp) {
      return wrap(
          "timestampValue",
          new JsonPrimitive(
              Instant.ofEpochSecond(timestamp.seconds(), timestamp.nanos()).toString()));
    }
    if (value instanceof FsGeoPoint point) {
      JsonObject geo = new JsonObject();
      geo.add("latitude", new JsonPrimitive(point.latitude()));
      geo.add("longitude", new JsonPrimitive(point.longitude()));
      return wrap("geoPointValue", geo);
    }
    if (value instanceof List<?> items) {
      JsonArray values = new JsonArray();
      items.forEach(item -> values.add(toRestValue(item)));
      JsonObject array = new JsonObject();
      array.add("values", values);
      return wrap("arrayValue", array);
    }
    if (value instanceof Map<?, ?> map) {
      JsonObject fields = new JsonObject();
      map.forEach((key, item) -> fields.add((String) key, toRestValue(item)));
      JsonObject wrapper = new JsonObject();
      wrapper.add("fields", fields);
      return wrap("mapValue", wrapper);
    }
    throw new IllegalArgumentException("no REST encoding for " + value.getClass());
  }

  static Map<String, Object> fromRestDocument(JsonObject document) {
    Map<String, Object> out = new LinkedHashMap<>();
    document.entrySet().forEach(entry -> out.put(entry.getKey(), fromRestValue(entry.getValue())));
    return out;
  }

  static Object fromRestValue(JsonElement element) {
    JsonObject value = element.getAsJsonObject();
    if (value.has("stringValue")) {
      return value.get("stringValue").getAsString();
    }
    if (value.has("booleanValue")) {
      return value.get("booleanValue").getAsBoolean();
    }
    if (value.has("integerValue")) {
      return Long.parseLong(value.get("integerValue").getAsString());
    }
    if (value.has("doubleValue")) {
      JsonElement raw = value.get("doubleValue");
      return raw.getAsJsonPrimitive().isString()
          ? parseSpecialDouble(raw.getAsString())
          : raw.getAsDouble();
    }
    if (value.has("bytesValue")) {
      return new FsBlob(
          ByteString.copyFrom(Base64.getDecoder().decode(value.get("bytesValue").getAsString())));
    }
    if (value.has("timestampValue")) {
      Instant instant = Instant.parse(value.get("timestampValue").getAsString());
      return new FsTimestamp(instant.getEpochSecond(), instant.getNano());
    }
    if (value.has("geoPointValue")) {
      JsonObject geo = value.getAsJsonObject("geoPointValue");
      return new FsGeoPoint(
          geo.has("latitude") ? geo.get("latitude").getAsDouble() : 0,
          geo.has("longitude") ? geo.get("longitude").getAsDouble() : 0);
    }
    if (value.has("arrayValue")) {
      JsonObject array = value.getAsJsonObject("arrayValue");
      List<Object> items = new ArrayList<>();
      if (array.has("values")) {
        array.getAsJsonArray("values").forEach(item -> items.add(fromRestValue(item)));
      }
      return items;
    }
    if (value.has("mapValue")) {
      JsonObject map = value.getAsJsonObject("mapValue");
      Map<String, Object> out = new LinkedHashMap<>();
      if (map.has("fields")) {
        map.getAsJsonObject("fields")
            .entrySet()
            .forEach(entry -> out.put(entry.getKey(), fromRestValue(entry.getValue())));
      }
      return out;
    }
    throw new IllegalArgumentException("unrecognized REST value: " + value);
  }

  private static JsonObject wrap(String kind, JsonElement value) {
    JsonObject out = new JsonObject();
    out.add(kind, value);
    return out;
  }

  private static JsonPrimitive restDouble(double d) {
    if (Double.isNaN(d)) {
      return new JsonPrimitive("NaN");
    }
    if (d == Double.POSITIVE_INFINITY) {
      return new JsonPrimitive("Infinity");
    }
    if (d == Double.NEGATIVE_INFINITY) {
      return new JsonPrimitive("-Infinity");
    }
    return new JsonPrimitive(d);
  }

  private static double parseSpecialDouble(String text) {
    return switch (text) {
      case "NaN" -> Double.NaN;
      case "Infinity" -> Double.POSITIVE_INFINITY;
      case "-Infinity" -> Double.NEGATIVE_INFINITY;
      default -> Double.parseDouble(text);
    };
  }
}
