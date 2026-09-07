# Releasing to Maven Central

The POM already carries everything Central checks in metadata — `name`,
`description`, `url`, `licenses`, `developers`, `scm` — and the `release`
profile produces the sources jar, javadoc jar and GPG signatures it requires.
What remains is account setup, which is one-time, and the release itself.

## One-time setup

### 1. Claim the `com.codebinge` namespace — ✅ done

Verified on Central via a DNS `TXT` record on `codebinge.com`, 2026-09-07. It
matches the Java package the generated code already uses (`option java_package`
in `options.proto`).

Nothing to redo: namespace verification is permanent and covers every artifact
published under `com.codebinge`, including future ones. The `<groupId>` in
`pom.xml` is settled and must not change — it is the one coordinate consumers
depend on by name, and it cannot be altered after a first release.

### 2. Create a signing key — done, algorithm unproven

Central requires every artifact to be signed, and the public key must be on a
public keyserver before upload.

**Current key**, generated and published 2026-09-07:

```
ed25519  5C1093B91E771489A94D640EECAAE69B50701F11  Will <will@codebinge.com>
         published to keyserver.ubuntu.com, expires 2029-09-06
```

Use `--full-generate-key`, not `--gen-key`. The latter takes the current
default parameters with no dialog at all — on GnuPG 2.5 that default is
ed25519, which is how the key above ended up EdDSA rather than RSA.

```sh
gpg --full-generate-key                        # dialogs for algorithm, size, expiry
gpg --list-secret-keys --keyid-format=long     # note the key id
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>
```

Sonatype states no formal algorithm requirement, but every example in their
documentation uses RSA and EdDSA is not mentioned, so ed25519 support is
unconfirmed. This is safe to discover empirically: `autoPublish` is `false`, so
a rejected signature surfaces during portal validation with nothing published.
If it is rejected, generate an RSA 4096 key with `--full-generate-key`, publish
it alongside this one — keyservers hold multiple keys per identity — and
redeploy. Keyservers supported by Central: `keyserver.ubuntu.com`,
`keys.openpgp.org`, `pgp.mit.edu`.

Back the private key up somewhere durable. Losing it does not invalidate
published artifacts, but it means generating and publishing a new key.

The expiry matters only for future releases: artifacts signed while the key was
valid stay valid. Extend it, or make a new key, before releasing after
2029-09-06.

### 3. Generate a Central token and store it

In the Central Portal, under your account, generate a **user token**. Put it in
`~/.m2/settings.xml` — never in this repository:

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

The `<id>` must be `central`, matching `publishingServerId` in the POM.

## Releasing

1. **Drop the `-SNAPSHOT`.** Central rejects snapshot versions.

   ```sh
   mvn -B versions:set -DnewVersion=0.1.0
   ```

2. **Check the version story.** The Java package version is independent of the
   specification version (see §10 of the encoding spec) — bump it on its own
   merits. Update `CHANGELOG.md`.

3. **Confirm the extension number is not still provisional.** Releasing while
   `options.proto` declares `50000` publishes a coordinate that a later
   registration will break. See §7.

4. **Deploy.**

   ```sh
   mvn -Prelease deploy
   ```

   This builds the three jars, signs them, and uploads a bundle to the Central
   Portal. `autoPublish` is `false`, so the bundle waits in the portal for you
   to inspect and press Publish. Once a first release has gone through cleanly,
   flipping it to `true` makes later releases one command.

5. **Tag it.**

   ```sh
   git tag -a java-v0.1.0 -m "Java 0.1.0" && git push origin java-v0.1.0
   ```

   Tags are prefixed per language, since the three implementations version
   independently.

6. **Restore the snapshot** for continued development:

   ```sh
   mvn -B versions:set -DnewVersion=0.2.0-SNAPSHOT
   ```

## Verifying afterwards

Artifacts appear at `repo1.maven.org` within about 15 minutes and in Central
search within a few hours. The fastest check:

```sh
curl -sI https://repo1.maven.org/maven2/com/codebinge/firestore-proto-codec/0.1.0/firestore-proto-codec-0.1.0.pom
```

**A published version can never be changed or removed.** If something is wrong,
the only remedy is publishing a new version.
