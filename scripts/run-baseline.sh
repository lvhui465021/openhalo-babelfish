#!/usr/bin/env bash
# Run the install-first multi-protocol baseline with the integrated layout.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
BABELFISH_EXT_DIR="${BABELFISH_EXT_DIR:-$ROOT_DIR/components/babelfish}"
MYSQLEXT_DIR="${MYSQLEXT_DIR:-$ROOT_DIR/components/mysql}"
SQLCMD_BIN_DIR="${SQLCMD_BIN_DIR:-$ROOT_DIR/sqlcmd-bin}"

for dir in "$KERNEL_DIR" "$BABELFISH_EXT_DIR" "$MYSQLEXT_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "missing component directory: $dir" >&2
        echo "run: git submodule update --init --recursive" >&2
        exit 1
    fi
done

MYSQLEXT_DIR="$MYSQLEXT_DIR" \
BABELFISH_EXT_DIR="$BABELFISH_EXT_DIR" \
SQLCMD_BIN_DIR="$SQLCMD_BIN_DIR" \
"$KERNEL_DIR/run-baseline.sh"
