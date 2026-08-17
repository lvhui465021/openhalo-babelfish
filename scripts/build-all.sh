#!/usr/bin/env bash
# Build the fixed PG 18.3 fusion stack in dependency order.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL_DIR="${KERNEL_DIR:-$ROOT_DIR/components/postgres}"
BABELFISH_DIR="${BABELFISH_DIR:-$ROOT_DIR/components/babelfish}"
MYSQL_EXT_DIR="${MYSQL_EXT_DIR:-$ROOT_DIR/components/mysql}"
PREFIX="${PREFIX:-$KERNEL_DIR/inst}"
WITH_CLIENTS="${WITH_CLIENTS:-auto}"

for dir in "$KERNEL_DIR" "$BABELFISH_DIR" "$MYSQL_EXT_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "missing component directory: $dir" >&2
        echo "run: git submodule update --init --recursive" >&2
        exit 1
    fi
done

KERNEL_DIR="$KERNEL_DIR" PREFIX="$PREFIX" "$BABELFISH_DIR/build-all.sh"
KERNEL_DIR="$KERNEL_DIR" PREFIX="$PREFIX" "$MYSQL_EXT_DIR/build-all.sh"

case "$WITH_CLIENTS" in
    auto)
        if command -v mysql >/dev/null 2>&1 && command -v sqlcmd >/dev/null 2>&1; then
            PREFIX="$PREFIX" "$ROOT_DIR/scripts/install-clients.sh"
        else
            echo "client commands not linked: install MySQL Client and Microsoft sqlcmd, then run scripts/install-clients.sh" >&2
        fi
        ;;
    1|yes|true)
        PREFIX="$PREFIX" "$ROOT_DIR/scripts/install-clients.sh"
        ;;
    0|no|false)
        ;;
    *)
        echo "WITH_CLIENTS must be auto, 1, or 0 (got: $WITH_CLIENTS)" >&2
        exit 1
        ;;
esac

echo "fusion stack installed under: $PREFIX"
