# Integration guide

## Scope

This repository is the release and integration boundary for the fixed
PostgreSQL 18.3 openHalo × Babelfish product.  It does not vendor component
source code: each component remains independently reviewable, while a Gitlink
records the exact combination that is tested and released.

| Path | Repository | Maintenance branch | Current development revision |
| --- | --- | --- | --- |
| `components/postgres` | `postgresql_modified_for_babelfish` | `openhalo-fusion` | `d9fe2b70f4` |
| `components/babelfish` | `babelfish_extensions` | `openhalo-fusion` | `e003ba2204` |
| `components/mysql` | `mysql_extensions` | `main` | `621c31dfa` |

The pre-existing upstream-oriented repository names are intentionally kept:
they preserve provenance and make upstream comparison straightforward.  The
product-facing name belongs at this integration layer.

`v18.3-fusion.1` was tagged at the preceding postgres revision `fbacb2057b`.
`v18.3-fusion.2` is the last accepted manifest: `d14bca64a9`,
`63e6cebcf`, and `621c31dfa`. The current development manifest advances the
kernel for configurable MySQL CLI selection and Babelfish generated-file
ignore rules; it requires its own complete baseline before a subsequent tag.

## Build and test ownership

`scripts/build-all.sh` builds the kernel and four Babelfish extensions first,
then the three standalone MySQL PGXS modules.  It passes explicit component
paths so the layout does not depend on historical sibling directory names.

`scripts/run-baseline.sh` delegates to the kernel's install-first baseline and
supplies the standalone MySQL and Babelfish paths.  The kernel keeps PG-core
Meson suites and end-to-end postmaster TAP tests; MySQL TAP tests stay in
`components/mysql`; TDS TAP tests stay in `components/babelfish`.

The TDS TAP suites require a real Microsoft `sqlcmd` client. A local wrapper
around FreeTDS `tsql` can help with development experiments, but it is not a
substitute for TDS acceptance because its authentication and diagnostic
behavior differs from `sqlcmd`. The test helper accepts client-specific flags
through `SQLCMD_OPTIONS`; `mssql-tools18` must use `SQLCMD_OPTIONS=-No` for the
non-TLS TAP fixture. This is a test setting, not a production TLS policy.

`scripts/install-clients.sh` may link externally installed vendor clients into
the product prefix as `bin/mysql` and `bin/sqlcmd`. The names deliberately
remain unchanged: neither client is an OpenHalo implementation. The script
uses symbolic links because `sqlcmd` must remain adjacent to its matching ODBC
runtime. `scripts/run-baseline.sh` selects these linked paths by default and
also accepts `MYSQL_BIN` and `SQLCMD_BIN_DIR` overrides.

The current manifest and its exact test evidence are recorded in
[VALIDATION.md](VALIDATION.md).

## Change and release policy

1. Make and validate a component change in its own repository and push its
   maintenance branch.
2. In this repository, update only the intended submodule Gitlink(s), run the
   applicable integration build/tests, and commit the new combined manifest.
3. Tag a release here only after the component Gitlinks are intentionally
   frozen.  A future tag should use the `v18.3-fusion.N` form.

Do not use `git submodule update --remote` as a release action: it follows a
branch tip and changes the manifest without declaring a tested component set.
Use it only as an explicit maintenance preparation step, then inspect and
commit the resulting Gitlink change.

`README.md`, this guide, `VALIDATION.md`, and `DEPLOYMENT.md` are the
authoritative product-level documents.  Component documents describe their
implementation and compatibility details, but must not override the pinned
manifest, ports, or acceptance result recorded here.
