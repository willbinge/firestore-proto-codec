// Copyright 2026 Code Binge LLC

package com.codebinge.firestore.codec;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;

import com.codebinge.firestore.codec.testdata.v1.Scalars;
import com.codebinge.firestore.codec.testdata.v1.WellKnown;
import org.junit.jupiter.api.Test;

/**
 * Guards the protobuf gencode/runtime pairing.
 *
 * <p>protobuf-java 4.x gencode calls {@code
 * RuntimeVersion.validateProtobufGencodeVersion} from a static initializer and
 * refuses to load when the runtime jar is older than the protoc that generated
 * it. That is a <em>class-load</em> failure, so compilation succeeds and the
 * mismatch only surfaces the first time a generated class is touched at
 * runtime.
 *
 * <p>If this fails with "Runtime version cannot be older than the linked
 * gencode version", either bump {@code protobuf.version} in pom.xml to the
 * version in the generated files' {@code Protobuf Java Version} header, or
 * re-run {@code tool/generate.sh} with a protoc matching the pinned runtime.
 */
class ProtoGencodeTest {

  @Test
  void generatedClassesLoadAgainstThePinnedRuntime() {
    // One class per generated .proto: the validation is per-class, so loading a
    // single one would only prove that file's vintage.
    assertDoesNotThrow(Scalars::getDefaultInstance);
    assertDoesNotThrow(com.codebinge.firestore.codec.v1.Field::getDefaultInstance);
    assertDoesNotThrow(com.codebinge.firestore.codec.testdata.v1.IntKeyMap::getDefaultInstance);
  }

  @Test
  void wellKnownTypesResolveToTheRuntimeCopy() {
    // testdata.proto imports google/protobuf/timestamp.proto, but the Java for
    // it must come from protobuf-java rather than a locally generated copy;
    // two com.google.protobuf.Timestamp classes would not interoperate.
    // Assigning the getter's result to the runtime type is what proves it.
    com.google.protobuf.Timestamp timestamp =
        WellKnown.newBuilder()
            .setTimestamp(com.google.protobuf.Timestamp.newBuilder().setSeconds(1700000000L))
            .build()
            .getTimestamp();
    assertEquals(1700000000L, timestamp.getSeconds());
    assertEquals(
        "google.protobuf.Timestamp",
        WellKnown.getDescriptor().findFieldByName("timestamp").getMessageType().getFullName());
  }

  @Test
  void customOptionsSurviveOntoTheDescriptor() {
    // The whole implementation depends on this: protobuf-java re-parses a
    // generated file's options with its extensions registered, which is why no
    // registration step is needed here.
    assertEquals(
        true,
        com.codebinge.firestore.codec.testdata.v1.Unsigned.getDescriptor()
            .findFieldByName("as_integer")
            .getOptions()
            .hasExtension(com.codebinge.firestore.codec.v1.Options.field));
  }
}
