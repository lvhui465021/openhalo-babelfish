# openhalo-babelfish

`openhalo-babelfish` is the product integration repository for the fixed
PostgreSQL 18.3 compatibility stack.  It pins and builds one postmaster with
three client-facing compatibility surfaces:

| Surface | Component | Default port |
| --- | --- | --- |
| PostgreSQL wire protocol and SQL | `components/postgres` | 5432 |
| SQL Server TDS and T-SQL | `components/babelfish` | 1433 |
| MySQL wire protocol and syntax compatibility | `components/mysql` | 3306 |

The components are Git submodules.  Their exact Gitlinks are the release
manifest; the branches in `.gitmodules` are only the intended maintenance
tracks.  See [the integration guide](docs/INTEGRATION.md) for ownership,
upgrade policy, and the currently pinned revisions.

## Clone and build

```bash
git clone --recurse-submodules git@github.com:lvhui465021/openhalo-babelfish.git
cd openhalo-babelfish
scripts/build-all.sh
```

For an existing clone, initialize the pinned components before use:

```bash
git submodule update --init --recursive
```

The default installation prefix is `components/postgres/inst`.  Override it,
or any component location, when needed:

```bash
PREFIX=/opt/openhalo scripts/build-all.sh
```

The MySQL listener defaults to `mysql_port = 3306`.  Use another port such as
`13306` only as an explicit development override when a system MySQL instance
already occupies 3306.

After configuring a cluster and making a `sqlcmd`-compatible client available
to the TDS TAP suites, run the unified baseline:

```bash
scripts/run-baseline.sh
```

For the Microsoft ODBC 18 client, use its installed tool directory and make
encryption optional for the non-TLS TAP fixture:

```bash
SQLCMD_BIN_DIR=/opt/mssql-tools18/bin \
SQLCMD_OPTIONS=-No \
scripts/run-baseline.sh
```

`-No` is for the local TAP fixture only. Production TDS deployments should
configure and validate TLS rather than disabling required encryption.

See [the validation record](docs/VALIDATION.md) for the tested manifest,
environment, result matrix, and clean-clone acceptance command.

For production deployment, rollback, known compatibility limits, and the
additional acceptance work that is intentionally outside the TAP baseline,
read [the deployment guide](docs/DEPLOYMENT.md) before exposing a listener to
clients.

The repository's automated checks are described in [the CI guide](docs/CI.md).
The full integration baseline intentionally runs only on a prepared Ubuntu
24.04 self-hosted runner because it needs the fixed Babelfish toolchain and a
real Microsoft SQLCMD client.

The first build requires the prerequisites documented in
`components/postgres/docs/FUSION_PLAN.md` (Meson/Ninja toolchain, libxml2,
OpenSSL, Java/CMake, flex/bison, Perl, and ANTLR4 C++ runtime 4.13.2).
