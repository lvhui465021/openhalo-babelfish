# Protocol test clients

The server components are the only source repositories vendored by this
integration manifest. `mysql` and `sqlcmd` remain independently supplied
third-party clients; the product does not rename either command or claim
ownership of them.

Install an Oracle MySQL CLI and Microsoft `mssql-tools18` `sqlcmd` through the
operating system or an approved artifact source, then link the exact binaries
into the installation prefix:

```bash
PREFIX=/opt/openhalo scripts/install-clients.sh
PREFIX=/opt/openhalo scripts/verify-clients.sh
```

The linked names are `/opt/openhalo/bin/mysql` and
`/opt/openhalo/bin/sqlcmd`. They are symbolic links rather than copied
binaries: Microsoft `sqlcmd` depends on the matching ODBC Driver installation,
so packaging only its executable would produce a broken client.

`scripts/build-all.sh` performs the linking automatically when both commands
are already on `PATH`. Use `WITH_CLIENTS=1` to require it, or
`WITH_CLIENTS=0` to build server components without client linking.

The TDS acceptance baseline requires the Microsoft ODBC client. Do not use a
FreeTDS wrapper as acceptance evidence. A future source-built `go-sqlcmd`
evaluation belongs in a separate compatibility matrix; it must not silently
replace the ODBC client.
