# Integration handoff

## Current state

The initial product integration is assembled with three pinned components:
the PostgreSQL 18.3 fusion kernel, Babelfish extensions, and standalone MySQL
extensions. The kernel baseline accepts `MYSQLEXT_DIR`, `BABELFISH_EXT_DIR`,
and `SQLCMD_BIN_DIR`, allowing this repository's `components/` layout to be
used without compatibility symlinks.

The current Gitlink combination was built successfully on Ubuntu 24.04 with
`scripts/build-all.sh`. The focused kernel MySQL contracts passed: the build
graph and vtable contracts passed, and the fork-drift test reported its
documented expected failure. `scripts/run-baseline.sh` also passed the PG core
group and all 485 MySQL TAP/postmaster checks.

The two selected TDS TAP tests now allocate an isolated TDS listener port,
while the product default remains 1433. They require a real `sqlcmd`-compatible
client for acceptance. The local `tsql` wrapper was sufficient to prove that
the temporary listener starts on its selected port, but it does not reproduce
the `sqlcmd` authentication and error-stream behavior those TAP tests expect;
their result is therefore not an acceptance result for the TDS protocol.

## Next acceptance boundary

Before creating the first product tag, complete the following on a clean
checkout:

1. `git submodule update --init --recursive` resolves all three Gitlinks from
   GitHub.
2. `scripts/build-all.sh` succeeds with the documented toolchain.
3. Install or provide a genuine `sqlcmd`-compatible client, configure the
   PostgreSQL, MySQL, and TDS listeners, and rerun `scripts/run-baseline.sh`.
   Record the TDS TAP result separately from any development `tsql` wrapper.
4. Re-run the build and baseline from the fresh clone, record the exact test
   environment and results, then advance only the tested Gitlinks in this
   repository.

The product stays on PostgreSQL 18.3 by policy.  A PostgreSQL-major upgrade is
a separate architecture decision, not routine dependency maintenance.
