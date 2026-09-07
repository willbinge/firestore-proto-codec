# Contributing

## The vectors are the contract

`testdata/` is shared by every implementation, and passing it is what
"conforming" means ([§9](docs/encoding.md#9-conformance)). Two consequences for
any change:

- **A behavior change starts with a vector.** Add the case to
  `testdata/manifest.json` and `testdata/cases/`, then make every implementation
  pass it. A fix landing in one language and not the others is how the three
  drift apart.
- **A new vector must not encode one runtime's quirks.** If a case cannot be
  built in some language — Dart's closed enums cannot construct an unknown enum
  number, for instance — give it a `requires` entry rather than dropping it.

## Changing the encoding itself

Read [§10](docs/encoding.md#10-stability) first. Some things are still free to
change while the spec is draft; several are already frozen at v1.0, and one —
the option extension number — is a one-way door once registered.

Spec changes go in `docs/encoding.md` in the same commit as the vectors that
pin them. The spec is normative; the implementations follow it, not the reverse.

## Running everything

```sh
./tool/sync-options-proto.sh --check   # each package ships its own copy
cd dart && dart test
cd ts   && npm ci && npm test
cd java && mvn test
```

CI runs exactly these.

Regenerating protobuf code is per-package: `dart/tool/generate.sh`,
`ts/tool/generate.sh`, `java/tool/generate.sh`. Each needs `protoc` on your
PATH, plus that language's plugin — `protoc-gen-dart` for Dart, and `npm
install` already run for TypeScript's `protoc-gen-es`. Nothing needs an include
path for `google/protobuf/*`; `protoc` supplies those itself.

CI does not verify that generated code is up to date. Generator output varies
with the `protoc` and plugin versions that produced it, so such a check would
have to pin all three toolchains exactly or fail spuriously on an unrelated
upgrade. Until it exists, regenerate and commit the result in the same change
as the `.proto` edit.

If you change `proto/codebinge/firestore/codec/v1/options.proto`, run
`./tool/sync-options-proto.sh` to update the per-package copies.

## Licensing of contributions

Contributions are accepted under the [Apache License, Version 2.0](LICENSE), per
its §5 — submitting a contribution licenses it under those terms. There is no
separate CLA.

If you add third-party material, it must be license-compatible and recorded in
[NOTICE](NOTICE), with any modifications you made stated in the file itself
(Apache-2.0 §4(b)).
