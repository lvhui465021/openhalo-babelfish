# Validation record

## Tested manifest

| Component | Branch | Revision |
| --- | --- | --- |
| PostgreSQL fusion kernel | `openhalo-fusion` | `fbacb2057b` |
| Babelfish extensions | `openhalo-fusion` | `63e6cebcf` |
| MySQL extensions | `main` | `621c31dfa` |

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

## Remaining release gate

Repeat the documented build and unified baseline from the target remote clean
checkout. If the result remains PASS and the three Gitlinks match this table,
freeze the manifest and create the first product tag (`v18.3-fusion.N`).
