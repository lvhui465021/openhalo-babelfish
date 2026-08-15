# Integration guide

## Scope

This repository is the release and integration boundary for the fixed
PostgreSQL 18.3 openHalo × Babelfish product.  It does not vendor component
source code: each component remains independently reviewable, while a Gitlink
records the exact combination that is tested and released.

| Path | Repository | Maintenance branch | Pinned revision at initial integration |
| --- | --- | --- | --- |
| `components/postgres` | `postgresql_modified_for_babelfish` | `openhalo-fusion` | `8bcabc6d95` |
| `components/babelfish` | `babelfish_extensions` | `openhalo-fusion` | `43130b10c` |
| `components/mysql` | `mysql_extensions` | `main` | `621c31dfa` |

The pre-existing upstream-oriented repository names are intentionally kept:
they preserve provenance and make upstream comparison straightforward.  The
product-facing name belongs at this integration layer.

## Build and test ownership

`scripts/build-all.sh` builds the kernel and four Babelfish extensions first,
then the three standalone MySQL PGXS modules.  It passes explicit component
paths so the layout does not depend on historical sibling directory names.

`scripts/run-baseline.sh` delegates to the kernel's install-first baseline and
supplies the standalone MySQL and Babelfish paths.  The kernel keeps PG-core
Meson suites and end-to-end postmaster TAP tests; MySQL TAP tests stay in
`components/mysql`; TDS TAP tests stay in `components/babelfish`.

The TDS TAP suites require a real `sqlcmd`-compatible client. A local wrapper
around FreeTDS `tsql` can help with development experiments, but it is not a
substitute for TDS acceptance because its authentication and diagnostic
behavior differs from `sqlcmd`.

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

Detailed component work, compatibility behavior, and current technical
handoff remain in `components/postgres/docs/HANDOFF.md` and its linked
documents.
