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

### 2. Create a signing key

Central requires every artifact to be signed, and the public key must be on a
public keyserver before upload.

```sh
gpg --gen-key                                  # RSA 4096, no expiry or a long one
gpg --list-secret-keys --keyid-format=long     # note the key id
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>
```

Back the private key up somewhere durable. Losing it does not break published
artifacts, but it means generating and re-publishing a new key.

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
