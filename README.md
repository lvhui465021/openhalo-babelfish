# openhalo-babelfish

`openhalo-babelfish` is the product integration repository for the fixed
PostgreSQL 18.3 compatibility stack.  It pins and builds one postmaster with
three client-facing compatibility surfaces:

| Surface | Component | Default port |
| --- | --- | --- |
| PostgreSQL wire protocol and SQL | `components/postgres` | 5432 |
| SQL Server TDS and T-SQL | `components/babelfish` | 1433 |
| MySQL wire protocol and syntax compatibility | `components/mysql` | 13306 |

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

After configuring a cluster and installing the optional `sqlcmd`-to-`tsql`
shim under `sqlcmd-bin/`, run the unified baseline:

```bash
scripts/run-baseline.sh
```

The first build requires the prerequisites documented in
`components/postgres/docs/FUSION_PLAN.md` (Meson/Ninja toolchain, libxml2,
OpenSSL, Java/CMake, flex/bison, Perl, and ANTLR4 C++ runtime 4.13.2).
