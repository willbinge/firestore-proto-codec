#!/bin/sh
# Regenerates the Dart code this package needs. Run from the repo root.
#
# Requires protoc and protoc-gen-dart on PATH. protoc supplies google/protobuf/*
# itself, so no include path is needed for the well-known types.
#
# descriptor.proto is generated into lib/ because package:protobuf does not
# ship it -- unlike timestamp.proto and the other well-known types, which the
# runtime provides and which must NOT be generated locally.
set -eu

protoc -I proto \
  --dart_out=dart/lib/src/generated \
  proto/codebinge/firestore/codec/v1/options.proto \
  google/protobuf/descriptor.proto

protoc -I proto -I testdata/schema \
  --dart_out=dart/test/generated \
  testdata/schema/testdata.proto testdata/schema/invalid.proto

protoc -I proto \
  --dart_out=dart/test/generated \
  proto/google/type/latlng.proto
