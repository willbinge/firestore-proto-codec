# Releasing

Three implementations, three registries, three independent version numbers
([§10](docs/encoding.md#10-stability)). A release is per-language: shipping Dart
does not oblige you to ship TypeScript.

Published so far:

| Registry | Coordinate | Version |
|---|---|---|
| npm | `firestore-proto-codec` | 0.3.0 |
| pub.dev | `firestore_proto_codec` | 0.2.0 |
| Maven Central | `com.codebinge:firestore-proto-codec` | 0.2.0 |

The version numbers differ on purpose. npm skipped 0.1.0 because it was burned
by a mistake described below.

## Release in order of permanence

When shipping the same change to all three, go **npm → pub.dev → Maven
Central**, because that is least-recoverable last:

| | If you get it wrong |
|---|---|
| **npm** | Unpublish within 72h if nothing depends on it; after that, deprecate |
| **pub.dev** | Cannot unpublish; a version can be *retracted* so new resolutions skip it |
| **Maven Central** | **Nothing.** A published version is permanent and cannot be changed or removed |

None of them ever let a version number be reused. A bad publish costs you that
number permanently on every registry; the only question is how visible it stays.

So mistakes surface on the forgiving registry first. Do not reverse the order to
"get the hard one out of the way."

## Before any release

1. **`options.proto` must declare `field = 1376`.** That number is registered to
   this project and must never change ([§7](docs/encoding.md#7-options)). A
   consumer on a different number stops seeing annotations *silently* rather
   than failing.
2. **CI green on the commit you are releasing**, and `./tool/sync-options-proto.sh --check`
   passing, so each package ships an identical copy of the proto.
3. **Update that language's `CHANGELOG.md`.** Versions are per-implementation;
   bump on its own merits, not to match the others.
4. **Tag the commit you actually released**, prefixed by language:
   `dart-v0.1.0`, `ts-v0.2.0`, `java-v0.1.0`. Where a release requires editing a
   version file, commit that edit *before* tagging — see the Java section.

---

## npm (TypeScript)

```sh
cd ts
npm version <x.y.z> --no-git-tag-version   # updates package.json AND package-lock.json
npm ci && npm run typecheck && npm test
npm publish
```

`npm login` first if needed. 2FA is on, so expect a one-time-code prompt.

### Things that have bitten us

**The first publish of a package takes `latest` no matter what `--tag` says.**
Publishing `0.1.0` with `--tag next` set *both* `next` and `latest` to it. This
is why 0.1.0 is burned: it went out with the provisional extension number as the
default install. There is no way to avoid this on a package's first version —
plan for the first publish to be the real one.

**Version numbers can never be reused.** Not even after unpublishing. A bad
`0.1.0` means the next release is `0.1.1` or `0.2.0`, forever.

**Deprecate rather than unpublish.** Unpublishing does not reclaim the number,
and removing every version locks the package name for 24 hours. Deprecation
keeps consumers working while warning them on every install:

```sh
npm deprecate firestore-proto-codec@0.1.0 "…reason and link…"
```

**An expired token reports `404 Not Found` on `PUT`,** not `401`. npm masks
unauthorized publishes so they do not leak whether a package exists. Check with
`npm whoami`; a 401 there means you need `npm login`.

**`npm version` updates the lockfile too.** Editing `package.json` by hand
leaves `package-lock.json` stale, which fails `npm ci` in CI rather than
locally.

### Verify

```sh
npm view firestore-proto-codec dist-tags
npm pack firestore-proto-codec@<x.y.z>   # then check dist/ and proto/ are inside
```

`main` points at `./dist/index.js`, which only exists because `files` and
`prepublishOnly` are set in `package.json`. If either is removed, the package
publishes with a `main` pointing at nothing.

---

## pub.dev (Dart)

```sh
cd dart
dart analyze --fatal-infos && dart test
dart pub publish
```

Authenticates through a browser. The dry run (`--dry-run`) is worth running
first; it validates metadata and warns about missing files.

### Things to know

**`pubspec.yaml` declares `platforms:` without web, deliberately.** `int64`
converts through Dart `int`, which is a double on the web and loses precision
above 2^53. Removing that block makes pub.dev advertise a platform on which the
codec silently corrupts data.

**Cannot unpublish.** A version can be *retracted*, which stops new resolutions
selecting it but leaves existing pins working.

**`LICENSE`, `NOTICE` and `CHANGELOG.md` must be inside `dart/`.** pub publishes
only what sits under the package directory, so the repo-root copies do not
count.

### Verify

```sh
curl -sS -H 'Accept: application/json' https://pub.dev/api/packages/firestore_proto_codec
```

Check `latest.version`, and that the archive contains
`proto/codebinge/firestore/codec/v1/options.proto` with `1376`.

---

## Maven Central (Java)

The POM already carries everything Central validates — `name`, `description`,
`url`, `licenses`, `developers`, `scm` — and the `release` profile produces the
sources jar, javadoc jar and GPG signatures it requires.

### One-time setup

**Namespace `com.codebinge` — ✅ verified** on Central via a DNS `TXT` record on
`codebinge.com`, 2026-09-07. Permanent, and covers every future artifact under
that groupId. `<groupId>` must never change: it is the coordinate consumers
depend on by name.

**Signing key — ✅ done.** Generated and published 2026-09-07:

```
ed25519  5C1093B91E771489A94D640EECAAE69B50701F11  Will <will@codebinge.com>
         published to keyserver.ubuntu.com, expires 2029-09-06
```

Use `--full-generate-key`, not `--gen-key`. The latter takes current defaults
with no dialog at all — on GnuPG 2.5 that default is ed25519, which is how this
key ended up EdDSA rather than RSA.

```sh
gpg --full-generate-key                        # dialogs for algorithm, size, expiry
gpg --list-secret-keys --keyid-format=long
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>
```

**Central accepts EdDSA.** Sonatype documents no algorithm requirement and every
example they publish uses RSA, so this was unproven until the first release. Now
settled twice over: the 0.1.0 deployment reached `VALIDATED` — signature
verification happens during portal validation — and the published `.asc` files
on `repo1` verify against this key. No RSA fallback needed. Supported
keyservers: `keyserver.ubuntu.com`, `keys.openpgp.org`, `pgp.mit.edu`.

**gpg-agent needs a pinentry that works without a terminal.** Maven runs `gpg`
with no tty, so the terminal-based pinentries (`pinentry-curses`,
`pinentry-tty`) fail with `gpg: signing failed: No pinentry`. Install a
graphical one for your platform and point the agent at it in
`~/.gnupg/gpg-agent.conf`:

```
pinentry-program /path/to/pinentry-<gui>
```

Then `gpgconf --kill gpg-agent` to reload. On macOS that is `pinentry-mac`; on
Linux, `pinentry-gnome3` or `pinentry-qt`.

Do **not** add `--pinentry-mode loopback` to the POM's gpg plugin: loopback
makes gpg read the passphrase from the calling program rather than the agent,
and Maven supplies none, so signing dead-ends with the same error. Loopback
belongs in CI, paired with a passphrase from a secret.

**Back up the key, and the revocation certificate separately.** Losing the key
does not invalidate published artifacts, but the revocation certificate at
`~/.gnupg/openpgp-revocs.d/<FINGERPRINT>.rev` cannot be regenerated once the key
is gone, and it is the only way to tell keyservers to stop trusting it.

**Central token in `~/.m2/settings.xml`** — never in this repository:

```xml
<settings>
  <servers>
    <server>
      <id>central</id>
      <username>TOKEN_USERNAME</username>
      <password>TOKEN_PASSWORD</password>
    </server>
  </servers>
</settings>
```

> ⚠️ The portal's copy button gives you **only the inner `<server>` block**.
> Pasting that alone produces a file whose root element is `<server>`, which
> Maven parses happily and reads as zero servers — the deploy then fails with
> `Cannot invoke "…Server.clone()" because "server" is null`. The `<settings>`
> and `<servers>` wrappers are required. The `<id>` must be `central`, matching
> `publishingServerId` in the POM.

### Releasing

```sh
cd java
mvn -B versions:set -DnewVersion=<x.y.z>     # Central rejects -SNAPSHOT
mvn -Prelease deploy
git commit -am "Release Java <x.y.z>"
git tag -a java-v<x.y.z> -m "Java <x.y.z>" && git push origin java-v<x.y.z>
mvn -B versions:set -DnewVersion=<next>-SNAPSHOT
git commit -am "Back to <next>-SNAPSHOT"
```

`autoPublish` is `false`, so `deploy` uploads and validates, then stops. The
bundle waits at
[central.sonatype.com/publishing/deployments](https://central.sonatype.com/publishing/deployments)
showing `VALIDATED`, with **Publish** and **Drop** buttons. Drop is harmless —
it discards without burning the version. Publish is forever.

> ⚠️ **Commit the version bump before tagging.** `versions:set` edits `pom.xml`
> in the working tree; tagging without committing leaves the tag pointing at a
> tree whose POM still reads `-SNAPSHOT`, so it does not match the published
> artifact. The 0.1.0 release hit this and needed a reconstructed commit
> afterwards.

### Verify

```sh
B=https://repo1.maven.org/maven2/com/codebinge/firestore-proto-codec/<x.y.z>/firestore-proto-codec-<x.y.z>
curl -sI $B.pom                        # ~15 min to appear; hours for search
curl -sL -o a.jar $B.jar && curl -sL -o a.jar.asc $B.jar.asc
gpg --verify a.jar.asc a.jar           # must say Good signature
unzip -p a.jar codebinge/firestore/codec/v1/options.proto | grep 'field ='
```

---

## After any release

The thing no test in this repo can prove: **have a downstream project annotate a
schema against the published package.** Every check here reads the extension
number from artifacts built in this repo. An independent consumer is the only
way to confirm 1376 round-trips — and a wrong number fails silently, so it is
exactly the case self-testing misses.
