# CI and release gate

## What runs automatically

`.github/workflows/integration.yml` performs a fast manifest check on every
push and pull request.  It verifies recursive submodule checkout, that every
submodule is pinned to an exact commit, that the integration scripts parse,
and that the checkout has no whitespace errors.

This check protects the integration repository from an incomplete submodule
checkout or a malformed orchestration change; it is intentionally not a
substitute for the runtime baseline.

## Full integration baseline

The same workflow exposes the `integration-baseline` job for manual runs and
for `v18.3-fusion.*` tags.  It is assigned to a self-hosted runner labelled
`openhalo-ubuntu-24.04`.  Prepare that runner with the documented fixed build
toolchain, a real Microsoft SQLCMD 18 client (and ODBC Driver 18), and enough
disk and time for a clean build.

The job runs:

```bash
PREFIX="$GITHUB_WORKSPACE/artifacts/inst" scripts/build-all.sh
SQLCMD_BIN_DIR=/opt/mssql-tools18/bin \
SQLCMD_OPTIONS=-No \
scripts/run-baseline.sh
```

`SQLCMD_OPTIONS=-No` is valid only for the isolated non-TLS TAP fixture.  It
must not be copied to production service configuration.

## Release procedure

1. Push the intended component changes first, then update only their Gitlinks
   in this repository.
2. Run the full workflow on the exact manifest and retain its logs as release
   evidence.
3. Complete the production-only checklist in `DEPLOYMENT.md` when the release
   will serve external clients.
4. Create the next immutable `v18.3-fusion.N` tag only after the preceding
   evidence is available.

Do not use `git submodule update --remote` as a release shortcut.  It changes
the manifest to a moving branch tip rather than a deliberately tested set of
revisions.
