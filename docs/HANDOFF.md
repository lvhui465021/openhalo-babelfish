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
documented expected failure.

The complete install-first baseline passed with Microsoft SQLCMD 18.6.0002.1:
the PG-core Meson group passed with 12 OK and 2 expected skips; MySQL passed
31 standalone TAP checks plus 485 kernel postmaster/protocol checks; and TDS
passed all 8 checks in `001_tdspasswd` and `003_bbfextnotloaded`. The TDS TAP
tests allocate an isolated TDS listener port, while the product default remains
1433. The non-TLS fixture was run with `SQLCMD_OPTIONS=-No`; this is explicitly
a test-only client setting.

The exact manifest, command, environment, and test matrix are in
[VALIDATION.md](VALIDATION.md).

## Release acceptance

Completed on 2026-08-16 from a fresh remote clean checkout:

1. `git clone --recurse-submodules git@github.com:lvhui465021/openhalo-babelfish.git`
   resolved all three Gitlinks from GitHub and matched the tested manifest.
2. `scripts/build-all.sh` succeeded with the documented toolchain.
3. `scripts/run-baseline.sh` passed with Microsoft SQLCMD 18.6.0002.1,
   ODBC Driver 18, and `SQLCMD_OPTIONS=-No` for the non-TLS TDS fixture.
4. The exact result is recorded in [VALIDATION.md](VALIDATION.md). The manifest
   is frozen and tagged `v18.3-fusion.1`.

After that tag, `components/postgres` was advanced to `d14bca64a9` for a
test-only `run-baseline.sh` portability fix; the full baseline was re-run and
still passes (`baseline: ALL PASS`).

The product stays on PostgreSQL 18.3 by policy.  A PostgreSQL-major upgrade is
a separate architecture decision, not routine dependency maintenance.
