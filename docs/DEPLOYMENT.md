# Deployment and production acceptance

## Supported release boundary

`v18.3-fusion.2` is the accepted fixed PostgreSQL 18.3 manifest.  It runs one
postmaster with PostgreSQL on 5432, TDS on 1433, and MySQL on 3306 by default.
Using 13306 is a development override for a host where 3306 is already in
use; it is not the product default.

Build from a recursive clone and use the integration scripts.  The exact
component revisions and baseline evidence are in `VALIDATION.md`; do not
replace them with arbitrary maintenance-branch tips.

## Before exposing the service

- Bind each listener only to the intended network interfaces and allow its
  port through the host firewall deliberately.
- Configure TLS and a valid certificate chain for the production TDS endpoint,
  then validate it with the target Microsoft SQLCMD/client configuration.
  The baseline's `SQLCMD_OPTIONS=-No` is prohibited for this step.
- Apply protocol-specific authentication rules.  In particular, TDS does not
  support SCRAM and MySQL authentication has the release-note constraints
  described in `components/postgres/docs/RELEASE_NOTES.md`.
- Change test credentials; do not reuse any fixture role, password, socket, or
  data directory in a deployed cluster.
- Run a backup-and-restore rehearsal.  `pg_dumpall` does not preserve the
  MySQL `rolpasswordext` verifier, so restore procedures must reset affected
  MySQL passwords.

## Production acceptance record

Record the release tag, component Gitlinks, operator, timestamp, command
output, and result for each item below.  A failed or unperformed item is not a
pass.

| Area | Required evidence |
| --- | --- |
| Build and functional baseline | `scripts/build-all.sh` and `scripts/run-baseline.sh` pass on the exact manifest |
| PostgreSQL, MySQL, and TDS reachability | Authenticated smoke queries through each intended network endpoint |
| TDS transport security | Certificate-chain and encrypted SQLCMD/client connection validation without `-No` |
| Authentication policy | Role and HBA tests for each enabled protocol |
| Backup and recovery | Restore into a new data directory and protocol smoke test afterward |
| Availability and performance | Workload-specific load, restart, and failure-recovery evidence |
| Optional TDS suites | Kerberos and cross-version dump/restore where those features are offered |

## Rollback

The source manifest can be restored reproducibly:

```bash
git checkout v18.3-fusion.2
git submodule update --init --recursive
```

Do not downgrade an existing data directory in place.  Roll back binaries by
using a separately prepared installation and restore from a verified backup
that is compatible with the selected server version.
