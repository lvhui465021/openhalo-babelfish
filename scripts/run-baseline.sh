#!/usr/bin/env bash
# Run the install-first multi-protocol baseline with the integrated layout.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
BABELFISH_EXT_DIR="${BABELFISH_EXT_DIR:-$ROOT_DIR/components/babelfish}"
MYSQLEXT_DIR="${MYSQLEXT_DIR:-$ROOT_DIR/components/mysql}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"
MYSQL_BIN="${MYSQL_BIN:-$PREFIX/bin/mysql}"
SQLCMD_BIN_DIR="${SQLCMD_BIN_DIR:-$PREFIX/bin}"

for dir in "$KERNEL_DIR" "$BABELFISH_EXT_DIR" "$MYSQLEXT_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "missing component directory: $dir" >&2
        echo "run: git submodule update --init --recursive" >&2
        exit 1
    fi
done

if [ ! -x "$MYSQL_BIN" ]; then
    if command -v mysql >/dev/null 2>&1; then
        MYSQL_BIN="$(command -v mysql)"
    else
        echo "mysql client not found" >&2
        echo "install an Oracle MySQL client or run scripts/install-clients.sh with MYSQL_BIN set" >&2
        exit 1
    fi
fi

if [ ! -x "$SQLCMD_BIN_DIR/sqlcmd" ]; then
    if command -v sqlcmd >/dev/null 2>&1; then
        SQLCMD_BIN_DIR="$(dirname "$(command -v sqlcmd)")"
    else
        echo "Microsoft sqlcmd client not found" >&2
        echo "install mssql-tools18 or run scripts/install-clients.sh with SQLCMD_BIN set" >&2
        exit 1
    fi
fi

if [ ! -x "$SQLCMD_BIN_DIR/sqlcmd" ]; then
    echo "sqlcmd is not executable: $SQLCMD_BIN_DIR/sqlcmd" >&2
    exit 1
fi

MYSQLEXT_DIR="$MYSQLEXT_DIR" \
BABELFISH_EXT_DIR="$BABELFISH_EXT_DIR" \
MYSQL_BIN="$MYSQL_BIN" \
SQLCMD_BIN_DIR="$SQLCMD_BIN_DIR" \
"$KERNEL_DIR/run-baseline.sh"
