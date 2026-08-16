# Validation record

## Current tested manifest

| Component | Branch | Revision |
| --- | --- | --- |
| PostgreSQL fusion kernel | `openhalo-fusion` | `d14bca64a9` |
| Babelfish extensions | `openhalo-fusion` | `63e6cebcf` |
| MySQL extensions | `main` | `621c31dfa` |

> The `v18.3-fusion.1` tag was created from the preceding manifest
> (`fbacb2057b`, `63e6cebcf`, `621c31dfa`). The current `main` advances only
> the kernel `run-baseline.sh` portability fix to `d14bca64a9`; the full
> baseline was re-run on 2026-08-16 after that change and still passes.

## Environment

- Ubuntu 24.04 on WSL.
- PostgreSQL 18.3 installation at `components/postgres/inst`.
- Microsoft SQL Server Command Line Tool 18.6.0002.1 with ODBC Driver 18.
- Perl test dependency `IPC::Run` available through the local Perl library.

The test fixture's Babelfish TDS listener does not offer encryption. SQLCMD 18
therefore ran with `-No` through `SQLCMD_OPTIONS=-No`. This is strictly a test
fixture setting; a production TDS deployment must configure TLS and validate
its certificates.

## Commands

```bash
git clone --recurse-submodules git@github.com:lvhui465021/openhalo-babelfish.git
cd openhalo-babelfish
scripts/build-all.sh

SQLCMD_BIN_DIR=/opt/mssql-tools18/bin \
SQLCMD_OPTIONS=-No \
scripts/run-baseline.sh
```

## Result on 2026-08-15

| Group | Result | Evidence |
| --- | --- | --- |
| PG-core Meson suites | PASS | 12 OK, 2 expected skips, 0 failures |
| MySQL standalone TAP | PASS | 3 files, 31 checks |
| MySQL kernel protocol/postmaster TAP | PASS | 2 files, 485 checks |
| TDS TAP | PASS | `001_tdspasswd`: 6 checks; `003_bbfextnotloaded`: 2 checks |
| Unified baseline | PASS | `baseline: ALL PASS` |

The TDS baseline uses a dynamically allocated temporary listener port and does
not require the host's default 1433 port to be free. The product default TDS
port remains 1433.

## Clean remote checkout result on 2026-08-16

A fresh `git clone --recurse-submodules` from
`git@github.com:lvhui465021/openhalo-babelfish.git` was built and tested on
the acceptance host. All three submodule checkouts resolved to the
`v18.3-fusion.1` manifest (`fbacb2057b`, `63e6cebcf`, `621c31dfa`).

| Group | Result | Evidence |
| --- | --- | --- |
| Build | PASS | `scripts/build-all.sh` completed; kernel and all extensions installed |
| PG-core Meson suites | PASS | 12 OK, 2 expected skips, 0 failures |
| MySQL standalone TAP | PASS | 3 files, 31 checks |
| MySQL kernel protocol/postmaster TAP | PASS | 2 files, 485 checks |
| TDS TAP | PASS | `001_tdspasswd`: 6 checks; `003_bbfextnotloaded`: 2 checks |
| Unified baseline | PASS | `baseline: ALL PASS` |

The acceptance host cannot write `/opt` without root, so the same Microsoft
`sqlcmd` 18.6.0002.1 and ODBC Driver 18 binaries were installed user-locally
and exposed through `SQLCMD_BIN_DIR`. `SQLCMD_OPTIONS=-No` was used as
documented for the non-TLS TAP fixture.

## Release gate

The clean remote checkout acceptance on 2026-08-16 passed with the three
Gitlinks still matching the tagged manifest. The manifest was frozen for the
first product tag, `v18.3-fusion.1`.

## Post-tag maintenance

After `v18.3-fusion.1`, `components/postgres` advanced to `d14bca64a9`
(test-only `run-baseline.sh` portability: no machine-specific `PERL5LIB`, and
a missing sqlcmd client now fails the baseline instead of being silently
skipped). The complete unified baseline was re-run on 2026-08-16 with
`SQLCMD_BIN_DIR` pointing at the user-local sqlcmd wrapper and
`SQLCMD_OPTIONS=-No`; result: `baseline: ALL PASS`.

## v18.3-fusion.2 clean remote checkout result on 2026-08-16

A fresh shallow `git clone --recurse-submodules --shallow-submodules` from
`git@github.com:lvhui465021/openhalo-babelfish.git` was built and tested on
the acceptance host. All three submodule checkouts resolved to the current
tested manifest (`d14bca64a9`, `63e6cebcf`, `621c31dfa`).

| Group | Result | Evidence |
| --- | --- | --- |
| Build | PASS | `scripts/build-all.sh` completed; kernel and all extensions installed |
| PG-core Meson suites | PASS | 12 OK, 2 expected skips, 0 failures |
| MySQL standalone TAP | PASS | 3 files, 31 checks |
| MySQL kernel protocol/postmaster TAP | PASS | 2 files, 485 checks |
| TDS TAP | PASS | `001_tdspasswd`: 6 checks; `003_bbfextnotloaded`: 2 checks |
| Unified baseline | PASS | `baseline: ALL PASS` |

This acceptance freezes the current manifest for the second product tag,
`v18.3-fusion.2`.
