# Integration handoff

## Current state

The initial product integration is assembled with three pinned components:
the PostgreSQL 18.3 fusion kernel, Babelfish extensions, and standalone MySQL
extensions.  The kernel baseline now accepts `MYSQLEXT_DIR`,
`BABELFISH_EXT_DIR`, and `SQLCMD_BIN_DIR`, allowing this repository's
`components/` layout to be used without compatibility symlinks.

## Next acceptance boundary

On a clean checkout, complete the following before creating the first product
tag:

1. `git submodule update --init --recursive` resolves all three Gitlinks from
   GitHub.
2. `scripts/build-all.sh` succeeds with the documented toolchain.
3. Configure the cluster's PostgreSQL, MySQL, and TDS listeners and run
   `scripts/run-baseline.sh` with the `sqlcmd` shim available when TDS tests
   are required.
4. Record the exact test environment and results in the component handoff, then
   advance only the tested Gitlinks in this repository.

The product stays on PostgreSQL 18.3 by policy.  A PostgreSQL-major upgrade is
a separate architecture decision, not routine dependency maintenance.
