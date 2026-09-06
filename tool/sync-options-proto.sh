#!/bin/sh
# Copies the canonical options.proto into each package so that a consumer who
# installs the package gets the file they need on their protoc include path.
# Registries publish only what is under the package directory, so a reference
# to ../../proto would not survive publication.
#
# Run from the repo root. With --check, verifies the copies are in sync and
# exits non-zero otherwise; that is what CI runs.
set -eu

SRC=proto/codebinge/firestore/codec/v1/options.proto
REL=codebinge/firestore/codec/v1/options.proto

# Java puts protos on the classpath under src/main/resources, so downstream
# builds can extract them from the jar; Dart and TypeScript have no such
# convention and use a plain proto/ directory.
DESTS="dart/proto/$REL ts/proto/$REL java/src/main/resources/$REL"

if [ "${1:-}" = "--check" ]; then
  status=0
  for dest in $DESTS; do
    if ! cmp -s "$SRC" "$dest"; then
      echo "out of sync: $dest" >&2
      status=1
    fi
  done
  [ "$status" -eq 0 ] && echo "options.proto copies are in sync"
  exit "$status"
fi

for dest in $DESTS; do
  mkdir -p "$(dirname "$dest")"
  cp "$SRC" "$dest"
  echo "synced $dest"
done
