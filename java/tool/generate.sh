#!/bin/sh
# Regenerates the Java code this package needs. Run from anywhere.
#
# Requires protoc on PATH. protoc supplies google/protobuf/* itself, so no
# include path is needed for the well-known types.
#
# Only this repo's own protos are listed. The well-known types and
# google/protobuf/descriptor.proto come from the protobuf-java jar; generating
# local copies would shadow the runtime's classes with incompatible ones.
#
# google/type/latlng.proto IS generated here, for the test schema only. The
# codec itself never references the Java class -- it matches LatLng by
# descriptor full name -- so the library has no dependency on it, and
# generating it avoids pinning proto-google-common-protos against the runtime.
set -eu
cd "$(dirname "$0")/.."

protoc -I ../proto \
  --java_out=src/main/java \
  codebinge/firestore/codec/v1/options.proto

protoc -I ../proto -I ../testdata/schema \
  --java_out=src/test/java \
  testdata.proto invalid.proto google/type/latlng.proto
