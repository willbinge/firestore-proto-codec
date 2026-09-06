# Security policy

## Reporting a vulnerability

Report privately through
[GitHub's private vulnerability reporting](https://github.com/willbinge/firestore-proto-codec/security/advisories/new).
Please do not open a public issue for a security report.

## Scope

This is an encoding library: it converts protobuf messages to and from Firestore
values and performs no I/O, no authentication, and no authorization. The
security-relevant failure modes are about data integrity rather than access
control:

- **Silent data corruption** — a value that round-trips to a different value, or
  that is written in a form the database cannot order or query correctly. The
  encoding exists specifically to prevent these
  ([§2](docs/encoding.md#2-scalar-types)), so a case where it does not is in
  scope.
- **A decode path that can be driven to crash or hang** by a document a
  different writer produced.
- **Nesting or recursion that escapes the depth guard**
  ([§5](docs/encoding.md#5-composite-kinds)).

Explicitly out of scope, because they are properties of an application's schema
rather than of the encoding:

- Firestore security rules and index definitions. Note that
  [§6](docs/encoding.md#6-presence-and-defaults) is a documented sharp edge — a
  rule reading `data.count` rejects documents whose count is zero, because
  defaults are omitted. Use `.get(field, default)`. That is a documented
  property, not a vulnerability.
- Collection paths, document ids, and anything about who may read or write a
  document.

## Supported versions

The specification is at v0.1, draft, and nothing is published yet. Until v1.0
there is no security backport branch: fixes land on `main`.
