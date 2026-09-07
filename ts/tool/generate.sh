#!/bin/sh
# Regenerates the TypeScript code this package needs. Run from anywhere.
#
# Requires protoc on PATH and `npm install` already run, for protoc-gen-es.
# protoc supplies google/protobuf/* itself, so no include path is needed for the
# well-known types.
set -eu
cd "$(dirname "$0")/.."

PLUGIN=./node_modules/.bin/protoc-gen-es
OPT=target=ts,import_extension=js

protoc -I ../proto \
  --plugin=protoc-gen-es=$PLUGIN --es_out=src/generated --es_opt=$OPT \
  codebinge/firestore/codec/v1/options.proto

# The test tree gets its own copy of options_pb.ts. protoc-gen-es emits
# relative imports within a single output root, so testdata.proto's import of
# the options file has to resolve inside test/generated. The duplicate is
# harmless: getOption matches by extension number and type, not by identity.
protoc -I ../proto -I ../testdata/schema \
  --plugin=protoc-gen-es=$PLUGIN --es_out=test/generated --es_opt=$OPT \
  testdata.proto invalid.proto google/type/latlng.proto \
  codebinge/firestore/codec/v1/options.proto
