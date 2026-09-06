// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.DynamicTest.dynamicTest;

import com.codebinge.firestore.codec.testdata.v1.AnyField;
import com.codebinge.firestore.codec.testdata.v1.Choice;
import com.codebinge.firestore.codec.testdata.v1.Composite;
import com.codebinge.firestore.codec.testdata.v1.Doubles;
import com.codebinge.firestore.codec.testdata.v1.Enums;
import com.codebinge.firestore.codec.testdata.v1.Inner;
import com.codebinge.firestore.codec.testdata.v1.IntKeyMap;
import com.codebinge.firestore.codec.testdata.v1.Presence;
import com.codebinge.firestore.codec.testdata.v1.Recursive;
import com.codebinge.firestore.codec.testdata.v1.Scalars;
import com.codebinge.firestore.codec.testdata.v1.StringifiedInt64;
import com.codebinge.firestore.codec.testdata.v1.StructField;
import com.codebinge.firestore.codec.testdata.v1.Unsigned;
import com.codebinge.firestore.codec.testdata.v1.WellKnown;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.protobuf.Message;
import com.google.protobuf.util.JsonFormat;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Stream;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

class ConformanceTest {

  private static final Path ROOT = Path.of("..", "testdata");

  private static final Map<String, Message> PROTOTYPES = prototypes();

  private final FirestoreProtoCodec codec = new FirestoreProtoCodec();

  private static Map<String, Message> prototypes() {
    Map<String, Message> out = new LinkedHashMap<>();
    for (Message prototype :
        new Message[] {
          Scalars.getDefaultInstance(),
          Doubles.getDefaultInstance(),
          Enums.getDefaultInstance(),
          Inner.getDefaultInstance(),
          Presence.getDefaultInstance(),
          Unsigned.getDefaultInstance(),
          WellKnown.getDefaultInstance(),
          Composite.getDefaultInstance(),
          com.codebinge.firestore.codec.testdata.v1.Options.getDefaultInstance(),
          Recursive.getDefaultInstance(),
          Choice.getDefaultInstance(),
          StringifiedInt64.getDefaultInstance(),
          IntKeyMap.getDefaultInstance(),
          AnyField.getDefaultInstance(),
          StructField.getDefaultInstance(),
        }) {
      out.put(prototype.getDescriptorForType().getFullName(), prototype);
    }
    return out;
  }

  @TestFactory
  Stream<DynamicTest> conformance() throws IOException {
    JsonObject manifest = readJson("manifest.json");
    JsonArray cases = manifest.getAsJsonArray("cases");
    return Stream.iterate(0, i -> i + 1)
        .limit(cases.size())
        .map(i -> cases.get(i).getAsJsonObject())
        .map(c -> dynamicTest(name(c) + " (" + text(c, "direction") + ")", () -> run(c)));
  }

  private void run(JsonObject c) throws IOException {
    String direction = text(c, "direction");
    String expectError = c.has("expect_error") ? text(c, "expect_error") : null;
    Message prototype = PROTOTYPES.get(text(c, "message"));
    assertNotNull(prototype, "no prototype registered for " + text(c, "message"));

    if (direction.equals("schema")) {
      CodecError error =
          assertThrows(
              CodecError.class,
              () -> codec.validateSchema(prototype.getDescriptorForType()));
      assertEquals(expectError, error.code().wireName());
      return;
    }

    if (direction.equals("encode") || direction.equals("roundtrip")) {
      Message message = buildMessage(prototype, text(c, "message_file"));
      if (expectError != null) {
        CodecError error = assertThrows(CodecError.class, () -> codec.encode(message));
        assertEquals(expectError, error.code().wireName());
      } else {
        assertEquals(
            readJson(text(c, "document_file")),
            RestJson.toRestDocument(codec.encode(message)));
      }
    }

    if (direction.equals("decode") || direction.equals("roundtrip")) {
      Map<String, Object> document =
          RestJson.fromRestDocument(readJson(text(c, "document_file")));
      if (expectError != null) {
        CodecError error =
            assertThrows(CodecError.class, () -> codec.decode(document, prototype));
        assertEquals(expectError, error.code().wireName());
      } else {
        // Compared as serialized bytes: the wire format omits implicit defaults
        // and encodes NaN deterministically, so it normalizes exactly the way
        // the spec means.
        Message actual = codec.decode(document, prototype);
        Message expected = buildMessage(prototype, text(c, "message_file"));
        assertArrayEquals(
            expected.toByteArray(),
            actual.toByteArray(),
            () -> "decoded: " + actual + "\nexpected: " + expected);
      }
    }
  }

  private static Message buildMessage(Message prototype, String relative) throws IOException {
    Message.Builder builder = prototype.newBuilderForType();
    JsonFormat.parser().merge(Files.readString(ROOT.resolve(relative)), builder);
    return builder.build();
  }

  private static JsonObject readJson(String relative) throws IOException {
    return JsonParser.parseString(Files.readString(ROOT.resolve(relative))).getAsJsonObject();
  }

  private static String name(JsonObject c) {
    return text(c, "name");
  }

  private static String text(JsonObject c, String key) {
    return c.get(key).getAsString();
  }
}
