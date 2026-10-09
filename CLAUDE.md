# firestore-proto-codec

Encodes a protobuf message as a Firestore value and decodes it back. A
specification plus three implementations that must agree.

**[`docs/encoding.md`](docs/encoding.md) is normative.** The implementations
follow it, not the reverse. Read the section you are touching before changing
behaviour — most of the non-obvious choices have their reasoning written down
there, including why they are not what you would guess.

## The things that will bite you

**The conformance vectors are the contract.** `testdata/` is shared by all three
implementations, and passing it is what "conforming" means
([§9](docs/encoding.md#9-conformance)). A behaviour change starts by adding a
vector, then making every language pass it. A fix that lands in one language
only is how three implementations drift apart.

**The extension number is 1376 and must never change.** It is registered to this
project in protobuf's Global Extension Registry, which reserves 1376–1380
([§7](docs/encoding.md#7-options)). It is baked into every generated artifact
and every consumer `.proto`. A consumer on a different number **stops seeing
annotations silently** rather than failing — fields quietly revert to default
encoding. Extension numbers are consumed per `extend` site, so a future
`MessageOptions` extension takes **1377**, not a reuse of 1376.

**Versions are per-implementation.** Published: Dart 0.1.0, TypeScript 0.2.0,
Java 0.1.0 — they do not track each other or the spec version
([§10](docs/encoding.md#10-stability)). npm is ahead because 0.1.0 was burned by
a bad publish; see [`RELEASING.md`](RELEASING.md). Each version file holds the
release being *prepared*, so it normally runs ahead of its registry; the top
`CHANGELOG.md` entry is what says whether a version has shipped.

**Silent failure is the enemy.** The whole spec exists because `toProto3Json()`
fails quietly — the write succeeds and the query is wrong. When choosing between
an explicit error and a plausible-looking fallback, this project errors. Keep
that bias.

## Layout

| Path | |
|---|---|
| [`docs/encoding.md`](docs/encoding.md) | the specification, normative |
| [`testdata/`](testdata/) | conformance vectors, shared by every implementation |
| `proto/.../options.proto` | canonical per-field options; copied into each package |
| `dart/`, `ts/`, `java/` | the three implementations |
| [`RELEASING.md`](RELEASING.md) | publishing to npm, pub.dev and Maven Central |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | how to change the encoding |

## Running things

```sh
./tool/sync-options-proto.sh --check   # each package ships its own copy
cd dart && dart test
cd ts   && npm ci && npm test
cd java && mvn test
```

CI runs exactly these, on every push and PR.

Regenerating protobuf code is per-package — `dart/tool/generate.sh`,
`ts/tool/generate.sh`, `java/tool/generate.sh` — and needs `protoc` plus that
language's plugin. CI does **not** check that generated code is current:
generator output varies with toolchain versions, so such a check would need all
three pinned exactly or it fails on an unrelated upgrade. Regenerate and commit
in the same change as the `.proto` edit.

If you change `proto/codebinge/firestore/codec/v1/options.proto`, run
`./tool/sync-options-proto.sh` — CI fails if the per-package copies drift.

## Conventions

- **Public files state requirements, not this machine's layout.** No
  `/opt/homebrew` paths, no macOS-only steps presented as the only way. The
  generate scripts used to hardcode a Homebrew include path and were unusable on
  Linux.
- **Generated code is excluded from the Dart analyzer**
  (`dart/analysis_options.yaml`). A lint on protoc output is not actionable
  except by changing the generator. Do not widen the exclusion to hand-written
  code.
- **Third-party material goes in [`NOTICE`](NOTICE)** with any modification
  stated in the file itself (Apache-2.0 §4(b)). `proto/google/type/latlng.proto`
  is vendored Google code; the generated Dart under
  `dart/lib/src/generated/google/protobuf/` is BSD-3 Google code.
- **Ask before anything public and permanent** — pushing, opening a PR,
  publishing a package, changing repo visibility. Approval for one does not
  carry to the next.
